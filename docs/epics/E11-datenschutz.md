# E11 – Datenschutz (DSGVO)

**Phase:** 2 · **Abhängig von:** E01, E08 · **Status:** offen

## Ziel
Datenschutzkonforme Speicherung: nur notwendige Daten, Rechte der Betroffenen, Lösch-/Sperrkonzept, Verschlüsselung, Dokumentation.

## Kontext / Links
[compliance.md](../compliance.md)

## Definition of Done
- Datenkatalog existiert, Betroffenenrechte sind technisch umsetzbar, Verschlüsselung und Log-Retention sind konfiguriert, Vorlagen (AVV, VVT) liegen vor.

## Issues
- [ ] **E11-01 Datenkatalog** – Jedes gespeicherte Feld: Zweck, Rechtsgrundlage, Frist, Sichtbarkeit. AK: Dokument + Review bei neuen Feldern (Checkliste in PR-Template).
- [ ] **E11-02 Datenminimierung im Code** – Review aller Datenmodelle, optionale Felder, Pseudonymisierung wo möglich. AK: Review-Bericht.
- [ ] **E11-03 Lösch- und Sperrkonzept** – Sperrung bei Aufbewahrungspflicht, Löschung nach Frist, Löschung in Backups/KI-Index. AK: Prozess + Tests.
- [ ] **E11-04 Betroffenenrechte** – Auskunft/Export (Art. 15/20), Berichtigung, Einschränkung. AK: UI/API + Audit.
- [ ] **E11-05 Verschlüsselung** – TLS intern/extern, Volume-/DB-Verschlüsselung, Feldverschlüsselung für sensible Daten (z. B. Bankzugang). AK: Nachweis in Doku.
- [ ] **E11-06 Logging-Datenschutz** – Keine personenbezogenen Daten in Logs, Retention, Maskierung. AK: Log-Tests.
- [ ] **E11-07 Dokumentvorlagen** – AVV (Auftragsverarbeitung), VVT, TOM-Beschreibung, Datenschutzhinweise für Kunden. AK: Vorlagen in `docs/legal/`.
- [ ] **E11-08 Einwilligungen & Opt-ins** – KI-Training, Föderation-Sichtbarkeit, Telemetrie. AK: Einwilligungs-Log.
- [ ] **E11-09 Datenschutz-Folgenabschätzung** – DSFA für KI und Bankdaten. AK: Dokument.
- [ ] **E11-10 Föderations-Datenschutz** – Welche Daten an Partner gehen (E05/E04-06), Löschanfragen an Partner. AK: Konzept.
