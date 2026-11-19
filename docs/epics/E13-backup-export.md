# E13 – Backup, Restore & Datenexport

**Phase:** 2 · **Abhängig von:** E08, E12 · **Status:** offen

## Ziel
Zuverlässige Backups (Velero + DB-Backups + reine Datensicherung) und ein einfacher vollständiger Datenexport als Archiv für Kunden.

## Kontext / Links
[operations.md](../operations.md)

## Definition of Done
- Automatische Backups je Mandant, getestete Restores (Namespace + DB PITR), Kunden-Export per Klick.

## Issues
- [ ] **E13-01 Offsite-Backup-Ziel** – S3 mit Object Lock und Versioning an anderem Standort/Anbieter in der EU (Referenz: SeaweedFS; gleichwertig EU-S3-Dienst mit Object Lock; Garage/MinIO scheiden aus), Buckets `velero`, `postgres`, `cluster`, `archive-<tenant>` mit getrennten Zugangsdaten (kein Löschen von Versionen, keine Lifecycle-Änderung), Verschlüsselung, Offline-Hinterlegung des Kopia-Passworts ([operations.md](../operations.md#backup-und-restore)). AK: ADR + bestandener Object-Lock-Test (Retention, Löschen auch mit Bypass abgelehnt).
- [ ] **E13-02 Velero-Setup** – Velero mit Kopia und CSI-Datenverschiebung (`snapshotMoveData: true`) zum Offsite-Ziel, Schedules je Mandanten-Namespace (täglich 30 Tage, wöchentlich 12 Wochen) und für die Cluster-Basis, Backup-Storage-Location Offsite. AK: Backup + Restore getestet, Daten liegen nachweislich offsite.
- [ ] **E13-03 Datenbank-Backup** – CloudNativePG mit Barman-Cloud-Plugin zum Offsite-Ziel, WAL-Archivierung (`archive_timeout` 5 min), tägliches Basis-Backup, PITR 30 Tage; auch für die Keycloak-DB. AK: Restore auf Zeitpunkt getestet.
- [ ] **E13-04 Logischer Datenexport** – Job erzeugt Archiv (JSON/CSV, PDFs, `manifest.json` mit SHA-256, `index.xml`). AK: Archiv vollständig und prüfbar.
- [ ] **E13-05 Export im UI/API** – Anfordern, Fortschritt, Download (zeitlich begrenzter Link), Benachrichtigung. AK: Rollenrecht „Export".
- [ ] **E13-06 Import/Wiederherstellung aus Archiv** – Migration zwischen Instanzen/Umzug. AK: Roundtrip-Test (Export → Import = identisch).
- [ ] **E13-07 Restore-Tests automatisiert** – Monatlich Restore eines Mandanten in Test-Namespace (Velero + DB-PITR + Hash-Prüfung aller Archivobjekte), halbjährlich vollständiger Notfall-Test (Verlust Cluster/Standort). AK: Bericht/Alarm.
- [ ] **E13-08 RPO/RTO & Runbooks** – Ziele festgelegt (DB RPO ≤ 5 min, Volumes 24 h, Archiv ≤ 15 min; RTO Mandant ≤ 4 h, Cluster-Verlust ≤ 48 h, siehe [operations.md](../operations.md#backup-und-restore)); Notfall-Handbuch inkl. Verlust des Offsite-Ziels und Kopia-Passworts. AK: Runbooks getestet.
- [ ] **E13-09 Löschkonzept für Backups** – Backup-Retention vs. DSGVO/Aufbewahrung. AK: Dokument.
- [ ] **E13-10 KI-Daten** – Chats, Index, Adapter in Backup/Export einbeziehen (E14). AK: Vollständigkeitstest.
- [ ] **E13-11 Archiv-Replikator** – CronJob im Backend kopiert Archivobjekte (`archive`-Bucket) in den Offsite-Bucket des Mandanten mit gleicher Retention/gleichem Modus und sichert das Präfix `uploads/` des `data`-Buckets (nicht gesperrt), prüft SHA-256, Replikationsstatus in der DB, Metriken (Rückstand, Fehler); nur schreibende Zugangsdaten. AK: Test mit SeaweedFS (Object Lock); Alarm bei Rückstand > 1 h; Rückspielen in neuen Bucket getestet.
