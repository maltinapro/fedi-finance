# ELSTER-Anbindung (ERiC)

Arbeitsstand 24.11.2026. Rechtliche und steuerliche Aussagen von der Steuerberatung prüfen lassen
([#45](https://github.com/maltinapro/fedi-finance/issues/45)); Lizenz- und Herstellerpflichten gegen den ERiC-Lizenzvertrag
und das Entwicklerhandbuch prüfen (E21-01).

> **Quellenlage:** ✔ = am 24.11.2026 gelesen in der Dokumentation des Open-Source-Projekts Haben, das ERiC bereits
> einbindet ([Quellen](#quellen)); das ist eine **Drittquelle**, keine amtliche. ◐ = nicht geprüft.

## Entscheidung

FediFinance übermittelt Steuermeldungen **direkt an ELSTER** über **ERiC** (ELSTER Rich Client), die Bibliothek der
Finanzverwaltung (decisions.md Nr. 4). ERiC ist nicht quelloffen. Das ist eine bewusste, eng begrenzte **Ausnahme** vom
Open-Source-Grundsatz, weil es für die direkte Übermittlung aus eigener Software keinen quelloffenen Ersatz gibt ◐:

- ERiC liegt nicht im Repository und nicht in veröffentlichten Images (Weitergabe nicht erlaubt ✔); der Betreiber stellt es bereit.
- ERiC läuft in einem eigenen, optionalen Dienst (`elster-service`), nicht im Backend; ohne ERiC funktioniert FediFinance
  vollständig, nur die Direktübermittlung fehlt (Rückfallwege siehe unten).
- Build, Tests und CI laufen ohne ERiC (dynamisches Laden zur Laufzeit, Mock in Tests).

## Voraussetzungen

| Baustein | Wofür | Woher | Wer |
| --- | --- | --- | --- |
| **ERiC** (`libericapi.so` + Plugins, Linux x86_64) | prüft, verschlüsselt, signiert und überträgt | ELSTER-Entwicklerbereich, Nutzungsbedingungen zustimmen ✔ | Betreiber |
| **Hersteller-ID** (fünf Ziffern) | Kennung der Software in jeder Übermittlung; schon für die Plausibilitätsprüfung nötig ✔ | Registrierung als Entwickler auf elster.de, Prüfung durch das Bayerische Landesamt für Steuern (Tage bis Wochen) ✔ | Betreiber |
| **Zertifikatsdatei** (`.pfx`) und PIN | signiert jede Übermittlung | ELSTER-Benutzerkonto mit Anmeldeart „Zertifikatsdatei“ (Organisationszertifikat für Unternehmen ◐); ELSTER Secure ist für Software nicht nutzbar ✔; Gültigkeit drei Jahre ✔ | Unternehmen (Mandant) |
| Bestätigte **Datenschutzhinweise** der Finanzverwaltung | vom ERiC-Lizenzvertrag vor der ersten Nutzung verlangt ✔ | in der Anwendung, protokolliert | Mandant |
| Stammdaten | Steuernummer, Bundesland/Finanzamt, Name, Anschrift | E04-01 | Mandant |

## Wer ist Hersteller?

Die Hersteller-ID gehört dem **Softwarehersteller**, nicht dem Steuerpflichtigen ✔. Eine gemeinsame ID für ein
Open-Source-Projekt sieht ELSTER nicht vor ✔. Für FediFinance heißt das:

- **Gehosteter Betrieb (E12-13):** Der Betreiber beantragt **eine** Hersteller-ID und nutzt sie für alle seine Mandanten.
  Er ist damit Hersteller im Sinne des ERiC-Lizenzvertrags und übernimmt dessen Pflichten ✔: Support für die Nutzer,
  Einsatz mindestens der von ELSTER vorgegebenen ERiC-Mindestversion, Bestätigung der Datenschutzhinweise durch die Nutzer.
  Bei Verstößen kann die ID gesperrt werden – dann kann kein Mandant des Betreibers mehr senden ✔.
- **Selbstbetrieb:** Wer FediFinance selbst betreibt, beantragt eine eigene Hersteller-ID.
- Wer FediFinance verändert und weitergibt, braucht eine eigene ID ✔.
- Das Projekt bringt keine Hersteller-ID mit; sie wird per Konfiguration gesetzt (`elster.herstellerId`), nie ins Repository
  oder Image geschrieben. Die frühere Test-Hersteller-ID ist gesperrt; auch Tests brauchen eine eigene ID ✔.

## Übermittlungswege

| Weg | Beschreibung | Status |
| --- | --- | --- |
| **A. Mit dem Zertifikat des Unternehmens** | Standard: Der Mandant lädt seine `.pfx` hoch, die PIN wird je Übermittlung abgefragt | E21-06 ff. |
| B. Übermittlung im Auftrag (§ 87d AO) | Betreiber sendet mit eigenem Zertifikat für seine Mandanten (wie Cloud-Anbieter ✔); verlangt Identifikation jedes Auftraggebers und Aufzeichnungen (5 Jahre) ✔ | später optional, Spike + Rechtsprüfung (E21-14) |
| C. Über die Steuerberatung | Kanzlei übermittelt aus ihrer Software; FediFinance liefert den DATEV-Export (E20) | ohne ERiC |
| D. Ohne Hersteller-ID | XML-Datei für den Import in Mein ELSTER (Voranmeldung ✔), sonst Ausfüllhilfe; Abgabe manuell vermerken | Rückfall (E21-11) |

## Architektur

```
Mandanten-Namespace tenant-<id>
  Backend ──(intern, mTLS/Token)──▶ elster-service (Rust, lädt ERiC per libloading) ──HTTPS──▶ ELSTER-Server
     │                                   ▲ ERiC aus privatem Betreiber-Image (Init-Container → emptyDir)
     └─▶ S3 archive: gesendetes XML, Transferticket, Übermittlungsprotokoll (PDF), Serverantwort
```

- **Je Mandant ein Dienst** (`elster.enabled` im Chart): Zertifikat, PIN und Steuerdaten verlassen den Namespace nicht, ein
  Absturz der nativen Bibliothek trifft nur einen Mandanten; der Ressourcenbedarf ist klein. Ob ERiC mehrere Mandanten in
  einem Prozess sicher bedienen kann (Multi-Instanz-API), wird in E21-01 nur als Alternative bewertet.
- **Bereitstellung von ERiC:** Der Betreiber baut ein privates Image mit ERiC (nicht öffentlich, nicht in der Projekt-Registry);
  ein Init-Container kopiert ERiC in ein `emptyDir`. Alternative: Download von der Finanzverwaltung nach Zustimmung im
  Einrichtungsassistenten (wie Haben ✔) – Entscheidung in E21-01.
- **Netz:** Ingress zum Dienst nur vom Backend (NetworkPolicy), Egress nur zu den ELSTER-Servern.
- **Zertifikat:** Upload im UI, Ablage verschlüsselt (Envelope-Verschlüsselung, Schlüssel aus Kubernetes-Secret), Ablaufdatum
  auslesen und vorher warnen. Die **PIN wird nicht gespeichert**; nur für einen automatischen Postfach-Abruf optional
  (opt-in) verschlüsselt. Entschlüsselte Zertifikate nur kurz im Speicher bzw. als temporäre Datei mit Rechten `0600`.
- **Rechte:** eigene Berechtigung „Steuermeldung übermitteln“ (Inhaber/Buchhalter, E02-04), optional Vier-Augen-Freigabe;
  jede Prüfung und Übermittlung im Audit-Log.
- **Logs:** ERiC-Protokolle enthalten Steuerdaten; sie werden nicht ins zentrale Logging geschrieben, sondern als
  Übermittlungsnachweis archiviert, das Dienst-Log enthält nur IDs und Status (DSGVO, [compliance.md](compliance.md#dsgvo)).

## Ablauf einer Übermittlung

1. FediFinance berechnet die Meldung aus den festgeschriebenen Buchungen (z. B. Kennzahlen der Voranmeldung, E09-05).
2. Backend erzeugt das XML der Datenart und Version (Jahresdokumentation aus dem ELSTER-Entwicklerbereich ◐).
3. **Nur prüfen:** ERiC-Plausibilitätsprüfung ohne Zertifikat ✔; Fehler werden den Kennzahlen zugeordnet angezeigt.
4. **Testübermittlung** mit Testmerker: Der ELSTER-Server nimmt an, leitet aber nicht an das Finanzamt weiter ✔.
5. **Echtübermittlung** nach Bestätigungsdialog (Steuerart, Zeitraum, Zahllast), PIN-Eingabe.
6. Die Meldung wird festgeschrieben; gesendetes XML, Transferticket, Übermittlungsprotokoll (PDF) und Serverantwort werden
   hash-adressiert im `archive`-Bucket abgelegt (E08). Eine Korrektur ist eine neue, berichtigte Meldung (GoBD: kein Ändern).

## Verfahren und Reihenfolge

| Stufe | Verfahren | Abhängig von |
| --- | --- | --- |
| 1 | Umsatzsteuer-Voranmeldung (inkl. berichtigter Anmeldung), Dauerfristverlängerung/Sondervorauszahlung, Zusammenfassende Meldung ◐ | E09-05, E06-05 |
| 2 | Umsatzsteuererklärung, Anlage EÜR, E-Bilanz (XBRL-Taxonomie), Körperschaft- und Gewerbesteuererklärung | E09-02, E09-03, E09-07 |
| 3 | ELSTER-Postfach: Bescheide abrufen und archivieren, Abgleich mit der erwarteten Steuer; Nachrichten an das Finanzamt | Stufe 1 |
| nicht geplant | Lohnsteuer (kein Lohnmodul), Einkommensteuer (private Daten, Datenminimierung) | – |

## Betrieb

- ERiC erscheint regelmäßig in neuen Versionen; ELSTER gibt eine Mindestversion vor ✔. Der Betreiber aktualisiert sein
  ERiC-Image; FediFinance dokumentiert die geprüften Versionen und führt Contract-Tests (Plausibilitätsprüfung mit
  Referenzfällen) gegen jede neue Version aus (E21-12).
- Monitoring: ERiC-Version, Ablauf von Zertifikaten, Fehlerquote je Verfahren (E17).

## Offene Punkte

- ERiC-Lizenzvertrag und Entwicklerhandbuch selbst lesen: Weitergabe, Download-Automatisierung, Pflichten des Herstellers,
  Mindestversion, Testmerker, Organisationszertifikat für Kapitalgesellschaften (E21-01).
- Übermittlung im Auftrag (§ 87d AO) für gehostete Betreiber (E21-14).
- Zusammenfassende Meldung: Übermittlungsweg (ELSTER/ERiC oder BZSt) bestätigen.

## Quellen

- Haben (AGPL-3.0, Drittquelle, gelesen 24.11.2026): [ELSTER einrichten](https://github.com/Speicherstadt/haben/blob/main/docs/einrichtung-elster.md),
  [Abgabe an ELSTER](https://github.com/Speicherstadt/haben/blob/main/docs/elster-abgabe.md)
- Amtlich (in E21-01 prüfen): [ELSTER-Entwicklerbereich](https://www.elster.de/eportal/infoseite/entwickler),
  ERiC-Lizenzvertrag (`lizenz.pdf` im ERiC-Paket), ERiC-Entwicklerhandbuch, [§ 87d AO](https://www.gesetze-im-internet.de/ao_1977/__87d.html)
