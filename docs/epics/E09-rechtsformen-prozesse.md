# E09 – Rechtsformen & Buchhaltungsprozesse

**Phase:** 2 · **Abhängig von:** E06, E08 · **Status:** offen

## Ziel
Je Rechtsform die notwendigen Prozesse abbilden (Profile/Feature-Flags), inkl. Abschlüsse und Steuermeldungen.

## Kontext / Links
[compliance.md](../compliance.md)

## Definition of Done
- Profile für Einzelunternehmen/Freiberufler/GbR (EÜR), OHG/KG, UG/GmbH (Bilanz) sind wählbar; Jahresabschluss-Prozess pro Profil durchspielbar.

## Issues
- [ ] **E09-01 Rechtsform-Profile** – Datenmodell: Profil → aktivierte Module, Pflichtfelder, Kontenrahmen-Defaults. AK: Profile als Konfiguration.
- [ ] **E09-02 EÜR** – Einnahmen-/Überschussrechnung, Anlage EÜR-Daten, Zufluss-/Abflussprinzip. AK: Referenzfälle.
- [ ] **E09-03 Bilanz & GuV** – Eröffnungs-/Schlussbilanz, Abgrenzungen (RAP), Rückstellungen. AK: Referenzfälle.
- [ ] **E09-04 Anlagenbuchhaltung** – Anlagegüter, AfA (linear/degressiv/GWG/Sammelposten). AK: AfA-Tests.
- [ ] **E09-05 Umsatzsteuer-Voranmeldung** – Kennzahlen berechnen, XML-Export; Übermittlung per ELSTER in [E21](E21-elster-anbindung.md). AK: Abgleich mit Testdaten.
- [ ] **E09-06 Jahresabschluss-Workflow** – Checkliste, Periodenabschluss, Eröffnungsvorträge, Sperre. AK: Workflow im UI.
- [ ] **E09-07 Kapitalgesellschaft** – Gesellschafterkonten, Gewinnverwendung, E-Bilanz-Export (Taxonomie; Übermittlung E21-09), Offenlegungs-Hinweise. AK: Beispiel-Export.
- [ ] **E09-08 Mahnwesen** – Mahnstufen, Verzugszinsen, Mahngebühren, Mahnlauf. AK: Mahnungs-PDF (E07-09, PDFCraft-Anforderung R5).
- [ ] **E09-09 Zahlungsverwaltung** – Zahlungsziele, Skonto, offene Posten, Zahlungsvorschläge (SEPA-Export pain.001). AK: Export validiert.
- [ ] **E09-10 Export für Steuerberater** – verschoben nach [E20](E20-steuerberatung-umstieg.md) (DATEV-Export ist Pflicht, nicht optional, siehe [market.md](../market.md)); Prüfer-Export in E08-09. AK: entfällt hier.
- [ ] **E09-11 Weitere Rechtsformen** – e. V., Österreich/Schweiz (später). AK: Entscheidung dokumentiert.

## Offene Fragen
decisions.md Nr. 10; ELSTER: [E21](E21-elster-anbindung.md).
