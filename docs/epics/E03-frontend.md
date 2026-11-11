# E03 – Frontend-Grundgerüst

**Phase:** 0 · **Abhängig von:** E00, E02 · **Status:** offen

## Ziel
TypeScript-Frontend mit Login, Layout, Navigation, Design-System und API-Anbindung; Basis für alle Fachmodule und den KI-Chat.

## Kontext / Links
Logo: `assets/logo.svg`. [decisions.md](../decisions.md)

## Definition of Done
- Angemeldeter Benutzer sieht ein rollenabhängiges Layout, Spracheinstellung (de/en), Tests laufen in CI.

## Issues
- [ ] **E03-01 Framework-Entscheidung & Setup** – Vorschlag React + Vite + TS; Routing, State/Server-State (TanStack Query). AK: ADR + Skelett.
- [ ] **E03-02 Design-System** – Farben/Typografie aus dem Logo, Komponentenbibliothek (z. B. Radix/shadcn), Dark Mode, Barrierefreiheit (WCAG 2.1 AA). AK: Storybook/Komponentenkatalog.
- [ ] **E03-03 Auth-Integration** – OIDC-Client, Token-Handling (kein Token in localStorage, wenn vermeidbar), Rollen-Guards. AK: Login/Logout-Flow getestet.
- [ ] **E03-04 API-Client** – Generiert aus OpenAPI (E01-06), Fehlerbehandlung, Retry. AK: Typsicher.
- [ ] **E03-05 App-Shell** – Navigation, Mandantenname/Logo, Benutzermenü, Benachrichtigungen. AK: Responsive.
- [ ] **E03-06 Internationalisierung** – i18n (de, en), Zahlen-/Datums-/Währungsformate. AK: Alle Texte über i18n.
- [ ] **E03-07 Formular- und Tabellenbausteine** – Validierung, Geldbeträge (Dezimal, keine Floats), Tabellen mit Filter/Sortierung/Export. AK: Wiederverwendbar.
- [ ] **E03-08 E2E-Tests** – Playwright gegen Dev-Umgebung. AK: Login-Smoke-Test in CI.
- [ ] **E03-09 Container-Image & Auslieferung** – Statisches Bundle (nginx/caddy unprivileged). AK: Image in CI.
