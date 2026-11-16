# E00 – Projekt-Fundament

**Phase:** 0 · **Abhängig von:** – · **Status:** offen

## Ziel
Repository-Struktur, Entwicklungsumgebung, CI und Konventionen, damit alle folgenden Epics schnell und reproduzierbar umgesetzt werden können.

## Kontext / Links
[architecture.md](../architecture.md), [AGENTS.md](../../AGENTS.md), [decisions.md](../decisions.md)

## Definition of Done
- `backend/`, `frontend/`, `deploy/helm/`, `ai/` existieren als Skelett, CI ist grün, Dev-Umgebung startet mit einem Befehl.
- Befehle sind in `AGENTS.md` und README dokumentiert.

## Issues
- [ ] **E00-01 Monorepo-Skelett** – Verzeichnisse, `.gitignore`, `.editorconfig`, Lizenz-/Header-Konvention. AK: Struktur wie in architecture.md.
- [ ] **E00-02 Rust-Workspace** – Cargo-Workspace mit `rustfmt`, `clippy` (deny warnings), `cargo-deny` (Lizenzprüfung, nur OSS). AK: `cargo fmt --check`, `cargo clippy`, `cargo test` laufen.
- [ ] **E00-03 TypeScript/Node-Workspace** – Node-LTS und dieselben Werkzeuge wie PDFCraft (npm, Vite, Vitest, oxlint, TypeScript), damit übernommener PDFCraft-Code ohne Anpassung läuft; Formatierung mit Prettier. AK: `npm run lint` und `npm test` laufen.
- [ ] **E00-04 Dev-Umgebung** – `docker compose` (oder kind/k3d) mit Postgres, Keycloak, MinIO und PDFCraft (`ghcr.io/maltinapro/pdfcraft-backend`, gepinnte Version) + Valkey; ein Init-Schritt legt das PDFCraft-Token an (`pdfcraft-backend tokens create`). AK: `make dev` startet alles; `curl` gegen PDFCraft `/health` und `POST /v1/invoices` funktioniert.
- [ ] **E00-05 CI-Pipeline (GitHub Actions)** – Build, Lint, Test für Rust/TS, Helm-Lint, Dependency-/Lizenzscan, Secret-Scan. AK: PR-Checks laufen.
- [ ] **E00-06 Commit-/PR-Konventionen** – PR-Template, Conventional-Commit-Check für PR-Titel, CODEOWNERS, Dependabot/Renovate. AK: Template vorhanden, Check aktiv.
- [ ] **E00-07 Lizenz- und Namensentscheidung** – Projektlizenz prüfen, Namens-/Domain-Entscheidung (Vokabular-Domain). AK: Eintrag in decisions.md.
- [ ] **E00-08 Doku-Gerüst prüfen** – Links in docs prüfen (Markdown-Link-Check in CI). AK: CI-Job grün.

## Offene Fragen
Projektlizenz (siehe decisions.md Nr. 8).
