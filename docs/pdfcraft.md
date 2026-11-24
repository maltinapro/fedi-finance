# PDFCraft-Integration

FediFinance erzeugt **alle** PDFs mit [PDFCraft](https://github.com/maltinapro/pdfcraft) und übernimmt dessen
Gestaltung (Material Design 3, siehe [design.md](design.md)). PDFCraft bleibt eine **zustandslose Render-Engine**:
es speichert keine Kunden- oder Belegdaten. Speichern, Nummerieren, Festschreiben, Archivieren, Versenden und Buchen
übernimmt FediFinance.

Geprüfter Stand: PDFCraft-Release `v0.34.0` (`c6f3f1f`, 22.11.2026; enthält R1–R11, npm-Pakete veröffentlicht, siehe
[Abschnitt 7](#7-anforderungen-an-pdfcraft-upstream)). Bei neuen PDFCraft-Versionen diesen Abschnitt und die
Anforderungsliste ([Abschnitt 7](#7-anforderungen-an-pdfcraft-upstream)) aktualisieren.

## 1. Was PDFCraft heute kann

| Bereich | Funktion (PDFCraft) | Nutzen für FediFinance |
| --- | --- | --- |
| Belegarten | Rechnung, Gutschrift/Stornorechnung, Angebot, Auftragsbestätigung, Lieferschein, Brief (DIN 5008 Form B); nur per API: Mahnung (`dunning`, Stufe 1–3, Gebühren, Verzugszinsen nach § 288 BGB übergeben oder aus der Basiszinstabelle berechnet) und Bericht (`report`, Tabellen mit Spaltentypen, Gruppen-/Gesamtsummen, Querformat, „Seite x von y", max. 10 000 Zeilen) | Ausgangsbelege, Vorgangskette, Mahnwesen (E09) und Auswertungen ohne eigene Vorlagen |
| PDF-Designs | *Classic* (sachlich), *Modern Minimal* (luftig, Infoblock rechts neben dem Anschriftfeld, große Zahlbetrag-Zeile), *Contrast* (Akzent-Kopfband, Akzent-Tabellenkopf, Summenbox); gemeinsames Layoutmodul `layout.typ` mit Design-Tokens; DIN-Positionen in allen Designs gleich | Design-Auswahl im Erscheinungsbild des Unternehmens |
| Gestaltung | Logo, Unterschriftsbild, Akzentfarbe (Kontrastprüfung), Schriftart, Einleitungs-/Schluss-/Fußtext, Wasserzeichen „Entwurf" (je Request per `options.watermark: "draft"`), strukturierter Fuß (`settings.footerMode: "structured"`: Kontakt, Rechtsform/Sitz/Registergericht/-nummer/Geschäftsführung/AR-Vorsitz, Bank und Steuerdaten) | Briefpapier je Mandant, Pflichtangaben aus Stammdaten |
| E-Rechnung | PDF/A-3b mit eingebettetem XML (EN 16931 CII oder XRechnung), Factur-X-XMP; Korpus in der PDFCraft-CI mit Mustang validiert; bei Lücken wird `invoice-draft.xml` eingebettet | ZUGFeRD/XRechnung ohne eigene XML-Erzeugung |
| API | REST `/v1`: `POST /v1/invoices`, `/v1/documents`, `/v1/invoices/bulk`, `/v1/documents/bulk` (ZIP), `POST /v1/einvoices/parse` (E-Rechnung lesen + Plausibilitätsprüfung, zustandslos), `GET /v1/token`, `GET /v1/version` (Version, Commit, Typst, Template-Hashes je Belegart; Header `X-Pdfcraft-Version` an jeder Antwort), `GET /health`; OpenAPI 3.1 (`docs/openapi.yaml`, aus dem Code generiert) | Typsicherer Client, Contract-Tests, Render-Snapshot |
| Tokens | Paid-/Free-Tokens in Valkey; statische Dienst-Tokens (`SERVICE_TOKENS`/`SERVICE_TOKENS_FILE`, SHA-256-Hashes, ohne Ablauf, `tokens create-service`), ohne Valkey mit Rate-Limit je Instanz | Ein Token je Mandant ohne Rotation und ggf. ohne Valkey |
| Reproduzierbarkeit | Byte-identische PDFs bei gleicher Eingabe und gleichem Build, abgesichert durch Tests über alle Belegarten × Designs (auch prozessübergreifend); Grenzen (Version, Typst, Schriften, Plattform) in `docs/09-api-reference.md` | Hash-Prüfung und Neu-Rendern aus dem Snapshot (E07-11) |
| Vorschau | `?zones=1` liefert im Header `X-Pdfcraft-Zones` die Geometrie der Zonen 3/4 (mm, Seite) für die klickbare Vorschau | Papier-Editor mit Zonen-Overlay |
| Leistung | typ. 5–12 ms je Rechnung (3 Positionen), Compile-Queue mit Lastabwurf (`503 server_busy` + `Retry-After`), Rate-Limit je Token (`429` + `Retry-After`) | Synchrone Vorschau, Bulk über Jobs |
| Frontend | React 19 + Vite + TS, ohne UI-Bibliothek; Design-System als Paket `@maltinapro/pdfcraft-design` (`frontend/packages/design`: `tokens.css` + Kontrasttest, `ui.css`, `ui`-Komponenten, Icons, `theme.ts`, Changelog), Inter (self-hosted), Hell/Dunkel/System, hoher Kontrast, `tr(de, en)` | Basis des FediFinance-Frontends ([Abschnitt 6](#6-frontend-strategie)) |
| Editor | Papier-Editor als Paket `@maltinapro/pdfcraft-editor` (`frontend/packages/editor`, `PaperEditor` mit Adapter: `render` Pflicht, Kunden/Artikel/Porto/XML optional; Dokument und Einstellungen als Props) mit vier Zonen (Absender & Aussehen, Empfänger, Details, Positionen), Stepper, Klick auf das PDF öffnet die Felder, Splitter (Desktop) bzw. Formular/Vorschau-Tabs (mobil), Positionskarten mit Zeilensumme, Hinweisliste | Belegeditor (E07-06) |
| Weitere | Stammdaten Kunden/Artikel, Belegarchiv mit ZIP-Download und Folgebelegen, E-Rechnungs-Viewer und Plausibilitätsprüfung (CII/UBL, im Browser und per `/v1/einvoices/parse`, Parität über Golden-Tests), Leistungsdatum/-zeitraum und Fälligkeit, Internetmarke (optional, standardmäßig aus), Prometheus-Metriken + Grafana-Dashboards, Helm-Chart mit `values-production.yaml` (nur `/v1`, HPA, PDB, NetworkPolicy, ServiceMonitor, OCI `oci://ghcr.io/maltinapro/charts/pdfcraft`) | Vorbild für Stammdaten, Archiv, Eingangsrechnungen, Betrieb |
| Nicht vorhanden | Serverseitige Speicherung (alles liegt im Browser bzw. in einer JSON-Sicherung), Benutzer/Rollen, Nummernkreise, Buchhaltung, Mahnlauf/offene Posten; Mahnung und Bericht nur per API (kein Editor) | → Aufgabe von FediFinance bzw. Anforderungen (Abschnitt 7) |

Lizenz: MIT (Vendored Typst-Pakete mit eigenen Lizenzen) – Übernahme von Code ist erlaubt; Herkunft vermerken.

## 2. Aufgabenteilung

| Aufgabe | PDFCraft | FediFinance |
| --- | --- | --- |
| PDF/A-3b rendern, Designs, DIN 5008 | ✔ | – |
| E-Rechnungs-XML erzeugen und einbetten | ✔ | prüft vor Freigabe, archiviert XML separat |
| Eingaben validieren (Längen, Formate, Pflichtfelder für XML) | ✔ (Request-Validierung) | ✔ (fachlich: § 14 UStG, Nummernkreise, Steuerfälle) |
| Unternehmensdaten, Erscheinungsbild, Partner, Artikel | – (nur im Browser) | ✔ PostgreSQL, versioniert |
| Entwürfe, Belegnummern, Freigabe, Festschreibung | – | ✔ |
| PDF/XML speichern, Hash, Aufbewahrung | – | ✔ (E08) |
| Versand (Download, E-Mail, Föderation) | – | ✔ (E07-12, E05-08) |
| Benutzer, Rollen, Audit-Log | – | ✔ (E02, E01-07) |
| Sicherung | Browser-JSON-Datei | Server-Backups + Export (E13); Import der PDFCraft-Sicherung (E04-11) |

## 3. Integrationsarchitektur

```
Browser (FediFinance-Frontend, Belegeditor)
   │  OIDC-Session, kein PDFCraft-Token im Browser
   ▼
FediFinance-Backend (Rust)
   ├─ Mapping Belegmodell → PDFCraft-JSON  { settings, invoice } bzw. { type, settings, document }
   ├─ PDFCraft-Client (Bearer-Token aus Secret, Timeout, Retry nach Retry-After)
   │      │  REST /v1 (cluster-intern)
   │      ▼
   │   PDFCraft-Backend (zustandslos) ── Valkey (nur Token-Hash + Rate-Limit)
   │
   ├─ Vorschau: PDF + X-Pdfcraft-Zones durchreichen, nichts speichern
   └─ Freigabe: finales PDF → Dokumentenspeicher (SHA-256) + XML + Render-Snapshot → Buchung
```

### Abläufe

1. **Vorschau (Entwurf):** Frontend sendet den Entwurf an `POST /api/v1/documents/{id}/preview` (Name vorläufig).
   Das Backend mappt, ruft PDFCraft mit `?zones=1` auf und gibt PDF und Zonen-Header zurück. Nicht gespeichert,
   nicht protokolliert (nur Metriken). Vorschauen tragen „Entwurf" (`options.watermark: "draft"`, R2).
2. **Freigabe:** Belegnummer wird lückenlos vergeben (E06-04), das Backend rendert **einmal** final, extrahiert das
   eingebettete XML, prüft, dass es nicht `invoice-draft.xml` ist (sonst Abbruch), und legt PDF, XML und
   **Render-Snapshot** unveränderlich ab (E08-01). Danach wird der Beleg nie neu gerendert; Korrektur nur per
   Storno/Gutschrift.
3. **Massenerzeugung:** Hintergrundjob (E01-08) nutzt die Bulk-Endpunkte (ZIP), beachtet `bulkMax` aus
   `GET /v1/token` und das Rate-Limit.
4. **Empfang:** Eingehende ZUGFeRD/XRechnung-Dateien werden serverseitig geparst (E07-10, bevorzugt über
   `POST /v1/einvoices/parse`, R7); die Anzeige im UI nutzt den Viewer-Code von PDFCraft.

### Render-Snapshot

Zu jedem festgeschriebenen PDF speichert FediFinance: Request-JSON an PDFCraft (inkl. Design, Akzentfarbe, Schrift,
Texte; Logo/Unterschrift als Hash-Referenz statt Base64-Kopie), PDFCraft-Version (`X-Pdfcraft-Version`, Commit und
Template-Hash der Belegart aus `GET /v1/version`, R3; zusätzlich Image-Digest), Endpunkt,
Zeitpunkt, SHA-256 von PDF und XML. Damit ist nachvollziehbar, wie der Beleg entstanden ist; Designänderungen
wirken nur auf neue Belege.

### Fehlerbehandlung

| PDFCraft-Antwort | FediFinance |
| --- | --- |
| `400` mit Feldpfaden | in API-Fehler mit FediFinance-Feldnamen übersetzen, im Editor am Feld anzeigen |
| `401` | Betriebsalarm (Token ungültig/abgelaufen), Nutzer sieht „PDF-Dienst nicht verfügbar" |
| `429` / `503` + `Retry-After` | Vorschau: einmal warten und erneut; Jobs: Backoff |
| Timeout / Netzwerk | Vorschau: „Keine Verbindung zum PDF-Dienst – wird erneut versucht"; Freigabe: abbrechen, nichts vergeben |

Die Belegnummer wird in derselben Transaktion vergeben, in der das finale PDF abgelegt wird; schlägt das Rendern
fehl, wird zurückgerollt (keine Lücke, kein Beleg ohne PDF). Details in E06-04/E07-07.

## 4. Betrieb

- **Image:** `ghcr.io/maltinapro/pdfcraft-backend:<version>` (Release-Workflow von PDFCraft), Version im
  FediFinance-Chart gepinnt (Dev-Umgebung: `deploy/dev/compose.yaml`, derzeit `0.34.0`); Upgrade nur mit grünem Contract-Test (E07-02).
- **Frontend-Pakete:** `@maltinapro/pdfcraft-design` und `@maltinapro/pdfcraft-editor` liegen öffentlich in GitHub
  Packages (`https://npm.pkg.github.com`). Für die Installation (lokal, CI, Renovate) braucht npm trotzdem ein Token mit
  `read:packages` (klassisches PAT; in GitHub Actions `GITHUB_TOKEN`, wenn das Paket dem Repo Lesezugriff gibt):
  `.npmrc` mit `@maltinapro:registry=https://npm.pkg.github.com` und
  `//npm.pkg.github.com/:_authToken=${NODE_AUTH_TOKEN}`. Die Pakete enthalten TypeScript-Quellen (Vite kompiliert sie).
- **Valkey:** Paid-/Free-Tokens und das gemeinsame Rate-Limit brauchen Valkey (Token-Hashes, Rate-Limit; keine
  Kundendaten). Mit statischen Dienst-Tokens (R1) läuft `/v1` auch ohne Valkey; das Rate-Limit gilt dann je Replika.
- **Token:** je Mandant ein statisches Dienst-Token ohne Ablauf und ohne Wasserzeichen
  (`pdfcraft-backend tokens create-service <mandant> --limit <n>`); PDFCraft erhält nur den SHA-256-Hash über
  `SERVICE_TOKENS_FILE` (Chart: `backend.serviceTokensSecret`), FediFinance das Klartext-Token als Kubernetes-Secret
  (Provisioning E12-07). Mollie/Kauf/Anubis bleiben aus. Die Dev-Umgebung nutzt noch ein Paid-Token
  (`tokens create --plan starter --days 365`, `PAID_TOKENS_ENABLED=true`); Umstellung auf Dienst-Tokens mit E07-02/E12-07.
- **Deployment-Varianten** (Entscheidung in E07-01/E12-12):

| Variante | Vorteile | Nachteile |
| --- | --- | --- |
| **Geteilt** (Namespace `pdfcraft`, ein Token je Mandant) – *Vorschlag Standard* | ein Deployment + ein Valkey für alle; PDFCraft speichert nichts, passt zur Regel „geteilte Ressourcen, getrennte Daten" | Belegdaten passieren einen gemeinsamen Prozess (nur im Speicher); NetworkPolicy-Egress zum Namespace nötig; ein Upgrade betrifft alle |
| **Je Mandant** (im Namespace `tenant-<id>`) | strikte Isolation, Version je Mandant | Pod + Valkey je Mandant (Ressourcen, Betrieb) |

  Das Chart unterstützt beides: `pdfcraft.enabled=true` (im Namespace) oder `pdfcraft.url` (extern/geteilt). Für
  beide Varianten kann das PDFCraft-Chart (OCI, `values-production.yaml`, `fullnameOverride`; R11) genutzt werden.
- **Netzwerk:** PDFCraft ist nur cluster-intern erreichbar (kein Ingress), `CORS_ALLOWED_ORIGINS` leer/strikt,
  `METRICS_ADDR` nur für Prometheus.
- **Observability:** PDFCraft liefert `/metrics` und Grafana-Dashboards (`deploy/helm/pdfcraft/dashboards/`), die
  übernommen werden (E17).

## 5. Datenmodell-Abgleich

- Erscheinungsbild des Unternehmens = PDFCraft-Zone 1 *Absender & Aussehen*: `design`, Akzentfarbe, Schrift, Logo,
  Unterschrift, Texte, E-Rechnungsprofil (E07-03, E04-01).
- Partner = Empfängerzone: Name, Anschrift, E-Mail, USt-IdNr., Käuferreferenz/Leitweg-ID (E04-03).
- Artikel = PDFCraft-Artikelstamm: Bezeichnung, Einheit, Preis, Steuersatz (E04-10).
- Belege: Nummer, Datum, Leistungsdatum/-zeitraum, Fälligkeit, Bezüge (Gutschrift → Rechnung), Positionen.
  Beträge in FediFinance dezimal; das Mapping (E07-04) ist die einzige Stelle, die PDFCraft-JSON kennt.
- Die PDFCraft-Sicherung (`pdfcraft-backup-<datum>.json`, `backupVersion` 2: Konfiguration, Entwürfe, Archiv,
  Kunden, Artikel) kann importiert werden – Umstieg von PDFCraft auf FediFinance (E04-11).

## 6. Frontend-Strategie

Frage: PDFCraft-Frontend kopieren oder neu schreiben?

| Option | Bewertung |
| --- | --- |
| A. Ganzes PDFCraft-Frontend kopieren (Fork) | **Nein.** Etwa die Hälfte ist PDFCraft-spezifisch (localStorage-Persistenz, Browser-Sicherung, Free-Token/Anubis, Kaufseite, Landing-/SEO-Seiten); zwei auseinanderlaufende Kopien des Editors. |
| B. PDFCraft-App einbetten (iframe/Link) | **Nein.** Eigene Anmeldung, Daten im Browser statt in FediFinance, kein GoBD-Ablauf, uneinheitliche Bedienung. |
| C. Gemeinsame Pakete aus PDFCraft (`ui`: Tokens, Komponenten, Icons; `editor`: Papier-Editor mit austauschbarer Datenquelle) | **Ziel, jetzt verfügbar.** Beide Produkte profitieren von Fixes; PDFCraft veröffentlicht `@maltinapro/pdfcraft-design` 0.1.0 und `@maltinapro/pdfcraft-editor` 0.2.0 in GitHub Packages und nutzt sie selbst. |
| D. Neues FediFinance-Frontend mit gleichem Stack, Design-Fundament übernommen, Editor portiert | **Start.** Sofort machbar, volle Freiheit für Buchhaltungsseiten. |

**Empfehlung (D → C):**

1. **E03 – Design-Fundament übernehmen:** Seit PDFCraft `v0.34.0` bevorzugt als Abhängigkeit
   `@maltinapro/pdfcraft-design` (Tokens + Kontrasttest, `ui`-Komponenten, `ui.css`, Icons, `theme.ts`; Updates per
   Renovate). Fallback: Kopie aus einem gepinnten PDFCraft-Commit nach `frontend/src/design/` (Herkunft in
   `UPSTREAM.md`, Drift-Check in CI, E03-10). Entscheidung in E03-10.
2. **E03 – Shell und Seiten neu:** App-Shell, Navigation, Tabellen, Buchhaltungsseiten, Auth und Rollen sind
   FediFinance-spezifisch und werden nach [design.md](design.md) neu gebaut – mit denselben Komponenten.
3. **E07 – Editor:** Bevorzugt `@maltinapro/pdfcraft-editor` (R8): `PaperEditor` mit Adapter (`render(request, signal)
   → { blob, zones }` Pflicht; Kunden/Artikel als `EntrySource`, Porto, XML-Extraktion optional), Dokument und
   Einstellungen als Props; PDFCraft nutzt es mit localStorage, FediFinance mit seiner API (`render` über den
   Vorschau-Proxy E07-05). Fallback: Portierung mit Herkunftsvermerk. Entscheidung in E07-01.
4. Ebenfalls übernehmbar: E-Rechnungs-Viewer (`lib/einvoice/`: Extraktion, CII/UBL-Parser, Plausibilitätsprüfung),
   `validate.ts`-Logik (als Vorab-Hinweise), Screenshot-Skript (Playwright-Matrix).

Werkzeuge im Frontend wie in PDFCraft (npm, Vite, Vitest, oxlint, TypeScript), damit Code ohne Anpassung läuft (E00-03).

## 7. Anforderungen an PDFCraft (upstream)

Angelegt als Issues in `maltinapro/pdfcraft` (Label `enhancement`, 11/2026, E07-14); Status hier pflegen.

Stand 22.11.2026: **alle Anforderungen umgesetzt und released** (PRs [pdfcraft#230](https://github.com/maltinapro/pdfcraft/pull/230)–[pdfcraft#240](https://github.com/maltinapro/pdfcraft/pull/240); Release [`v0.33.0`](https://github.com/maltinapro/pdfcraft/releases/tag/v0.33.0) bzw. aktuell
[`v0.34.0`](https://github.com/maltinapro/pdfcraft/releases/tag/v0.34.0), [pdfcraft#244](https://github.com/maltinapro/pdfcraft/issues/244)). Image `ghcr.io/maltinapro/pdfcraft-backend:0.34.0`
(amd64 + arm64), OCI-Chart `oci://ghcr.io/maltinapro/charts/pdfcraft` `0.34.0` und die npm-Pakete
`@maltinapro/pdfcraft-design` 0.1.0 / `@maltinapro/pdfcraft-editor` 0.2.0 ([pdfcraft#243](https://github.com/maltinapro/pdfcraft/issues/243)) sind veröffentlicht.
Geprüft mit einem Smoke-Test des Release-Images (Dienst-Token ohne Valkey, `/v1/version`, `X-Pdfcraft-Version`,
„Entwurf", strukturierter Fuß, `dunning`, `report`, `/v1/einvoices/parse`, gleiche Bytes nach Neustart) und
`make dev-check` mit `0.34.0`. Kleinere Nacharbeiten (Paket-Tags, Testdateien im Editor-Paket, Release-Notes 0.34.0):
[pdfcraft#251](https://github.com/maltinapro/pdfcraft/issues/251). Die Spalte „Ersatz bis dahin" ist nur noch Fallback.

| ID | Anforderung | Warum | Ersatz bis dahin | Issue | Status / Umsetzung |
| --- | --- | --- | --- | --- | --- |
| R1 | Statische Dienst-Tokens (z. B. gehashte Tokens aus Env/Secret, ohne Ablauf; optional ohne Valkey) | Betrieb je Mandant ohne Token-Ablauf und ggf. ohne Valkey | Paid-Token mit langer Laufzeit + Rotation | [pdfcraft#214](https://github.com/maltinapro/pdfcraft/issues/214) | ✔ [pdfcraft#230](https://github.com/maltinapro/pdfcraft/pull/230): `SERVICE_TOKENS`/`SERVICE_TOKENS_FILE` (`<id>:<sha256>:<plan oder limit>`), `tokens create-service`; ohne Valkey Rate-Limit je Replika |
| R2 | Wasserzeichen „Entwurf" je Request steuerbar (auch für Paid-Tokens) | Vorschau unfreigegebener Belege eindeutig kennzeichnen | zweites Free-Token nur für Vorschauen (unschön) | [pdfcraft#215](https://github.com/maltinapro/pdfcraft/issues/215) | ✔ [pdfcraft#231](https://github.com/maltinapro/pdfcraft/pull/231): `options.watermark: "draft"` im Body aller vier POST-Endpunkte |
| R3 | Versionsauskunft (`GET /version` bzw. Header mit App- und Template-Version) | Render-Snapshot, Nachvollziehbarkeit | Image-Digest aus der Konfiguration | [pdfcraft#216](https://github.com/maltinapro/pdfcraft/issues/216) | ✔ [pdfcraft#232](https://github.com/maltinapro/pdfcraft/pull/232): `GET /v1/version` (ohne Token): Version, Commit, Typst, `templateHash`, `templates.<typ>`; Header `X-Pdfcraft-Version` an jeder Antwort |
| R4 | Garantiert deterministische Ausgabe (gleiche Eingabe + Version → gleiche Bytes) inkl. Test | Hash-Prüfung, Reproduzierbarkeit (E07-11) | eigener Test in FediFinance | [pdfcraft#217](https://github.com/maltinapro/pdfcraft/issues/217) | ✔ [pdfcraft#233](https://github.com/maltinapro/pdfcraft/pull/233): Tests über alle Belegarten × Designs, auch prozessübergreifend; nur linux/amd64 geprüft; Grenzen in `docs/09-api-reference.md` |
| R5 | Belegart Mahnung (Bezug auf offene Rechnungen, Gebühren, Zinsen) | Mahnwesen (E09) | Brief-Belegart mit Text | [pdfcraft#218](https://github.com/maltinapro/pdfcraft/issues/218) | ✔ [pdfcraft#234](https://github.com/maltinapro/pdfcraft/pull/234): `type: "dunning"`; Zinsen übergeben oder nach § 288 BGB aus der Basiszinstabelle berechnet (Anhang `dunning-interest.json`); nur API |
| R6 | Berichts-/Tabellendokument (Journal, Summen-/Saldenliste, BWA, Verfahrensdokumentation, Prüfer-Export-Deckblatt) | Auswertungen als PDF | eigene Typst-Vorlage in FediFinance prüfen | [pdfcraft#219](https://github.com/maltinapro/pdfcraft/issues/219) | ✔ [pdfcraft#235](https://github.com/maltinapro/pdfcraft/pull/235): `type: "report"`; max. 20 Tabellen, 12 Spalten, 10 000 Zeilen (längere Journale aufteilen); Gruppenüberschrift kann allein am Seitenende stehen |
| R7 | Zustandsloser Endpunkt „E-Rechnung parsen/prüfen" (PDF/XML → normalisiertes JSON + Prüfergebnis) | Eingangsrechnungen serverseitig mit derselben Logik wie der Viewer | eigener Rust-Parser (E07-10) | [pdfcraft#220](https://github.com/maltinapro/pdfcraft/issues/220) | ✔ [pdfcraft#236](https://github.com/maltinapro/pdfcraft/pull/236): `POST /v1/einvoices/parse` (PDF ≤ 20 MB, XML ≤ 5 MB), Parität zum Viewer über Golden-Tests; Plausibilitätsprüfung, keine XSD-/Schematron-Validierung |
| R8 | Papier-Editor als Paket mit austauschbarer Datenquelle | Frontend-Strategie C | Portierung mit Herkunftsvermerk | [pdfcraft#221](https://github.com/maltinapro/pdfcraft/issues/221) | ✔ [pdfcraft#237](https://github.com/maltinapro/pdfcraft/pull/237): `@maltinapro/pdfcraft-editor` 0.2.0 (nur TS-Quellen, hängt von `pdfcraft-design` ab), Adapter dokumentiert, von PDFCraft selbst genutzt; veröffentlicht in GitHub Packages ([pdfcraft#243](https://github.com/maltinapro/pdfcraft/issues/243)) |
| R9 | Design-System als Paket (Tokens, `ui`, Icons) | Drift vermeiden | Kopie + Drift-Check (E03-10) | [pdfcraft#222](https://github.com/maltinapro/pdfcraft/issues/222) | ✔ [pdfcraft#238](https://github.com/maltinapro/pdfcraft/pull/238): `@maltinapro/pdfcraft-design` 0.1.0 mit Changelog und Kontrasttest, von PDFCraft selbst genutzt; veröffentlicht in GitHub Packages ([pdfcraft#243](https://github.com/maltinapro/pdfcraft/issues/243)) |
| R10 | Strukturierter Fuß (Kontakt / Bank / Steuer- und Registerdaten) über die API (PDFCraft E11-05) | Pflichtangaben auf Geschäftsbriefen (§ 37a HGB, § 35a GmbHG) aus Stammdaten | freier Fußtext aus Stammdaten generiert | [pdfcraft#223](https://github.com/maltinapro/pdfcraft/issues/223) | ✔ [pdfcraft#239](https://github.com/maltinapro/pdfcraft/pull/239): `settings.footerMode: "structured"` + `sender.legalForm`, `registeredOffice`, `registerCourt`, `registerNumber`, `managingDirectors`, `supervisoryBoardChair`; Beschriftungen rechtlich ungeprüft ([#45](https://github.com/maltinapro/fedi-finance/issues/45)) |
| R11 | Produktions-Helm-Chart oder Chart-Bausteine | Einbindung in das FediFinance-Chart | eigene Templates im FediFinance-Chart | [pdfcraft#224](https://github.com/maltinapro/pdfcraft/issues/224) | ✔ [pdfcraft#240](https://github.com/maltinapro/pdfcraft/pull/240): `values-production.yaml` (nur `/v1`, HPA, PDB, NetworkPolicy, ServiceMonitor, bestehende Secrets), `fullnameOverride`; OCI-Chart ab `0.33.0` |
| R12 | E-Rechnung wahlweise als **UBL 2.1** (Peppol BIS Billing 3.0 / XRechnung UBL) statt CII, inkl. Gutschrift | Peppol schreibt UBL vor, CII nur bei Registrierung des Empfängers im SMP ([peppol.md](peppol.md)); PDFCraft erzeugt bisher CII | Konvertierung CII → UBL im Gateway (verlustbehaftet, nicht bevorzugt) | noch nicht angelegt (Vorschlag, E18-04) | offen |

## 8. Offene Punkte

- Geteiltes oder mandanteneigenes PDFCraft-Deployment (Abschnitt 4) – Vorschlag: geteilt.
- Editor-Paket (C) vs. Portierung (D) für den Editor – Entscheidung in E07-01; `@maltinapro/pdfcraft-editor` ist
  veröffentlicht, Empfehlung: Paket (Adapter bisher nur von PDFCraft selbst genutzt).
- Berichte (R6) in PDFCraft oder eigene Vorlagen – Entscheidung in E07-09; PDFCraft bietet `report` (max. 10 000 Zeilen).
- Dev-Umgebung auf Dienst-Tokens umstellen und PDFCraft-Chart (OCI) im FediFinance-Chart einbinden (E07-02, E12-07);
  Token für GitHub Packages in CI/Renovate bereitstellen, sobald das Frontend die Pakete nutzt (E03-10).
- Pflichtangaben auf Geschäftsbriefen und Rechnungen von Steuerberatung/Rechtsberatung prüfen lassen.
- UBL-Ausgabe für Peppol (R12) als Upstream-Issue anlegen, sobald E18-04 ansteht.
