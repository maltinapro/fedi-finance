# AGENTS.md

Instructions for AI coding agents (and humans) working in this repository.
**Keep this file up to date**: whenever structure, commands, conventions or the roadmap change, update it in the same PR.

## Project

**FediFinance** is a federated, GoBD-compliant accounting software. Every company runs its own FediFinance server;
servers exchange master data and business documents (e.g. invoices) with each other via **ActivityPub**, similar to Mastodon.
Business partners are found via their domain (e.g. `f1.com`) and linked automatically.

Key characteristics:

- Federation via ActivityPub (WebFinger, HTTP Signatures, custom business vocabulary).
- GoBD-compliant bookkeeping for the supported legal forms; PDFs are generated with [PDFCraft](https://github.com/maltinapro/pdfcraft), stored immutably and archived according to retention periods.
- Bank account connection, roles/permissions, login + SSO (Keycloak).
- GDPR by design: store only the data that is necessary.
- Per-customer AI assistant with its own data silo (RAG first, optional per-tenant LoRA adapters).
- Single-tenant-per-namespace deployment on Kubernetes via Helm; backups with Velero; full data export as archive.
- Only open source infrastructure software.

Tech stack: Rust (backend), TypeScript (frontend), Node.js (tooling, optional AI gateway), PostgreSQL, Keycloak,
filesystem/PVC storage, Helm/Kubernetes, vLLM (later on NVIDIA Ampere GPUs).

Status: **planning phase** – no application code yet. The concept lives in `docs/`, the work breakdown in `docs/epics/`.

## Where to find what

| Path | Content |
| --- | --- |
| `README.md` | Short overview |
| `docs/README.md` | Documentation index |
| `docs/architecture.md` | Architecture, components, tenancy model |
| `docs/federation.md` | ActivityPub design |
| `docs/compliance.md` | GoBD, retention, GDPR, e-invoicing |
| `docs/ai.md` | AI concept and model recommendation |
| `docs/operations.md` | Kubernetes, Helm, backup, export |
| `docs/decisions.md` | Decisions made and open questions |
| `docs/roadmap.md` | Epic overview, order, status |
| `docs/epics/` | One file per epic with its issues/tasks |
| `assets/logo.svg` | Project logo |

Planned code layout (create when the first epic needs it): `backend/` (Cargo workspace), `frontend/` (TypeScript),
`deploy/helm/` (Helm charts), `ai/` (AI gateway, evaluation).

## Working with epics

- Each epic is `docs/epics/EXX-name.md`; issues inside have IDs like `E05-03` and a checkbox status.
- Work **one epic (or part of an epic) per session/PR**. Start by reading the epic, its dependencies and `docs/decisions.md`.
- When finishing issues: tick the checkboxes in the epic, update the status table in `docs/roadmap.md`, and update affected docs.
- If scope changes, edit the epic instead of silently deviating; record important decisions in `docs/decisions.md`.
- Legal topics (GoBD, tax, retention) are implemented to the best knowledge but must be flagged for review by a tax advisor.

## Conventions

- Write pull request titles/descriptions and commit messages in English.
- Docs and epics are written in German; code, identifiers and code comments in English.
- Keep `README.md` (short overview) and `docs/` (details) up to date: whenever a change affects setup, architecture, project structure, features, API, configuration or the tech stack, update the affected file in the same PR. Keep the README short; put details in `docs/`.
- Work in one PR per roadmap step, branched from the latest `main`, so each step can be tested locally.
- PR titles must follow Conventional Commits (e.g. `feat: ...`), because PRs are squash-merged and the title becomes the commit message.
- Use open source components only (OSI-approved licenses) for infrastructure and dependencies; check licenses before adding a dependency.
- Never commit secrets. Collect only data that is required (GDPR data minimisation).
- Booked data is never modified in place (GoBD immutability): corrections are done via reversal entries.

## Build / test commands

None yet. Add the verified commands here as soon as the first code exists (e.g. `cargo test`, `npm test`, `helm lint`).

## Roadmap / TODOs (resume here)

Full list with status: `docs/roadmap.md`. Next steps:

- [ ] Review the epics in `docs/epics/` and adjust them (scope, order).
- [ ] Start with `E00` (repository foundation: monorepo skeleton, CI, dev environment).
- [ ] Then `E01` (Rust backend skeleton) and `E02` (auth with Keycloak).
