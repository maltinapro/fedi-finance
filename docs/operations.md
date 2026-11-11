# Betrieb: Kubernetes, Helm, Backup, Export

## Deployment

- Zielplattform: Kubernetes. Bereitstellung mit Helm.
- Chart `fedifinance` (Backend, Frontend, PDFCraft, AI-Gateway, DB-Cluster-CR, PVCs, Ingress, NetworkPolicy, ServiceAccount, Secret-Referenzen).
- Neuer Kunde = neuer Helm-Release im Namespace `tenant-<id>`: `helm install tenant-<id> deploy/helm/fedifinance -n tenant-<id> -f values-<id>.yaml`.
  Ein Provisioning-Skript/Operator legt Namespace, Quota, Keycloak-Realm, Domain/Zertifikat und Release an.
- Cluster-Basis (einmalig): Ingress-Controller, cert-manager, CloudNativePG-Operator, Keycloak, Velero, Monitoring (Prometheus/Grafana/Loki), später GPU Operator.
- Alle Komponenten Open Source.

## Mandanten-Lebenszyklus

1. Anlegen: Namespace, Quotas, Keycloak-Realm, DB, Storage, Helm-Release, DNS/Zertifikat, Initial-Admin.
2. Betrieb: Upgrades per `helm upgrade` (DB-Migrationen als Job), gestaffelte Rollouts.
3. Export: Archiv mit allen Daten (siehe unten).
4. Offboarding: Export bereitstellen, Aufbewahrungsfristen beachten, dann Namespace + Volumes + Backups gemäß Konzept löschen.

## Backup und Restore

| Ebene | Werkzeug | Inhalt |
| --- | --- | --- |
| Cluster/Namespace | **Velero** (Kopia, CSI-Snapshots) | Kubernetes-Objekte und PVCs (PDF-Archiv) |
| Datenbank | CloudNativePG Backup (Barman, WAL-Archivierung, PITR) | PostgreSQL |
| Reine Daten | Logischer Export (Datenarchiv, unabhängig von Kubernetes) | Portable Sicherung |

- Ziel: S3-kompatibler Objektspeicher (z. B. MinIO oder Garage), verschlüsselt, in der EU, getrennt vom Cluster.
- Regelmäßige automatisierte **Restore-Tests**; RPO/RTO werden definiert.
- Backups beachten Aufbewahrungs- und Löschkonzept (DSGVO).

## Datenexport (Archiv)

Der Kunde kann jederzeit ein Archiv herunterladen, das enthält:

- Stammdaten, Buchungen, Journal, Konten, Partner (maschinenlesbar: JSON/CSV + Prüfer-Export `index.xml`).
- Alle PDFs/Belege inkl. Prüfsummen (`manifest.json` mit SHA-256) und Verfahrensdokumentation.
- Chats und KI-Metadaten (optional), Benutzer/Rollen (ohne Passwörter).
- Optional signiert/verschlüsselt, Streaming-Download, Erstellung als Hintergrundjob.
