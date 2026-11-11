# Föderation (ActivityPub)

## Ziel

Jede FediFinance-Instanz ist ein eigener ActivityPub-Server. Geschäftspartner werden über ihre Domain gefunden;
Stammdaten werden vom Partner-Server geladen, Belege werden direkt zwischen den Servern zugestellt.

Beispiel: Firma A fügt `f1.com` als Geschäftspartner hinzu → Discovery → Stammdaten (Firmenname, Adresse, USt-IdNr.,
Bankverbindung, Rechnungsadresse) werden abgerufen → A kann Rechnungen an F1 senden.

## Protokollbausteine

- **Discovery**: WebFinger (`/.well-known/webfinger`) und NodeInfo (`/.well-known/nodeinfo`) auf der Domain; Actor-Typ `Organization`.
- **Actor** je Unternehmen mit `inbox`, `outbox`, Public Key.
- **Authentifizierung**: HTTP Signatures (Draft-cavage bzw. RFC 9421), Schlüsselrotation, Domain-Validierung.
- **Zustellung**: Inbox/Outbox mit Queue, Retry/Backoff, Idempotenz (Activity-IDs), Dead-Letter.
- **Freigabe**: Verknüpfung als Beziehung mit Handshake (`Follow`/`Accept` oder eigener Partner-Request); erst nach Annahme
  werden nicht-öffentliche Stammdaten geteilt.

## Eigenes Vokabular (JSON-LD)

Eigener Context, z. B. `https://fedifinance.org/ns/v1`:

| Objekt | Zweck |
| --- | --- |
| `ff:Company` | Stammdaten (erweitert `Organization`) |
| `ff:Invoice` | Rechnung mit Positionen, Steuer, Zahlungsinformationen, Anhang/Link zum PDF (+ ZUGFeRD/XRechnung) |
| `ff:InvoiceStatus` | Empfangsbestätigung, Ablehnung, Zahlungsbestätigung |
| `ff:CreditNote`, `ff:Reminder`, `ff:Quote`, `ff:Order` | weitere Belegtypen (später) |

Das Vokabular wird versioniert und dokumentiert, damit auch Dritte kompatibel implementieren können.

## Sicherheit & Datenschutz

- Stammdaten haben Sichtbarkeitsstufen (öffentlich / nur Partner / nie).
- Belege werden nur an die ausdrücklich adressierte Instanz geliefert (keine öffentliche Timeline).
- Rate Limits, Domain-Blocklist, SSRF-Schutz beim Abruf fremder Server, Größenlimits.
- Die Zustellung ersetzt nicht die rechtlichen Anforderungen an die E-Rechnung: siehe [compliance.md](compliance.md).

## Offene Punkte

Siehe [decisions.md](decisions.md): Rust-ActivityPub-Bibliothek vs. Eigenbau, Signaturstandard, Domain des Vokabulars.
