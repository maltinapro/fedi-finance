# E04 – Stammdaten & Geschäftspartner

**Phase:** 1 · **Abhängig von:** E01, E02, E03 · **Status:** offen

## Ziel
Verwaltung der eigenen Unternehmensstammdaten und der Geschäftspartner (lokal angelegt oder über Föderation verknüpft), datensparsam und versioniert.

## Kontext / Links
[federation.md](../federation.md), [compliance.md](../compliance.md)

## Definition of Done
- Eigene Firma konfigurierbar (Rechtsform, Steuerdaten, Bankverbindung, Logo), Partner anlegbar/suchbar, Änderungen historisiert.

## Issues
- [ ] **E04-01 Datenmodell Unternehmen** – Name, Rechtsform, Anschrift, USt-IdNr., Steuernummer, Registerdaten, Geschäftsjahr, Währung. AK: Migration + API.
- [ ] **E04-02 Onboarding-Assistent** – Erstkonfiguration (Rechtsform, Kontenrahmen, Besteuerungsart, Kleinunternehmer). AK: Profil steuert Folge-Features.
- [ ] **E04-03 Geschäftspartner (Kunde/Lieferant)** – CRUD, Typ, Zahlungsbedingungen, Ansprechpartner, Notizen. AK: Suche + Tests.
- [ ] **E04-04 Partner per Domain hinzufügen** – Eingabe `f1.com` → Discovery + Stammdaten-Import (nutzt E05). AK: Partner mit Quelle „föderiert" markiert.
- [ ] **E04-05 Stammdaten-Versionierung** – Historie, Gültigkeitszeiträume (Beleg verwendet Stand zum Belegdatum). AK: Änderung verändert alte Belege nicht.
- [ ] **E04-06 Sichtbarkeitsstufen** – Je Feld: öffentlich/Partner/privat für die Föderation. AK: Default datensparsam.
- [ ] **E04-07 USt-IdNr.-Prüfung** – Validierung (Format, optional VIES-Abfrage). AK: Ergebnis protokolliert.
- [ ] **E04-08 Import/Export** – CSV-Import von Partnern, Duplikaterkennung. AK: Fehlerreport.
- [ ] **E04-09 Mehrere Unternehmen/Mandanten-Einheiten** – (optional) mehrere Buchungskreise je Instanz. AK: Entscheidung dokumentiert.
