<p align="center">
  <img src="assets/logo.svg" alt="FediFinance logo" width="360" />
</p>

# FediFinance

Föderierte, GoBD-konforme Buchhaltungssoftware. Jedes Unternehmen betreibt einen eigenen FediFinance-Server;
Server tauschen Stammdaten und Belege (z. B. Rechnungen) über **ActivityPub** aus – dezentral wie Mastodon.

## Kernideen

- **Föderation**: Geschäftspartner werden über ihre Domain (z. B. `f1.com`) gefunden und verknüpft; Partner ohne FediFinance erreicht später optional Peppol ([docs/peppol.md](docs/peppol.md)).
- **GoBD & DSGVO**: revisionssichere Buchführung, Datensparsamkeit; PDFs und E-Rechnungen (ZUGFeRD/XRechnung) erzeugt
  [PDFCraft](https://github.com/maltinapro/pdfcraft) per REST, FediFinance speichert und archiviert sie.
- **Gestaltung**: Material Design 3 mit dem Design-System und Belegeditor von PDFCraft.
- **Mandantenfähig**: pro Kunde ein Kubernetes-Namespace (Helm-Release) mit eigener DB, Storage und KI.
- **KI-Assistent**: eigenes Datensilo pro Kunde, beantwortet Fragen zu Buchhaltung und Bedienung.
- **Offen**: nur Open-Source-Infrastruktur (Rust, TypeScript, PostgreSQL, Keycloak, Helm, Velero, vLLM); einzige Ausnahme ist ERiC für die ELSTER-Übermittlung ([docs/elster.md](docs/elster.md)).

## Status

Das Projekt-Fundament (Epic E00) steht: Monorepo-Skelett, CI und Dev-Umgebung. Fachlicher Anwendungscode folgt mit E01 ff.
Konzept und Arbeitspakete:

- [Dokumentation](docs/README.md)
- [Roadmap & Epics](docs/roadmap.md)
- [AGENTS.md](AGENTS.md) – Hinweise für KI-Agenten / Mitwirkende

## Entwicklung

Voraussetzungen: Rust (stable), Node.js ≥ 24, Docker mit Compose, Helm, `make`.

| Befehl | Zweck |
| --- | --- |
| `make dev` | Dev-Umgebung starten (Postgres, Keycloak, S3, Valkey, PDFCraft) und PDFCraft-Token anlegen |
| `make dev-check` | Smoke-Test: PDFCraft `/health` und `POST /v1/invoices` |
| `make dev-down` / `make dev-reset` | Dev-Umgebung stoppen / inkl. Daten löschen |
| `make lint` · `make test` · `make build` | Prüfen, testen, bauen (Rust, TypeScript, Helm) |
| `make check` | Alles wie in der CI |
| `make fmt` | Code formatieren |

Das Frontend ist **nicht** Teil von `make dev`: es läuft separat mit `cd frontend && npm install && npm run dev` unter <http://localhost:5173>. Dienste der Dev-Umgebung: Keycloak <http://localhost:8081>, PDFCraft <http://localhost:3000>, S3 <http://localhost:9000>, Postgres `localhost:5432`.

Struktur: `backend/` (Rust), `frontend/` (TypeScript/React), `deploy/` (Helm, Dev-Umgebung), `ai/`, `docs/`.

## Lizenz

Siehe [LICENSE](LICENSE).
