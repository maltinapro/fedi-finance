# Betrieb: Kubernetes, Helm, Backup, Export

## Deployment

- Zielplattform: Kubernetes. Bereitstellung mit Helm.
- Chart `fedifinance` (Backend, Frontend, AI-Gateway, DB-Cluster-CR, PVCs, Ingress, NetworkPolicy, ServiceAccount, Secret-Referenzen;
  PDFCraft optional im Namespace mit `pdfcraft.enabled`, sonst geteilter Dienst über `pdfcraft.url`, siehe [pdfcraft.md](pdfcraft.md#4-betrieb)).
- Neuer Kunde = neuer Helm-Release im Namespace `tenant-<id>`: `helm install tenant-<id> deploy/helm/fedifinance -n tenant-<id> -f values-<id>.yaml`.
  Ein Provisioning-Skript/Operator legt Namespace, Quota, Keycloak-Realm, Domain/Zertifikat und Release an.
- Cluster-Basis (einmalig): **Rook-Ceph** (mind. 3 Nodes, siehe [storage.md](storage.md)), Ingress-Controller, cert-manager, CloudNativePG-Operator, Keycloak, Velero, Monitoring (Prometheus/Grafana/Loki),
  PDFCraft + Valkey (geteilt, ohne Ingress; Image `ghcr.io/maltinapro/pdfcraft-backend`, Version gepinnt), später GPU Operator.
- Alle Komponenten Open Source.

## Mandanten-Lebenszyklus

1. Anlegen: Namespace, Quotas, Keycloak-Realm, DB, Storage, PDFCraft-Token (Secret), Helm-Release, DNS/Zertifikat, Initial-Admin.
2. Betrieb: Upgrades per `helm upgrade` (DB-Migrationen als Job), gestaffelte Rollouts.
3. Export: Archiv mit allen Daten (siehe unten).
4. Offboarding: Export bereitstellen, Aufbewahrungsfristen beachten, Namespace + Volumes + Backups gemäß Konzept löschen; die Archiv-Buckets mit Object Lock bleiben bis Fristende bestehen ([storage.md](storage.md#4-mandanten-offboarding-und-dsgvo)).

## Backup und Restore

Entscheidungen (11/2026), Begründung der Storage-Seite in [storage.md](storage.md#5-offsite-backup-und-archiv-replikat):

- **Velero** sichert Kubernetes-Objekte und Volumes; **CloudNativePG/Barman** sichert PostgreSQL (WAL, PITR); das **Archiv** (RGW-Buckets mit Object Lock) wird von einem eigenen Replikationsjob gesichert (Velero sichert keine RGW-Objekte).
- **Offsite ist Pflicht:** Alle Backups liegen in einem anderen Fehlerbereich als der Ceph-Cluster (anderer Standort, in der EU, eigene Zugangsdaten). Ein Ceph-Cluster mit 3 Replikaten ist kein Backup.
- Regel **3-2-1**: Live-Daten (Ceph) + Offsite-Kopie auf einem zweiten System; zusätzlich schützt Versioning/Object Lock im Offsite-Ziel vor Ransomware und Fehlbedienung.

| Ebene | Werkzeug | Inhalt | Ziel (Offsite) | Rhythmus / RPO |
| --- | --- | --- | --- | --- |
| Kubernetes-Objekte, Secrets, PVCs (RBD) | **Velero** mit Kopia: CSI-Snapshot, dann `snapshotMoveData: true` (Daten werden zum Offsite-Ziel verschoben; ein Snapshot allein läge im selben Ceph-Cluster und zählt nicht als Backup) | Manifeste, Helm-Release-Werte, Secrets, Keycloak-/Valkey-/KI-Volumes | Bucket `velero` | täglich (Nacht), RPO 24 h |
| PostgreSQL (Mandanten-DBs, Keycloak-DB) | CloudNativePG: Barman-Cloud-Plugin, fortlaufende WAL-Archivierung, Basis-Backup täglich | Datenbanken, PITR | Bucket `postgres` | RPO ≤ 5 min (`archive_timeout` 5 min) |
| Dokumentenarchiv | **Archiv-Replikator** (CronJob des Backends, siehe unten) | PDFs/XML/Snapshots mit Retention | Bucket je Mandant mit Object Lock | RPO ≤ 15 min nach Freigabe, Alarm bei > 1 h Rückstand |
| Reine Daten | Logischer Export (E13-04), unabhängig von Kubernetes | Portable Sicherung | auf Anforderung | – |
| Cluster-Steuerung | Etcd-/Control-Plane-Backup der Kubernetes-Distribution, Rook-Ceph-Konfiguration (per Velero/GitOps) | Cluster-Zustand | Bucket `cluster` | täglich |

**Offsite-Ziel (Entscheidung):** S3-API mit Object Lock und Versioning, EU, getrennte Verwaltung/Zugangsdaten vom Cluster.
Referenzimplementierung ist ein eigener **SeaweedFS**-Server an einem zweiten Standort (Object Lock getestet, OSS); gleichwertig ist jeder
EU-S3-Dienst eines anderen Anbieters mit nachgewiesenem Object Lock, da nur die S3-API verwendet wird. Garage und MinIO scheiden aus (kein Object Lock bzw. Lizenz/Images).
Bevor das Ziel produktiv genutzt wird, ist der Object-Lock-Test aus E13-01 zu bestehen.

**Absicherung des Offsite-Ziels:**

- Getrennte Buckets und Zugangsdaten je Zweck (`velero`, `postgres`, `cluster`, `archive-<tenant>`); die Cluster-Zugangsdaten dürfen schreiben und lesen, aber keine Lifecycle-/Object-Lock-Konfiguration ändern und keine Objektversionen endgültig löschen.
- Versioning aktiv; nicht aktuelle Versionen werden 14 Tage vorgehalten (Schutz gegen Ransomware, die Backups im Cluster löscht).
- Verschlüsselung: Kopia-Repository-Verschlüsselung (Passwort als Secret, zusätzlich im Offline-Tresor der Betreiber hinterlegt – ohne dieses Passwort sind die Backups wertlos), Barman-Backups serverseitig verschlüsselt, TLS auf dem Transport.
- Der Archiv-Replikator arbeitet mit eigenen, nur schreibenden Zugangsdaten und legt mit **derselben Retention und demselben Modus** (Compliance in Produktion) wie das Original ab; Offsite-Löschung vor Fristende ist so ebenfalls unmöglich.

**Archiv-Replikator:** Das Backend merkt sich je Archivobjekt, ob es offsite liegt (Metadaten in der DB). Der Job kopiert fehlende Objekte (Hash-Key bleibt gleich), liest Retention-Modus und -Datum vom Original, setzt sie am Replikat, prüft den SHA-256 nach dem Kopieren und meldet Rückstand und Fehler als Metrik (Alarm in E17-04). Die Freigabe eines Belegs bleibt gültig, auch wenn die Replikation hinterherhinkt.

**Aufbewahrung der Backups (Standard, je Mandant konfigurierbar):**

| Backup | Aufbewahrung |
| --- | --- |
| Velero täglich | 30 Tage |
| Velero wöchentlich | 12 Wochen |
| PostgreSQL PITR | 30 Tage (Basis-Backups), danach nur wöchentliche Basis-Backups bis 12 Wochen |
| Archiv-Replikat | bis Ende der Aufbewahrungsfrist des Belegs (Object Lock) |

Kurze Fristen sind Absicht (DSGVO-Datenminimierung): Backups enthalten personenbezogene Daten, die nach einer Löschung noch bis zum Ablauf mitgesichert sind.
Nach einem Restore werden Löschungen und Sperren aus dem Löschprotokoll erneut angewendet (E13-09, E11-03). Die gesetzlichen Aufbewahrungsfristen erfüllt das Archiv, nicht die Rotation der Backups.

**Restore und Ziele (RTO):**

| Szenario | Ziel | Weg |
| --- | --- | --- |
| Einzelner Mandant (Namespace, Fehlbedienung) | RTO ≤ 4 h | Velero-Restore in den Namespace, DB per PITR (CloudNativePG `recovery`), Archiv unverändert |
| Datenbank-Korruption | RTO ≤ 2 h | PITR auf Zeitpunkt vor dem Fehler |
| Verlust des Ceph-Clusters / des Standorts | RTO ≤ 48 h | Neuer Cluster (min. 3 Nodes), Rook-Ceph, Velero-Restore der Cluster-Basis, danach Mandanten nacheinander; Archiv-Buckets aus dem Offsite-Replikat zurückspielen (Retention wird mit übernommen) |
| Offsite-Ziel verloren | RPO-Lücke bis Neuaufbau | Neues Ziel anlegen, Velero/Barman starten neue Backups, Archiv-Replikator kopiert alles erneut |

- **Restore-Tests:** monatlich automatisiert (ein Mandant in Test-Namespace, DB-PITR, Hash-Prüfung aller Archivobjekte, Bericht), zusätzlich halbjährlich ein vollständiger Notfall-Test des Cluster-Verlusts nach Runbook (E13-07, E13-08).
- Backup-Fehler, Restore-Test-Fehler, Replikationsrückstand und ein voller Offsite-Speicher lösen Alarme aus (E17-04).
- Backups beachten Aufbewahrungs- und Löschkonzept (DSGVO).

## Datenexport (Archiv)

Der Kunde kann jederzeit ein Archiv herunterladen, das enthält:

- Stammdaten, Buchungen, Journal, Konten, Partner (maschinenlesbar: JSON/CSV + Prüfer-Export `index.xml`).
- Alle PDFs/Belege inkl. Prüfsummen (`manifest.json` mit SHA-256) und Verfahrensdokumentation.
- Chats und KI-Metadaten (optional), Benutzer/Rollen (ohne Passwörter).
- Optional signiert/verschlüsselt, Streaming-Download, Erstellung als Hintergrundjob.
