# E04 – Stammdaten & Geschäftspartner

**Phase:** 1 · **Abhängig von:** E01, E02, E03 · **Status:** offen

## Ziel
Verwaltung der eigenen Unternehmensstammdaten und der Geschäftspartner (lokal angelegt oder über Föderation verknüpft), datensparsam und versioniert.

## Kontext / Links
[federation.md](../federation.md), [compliance.md](../compliance.md), [pdfcraft.md](../pdfcraft.md#5-datenmodell-abgleich)
(Felder decken die PDFCraft-Zonen *Absender & Aussehen* und *Empfänger* sowie den Artikelstamm ab), [design.md](../design.md)

## Definition of Done
- Eigene Firma konfigurierbar (Rechtsform, Steuerdaten, Bankverbindung, Logo, Erscheinungsbild), Partner und Artikel anlegbar/suchbar, Änderungen historisiert.

## Issues
- [ ] **E04-01 Datenmodell Unternehmen** – Name, Rechtsform, Anschrift, Kontakt, USt-IdNr., Steuernummer, Registerdaten, Geschäftsführung (Pflichtangaben auf Geschäftsbriefen), Bankverbindung, Geschäftsjahr, Währung; Erscheinungsbild für PDFs (Logo, Unterschrift, Design, Akzentfarbe, Schrift, Texte – E07-03). AK: Migration + API.
- [ ] **E04-02 Onboarding-Assistent** – Erstkonfiguration (Rechtsform, Kontenrahmen, Besteuerungsart, Kleinunternehmer). AK: Profil steuert Folge-Features.
- [ ] **E04-03 Geschäftspartner (Kunde/Lieferant)** – CRUD, Typ, Anschrift, E-Mail, USt-IdNr., Käuferreferenz/Leitweg-ID, bevorzugtes E-Rechnungsprofil, Zahlungsbedingungen, Ansprechpartner, Notizen. AK: Suche + Tests.
- [ ] **E04-04 Partner per Domain hinzufügen** – Eingabe `f1.com` → Discovery + Stammdaten-Import (nutzt E05). AK: Partner mit Quelle „föderiert" markiert.
- [ ] **E04-05 Stammdaten-Versionierung** – Historie, Gültigkeitszeiträume (Beleg verwendet Stand zum Belegdatum). AK: Änderung verändert alte Belege nicht.
- [ ] **E04-06 Sichtbarkeitsstufen** – Je Feld: öffentlich/Partner/privat für die Föderation. AK: Default datensparsam.
- [ ] **E04-07 USt-IdNr.-Prüfung** – Validierung (Format, optional VIES-Abfrage). AK: Ergebnis protokolliert.
- [ ] **E04-08 Import/Export** – CSV-Import von Partnern, Duplikaterkennung. AK: Fehlerreport.
- [ ] **E04-09 Mehrere Unternehmen/Mandanten-Einheiten** – (optional) mehrere Buchungskreise je Instanz. AK: Entscheidung dokumentiert.
- [ ] **E04-10 Artikel/Leistungen** – Artikelstamm wie in PDFCraft (Bezeichnung, Einheit, Preis, Steuersatz) plus Erlöskonto; Auswahl im Belegeditor (E07-06). AK: CRUD, Suche, Tests.
- [ ] **E04-11 Import aus PDFCraft-Sicherung** – `pdfcraft-backup-<datum>.json` (`backupVersion` 2; auch Version 1) einlesen: Absender/Erscheinungsbild → Unternehmen, Kunden → Partner, Artikel → Artikelstamm; ausgestellte Belege optional als Altbelege (nicht nachträglich gebucht). AK: Vorschau mit Duplikaterkennung vor dem Import; Testdatei aus PDFCraft.
- [ ] **E04-12 Stammdaten-Seiten (UI)** – *Partner* (Kunden, Lieferanten, föderiert, Artikel als Tabs) und *Mehr → Unternehmen & Erscheinungsbild* nach design.md. AK: Screenshot-Matrix (E03-08).
