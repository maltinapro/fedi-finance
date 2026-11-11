# E05 – Föderation mit ActivityPub

**Phase:** 1 · **Abhängig von:** E04 · **Status:** offen

## Ziel
Instanzen finden sich über die Domain, tauschen Stammdaten aus und übermitteln Belege (z. B. Rechnungen) sicher über ActivityPub.

## Kontext / Links
[federation.md](../federation.md)

## Definition of Done
- Zwei lokale Instanzen (Dev-Umgebung) verknüpfen sich per Domain, tauschen Stammdaten, Rechnung wird zugestellt und bestätigt.
- Vokabular dokumentiert und versioniert.

## Issues
- [ ] **E05-01 Spike & Entscheidung Bibliothek** – `activitypub_federation` (Rust) vs. Eigenbau, HTTP-Signatures-Standard. AK: ADR.
- [ ] **E05-02 Vokabular-Spezifikation** – JSON-LD-Context, `ff:Company`, `ff:Invoice`, Status-Objekte, Versionierung. AK: Spezifikation in `docs/` + JSON-Schema.
- [ ] **E05-03 Discovery** – WebFinger, NodeInfo, Actor-Dokument, Caching. AK: Interop-Test zwischen zwei Instanzen.
- [ ] **E05-04 Schlüsselverwaltung** – Schlüsselpaar je Instanz, Rotation, sichere Ablage. AK: Rotation getestet.
- [ ] **E05-05 Inbox/Outbox & Signaturen** – Signieren, Verifizieren, Replay-Schutz, Digest-Header. AK: Negativtests.
- [ ] **E05-06 Partner-Handshake** – Anfrage/Annahme/Ablehnung/Entfernen, Benachrichtigung im UI. AK: Zustandsautomat getestet.
- [ ] **E05-07 Stammdaten-Synchronisation** – Initialer Abruf, Updates per Activity (`Update`), Konfliktregeln. AK: Änderungen kommen an.
- [ ] **E05-08 Belegzustellung** – `ff:Invoice` senden/empfangen inkl. PDF/XML-Anhang, Prüfsummen, Statusrückmeldungen. AK: Eingangsrechnung entsteht als Entwurf beim Empfänger.
- [ ] **E05-09 Zustellqueue & Zuverlässigkeit** – Retry/Backoff, Idempotenz, Dead-Letter, Monitoring. AK: Ausfalltest.
- [ ] **E05-10 Sicherheit** – SSRF-Schutz, Rate-Limits, Blocklist, Größenlimits, Domain-Verifikation. AK: Security-Tests.
- [ ] **E05-11 Interoperabilität & Fallback** – Partner ohne FediFinance: E-Mail/Download-Link. AK: Fallback-Flow.
- [ ] **E05-12 Föderations-Testumgebung** – Docker-Compose mit 2–3 Instanzen für E2E. AK: E2E in CI.

## Offene Fragen
decisions.md Nr. 2, 9.
