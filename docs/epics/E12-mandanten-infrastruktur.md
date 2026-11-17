# E12 – Mandanten-Infrastruktur (Kubernetes/Helm)

**Phase:** 2 · **Abhängig von:** E01, E03 · **Status:** offen

## Ziel
Pro Kunde ein eigener Namespace mit komplettem Stack, automatisch per Helm-Release aufgesetzt. Nur Open-Source-Infrastruktur.

## Kontext / Links
[operations.md](../operations.md), [architecture.md](../architecture.md)

## Definition of Done
- `helm install` erzeugt in einem leeren Namespace eine funktionsfähige Instanz (Backend, Frontend, DB, Storage, PDFCraft, Keycloak-Realm); Provisioning für neue Kunden per Skript/Operator.

## Issues
- [ ] **E12-01 Cluster-Basis** – Ingress, cert-manager, CloudNativePG-Operator, Keycloak, Monitoring; Installation per Helm/Helmfile. AK: Reproduzierbar auf k3d/kind.
- [ ] **E12-02 Helm-Chart `fedifinance`** – Deployments, Services, Ingress, ConfigMaps, ServiceAccounts, Probes, Ressourcenlimits. AK: `helm lint`, `helm template` + kubeconform in CI.
- [ ] **E12-03 Datenbank je Mandant** – CloudNativePG-Cluster, Migrations-Job (Hook), Zugangsdaten als Secret. AK: Upgrade-Test.
- [ ] **E12-04 Storage** – Dokumentenarchiv auf PVC (StorageClass-Anforderungen, z. B. Rook-Ceph CephFS/RBD: Replikation, Snapshots/CSI für Velero, Verschlüsselung, Quotas) oder auf einem S3-Bucket mit Object Lock (z. B. Ceph RGW; ein Bucket und Benutzer je Mandant, Object Lock beim Anlegen aktivieren, Zugangsdaten als Secret). Chart-Werte für beide Varianten. Hinweis: Rook-Ceph braucht mindestens 3 Nodes mit eigenen Platten und ersetzt kein Backup (E13). AK: Dokumentiert, Variante wählbar per Helm-Wert.
- [ ] **E12-05 Netzwerk & Isolation** – NetworkPolicies (Default-Deny), PodSecurity (restricted), ResourceQuota/LimitRange. AK: Policy-Tests.
- [ ] **E12-06 Domain & Zertifikate** – Kundendomain (Föderation!) und TLS per cert-manager, Wildcard-/Einzelzertifikate. AK: Automatisch.
- [ ] **E12-07 Provisioning-Automatisierung** – Neuer Kunde: Namespace, Realm, Secrets, Helm-Release, DNS-Hinweise, Initial-Admin. AK: Ein Befehl/Job.
- [ ] **E12-08 Upgrade-Strategie** – Gestaffelte Rollouts, Migrations-Kompatibilität (expand/contract), Rollback. AK: Runbook.
- [ ] **E12-09 Secrets-Management** – Sealed Secrets/SOPS oder External Secrets mit OpenBao/Vault-Alternative (OSS). AK: Keine Klartext-Secrets im Repo.
- [ ] **E12-10 Mandanten-Offboarding** – Export, Löschung Namespace/Volumes/Backups nach Konzept. AK: Runbook + Test.
- [ ] **E12-11 Ressourcenplanung & Kosten** – Standardprofile (S/M/L), Autoscaling, Mindestanforderungen. AK: Dokument.
- [ ] **E12-12 PDFCraft-Betrieb** – PDFCraft-Backend + Valkey geteilt (Namespace `pdfcraft`) oder je Mandant (`pdfcraft.enabled` / `pdfcraft.url` im Chart, [pdfcraft.md](../pdfcraft.md#4-betrieb)); Token je Mandant als Secret mit Rotation; kein Ingress, NetworkPolicy nur vom FediFinance-Backend; `/metrics` und PDFCraft-Grafana-Dashboards. AK: beide Varianten per `helm template` getestet; Upgrade der gepinnten Version nur mit grünem Contract-Test (E07-02).
