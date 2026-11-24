# Peppol-Anbindung (optionaler Transportweg)

Arbeitsstand (11/2026), gegen die aktuellen OpenPeppol-Spezifikationen geprüft (siehe [Geprüfter Stand](#geprüfter-stand)).
Rechtliche Aspekte von der Steuerberatung prüfen lassen ([#45](https://github.com/maltinapro/fedi-finance/issues/45)).

## Positionierung

FediFinance bleibt **föderiert**: Zwischen FediFinance-Servern ist [ActivityPub](federation.md) der native Weg, weil er
mehr kann als Dokumente zustellen (Partner-Handshake, Stammdaten-Synchronisation, Status, Zahlungsbestätigung).
Für die Welt **ohne** FediFinance gibt es Brücken (Gateways). **Peppol** ist die erste und wichtigste davon: Es erreicht
Unternehmen und Behörden, die Rechnungen über ihr Peppol-Netz empfangen, ohne dass diese FediFinance einsetzen müssen.

| Kanal | Gegenstelle | Inhalt | Rolle |
| --- | --- | --- | --- |
| ActivityPub | FediFinance-Server | Stammdaten, Belege, Status | nativ, bevorzugt |
| Peppol | beliebiges Peppol-Mitglied | E-Rechnung (UBL), Gutschrift, Rechnungsantwort | optional, Brücke |
| E-Mail/Download | alle anderen | PDF/A-3 mit XML | Fallback (E05-11) |

Peppol ersetzt ActivityPub nicht: Es kennt keine Stammdaten-Synchronisation, kein Partner-Handshake und keine Entdeckung
über Domains, sondern ein Vier-Ecken-Modell (Sender → Access Point → Access Point → Empfänger) mit Teilnehmer-IDs und
zentralen Verzeichnissen (SML/SMP).

## Kanalwahl je Partner

Beim Versand wählt das Backend den Kanal in dieser Reihenfolge (überschreibbar je Partner):

1. Partner ist FediFinance-Instanz (Domain verknüpft, E05) → ActivityPub.
2. Partner hat eine Peppol-ID und ist per SMP-Lookup erreichbar → Peppol.
3. Sonst → E-Mail/Download-Link.

Der Beleg (festgeschriebenes PDF + XML, E07/E08) ist in allen Fällen dasselbe; nur der Transport unterscheidet sich.
Das Backend kapselt Transporte hinter einer Schnittstelle (`DocumentTransport`: senden, Empfang, Zustellstatus),
damit weitere Netze (z. B. nationale E-Rechnungs-Plattformen) später als Adapter ergänzt werden können (E18-02).

## Technische Punkte

- **Peppol-ID:** Schema + Kennung, z. B. `9930:DE…` (`DE:VAT`, USt-IdNr.), `0204:` (`DE:LWID`, Peppol-Leitweg-ID, KoSIT),
  `0088:` (GLN). Partner und eigene Firma bekommen ein Feld (E04-03, E18-03).
- **Format:** Peppol BIS Billing 3.0 (CIUS von EN 16931) schreibt **UBL 2.1** (Invoice/CreditNote) verpflichtend vor;
  **CII (UN/CEFACT D16B) ist optional**: Empfänger müssen es im SMP zusätzlich registrieren. Folgen:
  - Senden: Der SMP-Lookup liefert die unterstützten Formate des Empfängers. PDFCraft erzeugt bisher nur CII; für Empfänger
    ohne CII-Registrierung ist UBL nötig (Vorschlag **R12**, siehe [pdfcraft.md](pdfcraft.md#7-anforderungen-an-pdfcraft-upstream);
    Konvertierung CII → UBL im Gateway ist verlustbehaftet und nicht bevorzugt). Entscheidung in E18-04.
  - Empfangen: UBL muss immer akzeptiert werden (der Parser aus E07-10 liest CII und UBL).
  - Spezifikations- und Prozess-IDs: `CustomizationID` `urn:cen.eu:en16931:2017#compliant#urn:fdc:peppol.eu:2017:poacc:billing:3.0`,
    `ProfileID` `urn:fdc:peppol.eu:2017:poacc:billing:01:1.0` (Profil 01, Rechnung) bzw. `urn:peppol:bis:billing_with_response` (Profil 02).
  - XML muss UTF-8 sein; die Nutzlast wird im Peppol Business Message Envelope (SBDH) übertragen (Aufgabe des Access Points).
  - Das gesendete XML wird wie jedes andere Beleg-XML unveränderlich archiviert (E08).
  - Rechnungstypcodes 326 (Teilrechnung), 384 (Korrekturrechnung) und 389 (Gutschriftsverfahren) sind laut BIS nur für
    bestimmte Länder (DE, 384 auch SK) zulässig; Standard sind 380 (Rechnung) und 381 (Gutschrift).
- **Validierung:** Vor dem Versand XSD und Schematron: Peppol-BIS-Regeln (UBL und CII; OpenPeppol-Artefakte, z. B. über
  `phive-rules-peppol`) und bei XRechnung-Empfängern zusätzlich die XRechnung-Prüfung (KoSIT-Validator mit
  XRechnung-Konfiguration). Beides ist Java-Werkzeug (Apache-2.0) und läuft als Prüfdienst/CI-Schritt (E18-05). PDFCraft liefert
  nur eine Plausibilitätsprüfung. XRechnung und Peppol BIS sind verschiedene CIUS (andere `CustomizationID`).
- **Empfang:** Eingehendes UBL wird wie eine föderierte Rechnung behandelt: parsen/prüfen (E07-10), Eingangsrechnung als
  Entwurf (E06-07), Original-XML und Transportnachweis archivieren.
- **Status (zwei Ebenen):**
  - *Technisch:* **Message Level Status (MLS)** zwischen den Access Points. Er ersetzt die Message Level Response (MLR), die
    ausläuft. Nach Peppol Network Policy 1.0.0 (2026-07-02) müssen alle Service Provider MLS senden und empfangen; ohne
    Angabe im SBDH gilt `FAILURE_ONLY` (nur Fehlermeldungen). MLS wird vom Access Point behandelt; FediFinance übernimmt
    das Ergebnis als Zustellstatus. MLR wird **nicht** implementiert.
  - *Fachlich:* **Invoice Response** (nur Profil 02, optional und mit eigener SMP-Registrierung) mit den Statuscodes
    AB (bestätigt), IP (in Bearbeitung), UQ (Rückfrage), CA (bedingt angenommen), RE (abgelehnt), AP (angenommen) und PD (bezahlt),
    abgebildet auf `ff:InvoiceStatus` (E18-08).

## Betriebsmodelle

Peppol-Nachrichten laufen über **Access Points** von Peppol Service Providern. Ein Access Point muss das Peppol-AS4-Profil
(v2.0.3), dynamische Discovery über SML/SMP, die Peppol-PKI (Transport-Zertifikate), SBDH-Envelope, MLS und das
Peppol Reporting der Service Provider (Berichte an OpenPeppol) beherrschen; Service Provider werden über eine
Seat-ID im SPIS identifiziert. Aufnahmeverfahren, Mitgliedschaft, Testverfahren und Kosten sind in den öffentlichen
Spezifikationen nicht beschrieben und müssen in E18-01 bei OpenPeppol erfragt werden.

| Modell | Beschreibung | Bewertung |
| --- | --- | --- |
| A – Externer Access Point (Provider-API) | FediFinance spricht per Adapter die API eines Peppol-Anbieters | schnell; der Anbieter verarbeitet Belegdaten und ist damit eine Ausnahme von „keine Drittanbieter-SaaS für Kundendaten": nur mit Opt-in, AVV und EU-Hosting |
| B – Betreiber-Gateway | Der FediFinance-Betreiber wird Peppol-Service-Provider und betreibt **einen** Access Point + SMP cluster-weit (Open Source, siehe unten) | volle Kontrolle, passt zum Open-Source-Grundsatz; Aufnahme, Pflichten (MLS, Reporting) und Betriebsaufwand beim Betreiber; zusätzlicher Java-Dienst neben Rust/TypeScript |
| C – Access Point je Mandant | Jeder Mandant betreibt einen eigenen Access Point | verworfen: Service-Provider-Pflichten (Zertifikate, MLS, Reporting) je Mandant, hoher Aufwand |

Vorschlag: Schnittstelle zum Gateway provider-neutral halten; **Start mit A oder B** je nach Betreiberentscheidung
(Spike E18-01).

Open-Source-Bausteine für Modell B (Stand 11/2026, alle Java, Lizenzen vor Einsatz prüfen):

| Baustein | Zweck | Lizenz |
| --- | --- | --- |
| [phoss-ap](https://github.com/phax/phoss-ap) (auf phase4) | vollständiger Access Point: AS4, SMP-Client, SBDH, MLS, Reporting, Retry, Weiterleitung per HTTP/S3/SFTP, optionale Validierung | Apache-2.0 |
| [phoss-smp](https://github.com/phax/phoss-smp) | SMP-Server (eigene Teilnehmer registrieren) | MPL-2.0 (laut `pom.xml`) |
| [Oxalis](https://github.com/OxalisCommunity/oxalis) | Alternative AP-Implementierung | EUPL |
| phive + `phive-rules-peppol`, KoSIT-Validator | Validierung (siehe oben) | Apache-2.0 |

### Mandantentrennung und Datenschutz

- Das Gateway (B) ist wie Keycloak/PDFCraft eine geteilte Komponente: Es hält die Access-Point-Zertifikate, routet
  eingehende Nachrichten anhand der Peppol-ID zum Mandanten und **speichert keine Belege dauerhaft** (nur Queue/
  Zustellprotokoll ohne Inhalt). Die Ablage erfolgt im Mandanten-Archiv (E08).
- Peppol ist **opt-in je Mandant** (Registrierung der Teilnehmer-ID im SMP, Deregistrierung beim Offboarding).
- NetworkPolicy: nur gezielter Verkehr zwischen Mandanten-Backend und Gateway; AVV/Unterauftragnehmer dokumentieren (E11).

## Geprüfter Stand

Geprüft am 24.11.2026 gegen die öffentlichen OpenPeppol-Repositories (`peppol-bis-invoice-3`, `poacc-upgrade-3`,
`edec-specifications`, `edec-codelists`, `edec-as4`); `docs.peppol.eu` war aus der Entwicklungsumgebung nicht erreichbar.

| Gegenstand | Stand |
| --- | --- |
| Peppol BIS Billing 3.0 | 3.0.22-hotfix (28.10.2026); 3.0.21 (Veröffentlichung 20.05.2026, verpflichtend ab 17.08.2026); Profil 02 „billing with response" neu |
| Validierungsartefakte | UBL und CII 1.3.16 (10.04.2026) |
| Invoice Response BIS | Statuscodes AB, IP, UQ, CA, RE, AP, PD (UNCL4343-Teilmenge) |
| Peppol Network Policy | 1.0.0 (02.07.2026): MLS-Pflicht, UTF-8, Payload-Größenmessung |
| MLS | ersetzt MLR (läuft aus), SPOG on MLS 1.0.0 (02.07.2026) |
| Peppol AS4 Profile | v2.0.3 (22.04.2024) |
| Business Message Envelope (SBDH) | 2.0.2 (02.07.2026) |
| SML / SMP / Identifier-Policy | 1.3.0 / 1.4.0 / 4.4.0 (jeweils 06.02.2025) |
| Code lists | v9.7 (Teilnehmer-ID-Schemata `DE:VAT` 9930, `DE:LWID` 0204, `GLN` 0088 aktiv) |

Nicht verifiziert (nicht in den öffentlichen Spezifikationen): Mitgliedschaft/Kosten/Testverfahren für Service Provider,
Annahme von Peppol-Rechnungen durch Bundesbehörden (Anbindung über Peppol statt ZRE/OZG-RE), steuerliche Behandlung.
Diese Punkte klärt E18-01 bzw. die Steuerberatung.

## Phasen

Nicht Teil des MVP. [E18](epics/E18-peppol-anbindung.md) folgt in Phase 2 nach E05, E07, E08 und E12; die
Transport-Abstraktion wird früh in E05-08 vorbereitet, damit ActivityPub nicht fest verdrahtet wird.

## Offene Punkte

Siehe [decisions.md](decisions.md): Betriebsmodell (A/B), UBL-Erzeugung (R12), Open-Source-Validator, Zielmärkte außer Deutschland.
