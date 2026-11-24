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
- [ ] **E05-02 Vokabular-Spezifikation** – JSON-LD-Context, `ff:Company`, `ff:Invoice`, Status-Objekte, Versionierung; früh als offene Spezifikation veröffentlichen (Domain: decisions.md Nr. 9), damit Dritte (ERP-Hersteller, andere Open-Source-Buchhaltungen) andocken können ([market.md](../market.md#6-positionierungsvorschlag)). AK: Spezifikation in `docs/` + JSON-Schema, öffentlich abrufbar unter der Context-URL.
- [ ] **E05-03 Discovery** – WebFinger, NodeInfo, Actor-Dokument, Caching. AK: Interop-Test zwischen zwei Instanzen.
- [ ] **E05-04 Schlüsselverwaltung** – Schlüsselpaar je Instanz, Rotation, sichere Ablage. AK: Rotation getestet.
- [ ] **E05-05 Inbox/Outbox & Signaturen** – Signieren, Verifizieren, Replay-Schutz, Digest-Header. AK: Negativtests.
- [ ] **E05-06 Partner-Handshake** – Anfrage/Annahme/Ablehnung/Entfernen, Benachrichtigung im UI. AK: Zustandsautomat getestet.
- [ ] **E05-07 Stammdaten-Synchronisation** – Initialer Abruf, Updates per Activity (`Update`), Konfliktregeln. AK: Änderungen kommen an.
- [ ] **E05-08 Belegzustellung** – `ff:Invoice` senden/empfangen inkl. PDF/XML-Anhang, Prüfsummen, Statusrückmeldungen. AK: Eingangsrechnung entsteht als Entwurf beim Empfänger. Implementierung hinter einer Transport-Schnittstelle (`DocumentTransport`, siehe E18-02), damit weitere Kanäle (Peppol) ergänzt werden können.
- [ ] **E05-09 Zustellqueue & Zuverlässigkeit** – Retry/Backoff, Idempotenz, Dead-Letter, Monitoring. AK: Ausfalltest.
- [ ] **E05-10 Sicherheit** – SSRF-Schutz, Rate-Limits, Blocklist, Größenlimits, Domain-Verifikation. AK: Security-Tests.
- [ ] **E05-11 Interoperabilität & Fallback** – Partner ohne FediFinance: E-Mail/Download-Link, mit abschaltbarem Hinweis „Rechnungen direkt empfangen mit FediFinance“ (ohne Tracking-Pixel, datensparsam); Kennzahl je Instanz: Anteil föderierter Zustellungen. AK: Fallback-Flow, Hinweis je Mandant abschaltbar. Peppol als weiterer Kanal: [E18](E18-peppol-anbindung.md).
- [ ] **E05-12 Föderations-Testumgebung** – Docker-Compose mit 2–3 Instanzen für E2E. AK: E2E in CI.
- [ ] **E05-13 Demo-Szenario Unternehmensgruppe** – Auf Basis von E05-12: Holding + zwei Tochtergesellschaften mit Beispieldaten; gegenseitige Rechnungen, Empfangsbestätigung, Eingangsrechnung als Entwurf, Zahlungsbestätigung (`ff:InvoiceStatus`). Zeigt den Kern-USP ohne fremde Partner, für Demos und Pilotkunden ([market.md](../market.md#6-positionierungsvorschlag)). AK: Ein Befehl startet das Szenario; Ablauf dokumentiert.

## Offene Fragen
decisions.md Nr. 2, 9.
