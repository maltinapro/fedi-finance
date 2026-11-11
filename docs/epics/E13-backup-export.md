# E13 – Backup, Restore & Datenexport

**Phase:** 2 · **Abhängig von:** E08, E12 · **Status:** offen

## Ziel
Zuverlässige Backups (Velero + DB-Backups + reine Datensicherung) und ein einfacher vollständiger Datenexport als Archiv für Kunden.

## Kontext / Links
[operations.md](../operations.md)

## Definition of Done
- Automatische Backups je Mandant, getestete Restores (Namespace + DB PITR), Kunden-Export per Klick.

## Issues
- [ ] **E13-01 Backup-Ziel** – S3-kompatibler OSS-Speicher (MinIO/Garage), Verschlüsselung, Zugriffskonzept. AK: ADR.
- [ ] **E13-02 Velero-Setup** – Schedules je Mandanten-Namespace, CSI-Snapshots/Kopia, Retention. AK: Backup + Restore getestet.
- [ ] **E13-03 Datenbank-Backup** – CloudNativePG Barman, WAL-Archivierung, PITR. AK: Restore auf Zeitpunkt getestet.
- [ ] **E13-04 Logischer Datenexport** – Job erzeugt Archiv (JSON/CSV, PDFs, `manifest.json` mit SHA-256, `index.xml`). AK: Archiv vollständig und prüfbar.
- [ ] **E13-05 Export im UI/API** – Anfordern, Fortschritt, Download (zeitlich begrenzter Link), Benachrichtigung. AK: Rollenrecht „Export".
- [ ] **E13-06 Import/Wiederherstellung aus Archiv** – Migration zwischen Instanzen/Umzug. AK: Roundtrip-Test (Export → Import = identisch).
- [ ] **E13-07 Restore-Tests automatisiert** – Regelmäßiger Restore in Test-Namespace mit Integritätsprüfung. AK: Bericht/Alarm.
- [ ] **E13-08 RPO/RTO & Runbooks** – Ziele, Notfall-Handbuch. AK: Dokument.
- [ ] **E13-09 Löschkonzept für Backups** – Backup-Retention vs. DSGVO/Aufbewahrung. AK: Dokument.
- [ ] **E13-10 KI-Daten** – Chats, Index, Adapter in Backup/Export einbeziehen (E14). AK: Vollständigkeitstest.
