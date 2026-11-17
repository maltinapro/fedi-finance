# AGENTS.md

Instructions for AI coding agents (and humans) working in this repository.
**Keep this file up to date**: whenever structure, commands, conventions or the roadmap change, update it in the same PR.

## Project

**FediFinance** is a federated, GoBD-compliant accounting software. Every company runs its own FediFinance server;
servers exchange master data and business documents (e.g. invoices) with each other via **ActivityPub**, similar to Mastodon.
Business partners are found via their domain (e.g. `f1.com`) and linked automatically.

Key characteristics:

- Federation via ActivityPub (WebFinger, HTTP Signatures, custom business vocabulary).
- GoBD-compliant bookkeeping for the supported legal forms; PDFs are rendered by [PDFCraft](https://github.com/maltinapro/pdfcraft) (stateless, called via its REST API `/v1`) and stored immutably by FediFinance, archived according to retention periods.
- UI in Material Design 3, reusing PDFCraft's design system (tokens, components, icons) and paper-first document editor.
- Bank account connection, roles/permissions, login + SSO (Keycloak).
- GDPR by design: store only the data that is necessary.
- Per-customer AI assistant with its own data silo (RAG first, optional per-tenant LoRA adapters).
- Single-tenant-per-namespace deployment on Kubernetes via Helm; backups with Velero; full data export as archive.
- Only open source infrastructure software.

Tech stack: Rust (backend), TypeScript/React + Vite (frontend, same stack as PDFCraft), Node.js (tooling, optional AI gateway), PostgreSQL, Keycloak,
PVC or S3 (Object Lock) document storage, Helm/Kubernetes, vLLM (later on NVIDIA Ampere GPUs).

Status: **foundation done (E00)** – repository skeleton, CI and dev environment exist; no application logic yet. The concept lives in `docs/`, the work breakdown in `docs/epics/`.

## Where to find what

| Path | Content |
| --- | --- |
| `README.md` | Short overview |
| `docs/README.md` | Documentation index |
| `docs/architecture.md` | Architecture, components, tenancy model |
| `docs/federation.md` | ActivityPub design |
| `docs/compliance.md` | GoBD, retention, GDPR, e-invoicing |
| `docs/ai.md` | AI concept and model recommendation |
| `docs/storage.md` | Storage: Rook-Ceph (min. 3 Nodes), Archiv mit S3 Object Lock, Backup-Ziel, Offboarding |
| `docs/operations.md` | Kubernetes, Helm, backup, export |
| `docs/pdfcraft.md` | PDFCraft features, REST integration, operation, frontend strategy, upstream requirements (R1–R11) |
| `docs/design.md` | Design guide (Material Design 3, adopted from PDFCraft; only FediFinance additions/deviations) |
| `docs/decisions.md` | Decisions made and open questions |
| `docs/roadmap.md` | Epic overview, order, status |
| `docs/epics/` | One file per epic with its issues/tasks |
| `assets/logo.svg` | Project logo |

Code layout: `backend/` (Cargo workspace, crates in `backend/crates/`), `frontend/` (TypeScript/React/Vite; later `frontend/src/design/` = design system copied from PDFCraft, source commit in `UPSTREAM.md`),
`deploy/helm/fedifinance/` (Helm chart), `deploy/dev/` (docker compose dev stack, scripts, sample payload), `ai/` (AI gateway, evaluation; placeholder).
CI: `.github/workflows/ci.yml` (Rust, cargo-deny, frontend, Helm, dev-compose validation, gitleaks, Markdown link check) and `pr-title.yml` (Conventional Commits). Dependabot keeps cargo, npm, actions and compose images current; `CODEOWNERS` and the PR template live in `.github/`.

## Working with epics

- Each epic is `docs/epics/EXX-name.md`; issues inside have IDs like `E05-03` and a checkbox status.
- Work **one epic (or part of an epic) per session/PR**. Start by reading the epic, its dependencies and `docs/decisions.md`.
- When finishing issues: tick the checkboxes in the epic, update the status table in `docs/roadmap.md`, and update affected docs.
- GitHub issues mirror the epics (epic issue + one sub-issue per task; labels `epic`, `task`, `phase-N`) and are created phase by phase; see `docs/epics/README.md` and `docs/roadmap.md`. Reference the task issue in the PR (`Closes #N`).
- If scope changes, edit the epic instead of silently deviating; record important decisions in `docs/decisions.md`.
- Legal topics (GoBD, tax, retention) are implemented to the best knowledge but must be flagged for review by a tax advisor.

## Conventions

- Write pull request titles/descriptions and commit messages in English.
- Docs and epics are written in German; code, identifiers and code comments in English.
- Keep `README.md` (short overview) and `docs/` (details) up to date: whenever a change affects setup, architecture, project structure, features, API, configuration or the tech stack, update the affected file in the same PR. Keep the README short; put details in `docs/`.
- Work in one PR per roadmap step, branched from the latest `main`, so each step can be tested locally.
- PR titles must follow Conventional Commits (e.g. `feat: ...`), because PRs are squash-merged and the title becomes the commit message.
- No per-file license headers: the license is `LICENSE` (MIT, provisional, see `docs/decisions.md` #8) and manifests carry `license = "MIT"`.
- Use open source components only (OSI-approved licenses) for infrastructure and dependencies; check licenses before adding a dependency.
- Never commit secrets. Collect only data that is required (GDPR data minimisation).
- Booked data is never modified in place (GoBD immutability): corrections are done via reversal entries.
- All PDFs come from PDFCraft via the backend; the browser never holds a PDFCraft token. Issued PDFs are rendered once at release and never re-rendered (`docs/pdfcraft.md`).
- UI changes follow `docs/design.md` and the PDFCraft design guide; code copied from PDFCraft (MIT) keeps a source note; deviations are documented in `docs/design.md`.
- When PDFCraft changes (new version, features, design), update `docs/pdfcraft.md` (checked commit, feature table, requirements).

## Build / test commands

Run from the repository root; `make help` lists all targets. `make check` runs what CI runs (except cargo-deny, gitleaks, link check).

| Command | What it does |
| --- | --- |
| `make dev` | `docker compose` stack in `deploy/dev/` (Postgres+pgvector, Keycloak, S3 via SeaweedFS, Valkey, PDFCraft pinned `0.31.0`); creates a PDFCraft token in `deploy/dev/.secrets/pdfcraft-token` (git-ignored) |
| `make dev-check` | `curl` PDFCraft `/health` and `POST /v1/invoices` (expects a PDF) |
| `make dev-down` / `make dev-reset` | stop the stack / stop and delete volumes and token |
| `make lint` | `cargo fmt --check`, `cargo clippy -- -D warnings`, `npm run lint` (oxlint + Prettier), `helm lint` |
| `make test` | `cargo test`, `npm test` (Vitest) |
| `make build` | `cargo build`, `npm run build` (tsc + Vite) |
| `make fmt` | `cargo fmt`, `npm run format` |
| `cd backend && cargo deny check` | advisories, licenses (OSS only), sources; needs `cargo install cargo-deny` |

Dev ports (all bound to 127.0.0.1): Postgres 5432, Keycloak 8081, S3 9000, PDFCraft 3000; override via `deploy/dev/.env` (see `.env.example`). Credentials there are local-only defaults.

## Roadmap / TODOs (resume here)

Full list with status: `docs/roadmap.md`. Next steps:

- [ ] Review the epics in `docs/epics/` and adjust them (scope, order). PDFCraft alignment done (11/2026): E03, E07 rewritten, E00/E04/E06/E12 adjusted.
- [x] Phase-0 GitHub issues synced with the epic files (#5, #6, #31, #32, #33, #34, #37–#40); E03-10 created as #44.
- [x] PDFCraft upstream requests R1–R11 created (maltinapro/pdfcraft#214–#224); keep their status in `docs/pdfcraft.md` §7.
- [ ] Legal review of mandatory details on invoices/business letters by a tax/legal advisor (#45) before the first real customer.
- [x] `E00` (repository foundation: monorepo skeleton, CI, dev environment) done. Open: maintainer decision on project license (#8) and vocabulary domain (#9) in `docs/decisions.md`.
- [ ] Then `E01` (Rust backend skeleton) and `E02` (auth with Keycloak).
