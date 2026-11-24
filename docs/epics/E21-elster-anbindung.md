# E21 – ELSTER-Anbindung (ERiC)

**Phase:** 2 · **Abhängig von:** E06, E08, E09, E12 · **Status:** offen

## Ziel
Steuermeldungen (zuerst die Umsatzsteuer-Voranmeldung) werden aus FediFinance geprüft und direkt an ELSTER übermittelt;
Übermittlungsnachweise werden revisionssicher archiviert. ERiC ist eine eng begrenzte Ausnahme vom Open-Source-Grundsatz
und läuft isoliert in einem optionalen Dienst je Mandant.

## Kontext / Links
[elster.md](../elster.md), [compliance.md](../compliance.md), [market.md](../market.md), decisions.md Nr. 4, E09-05, E09-07, E12-13, E20.

## Definition of Done
- Eine Umsatzsteuer-Voranmeldung wird in FediFinance geprüft, testweise und echt an ELSTER übermittelt, festgeschrieben und
  mit XML, Transferticket und Protokoll archiviert.
- Ohne ERiC bzw. Hersteller-ID bleibt FediFinance voll nutzbar (Rückfall: XML für Mein ELSTER, DATEV-Export für die Kanzlei).
- Build und CI laufen ohne ERiC.

## Issues
- [ ] **E21-01 Spike & ADR** – ERiC-Lizenzvertrag und Entwicklerhandbuch: Weitergabe, Bereitstellung (privates Image vs. Download), Herstellerpflichten, Mindestversion, Testmerker, Thread-/Multi-Instanz-Fähigkeit; Hersteller-ID für die Projekt-Testumgebung beantragen. AK: ADR; [elster.md](../elster.md) mit amtlichen Quellen aktualisiert.
- [ ] **E21-02 `elster-service` Grundgerüst** – Rust-Dienst, lädt ERiC zur Laufzeit (`libloading`), API: Version, prüfen, testweise senden, senden; Mock-ERiC für Tests. AK: CI ohne ERiC grün; lokaler Test mit dem Testzertifikat aus dem ERiC-Paket.
- [ ] **E21-03 Deployment** – Chart-Werte `elster.enabled`, `elster.herstellerId`, `elster.ericImage`; Init-Container kopiert ERiC aus privatem Betreiber-Image; NetworkPolicy (nur Backend → Dienst, Egress nur ELSTER). AK: `helm template` beider Varianten (an/aus), Test auf k3d.
- [ ] **E21-04 Zertifikatsverwaltung** – Upload `.pfx`, verschlüsselte Ablage, Ablaufdatum und Warnung, PIN nie gespeichert (Ausnahme: opt-in für Postfach-Abruf). AK: Tests, dass PIN und Klartext-Zertifikat weder in DB, Logs noch Backups landen.
- [ ] **E21-05 Einrichtungsassistent (UI)** – Status Hersteller-ID/ERiC, Datenschutzhinweise der Finanzverwaltung bestätigen (protokolliert), Zertifikat hochladen, Testübermittlung. AK: E2E-Test mit Mock; Screenshot-Matrix (E03-08).
- [ ] **E21-06 Umsatzsteuer-Voranmeldung übermitteln** – XML aus E09-05, nur prüfen, testweise senden, echt senden mit Bestätigungsdialog, berichtigte Anmeldung, Festschreibung; Archiv von XML, Transferticket, Protokoll-PDF, Serverantwort (E08); Recht „Steuermeldung übermitteln“ (E02-04), optional Vier-Augen. AK: Testübermittlung gegen ELSTER erfolgreich; Archivobjekte vorhanden.
- [ ] **E21-07 Weitere Umsatzsteuer-Meldungen** – Dauerfristverlängerung/Sondervorauszahlung, Zusammenfassende Meldung (Übermittlungsweg in E21-01 bestätigen). AK: Testübermittlung je Verfahren.
- [ ] **E21-08 Jahreserklärungen** – Umsatzsteuererklärung, Anlage EÜR (E09-02), Körperschaft- und Gewerbesteuererklärung. AK: Testübermittlung je Verfahren, Abgleich mit Referenzfällen.
- [ ] **E21-09 E-Bilanz** – XBRL nach Taxonomie aus E09-07 über ERiC übermitteln. AK: Testübermittlung.
- [ ] **E21-10 ELSTER-Postfach** – Bescheide abrufen, archivieren, mit erwarteter Steuer abgleichen; Nachrichten an das Finanzamt. AK: Abruf in der Testumgebung.
- [ ] **E21-11 Rückfall ohne Hersteller-ID** – XML-Export der Voranmeldung für den Import in Mein ELSTER, Ausfüllhilfe für weitere Formulare, Abgabe manuell vermerken (mit Nachweis-Upload). AK: Import in Mein ELSTER getestet.
- [ ] **E21-12 Betrieb & Versionen** – Update-Prozess für ERiC (Mindestversion), Liste geprüfter Versionen, Contract-Tests mit Referenzfällen je Version, Monitoring (Version, Zertifikatsablauf, Fehlerquote; E17); Herstellerpflichten in der Leistungsbeschreibung (E12-13). AK: Runbook.
- [ ] **E21-13 Dokumentation & Rechtsprüfung** – Anleitung für Betreiber (Hersteller-ID, ERiC) und Mandanten (Zertifikat); Kennzahlen und Abläufe von der Steuerberatung prüfen lassen ([#45](https://github.com/maltinapro/fedi-finance/issues/45)). AK: Doku aktuell, Prüfliste ergänzt.
- [ ] **E21-14 Spike Übermittlung im Auftrag (§ 87d AO)** – Betreiber sendet mit eigenem Zertifikat: Identifikations- und Aufzeichnungspflichten, Haftung, Aufwand vs. Nutzen für gehostete Kunden. AK: ADR mit Rechtsprüfung.

## Offene Fragen
Bereitstellungsweg von ERiC und Multi-Instanz-Betrieb (E21-01); Übermittlung im Auftrag (E21-14).
