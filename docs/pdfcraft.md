# PDFCraft-Integration

FediFinance erzeugt **alle** PDFs mit [PDFCraft](https://github.com/maltinapro/pdfcraft) und übernimmt dessen
Gestaltung (Material Design 3, siehe [design.md](design.md)). PDFCraft bleibt eine **zustandslose Render-Engine**:
es speichert keine Kunden- oder Belegdaten. Speichern, Nummerieren, Festschreiben, Archivieren, Versenden und Buchen
übernimmt FediFinance.

Geprüfter Stand: PDFCraft `main` @ `3b4bb0b` (16.11.2026; seit `00c5e04` nur Dependency-Updates). Bei neuen PDFCraft-Versionen diesen Abschnitt und die
Anforderungsliste ([Abschnitt 7](#7-anforderungen-an-pdfcraft-upstream)) aktualisieren.

## 1. Was PDFCraft heute kann

| Bereich | Funktion (PDFCraft) | Nutzen für FediFinance |
| --- | --- | --- |
| Belegarten | Rechnung, Gutschrift/Stornorechnung, Angebot, Auftragsbestätigung, Lieferschein, Brief (DIN 5008 Form B) | Ausgangsbelege und Vorgangskette ohne eigene Vorlagen |
| PDF-Designs | *Classic* (sachlich), *Modern Minimal* (luftig, Infoblock rechts neben dem Anschriftfeld, große Zahlbetrag-Zeile), *Contrast* (Akzent-Kopfband, Akzent-Tabellenkopf, Summenbox); gemeinsames Layoutmodul `layout.typ` mit Design-Tokens; DIN-Positionen in allen Designs gleich | Design-Auswahl im Erscheinungsbild des Unternehmens |
| Gestaltung | Logo, Unterschriftsbild, Akzentfarbe (Kontrastprüfung), Schriftart, Einleitungs-/Schluss-/Fußtext, Wasserzeichen „Entwurf" | Briefpapier je Mandant |
| E-Rechnung | PDF/A-3b mit eingebettetem XML (EN 16931 CII oder XRechnung), Factur-X-XMP; Korpus in der PDFCraft-CI mit Mustang validiert; bei Lücken wird `invoice-draft.xml` eingebettet | ZUGFeRD/XRechnung ohne eigene XML-Erzeugung |
| API | REST `/v1`: `POST /v1/invoices`, `/v1/documents`, `/v1/invoices/bulk`, `/v1/documents/bulk` (ZIP), `GET /v1/token`, `GET /health`; OpenAPI 3.1 (`docs/openapi.yaml`, aus dem Code generiert) | Typsicherer Client, Contract-Tests |
| Vorschau | `?zones=1` liefert im Header `X-Pdfcraft-Zones` die Geometrie der Zonen 3/4 (mm, Seite) für die klickbare Vorschau | Papier-Editor mit Zonen-Overlay |
| Leistung | typ. 5–12 ms je Rechnung (3 Positionen), Compile-Queue mit Lastabwurf (`503 server_busy` + `Retry-After`), Rate-Limit je Token (`429` + `Retry-After`) | Synchrone Vorschau, Bulk über Jobs |
| Frontend | React 19 + Vite + TS, ohne UI-Bibliothek; Design-Tokens (`tokens.css`), Komponenten (`components/ui/`), Inline-SVG-Icons, Inter (self-hosted), Hell/Dunkel/System, hoher Kontrast, `tr(de, en)` | Basis des FediFinance-Frontends ([Abschnitt 6](#6-frontend-strategie)) |
| Editor | Papier-Editor mit vier Zonen (Absender & Aussehen, Empfänger, Details, Positionen), Stepper, Klick auf das PDF öffnet die Felder, Splitter (Desktop) bzw. Formular/Vorschau-Tabs (mobil), Positionskarten mit Zeilensumme, Hinweisliste | Belegeditor (E07-06) |
| Weitere | Stammdaten Kunden/Artikel, Belegarchiv mit ZIP-Download und Folgebelegen, E-Rechnungs-Viewer und Plausibilitätsprüfung (CII/UBL, nur im Browser), Leistungsdatum/-zeitraum und Fälligkeit, Internetmarke (optional, standardmäßig aus), Prometheus-Metriken + Grafana-Dashboards, Helm-Demo-Chart | Vorbild für Stammdaten, Archiv, Eingangsrechnungen, Betrieb |
| Nicht vorhanden | Serverseitige Speicherung (alles liegt im Browser bzw. in einer JSON-Sicherung), Benutzer/Rollen, Nummernkreise, Buchhaltung, Mahnung, Berichte | → Aufgabe von FediFinance bzw. Anforderungen (Abschnitt 7) |

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
   nicht protokolliert (nur Metriken). Vorschauen tragen „Entwurf" (setzt Anforderung R2 voraus).
2. **Freigabe:** Belegnummer wird lückenlos vergeben (E06-04), das Backend rendert **einmal** final, extrahiert das
   eingebettete XML, prüft, dass es nicht `invoice-draft.xml` ist (sonst Abbruch), und legt PDF, XML und
   **Render-Snapshot** unveränderlich ab (E08-01). Danach wird der Beleg nie neu gerendert; Korrektur nur per
   Storno/Gutschrift.
3. **Massenerzeugung:** Hintergrundjob (E01-08) nutzt die Bulk-Endpunkte (ZIP), beachtet `bulkMax` aus
   `GET /v1/token` und das Rate-Limit.
4. **Empfang:** Eingehende ZUGFeRD/XRechnung-Dateien werden serverseitig geparst (E07-10); die Anzeige im UI
   nutzt den Viewer-Code von PDFCraft.

### Render-Snapshot

Zu jedem festgeschriebenen PDF speichert FediFinance: Request-JSON an PDFCraft (inkl. Design, Akzentfarbe, Schrift,
Texte; Logo/Unterschrift als Hash-Referenz statt Base64-Kopie), PDFCraft-Version (Image-Tag/Digest), Endpunkt,
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
  FediFinance-Chart gepinnt; Upgrade nur mit grünem Contract-Test (E07-02).
- **Valkey:** PDFCraft benötigt für `/v1` Valkey (Token-Hashes, Rate-Limit). Keine Kundendaten darin.
- **Token:** je Mandant ein Token ohne Wasserzeichen (`pdfcraft-backend tokens create --plan <plan> --days <n>`)
  als Kubernetes-Secret; Rotation über das Provisioning (E12-07). `PAID_TOKENS_ENABLED=true`, Mollie/Kauf/Anubis
  bleiben aus. Langfristig besser: statische Dienst-Tokens ohne Ablauf (R1).
- **Deployment-Varianten** (Entscheidung in E07-01/E12-12):

| Variante | Vorteile | Nachteile |
| --- | --- | --- |
| **Geteilt** (Namespace `pdfcraft`, ein Token je Mandant) – *Vorschlag Standard* | ein Deployment + ein Valkey für alle; PDFCraft speichert nichts, passt zur Regel „geteilte Ressourcen, getrennte Daten" | Belegdaten passieren einen gemeinsamen Prozess (nur im Speicher); NetworkPolicy-Egress zum Namespace nötig; ein Upgrade betrifft alle |
| **Je Mandant** (im Namespace `tenant-<id>`) | strikte Isolation, Version je Mandant | Pod + Valkey je Mandant (Ressourcen, Betrieb) |

  Das Chart unterstützt beides: `pdfcraft.enabled=true` (im Namespace) oder `pdfcraft.url` (extern/geteilt).
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
| C. Gemeinsame Pakete aus PDFCraft (`ui`: Tokens, Komponenten, Icons; `editor`: Papier-Editor mit austauschbarer Datenquelle) | **Ziel.** Beide Produkte profitieren von Fixes; erfordert Umbau in PDFCraft (Workspace, Speicher-Adapter statt localStorage, Veröffentlichung z. B. GitHub Packages). |
| D. Neues FediFinance-Frontend mit gleichem Stack, Design-Fundament übernommen, Editor portiert | **Start.** Sofort machbar, volle Freiheit für Buchhaltungsseiten. |

**Empfehlung (D → C):**

1. **E03 – Design-Fundament übernehmen (kopieren):** `tokens.css` (+ Kontrasttest), `components/ui/*`, `ui.css`,
   `icons.tsx`, `theme.ts`, Inter-Einbindung aus einem gepinnten PDFCraft-Commit nach `frontend/src/design/`
   (Herkunft in `UPSTREAM.md`, Drift-Check in CI, E03-10). Klein (~600 Zeilen), stabil, MIT.
2. **E03 – Shell und Seiten neu:** App-Shell, Navigation, Tabellen, Buchhaltungsseiten, Auth und Rollen sind
   FediFinance-spezifisch und werden nach [design.md](design.md) neu gebaut – mit denselben Komponenten.
3. **E07 – Editor:** Bevorzugt extrahiert PDFCraft seinen Papier-Editor als Paket mit Props/Callbacks
   (`loadDraft`, `saveDraft`, `renderPreview → { pdf, zones }`, Stammdaten-Picker) (R8, R9); PDFCraft nutzt es mit
   localStorage, FediFinance mit seiner API. Bis dahin wird der Editor mit Herkunftsvermerk portiert und die Daten-
   schicht ersetzt. Entscheidung in E07-01 (beide Repos gehören demselben Owner, Option C ist realistisch).
4. Ebenfalls übernehmbar: E-Rechnungs-Viewer (`lib/einvoice/`: Extraktion, CII/UBL-Parser, Plausibilitätsprüfung),
   `validate.ts`-Logik (als Vorab-Hinweise), Screenshot-Skript (Playwright-Matrix).

Werkzeuge im Frontend wie in PDFCraft (npm, Vite, Vitest, oxlint, TypeScript), damit Code ohne Anpassung läuft (E00-03).

## 7. Anforderungen an PDFCraft (upstream)

Angelegt als Issues in `maltinapro/pdfcraft` (Label `enhancement`, 11/2026, E07-14); Status hier pflegen.

| ID | Anforderung | Warum | Ersatz bis dahin | Issue |
| --- | --- | --- | --- | --- |
| R1 | Statische Dienst-Tokens (z. B. gehashte Tokens aus Env/Secret, ohne Ablauf; optional ohne Valkey) | Betrieb je Mandant ohne Token-Ablauf und ggf. ohne Valkey | Paid-Token mit langer Laufzeit + Rotation | [pdfcraft#214](https://github.com/maltinapro/pdfcraft/issues/214) offen |
| R2 | Wasserzeichen „Entwurf" je Request steuerbar (auch für Paid-Tokens) | Vorschau unfreigegebener Belege eindeutig kennzeichnen | zweites Free-Token nur für Vorschauen (unschön) | [pdfcraft#215](https://github.com/maltinapro/pdfcraft/issues/215) offen |
| R3 | Versionsauskunft (`GET /version` bzw. Header mit App- und Template-Version) | Render-Snapshot, Nachvollziehbarkeit | Image-Digest aus der Konfiguration | [pdfcraft#216](https://github.com/maltinapro/pdfcraft/issues/216) offen |
| R4 | Garantiert deterministische Ausgabe (gleiche Eingabe + Version → gleiche Bytes) inkl. Test | Hash-Prüfung, Reproduzierbarkeit (E07-11) | eigener Test in FediFinance | [pdfcraft#217](https://github.com/maltinapro/pdfcraft/issues/217) offen |
| R5 | Belegart Mahnung (Bezug auf offene Rechnungen, Gebühren, Zinsen) | Mahnwesen (E09) | Brief-Belegart mit Text | [pdfcraft#218](https://github.com/maltinapro/pdfcraft/issues/218) offen |
| R6 | Berichts-/Tabellendokument (Journal, Summen-/Saldenliste, BWA, Verfahrensdokumentation, Prüfer-Export-Deckblatt) | Auswertungen als PDF | eigene Typst-Vorlage in FediFinance prüfen | [pdfcraft#219](https://github.com/maltinapro/pdfcraft/issues/219) offen |
| R7 | Zustandsloser Endpunkt „E-Rechnung parsen/prüfen" (PDF/XML → normalisiertes JSON + Prüfergebnis) | Eingangsrechnungen serverseitig mit derselben Logik wie der Viewer | eigener Rust-Parser (E07-10) | [pdfcraft#220](https://github.com/maltinapro/pdfcraft/issues/220) offen |
| R8 | Papier-Editor als Paket mit austauschbarer Datenquelle | Frontend-Strategie C | Portierung mit Herkunftsvermerk | [pdfcraft#221](https://github.com/maltinapro/pdfcraft/issues/221) offen |
| R9 | Design-System als Paket (Tokens, `ui`, Icons) | Drift vermeiden | Kopie + Drift-Check (E03-10) | [pdfcraft#222](https://github.com/maltinapro/pdfcraft/issues/222) offen |
| R10 | Strukturierter Fuß (Kontakt / Bank / Steuer- und Registerdaten) über die API; PDFCraft E11-05 ([#189](https://github.com/maltinapro/pdfcraft/issues/189)) ist geschlossen, laut Epic aber offen und nicht in der API | Pflichtangaben auf Geschäftsbriefen (§ 37a HGB, § 35a GmbHG) aus Stammdaten | freier Fußtext aus Stammdaten generiert | [pdfcraft#223](https://github.com/maltinapro/pdfcraft/issues/223) offen |
| R11 | Produktions-Helm-Chart oder Chart-Bausteine | Einbindung in das FediFinance-Chart | eigene Templates im FediFinance-Chart | [pdfcraft#224](https://github.com/maltinapro/pdfcraft/issues/224) offen |

## 8. Offene Punkte

- Geteiltes oder mandanteneigenes PDFCraft-Deployment (Abschnitt 4) – Vorschlag: geteilt.
- Editor-Paket (C) vs. Portierung (D) für den Editor – Entscheidung in E07-01.
- Berichte (R6) in PDFCraft oder eigene Vorlagen – Entscheidung in E07-09.
- Pflichtangaben auf Geschäftsbriefen und Rechnungen von Steuerberatung/Rechtsberatung prüfen lassen.
