# E08 – GoBD, Dokumentenarchiv & Aufbewahrung

**Phase:** 1 · **Abhängig von:** E06, E07 · **Status:** offen

## Ziel
Revisionssicheres Ablegen aller Belege/PDFs im Archiv-Bucket (S3 mit Object Lock; Arbeitsdaten im `data`-Bucket, nie in der DB) mit Hashes, Zeitstempeln, Aufbewahrungsfristen, Sperrung und Archivierung nach Fristen; Prüfzugriff.

## Kontext / Links
[compliance.md](../compliance.md), [architecture.md](../architecture.md)

## Definition of Done
- Jedes Dokument ist unveränderbar abgelegt, mit Beleg verknüpft, Hash wird periodisch geprüft; Fristen werden verwaltet; Betriebsprüfer-Export vorhanden.

## Issues
- [ ] **E08-01 Dokumentenspeicher (S3)** – Storage-Abstraktion auf S3 (provider-neutral, Konfiguration `S3_*`, [storage.md](../storage.md#2-s3-vertrag-der-anwendung)) mit zwei Rollen: `DataStore` (Bucket `data`, veränderlich) und `ArchiveStore` (Bucket `archive` mit **Object Lock**, nur anlegen/lesen, kein Überschreiben/Löschen). Hash-adressierte Ablage (SHA-256), Retention bei Freigabe bis Fristende (Compliance in Produktion, Governance in Dev/Test), Startup-Prüfung (Buckets erreichbar, Versioning + Object Lock aktiv), keine Dokumente in der DB, kein PVC-Backend; Metadaten in DB, Key-Sicherheit; zu jedem von PDFCraft erzeugten PDF auch das eingebettete XML und der Render-Snapshot (pdfcraft.md Abschnitt 3). Dev/Test: Archiv-Bucket mit Object Lock gegen SeaweedFS anlegen. AK: Überschreiben/Löschen unmöglich (Test gegen S3 mit Object Lock, auch mit Admin-/Bypass-Rechten); Backend startet nicht ohne Object Lock im Produktionsmodus; Konzept in [compliance.md](../compliance.md#technische-umsetzung-der-unveränderbarkeit-dokumentenarchiv).
- [ ] **E08-02 Upload & Belegerfassung** – Upload (PDF/Bild/XML) in `data/uploads/` (Quarantäne), Virenscan (ClamAV), Typprüfung, Größenlimits, OCR-Hook (E14); nach bestandener Prüfung unverändert (gleicher SHA-256) ins Archiv, danach Quarantäne-Kopie löschen; Alarm bei zu langer Verweildauer (zeitnahe Archivierung, GoBD). AK: Scan-Test, Übernahmetest.
- [ ] **E08-03 Beleg ↔ Buchung Verknüpfung** – Pflichtverknüpfung, „Beleg fehlt"-Auswertung. AK: Bericht.
- [ ] **E08-04 Integritätsprüfung** – Periodischer Job prüft Hashes (Dateien/Objekte gegen DB-Metadaten), Alarm bei Abweichung. AK: Manipulationstest.
- [ ] **E08-05 Zeitstempel** – Hash-Kette; optional RFC-3161-Zeitstempel. AK: Entscheidung (decisions.md Nr. 7) + Umsetzung.
- [ ] **E08-06 Aufbewahrungsfristen** – Konfiguration je Dokumentart, Berechnung Fristende, Sperre gegen Löschung. AK: Tests mit Fristgrenzen.
- [ ] **E08-07 Archivierung** – Nach Jahresabschluss: Kennzeichnung als abgeschlossen; Löschvorschlag nach Fristablauf mit Freigabe (erst dann entfernt der Lifecycle die Objektversionen). Verschieben in einen günstigeren S3-Storage-Class-Tier optional, sofern der Provider das mit Object Lock unterstützt. AK: Protokoll.
- [ ] **E08-08 Verfahrensdokumentation** – Generierung aus Konfiguration und Prozessbeschreibungen (PDF via E07). AK: Vorlage + Versionierung.
- [ ] **E08-09 Prüfer-Zugriff (Z1–Z3)** – Prüferrolle, Export im Beschreibungsstandard (`index.xml`), Protokoll der Zugriffe. AK: Validierbar mit IDEA-/Prüfsoftware-Struktur.
- [ ] **E08-10 Änderungsprotokoll** – Alle Änderungen an Stammdaten/Einstellungen im Audit-Log (E01-07). AK: Vollständigkeitstest.
- [ ] **E08-11 IKS-Kontrollen** – Vier-Augen-Prinzip, Freigabegrenzen, Funktionstrennung konfigurierbar. AK: Tests.
- [ ] **E08-12 Steuerberater-Review** – Checkliste GoBD, Review-Termin, Ergebnisse in Issues. AK: Review-Dokument.
