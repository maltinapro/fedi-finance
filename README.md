# FediFinance

<img src="assets/logo.svg" alt="FediFinance logo" width="120" />

Föderierte, GoBD-konforme Buchhaltungssoftware. Jedes Unternehmen betreibt einen eigenen FediFinance-Server;
Server tauschen Stammdaten und Belege (z. B. Rechnungen) über **ActivityPub** aus – dezentral wie Mastodon.

## Kernideen

- **Föderation**: Geschäftspartner werden über ihre Domain (z. B. `f1.com`) gefunden und verknüpft.
- **GoBD & DSGVO**: revisionssichere Buchführung, PDF-Archivierung (PDFs via [PDFCraft](https://github.com/maltinapro/pdfcraft)), Datensparsamkeit.
- **Mandantenfähig**: pro Kunde ein Kubernetes-Namespace (Helm-Release) mit eigener DB, Storage und KI.
- **KI-Assistent**: eigenes Datensilo pro Kunde, beantwortet Fragen zu Buchhaltung und Bedienung.
- **Offen**: nur Open-Source-Infrastruktur (Rust, TypeScript, PostgreSQL, Keycloak, Helm, Velero, vLLM).

## Status

Planungsphase – es gibt noch keinen Anwendungscode. Konzept und Arbeitspakete:

- [Dokumentation](docs/README.md)
- [Roadmap & Epics](docs/roadmap.md)
- [AGENTS.md](AGENTS.md) – Hinweise für KI-Agenten / Mitwirkende

## Lizenz

Siehe [LICENSE](LICENSE).
