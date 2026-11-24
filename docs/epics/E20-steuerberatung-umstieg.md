# E20 – Steuerberatung & Umstieg (DATEV-Export, Migration)

**Phase:** 2 · **Abhängig von:** E04, E06, E08 · **Status:** offen

## Ziel
FediFinance ist für Steuerberatungen anschlussfähig (DATEV-Export als Pflichtfunktion, Steuerberater-Zugang) und der
Umstieg aus verbreiteten Programmen ist einfach (Import aus DATEV-Buchungsstapel, Lexware Office, sevDesk). Beides ist
laut [market.md](../market.md#5-schwächen-und-risiken) ein Ausschlusskriterium für die meisten Kunden und muss vor dem
ersten echten Kunden stehen.

## Kontext / Links
[market.md](../market.md), [compliance.md](../compliance.md), E02-04 (Rolle Steuerberater), E08-09 (Prüfer-Export),
E09-10 (verschoben hierher), E13-06 (Umzug zwischen FediFinance-Instanzen).

## Definition of Done
- Ein Geschäftsjahr aus FediFinance lässt sich als DATEV-Buchungsstapel inkl. Stammdaten exportieren und von einer
  Steuerberatung importieren; Belege sind zugeordnet.
- Die Steuerberatung kann per Einladung lesend zugreifen und Exporte selbst abrufen.
- Stammdaten, offene Posten und Saldenvorträge lassen sich aus DATEV-Buchungsstapel, Lexware Office und sevDesk übernehmen.

## Issues
- [ ] **E20-01 Spike DATEV-Schnittstellen** – Formatbeschreibung DATEV-Format (EXTF: Buchungsstapel, Debitoren/Kreditoren, Kontenbeschriftungen), Belegübergabe (Belegbilder/Belegverknüpfung), DATEVconnect und Marktplatz-Partnerschaft: Nutzungsbedingungen, Lizenz der Spezifikation, Kosten, ob eine Implementierung ohne Partnerschaft zulässig ist. AK: ADR; Fakten in [market.md](../market.md) nachgetragen.
- [ ] **E20-02 DATEV-Buchungsstapel-Export** – Export je Zeitraum/Geschäftsjahr, SKR03/SKR04, Steuerschlüssel (Mapping aus E06-05), Personenkonten, Festschreibungskennzeichen, Kontenbeschriftungen, Debitoren/Kreditoren. AK: Golden Tests gegen Referenzdateien; Importtest bei einer Steuerberatung.
- [ ] **E20-03 Belegexport für die Steuerberatung** – Belege (PDF/XML aus dem Archiv, E08) zu den Buchungen mitliefern, Verknüpfung Beleg ↔ Buchung nach Ergebnis aus E20-01. AK: Belege in der Kanzlei-Software den Buchungen zugeordnet.
- [ ] **E20-04 Steuerberater-Arbeitsbereich** – Einladung per Link, Rolle Steuerberater (E02-04) lesend und zeitlich begrenzbar, Exporte selbst abrufen, Rückfragen zu Belegen; Zugriffe im Audit-Log. AK: E2E-Test Einladung → Export.
- [ ] **E20-05 Import DATEV-Buchungsstapel** – Stammdaten, Saldenvorträge und optional Buchungen des Vorjahres als Altdaten (nicht nachträglich festgeschrieben gebucht, Quelle markiert). AK: Vorschau, Duplikaterkennung, Abgleich Summen-/Saldenliste.
- [ ] **E20-06 Import Lexware Office (lexoffice)** – Kontakte, Artikel, offene Posten, Belege über API (falls Tarif vorhanden) oder Export-Dateien/DATEV-Export. AK: Testdaten-Import mit Abgleich.
- [ ] **E20-07 Import sevDesk** – Kontakte, Artikel, offene Posten, Belege über die öffentliche API oder Export-Dateien. AK: Testdaten-Import mit Abgleich.
- [ ] **E20-08 Umstiegsassistent (UI)** – Quelle wählen, Dateien/Zugang angeben, Vorschau, Konflikte lösen, Bericht; nutzt E04-08 und E04-11. AK: Screenshot-Matrix (E03-08), Importbericht wird archiviert.
- [ ] **E20-09 Dokumentation & Rechtsprüfung** – Anleitung für Kunden und Steuerberatungen; Hinweis, dass Altdaten im Altsystem aufbewahrungspflichtig bleiben und der Datenzugriff (Z1–Z3) darauf sichergestellt sein muss; von der Steuerberatung prüfen lassen ([#45](https://github.com/maltinapro/fedi-finance/issues/45), E08-12). AK: Doku aktuell, Prüfliste ergänzt.

## Offene Fragen
DATEV-Partnerschaft und Lizenz der Formatbeschreibung (E20-01); ELSTER (decisions.md Nr. 4) ist eigenständig in E09-05.
