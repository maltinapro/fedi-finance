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

| Ebene | Werkzeug | Inhalt |
| --- | --- | --- |
| Cluster/Namespace | **Velero** (Kopia, CSI-Snapshots) | Kubernetes-Objekte und RBD-PVCs; die S3-Archiv-Buckets mit Object Lock werden separat auf das Backup-Ziel repliziert |
| Datenbank | CloudNativePG Backup (Barman, WAL-Archivierung, PITR) | PostgreSQL |
| Reine Daten | Logischer Export (Datenarchiv, unabhängig von Kubernetes) | Portable Sicherung |

- Ziel: S3-kompatibler Objektspeicher **außerhalb des Ceph-Clusters** (anderer Standort/Fehlerbereich), verschlüsselt, in der EU; für das Archiv-Replikat mit Object Lock (zweiter Ceph-Cluster oder SeaweedFS, siehe [storage.md](storage.md#5-backup-ziel-und-replikation)).
- Regelmäßige automatisierte **Restore-Tests**; RPO/RTO werden definiert.
- Backups beachten Aufbewahrungs- und Löschkonzept (DSGVO).

## Datenexport (Archiv)

Der Kunde kann jederzeit ein Archiv herunterladen, das enthält:

- Stammdaten, Buchungen, Journal, Konten, Partner (maschinenlesbar: JSON/CSV + Prüfer-Export `index.xml`).
- Alle PDFs/Belege inkl. Prüfsummen (`manifest.json` mit SHA-256) und Verfahrensdokumentation.
- Chats und KI-Metadaten (optional), Benutzer/Rollen (ohne Passwörter).
- Optional signiert/verschlüsselt, Streaming-Download, Erstellung als Hintergrundjob.
