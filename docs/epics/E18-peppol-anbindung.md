# E18 – Peppol-Anbindung (optionaler Transportweg)

**Phase:** 2 · **Abhängig von:** E05, E07, E08, E12 · **Status:** offen

## Ziel
Rechnungen und Gutschriften können zusätzlich zu ActivityPub über das Peppol-Netz an Partner ohne FediFinance gesendet und
von dort empfangen werden. ActivityPub bleibt der native Weg zwischen FediFinance-Servern; Peppol ist eine optionale Brücke.

## Kontext / Links
[peppol.md](../peppol.md), [federation.md](../federation.md), [compliance.md](../compliance.md), [pdfcraft.md](../pdfcraft.md) (R12), decisions.md Nr. 13–14.

## Definition of Done
- Rechnung wird per Peppol an einen Testteilnehmer gesendet, eine Peppol-Rechnung wird empfangen und als Eingangsrechnung-Entwurf angelegt; Rechnungsantwort (Invoice Response) und MLS werden im Status abgebildet.
- Kanalwahl je Partner (ActivityPub → Peppol → E-Mail/Download) funktioniert; XML wird vor dem Versand gegen Peppol-/XRechnung-Regeln validiert und unveränderlich archiviert.
- Peppol ist je Mandant abschaltbar (Opt-in) und mandantengetrennt betrieben.

## Issues
- [ ] **E18-01 Spike & Entscheidung Betriebsmodell** – Externer Access Point (Provider-API) vs. Betreiber-Gateway (phase4/Oxalis) vs. je Mandant (verworfen); Aufnahme/Mitgliedschaft, Testverfahren, Kosten und Pflichten (MLS, Reporting) bei OpenPeppol erfragen, AVV, Lizenzen (phoss-ap/phoss-smp, Oxalis); Java-Dienst neben Rust/TypeScript bewerten. AK: ADR in `docs/decisions.md`.
- [ ] **E18-02 Transport-Abstraktion** – Schnittstelle `DocumentTransport` (senden, Empfang, Zustellstatus), ActivityPub (E05-08) und E-Mail/Download (E05-11) dahinter, Kanalwahl je Partner. AK: Tests mit Fake-Transport, Reihenfolge ActivityPub → Peppol → E-Mail.
- [ ] **E18-03 Peppol-IDs in Stammdaten** – Eigene Peppol-ID (Mandant) und Peppol-ID je Partner (Schema + Kennung, z. B. USt-IdNr., Leitweg-ID, GLN), Kanalpräferenz. AK: Validierung, Migration, Tests.
- [ ] **E18-04 UBL-Erzeugung (Peppol BIS Billing 3.0)** – UBL 2.1 Invoice/CreditNote (in Peppol Pflicht; CII nur, wenn der Empfänger es im SMP registriert hat): Format anhand des SMP-Lookups wählen; UBL über PDFCraft-Anforderung R12 oder Konvertierung im Gateway, Entscheidung dokumentieren. AK: erzeugtes UBL besteht die Validierung aus E18-05.
- [ ] **E18-05 Validierung** – XSD + Schematron: Peppol-BIS-Regeln (z. B. phive-rules-peppol) und bei XRechnung-Empfängern KoSIT-Validator; Prüfdienst (Java) oder CI-Schritt, in der Belegfreigabe und in der CI. AK: Korpus gültiger/ungültiger Belege; Freigabe wird bei Fehlern blockiert.
- [ ] **E18-06 Gateway: Senden** – Access-Point-Anbindung (gewähltes Modell), SMP-Lookup des Empfängers, AS4-Versand, Retry/Idempotenz, Zustellnachweis. AK: Versand an Testteilnehmer, Ausfalltest.
- [ ] **E18-07 Gateway: Empfang** – Routing anhand der Peppol-ID zum Mandanten, Weitergabe ohne dauerhafte Speicherung im Gateway, Eingangsrechnung als Entwurf (E06-07, E07-10), Original-XML + Transportnachweis ins Archiv (E08). AK: Mandantentrennung getestet.
- [ ] **E18-08 Statusrückmeldung** – Technisch: Message Level Status (MLS, ersetzt MLR; vom Access Point behandelt) als Zustellstatus übernehmen. Fachlich: Invoice Response (Profil 02, Codes AB/IP/UQ/CA/RE/AP/PD) senden/empfangen und auf `ff:InvoiceStatus` abbilden. AK: Statuswechsel im Beleg sichtbar; MLR wird nicht implementiert.
- [ ] **E18-09 Teilnehmer-Registrierung** – Opt-in je Mandant, Registrierung/Deregistrierung im SMP (inkl. Offboarding E12). AK: Lebenszyklus getestet.
- [ ] **E18-10 Sicherheit & Datenschutz** – Zertifikats-/Schlüsselverwaltung, NetworkPolicy Mandant ↔ Gateway, Logs ohne Belegdaten, AVV/Unterauftragnehmer (E11). AK: Security-Tests, Datenschutzdoku.
- [ ] **E18-11 Testumgebung** – Peppol-Testnetz (Test-SML/Testbed) bzw. lokaler Access Point in Docker-Compose für E2E. AK: E2E in CI ohne Produktivnetz.
- [ ] **E18-12 UI** – Kanal und Zustellstatus je Beleg, Peppol-Einstellungen und Partner-Peppol-ID in der Oberfläche (nach `docs/design.md`). AK: Komponenten- und E2E-Tests.
- [ ] **E18-13 Dokumentation & Rechtsprüfung** – Betriebsanleitung, Peppol-Rechnungen und Aufbewahrung von der Steuerberatung prüfen lassen ([#45](https://github.com/maltinapro/fedi-finance/issues/45)). AK: Doku aktuell, Prüfliste ergänzt.

## Offene Fragen
decisions.md Nr. 13 (Betriebsmodell), Nr. 14 (UBL-Erzeugung), Nr. 10 (Zielmärkte).
