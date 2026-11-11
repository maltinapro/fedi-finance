# E10 – Bankanbindung

**Phase:** 2 · **Abhängig von:** E06 · **Status:** offen

## Ziel
Kunden verbinden ihre Geschäftskonten, Umsätze werden importiert und Buchungen/Rechnungen zugeordnet. Nur Open-Source-Lösungen.

## Kontext / Links
decisions.md Nr. 3

## Definition of Done
- Konto verbunden, Umsätze automatisch abgerufen, Zuordnungsvorschläge zu offenen Posten, Bestätigung erzeugt Buchung.

## Issues
- [ ] **E10-01 Spike Anbindungsart** – FinTS/HBCI (PIN/TAN, PSD2), CAMT-/MT940-Import, PSD2-Zugang. Bewertung Lizenz/Aufwand/Abdeckung. AK: ADR.
- [ ] **E10-02 Dateiimport** – CAMT.053/MT940/CSV-Import als Basis (kein Bankzugang nötig). AK: Importtests mit Beispieldateien.
- [ ] **E10-03 Bankkonten-Datenmodell** – IBAN, BIC, Konto-Verknüpfung zu Sachkonto, Zugangsdaten verschlüsselt (Secret-Store), Einwilligungen. AK: Daten-Verschlüsselung geprüft.
- [ ] **E10-04 Live-Anbindung (FinTS)** – Konto verbinden, TAN-Flow im UI, Umsatzabruf per Job. AK: Test gegen Demo-Bank/Mock.
- [ ] **E10-05 Zuordnungs-Engine** – Matching (Betrag, Verwendungszweck, Rechnungsnummer, IBAN), Regeln, Lernen aus Bestätigungen. AK: Trefferquote auf Testdaten.
- [ ] **E10-06 Zahlungsabgleich** – Teilzahlungen, Sammelüberweisungen, Skonto, Differenzen. AK: Fälle getestet.
- [ ] **E10-07 Überweisungen (optional)** – SEPA-Überweisung/Lastschrift auslösen mit Freigabeprozess. AK: Vier-Augen-Freigabe.
- [ ] **E10-08 Datenschutz & Sicherheit** – Minimale Speicherung (nur Geschäftskonten), Aufbewahrung, Zugriffsrechte, Audit. AK: Review.
