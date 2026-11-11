# E06 – Buchhaltungskern & Rechnungen

**Phase:** 1 · **Abhängig von:** E04 · **Status:** offen

## Ziel
Doppelte Buchführung als Kern (auch für EÜR nutzbar), Kontenrahmen, Buchungsjournal, Ausgangs- und Eingangsrechnungen, Umsatzsteuer – unveränderbar nach Festschreibung.

## Kontext / Links
[compliance.md](../compliance.md)

## Definition of Done
- Rechnung erstellen → buchen → Journal/Konto/Saldenliste sichtbar; Festschreibung verhindert Änderungen; Storno funktioniert.

## Issues
- [ ] **E06-01 Kontenrahmen** – SKR03/SKR04 als Daten, Konten-Verwaltung, Kontoarten. AK: Import + Tests.
- [ ] **E06-02 Buchungs-Engine** – Buchungssatz (Soll/Haben, Dezimalarithmetik), Validierung, Mehrfachbuchung, Geschäftsjahr/Perioden. AK: Property-Tests (Soll = Haben).
- [ ] **E06-03 Festschreibung & Storno** – Append-only, Storno-/Korrekturbuchung, Periodensperre. AK: Update auf festgeschriebene Buchung unmöglich (DB-Constraint + Tests).
- [ ] **E06-04 Nummernkreise** – Lückenlos, je Belegart/Jahr, nebenläufigkeitssicher. AK: Lasttest ohne Lücken.
- [ ] **E06-05 Umsatzsteuer** – Steuersätze, Steuerschlüssel, Reverse Charge, innergemeinschaftliche Lieferung, Kleinunternehmer. AK: Testfälle je Fall.
- [ ] **E06-06 Ausgangsrechnung** – Entwurf → Freigabe → Versand; Positionen, Rabatte, Zahlungsbedingungen; Pflichtangaben § 14 UStG. AK: Validierung.
- [ ] **E06-07 Eingangsrechnung** – Erfassung (manuell, per Föderation, Upload), Prüfung/Freigabe-Workflow, Kontierung. AK: Vier-Augen-Option.
- [ ] **E06-08 Gutschrift/Storno-Rechnung** – Bezug zur Ursprungsrechnung. AK: Buchungen konsistent.
- [ ] **E06-09 Auswertungen** – Journal, Kontenblatt, Summen-/Saldenliste, BWA, offene Posten. AK: Abgleich mit Testdaten.
- [ ] **E06-10 Kostenstellen/Projekte (optional)** – Dimensionen für Buchungen. AK: Entscheidung dokumentiert.
- [ ] **E06-11 Mehrwährung (später)** – Kursverwaltung, Bewertung. AK: Entscheidung dokumentiert.
- [ ] **E06-12 Fachliche Testsuite** – Referenzfälle (Beispielbuchhaltungen) als Golden Tests. AK: In CI.
