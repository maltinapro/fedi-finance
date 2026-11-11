# E08 – GoBD, Dokumentenarchiv & Aufbewahrung

**Phase:** 1 · **Abhängig von:** E06, E07 · **Status:** offen

## Ziel
Revisionssicheres Ablegen aller Belege/PDFs im Dateisystem mit Hashes, Zeitstempeln, Aufbewahrungsfristen, Sperrung und Archivierung nach Fristen; Prüfzugriff.

## Kontext / Links
[compliance.md](../compliance.md), [architecture.md](../architecture.md)

## Definition of Done
- Jedes Dokument ist unveränderbar abgelegt, mit Beleg verknüpft, Hash wird periodisch geprüft; Fristen werden verwaltet; Betriebsprüfer-Export vorhanden.

## Issues
- [ ] **E08-01 Dokumentenspeicher** – Hash-adressierte Ablage (SHA-256) auf PVC, Metadaten in DB, Write-once, Pfad-Sicherheit. AK: Überschreiben unmöglich.
- [ ] **E08-02 Upload & Belegerfassung** – Upload (PDF/Bild/XML), Virenscan (ClamAV), Typprüfung, Größenlimits, OCR-Hook (E14). AK: Scan-Test.
- [ ] **E08-03 Beleg ↔ Buchung Verknüpfung** – Pflichtverknüpfung, „Beleg fehlt"-Auswertung. AK: Bericht.
- [ ] **E08-04 Integritätsprüfung** – Periodischer Job prüft Hashes, Alarm bei Abweichung. AK: Manipulationstest.
- [ ] **E08-05 Zeitstempel** – Hash-Kette; optional RFC-3161-Zeitstempel. AK: Entscheidung (decisions.md Nr. 7) + Umsetzung.
- [ ] **E08-06 Aufbewahrungsfristen** – Konfiguration je Dokumentart, Berechnung Fristende, Sperre gegen Löschung. AK: Tests mit Fristgrenzen.
- [ ] **E08-07 Archivierung** – Nach Frist/Jahresabschluss: Verschieben in Archiv-Tier (komprimiert, schreibgeschützt), Löschvorschlag nach Fristablauf mit Freigabe. AK: Protokoll.
- [ ] **E08-08 Verfahrensdokumentation** – Generierung aus Konfiguration und Prozessbeschreibungen (PDF via E07). AK: Vorlage + Versionierung.
- [ ] **E08-09 Prüfer-Zugriff (Z1–Z3)** – Prüferrolle, Export im Beschreibungsstandard (`index.xml`), Protokoll der Zugriffe. AK: Validierbar mit IDEA-/Prüfsoftware-Struktur.
- [ ] **E08-10 Änderungsprotokoll** – Alle Änderungen an Stammdaten/Einstellungen im Audit-Log (E01-07). AK: Vollständigkeitstest.
- [ ] **E08-11 IKS-Kontrollen** – Vier-Augen-Prinzip, Freigabegrenzen, Funktionstrennung konfigurierbar. AK: Tests.
- [ ] **E08-12 Steuerberater-Review** – Checkliste GoBD, Review-Termin, Ergebnisse in Issues. AK: Review-Dokument.
