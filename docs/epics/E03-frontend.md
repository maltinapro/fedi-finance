# E03 – Frontend-Grundgerüst

**Phase:** 0 · **Abhängig von:** E00, E02 · **Status:** offen

## Ziel
TypeScript-Frontend mit Login, Layout, Navigation, Design-System und API-Anbindung; Basis für alle Fachmodule und den KI-Chat.
Gestaltung in **Material Design 3** wie PDFCraft: Design-Fundament (Tokens, Komponenten, Icons) wird aus PDFCraft
übernommen, Shell und Seiten werden für FediFinance neu gebaut.

## Kontext / Links
[design.md](../design.md) (verbindlich), [pdfcraft.md](../pdfcraft.md#6-frontend-strategie) (Frontend-Strategie),
PDFCraft-[Design-Guide](https://github.com/maltinapro/pdfcraft/blob/main/docs/16-design-guide.md), Logo: `assets/logo.svg`,
[decisions.md](../decisions.md)

## Definition of Done
- Angemeldeter Benutzer sieht ein rollenabhängiges Layout im M3-Design (hell/dunkel/System), Spracheinstellung (de/en), Tests laufen in CI.
- Übernommener PDFCraft-Code ist mit Quell-Commit dokumentiert; Abweichungen stehen in design.md.

## Issues
- [ ] **E03-01 Framework-Entscheidung & Setup** – React 19 + Vite + TypeScript wie PDFCraft (damit Komponenten und Editor übernommen werden können); Router mit echten Pfaden und Auth-Guards (statt PDFCraft-Hash-Router), Server-State (Vorschlag TanStack Query). AK: ADR + Skelett.
- [ ] **E03-02 Design-System (Material Design 3 aus PDFCraft)** – `tokens.css` (Farbrollen, Zonenfarben, hoher Kontrast, `forced-colors`, Typografie Inter self-hosted, Abstände, Radien, Motion), `components/ui/` + `ui.css`, `icons.tsx` und `theme.ts` aus einem gepinnten PDFCraft-Commit nach `frontend/src/design/` übernehmen; keine UI-Bibliothek (kein Radix/shadcn/Tailwind); WCAG 2.2 AA. AK: Kontrasttest (`tokens.test.mjs`) grün; Komponentenkatalog als Dev-Route statt Storybook; Herkunft in `frontend/src/design/UPSTREAM.md`.
- [ ] **E03-03 Auth-Integration** – OIDC-Client, Token-Handling (kein Token in localStorage, wenn vermeidbar), Rollen-Guards. AK: Login/Logout-Flow getestet.
- [ ] **E03-04 API-Client** – Generiert aus OpenAPI (E01-06), Fehlerbehandlung, Retry. AK: Typsicher.
- [ ] **E03-05 App-Shell** – M3-Shell nach design.md 2.1: obere Leiste (64/56 px, ohne Umbruch), Ziele Start/Belege/Partner/Buchhaltung/Mehr als Navigationsleiste (< 840 px) bzw. Tabs (≥ 840 px), Mandantenlogo/-name, Überlaufmenü (Benutzer, Sprache, Theme System/Hell/Dunkel, Abmelden), Benachrichtigungs-Badge. AK: kein Überlauf bei 320–1440 px; Screenshot-Matrix.
- [ ] **E03-06 Internationalisierung** – de/en; Muster `tr(de, en)` aus PDFCraft oder Message-Katalog (Entscheidung in E03-01); Zahlen-/Datums-/Währungsformate (geschütztes Leerzeichen). AK: Alle Texte über i18n.
- [ ] **E03-07 Formular- und Tabellenbausteine** – Formulare mit den gefüllten PDFCraft-Feldern inkl. Fehlerlogik (touched/revealed, `data-field`, Banner mit Sprung zum Feld); Geldbeträge (Dezimal, keine Floats); neue Datentabelle nach design.md 2.2 (sortier-/filterbar, `tabular-nums`, Export, Listenansicht < 840 px), Status-Chips. AK: Wiederverwendbar, im Komponentenkatalog.
- [ ] **E03-08 E2E-Tests & Screenshot-Matrix** – Playwright gegen Dev-Umgebung; Screenshot-Skript wie PDFCraft (`npm run screenshots`: 320/390/768/1440 px, DE/EN, Hell/Dunkel). AK: Login-Smoke-Test in CI; Matrix lokal reproduzierbar.
- [ ] **E03-09 Container-Image & Auslieferung** – Statisches Bundle (nginx/caddy unprivileged). AK: Image in CI.
- [ ] **E03-10 Design-Abgleich mit PDFCraft** – Skript vergleicht `frontend/src/design/` mit dem in `UPSTREAM.md` gepinnten PDFCraft-Commit bzw. dem aktuellen PDFCraft-`main` und listet Drift; Übernahme von Upstream-Änderungen per PR; wird durch das gemeinsame Paket `@maltinapro/pdfcraft-design` (R9, seit PDFCraft `v0.34.0` in GitHub Packages) ersetzt – bevorzugt direkt statt Kopie; dann nur Renovate-Updates und ein `read:packages`-Token für CI/Renovate. AK: CI-Job (nicht blockierend) meldet Drift bzw. Paket eingebunden.
