# E07 – PDF-Erzeugung (PDFCraft) & E-Rechnung

**Phase:** 1 · **Abhängig von:** E06 · **Status:** offen

## Ziel
Alle PDFs (Rechnungen, Mahnungen, Berichte) werden mit [PDFCraft](https://github.com/maltinapro/pdfcraft) erzeugt; E-Rechnungsformate (XRechnung, ZUGFeRD/Factur-X) werden unterstützt.

## Kontext / Links
[compliance.md](../compliance.md) (E-Rechnung), decisions.md Nr. 1

## Definition of Done
- Rechnung → PDF/A-3 mit eingebettetem XML (EN 16931), validiert; Vorlagen konfigurierbar; PDF-Erzeugung reproduzierbar.

## Issues
- [ ] **E07-01 PDFCraft-Analyse (Spike)** – Schnittstellen (HTTP/CLI/Lib), Funktionsumfang (PDF/A, Einbettung, Vorlagen), Betrieb im Cluster. AK: Ergebnis in decisions.md, ggf. Anforderungs-Issues im PDFCraft-Repo.
- [ ] **E07-02 PDFCraft-Integration** – Client im Backend (Timeouts, Retry, Auth), Deployment als Dienst je Mandant. AK: Integrationstest.
- [ ] **E07-03 Rechnungsvorlagen** – Layout (Logo, Farben, Fußzeile), Vorlagen-Verwaltung, Mehrsprachigkeit. AK: Vorschau im UI.
- [ ] **E07-04 Weitere Dokumente** – Mahnung, Angebot, Gutschrift, Berichte (Journal, BWA, Saldenliste), Verfahrensdokumentation. AK: Je Dokument ein Template.
- [ ] **E07-05 XRechnung/ZUGFeRD-Erzeugung** – CII/UBL-XML aus dem Rechnungsmodell, Einbettung ins PDF/A-3. AK: Validierung mit offiziellem Validator (KoSIT/Mustang).
- [ ] **E07-06 E-Rechnung empfangen** – XML/PDF parsen, Prüfung, Übernahme als Eingangsrechnung. AK: Testkorpus.
- [ ] **E07-07 Deterministische Erzeugung** – Gleiche Eingabe = gleiches PDF (Metadaten/Zeitstempel kontrolliert) für Hash-Prüfung. AK: Test.
- [ ] **E07-08 Versand** – Download, E-Mail (SMTP), Föderation (E05-08). AK: Versandprotokoll.
- [ ] **E07-09 Performance & Queue** – Asynchrone Erzeugung über Jobs. AK: Lasttest.

## Offene Fragen
decisions.md Nr. 1.
