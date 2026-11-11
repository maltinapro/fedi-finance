# E01 – Rust-Backend-Grundgerüst

**Phase:** 0 · **Abhängig von:** E00 · **Status:** offen

## Ziel
Lauffähiges Rust-Backend mit sauberer Schichtung, Datenbankzugriff, Migrationen, Konfiguration, API-Konventionen und Audit-Log-Grundlage.

## Kontext / Links
[architecture.md](../architecture.md), [compliance.md](../compliance.md)

## Definition of Done
- Backend startet, verbindet sich mit Postgres, führt Migrationen aus, liefert `/health`, `/ready`, OpenAPI-Spec.
- Fehlerbehandlung, Logging, Konfiguration und Tests sind etabliert.

## Issues
- [ ] **E01-01 Crate-Struktur** – Workspace: `api`, `domain`, `infra`, `common`. Schichtentrennung (Domain ohne Framework-Abhängigkeit). AK: Architektur in docs dokumentiert.
- [ ] **E01-02 HTTP-Server (Axum)** – Routing, Middleware (Request-ID, Tracing, CORS, Limits), Graceful Shutdown. AK: `/health`, `/ready`.
- [ ] **E01-03 Konfiguration** – 12-Factor (Env/Datei), typisierte Config, Secrets nur aus Env/Dateien. AK: Validierung beim Start.
- [ ] **E01-04 PostgreSQL & Migrationen** – SQLx, Migrationsverzeichnis, Migration als separater Befehl/Job. AK: Migration läuft idempotent in CI.
- [ ] **E01-05 Fehler- und API-Konventionen** – Einheitliches Fehlerformat (RFC 9457 Problem Details), Pagination, Versionierung `/api/v1`. AK: Doku + Tests.
- [ ] **E01-06 OpenAPI** – utoipa, Spec-Export, TypeScript-Client-Generierung für das Frontend. AK: Spec in CI generiert und geprüft.
- [ ] **E01-07 Audit-Log-Grundlage** – Append-only Tabelle mit Hash-Kette, Schreib-API, Verifikationsfunktion. AK: Manipulationstest schlägt an.
- [ ] **E01-08 Hintergrundjobs** – Job-Queue (Postgres-basiert, z. B. `apalis`/Eigenbau), Retry, Idempotenz. AK: Beispiel-Job + Test.
- [ ] **E01-09 Testinfrastruktur** – Testcontainers für Postgres, Fixtures, Integrationstests. AK: `cargo test` ohne manuelle Setups.
- [ ] **E01-10 Container-Image** – Mehrstufiges Dockerfile (distroless/minimal), Nicht-Root, SBOM. AK: Image baut in CI.

## Offene Fragen
Framework-Bestätigung (Axum/SQLx) per Eintrag in decisions.md.
