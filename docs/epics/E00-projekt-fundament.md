# E00 – Projekt-Fundament

**Phase:** 0 · **Abhängig von:** – · **Status:** fertig

## Ziel
Repository-Struktur, Entwicklungsumgebung, CI und Konventionen, damit alle folgenden Epics schnell und reproduzierbar umgesetzt werden können.

## Kontext / Links
[architecture.md](../architecture.md), [AGENTS.md](../../AGENTS.md), [decisions.md](../decisions.md)

## Definition of Done
- `backend/`, `frontend/`, `deploy/helm/`, `ai/` existieren als Skelett, CI ist grün, Dev-Umgebung startet mit einem Befehl.
- Befehle sind in `AGENTS.md` und README dokumentiert.

## Issues
- [x] **E00-01 Monorepo-Skelett** – Verzeichnisse, `.gitignore`, `.editorconfig`, Lizenz-/Header-Konvention. AK: Struktur wie in architecture.md.
- [x] **E00-02 Rust-Workspace** – Cargo-Workspace mit `rustfmt`, `clippy` (deny warnings), `cargo-deny` (Lizenzprüfung, nur OSS). AK: `cargo fmt --check`, `cargo clippy`, `cargo test` laufen.
- [x] **E00-03 TypeScript/Node-Workspace** – Node-LTS und dieselben Werkzeuge wie PDFCraft (npm, Vite, Vitest, oxlint, TypeScript), damit übernommener PDFCraft-Code ohne Anpassung läuft; Formatierung mit Prettier. AK: `npm run lint` und `npm test` laufen.
- [x] **E00-04 Dev-Umgebung** – `docker compose` (oder kind/k3d) mit Postgres, Keycloak, S3-Speicher und PDFCraft (`ghcr.io/maltinapro/pdfcraft-backend`, gepinnte Version) + Valkey; ein Init-Schritt legt das PDFCraft-Token an (`pdfcraft-backend tokens create`). AK: `make dev` startet alles; `curl` gegen PDFCraft `/health` und `POST /v1/invoices` funktioniert (`make dev-check`). Umsetzung: `deploy/dev/`; als S3-Speicher dient SeaweedFS, da MinIO keine Community-Images mehr veröffentlicht.
- [x] **E00-05 CI-Pipeline (GitHub Actions)** – Build, Lint, Test für Rust/TS, Helm-Lint, Dependency-/Lizenzscan, Secret-Scan. AK: PR-Checks laufen.
- [x] **E00-06 Commit-/PR-Konventionen** – PR-Template, Conventional-Commit-Check für PR-Titel, CODEOWNERS, Renovate (`renovate.json`, wie PDFCraft). AK: Template vorhanden, Check aktiv.
- [x] **E00-07 Lizenz- und Namensentscheidung** – Projektlizenz prüfen, Namens-/Domain-Entscheidung (Vokabular-Domain). AK: Eintrag in decisions.md (Nr. 8 und 9: Empfehlung dokumentiert, Entscheidung beim Maintainer).
- [x] **E00-08 Doku-Gerüst prüfen** – Links in docs prüfen (Markdown-Link-Check in CI). AK: CI-Job grün.

## Offene Fragen
Projektlizenz (siehe decisions.md Nr. 8) und Vokabular-Domain (Nr. 9) sind noch vom Maintainer zu entscheiden.
