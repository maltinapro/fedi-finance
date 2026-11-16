# E07 – Belege & PDF-Erzeugung mit PDFCraft, E-Rechnung

**Phase:** 1 · **Abhängig von:** E01, E03 (E07-01…03, E07-05); E04, E06 (übrige) · **Status:** offen

## Ziel
FediFinance erzeugt alle Geschäftsdokumente über die REST-API von [PDFCraft](https://github.com/maltinapro/pdfcraft)
(`/v1`) und **speichert** sie; PDFCraft bleibt zustandslose Render-Engine. Belege werden im Papier-Editor aus
PDFCraft bearbeitet (vier Zonen, Live-Vorschau), mit einem der PDF-Designs *Classic*, *Modern Minimal* oder
*Contrast* gestaltet und als PDF/A-3b mit eingebetteter E-Rechnung (EN 16931 / XRechnung) festgeschrieben.

## Kontext / Links
[pdfcraft.md](../pdfcraft.md) (Funktionsumfang, Architektur, Anforderungen R1–R11), [design.md](../design.md),
[compliance.md](../compliance.md) (E-Rechnung), PDFCraft:
[API-Referenz](https://github.com/maltinapro/pdfcraft/blob/main/docs/09-api-reference.md),
[OpenAPI](https://github.com/maltinapro/pdfcraft/blob/main/docs/openapi.yaml),
[Design-Guide](https://github.com/maltinapro/pdfcraft/blob/main/docs/16-design-guide.md).

## Definition of Done
- Rechnung wird im Belegeditor erstellt; die Vorschau läuft über das FediFinance-Backend (kein PDFCraft-Token im Browser).
- Bei Freigabe wird einmal final gerendert; PDF, XML und Render-Snapshot liegen unveränderlich im Archiv (E08).
- Alle sechs PDFCraft-Belegarten und alle drei Designs werden unterstützt; die PDFCraft-Version ist gepinnt und per Contract-Test abgesichert.

## Issues
- [ ] **E07-01 Anbindung festlegen** – PDFCraft-Version (Image `ghcr.io/maltinapro/pdfcraft-backend:<tag>`), Deployment-Variante (geteilt vs. je Mandant), Token-Konzept (Token je Mandant als Secret), Valkey, Editor-Strategie (Paket vs. Portierung, pdfcraft.md Abschnitt 6). AK: ADR in decisions.md; PDFCraft läuft in der Dev-Umgebung (E00-04).
- [ ] **E07-02 PDFCraft-Client (Rust)** – Typen aus dem gepinnten `openapi.yaml` (generiert oder handgeschrieben + Abgleichtest), Timeouts, Retry nach `Retry-After` bei `429`/`503`, Fehlerabbildung (`400`-Feldpfade → FediFinance-Felder), Metriken, Token aus Secret. AK: Contract-Test gegen das gepinnte PDFCraft-Image in CI.
- [ ] **E07-03 Erscheinungsbild (Briefpapier)** – Unternehmensweite Einstellungen = PDFCraft-Zone 1: Design (`classic`, `modern-minimal`, `contrast`), Akzentfarbe, Schrift, Logo, Unterschriftsbild, Einleitungs-/Schluss-/Fußtext, E-Rechnungsprofil; versioniert in der DB (E04-01); Design-Auswahl mit Vorschaubildern und Kurzbeschreibung wie in PDFCraft. AK: Änderung wirkt nur auf neue Belege; Rolle „Unternehmen verwalten" nötig.
- [ ] **E07-04 Mapping Belegmodell → PDFCraft** – Rechnung → `POST /v1/invoices` (`{ settings, invoice }`), übrige Arten → `POST /v1/documents` (`{ type, settings, document }`); Dezimalbeträge, Steuerfälle (Regelsteuer, steuerfrei mit Grund, Kleinunternehmer, Reverse Charge), Leistungsdatum/-zeitraum, Fälligkeit, Käuferreferenz/Leitweg-ID, Bezug Gutschrift → Rechnung. Einzige Stelle, die PDFCraft-JSON kennt. AK: Golden-Tests je Belegart und Steuerfall.
- [ ] **E07-05 Vorschau-Proxy** – Backend-Endpunkt für Entwurfsvorschauen: ruft PDFCraft mit `?zones=1`, reicht PDF und `X-Pdfcraft-Zones` durch, speichert nichts, Rate-Limit je Benutzer; Wasserzeichen „Entwurf" (R2). AK: kein PDFCraft-Token im Browser; Test, dass nichts persistiert wird.
- [ ] **E07-06 Belegeditor (Frontend)** – Papier-Editor aus PDFCraft nach [design.md](../design.md) 2.3: Zonen, Stepper, Zonen-Overlay auf der pdf.js-Vorschau, Splitter (≥ 840 px), Formular/Vorschau-Tabs (kompakt), Positionskarten, Hinweisliste; Entwürfe serverseitig, Partner-/Artikel-Picker (E04), Primäraktion *Freigeben*. Umsetzung als PDFCraft-Paket (R8) oder Portierung mit Herkunftsvermerk (E07-01). AK: alle Belegarten; Screenshot-Matrix (E03-08); Tastatur- und Screenreader-Bedienung.
- [ ] **E07-07 Freigabe & finale Erzeugung** – Bei Freigabe (E06-06): Nummer vergeben (E06-04), final ohne Wasserzeichen rendern, eingebettetes XML extrahieren, PDF + XML + Render-Snapshot (Request ohne Bilddaten, PDFCraft-Version, Design, SHA-256) über E08-01 ablegen – in einer Transaktion, bei Fehler Rollback ohne Nummernlücke. AK: festgeschriebene Belege werden nie neu gerendert (Test); Fehlerfall getestet.
- [ ] **E07-08 E-Rechnung (ZUGFeRD/Factur-X, XRechnung)** – Profil je Partner/Beleg (EN 16931 oder XRechnung, z. B. bei Leitweg-ID), XML wird von PDFCraft erzeugt und eingebettet; Freigabe wird blockiert, wenn PDFCraft `invoice-draft.xml` einbettet; XML separat als maßgebliches Dokument archiviert. AK: Mustang/KoSIT-Validierung eines eigenen Korpus in CI.
- [ ] **E07-09 Weitere Belegarten** – Gutschrift/Stornorechnung, Angebot, Auftragsbestätigung, Lieferschein, Brief über `/v1/documents`; Mahnung zunächst als Brief (R5); Berichte (Journal, Saldenliste, BWA) und Verfahrensdokumentation (E08-08) über PDFCraft (R6) oder eigene Vorlage – Entscheidung im Issue. AK: je Belegart ein Golden-Test.
- [ ] **E07-10 E-Rechnung empfangen** – Upload/Föderation: XML aus PDF/A-3 extrahieren, CII/UBL parsen, Plausibilitätsprüfung (Summen, Pflichtfelder) serverseitig (Rust oder PDFCraft-Endpunkt R7); Anzeige mit dem E-Rechnungs-Viewer aus PDFCraft (`lib/einvoice/`); Eingangsrechnung als Entwurf (E06-07). AK: PDFCraft-Testkorpus (`lib/einvoice/testdata`) wird korrekt gelesen.
- [ ] **E07-11 Deterministische Erzeugung** – Gleicher Snapshot + gleiche PDFCraft-Version = identische Bytes (Dokumentdatum aus Belegdatum, keine Zeitstempel); Ergebnis upstream absichern (R4). AK: Test in CI.
- [ ] **E07-12 Versand** – Download, E-Mail (SMTP), Föderation (E05-08); optional später Briefversand mit Internetmarke über PDFCraft `/v1/postage`, sobald dort gegen die Live-API verifiziert. AK: Versandprotokoll.
- [ ] **E07-13 Massenerzeugung & Last** – Bulk-Endpunkte (ZIP) über Hintergrundjobs (E01-08), `bulkMax` aus `GET /v1/token`, Rate-Limit beachten. AK: Lasttest (z. B. 1.000 Rechnungen) ohne Fehler.
- [ ] **E07-14 Anforderungen an PDFCraft** – Issues R1–R11 aus [pdfcraft.md](../pdfcraft.md#7-anforderungen-an-pdfcraft-upstream) im PDFCraft-Repo anlegen, Status dort pflegen. AK: Issues verlinkt.

## Offene Fragen
Deployment-Variante und Editor-Strategie (pdfcraft.md Abschnitt 8), Berichte (R6).
