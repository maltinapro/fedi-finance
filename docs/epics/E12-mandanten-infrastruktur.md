# E12 – Mandanten-Infrastruktur (Kubernetes/Helm)

**Phase:** 2 · **Abhängig von:** E01, E03 · **Status:** offen

## Ziel
Pro Kunde ein eigener Namespace mit komplettem Stack, automatisch per Helm-Release aufgesetzt. Nur Open-Source-Infrastruktur.

## Kontext / Links
[operations.md](../operations.md), [architecture.md](../architecture.md)

## Definition of Done
- `helm install` erzeugt in einem leeren Namespace eine funktionsfähige Instanz (Backend, Frontend, DB, Storage, PDFCraft, Keycloak-Realm); Provisioning für neue Kunden per Skript/Operator.

## Issues
- [ ] **E12-01 Cluster-Basis** – Rook-Ceph (mind. 3 Nodes mit je einer Rohplatte, Replikation 3, RBD + RGW, siehe [storage.md](../storage.md)), Ingress, cert-manager, CloudNativePG-Operator, Keycloak, Monitoring; Installation per Helm/Helmfile. AK: Reproduzierbar auf k3d/kind.
- [ ] **E12-02 Helm-Chart `fedifinance`** – Deployments, Services, Ingress, ConfigMaps, ServiceAccounts, Probes, Ressourcenlimits. AK: `helm lint`, `helm template` + kubeconform in CI.
- [ ] **E12-03 Datenbank je Mandant** – CloudNativePG-Cluster, Migrations-Job (Hook), Zugangsdaten als Secret. AK: Upgrade-Test.
- [ ] **E12-04 Storage & S3** – Umsetzung von [storage.md](../storage.md): Rook-Ceph-StorageClass `fedifinance-block` (RBD, Standard), RGW-Object-Store, OSD-Verschlüsselung, Quotas (PVC, RGW-User/Bucket). Chart-Werte `s3.endpoint`, `s3.region`, `s3.forcePathStyle`, `s3.data.{bucket,existingSecret}`, `s3.archive.{bucket,existingSecret,objectLockMode}` (`COMPLIANCE` | `GOVERNANCE`); Backend-Konfiguration per Env aus Secret/ConfigMap; NetworkPolicy zum S3-Endpoint. **Spike:** Kann Rook-`ObjectBucketClaim` (oder COSI) Object Lock beim Anlegen des Buckets? Ergebnis in ADR, davon hängt der Archiv-Weg in E12-07 ab. Hinweis: Ceph ersetzt kein Backup (E13). AK: Chart per `helm template` mit `existingSecret`; Spike dokumentiert; gegen Rook-RGW getestet (Bucket anlegen, Object-Lock-Test).
- [ ] **E12-05 Netzwerk & Isolation** – NetworkPolicies (Default-Deny), PodSecurity (restricted), ResourceQuota/LimitRange. AK: Policy-Tests.
- [ ] **E12-06 Domain & Zertifikate** – Kundendomain (Föderation!) und TLS per cert-manager, Wildcard-/Einzelzertifikate. AK: Automatisch.
- [ ] **E12-07 Provisioning-Automatisierung** – Neuer Kunde: Namespace, S3-Buckets und Zugangsdaten (`data` per Rook-`ObjectBucketClaim`; `archive` per Provisioner-Job mit RGW-Admin-Zugang, Bucket mit Object Lock + Versioning, eingeschränkter RGW-User, Secret `fedifinance-s3-archive` und ConfigMap in den Mandanten-Namespace; Admin-Zugang nur im Provisioner-Namespace, minimale RBAC, nicht per Helm, siehe [storage.md](../storage.md#5-zugangsdaten-und-provisioning)), Realm, Secrets, Helm-Release, DNS-Hinweise, Initial-Admin. AK: Ein Befehl/Job; Wiederholung ist idempotent; Archiv-Bucket hat Object Lock; Secrets im Namespace vorhanden, ohne dass jemand Zugangsdaten sieht.
- [ ] **E12-08 Upgrade-Strategie** – Gestaffelte Rollouts, Migrations-Kompatibilität (expand/contract), Rollback. AK: Runbook.
- [ ] **E12-09 Secrets-Management** – Sealed Secrets/SOPS oder External Secrets mit OpenBao/Vault-Alternative (OSS); Rotation der S3-Zugangsdaten (neuer Key, Secret aktualisieren, Pods neu starten, alten Key nach Übergangszeit löschen). AK: Keine Klartext-Secrets im Repo; Rotation getestet.
- [ ] **E12-10 Mandanten-Offboarding** – Export, Löschung Namespace/Volumes/`data`-Bucket/Backups nach Konzept; der `archive`-Bucket mit Object Lock bleibt bis Fristende (Zugriff/Verwaltung durch den Betreiber, Vertrag regelt Kosten/Zugriff, [storage.md](../storage.md#7-mandanten-offboarding-und-dsgvo)). AK: Runbook + Test.
- [ ] **E12-11 Ressourcenplanung & Kosten** – Standardprofile (S/M/L), Autoscaling, Mindestanforderungen. AK: Dokument.
- [ ] **E12-12 PDFCraft-Betrieb** – PDFCraft-Backend + Valkey geteilt (Namespace `pdfcraft`) oder je Mandant (`pdfcraft.enabled` / `pdfcraft.url` im Chart, [pdfcraft.md](../pdfcraft.md#4-betrieb)); Token je Mandant als Secret mit Rotation; kein Ingress, NetworkPolicy nur vom FediFinance-Backend; `/metrics` und PDFCraft-Grafana-Dashboards. AK: beide Varianten per `helm template` getestet; Upgrade der gepinnten Version nur mit grünem Contract-Test (E07-02).
- [ ] **E12-13 Gehostetes Angebot (Betreibermodell)** – Leistungsbeschreibung für Betreiber (eigener Betrieb oder Partner wie Hoster/Kanzleien): Profile aus E12-11, SLA, Backup-Zusagen (E13), AVV-Vorlage und Unterauftragnehmer (E11), Antrag → Provisioning (E12-07), Offboarding (E12-10). Voraussetzung, um Kunden ohne eigenen Cluster zu bedienen ([market.md](../market.md#5-schwächen-und-risiken)). AK: Dokument in `docs/operations.md`; Probe-Provisionierung eines Kunden nach Leistungsbeschreibung.
