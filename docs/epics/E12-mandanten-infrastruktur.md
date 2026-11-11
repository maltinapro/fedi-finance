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
- [ ] **E12-04 Storage** – PVC für Dokumentenarchiv, StorageClass-Anforderungen, Verschlüsselung, Quotas. AK: Dokumentiert.
- [ ] **E12-05 Netzwerk & Isolation** – NetworkPolicies (Default-Deny), PodSecurity (restricted), ResourceQuota/LimitRange. AK: Policy-Tests.
- [ ] **E12-06 Domain & Zertifikate** – Kundendomain (Föderation!) und TLS per cert-manager, Wildcard-/Einzelzertifikate. AK: Automatisch.
- [ ] **E12-07 Provisioning-Automatisierung** – Neuer Kunde: Namespace, Realm, Secrets, Helm-Release, DNS-Hinweise, Initial-Admin. AK: Ein Befehl/Job.
- [ ] **E12-08 Upgrade-Strategie** – Gestaffelte Rollouts, Migrations-Kompatibilität (expand/contract), Rollback. AK: Runbook.
- [ ] **E12-09 Secrets-Management** – Sealed Secrets/SOPS oder External Secrets mit OpenBao/Vault-Alternative (OSS). AK: Keine Klartext-Secrets im Repo.
- [ ] **E12-10 Mandanten-Offboarding** – Export, Löschung Namespace/Volumes/Backups nach Konzept. AK: Runbook + Test.
- [ ] **E12-11 Ressourcenplanung & Kosten** – Standardprofile (S/M/L), Autoscaling, Mindestanforderungen. AK: Dokument.
