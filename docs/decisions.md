# Entscheidungen und offene Fragen

## Getroffen (Vorgaben)

| Thema | Entscheidung |
| --- | --- |
| Backend | Rust |
| Frontend | TypeScript (Node.js für Tooling) |
| Datenbank | PostgreSQL |
| Dateispeicher | Dateisystem (PVC) für PDFs |
| Identity | Keycloak (OIDC, SSO, externe IdPs) |
| Föderation | ActivityPub |
| PDF | PDFCraft |
| Deployment | Kubernetes + Helm, ein Namespace/Release je Kunde |
| Backup | Velero + Datenexport |
| Lizenzen | Nur Open-Source-Infrastruktur |
| KI | Pro Kunde eigenes Datensilo; Start CPU, später NVIDIA Ampere |

## Vorschläge (zu bestätigen in der jeweiligen Epic)

| Thema | Vorschlag | Epic |
| --- | --- | --- |
| Rust-Webframework | Axum + Tokio, SQLx, utoipa (OpenAPI) | E01 |
| Frontend-Framework | React + Vite + TanStack Query | E03 |
| Postgres-Betrieb | CloudNativePG | E12 |
| KI-Basismodell | Qwen3 (Apache 2.0), Embeddings BGE-M3 | E14 |
| LLM-Serving | llama.cpp (CPU) → vLLM (GPU) | E14, E19 |
| Vektorsuche | pgvector in Mandanten-DB | E14 |
| Objektspeicher für Backups | MinIO oder Garage (Lizenz/Reife prüfen) | E13 |
| Keycloak-Topologie | Ein Keycloak, ein Realm je Mandant | E02 |

## Offene Fragen

1. **PDFCraft-Schnittstelle**: Wie wird PDFCraft angebunden (HTTP-Service, CLI, Bibliothek)? Unterstützt es PDF/A-3 und ZUGFeRD-Einbettung? (E07) – Das PDFCraft-Repository wurde bei der Planung nicht geprüft.
2. **ActivityPub in Rust**: vorhandene Bibliothek (z. B. `activitypub_federation`) oder Eigenbau? (E05)
3. **Bankanbindung** mit Open-Source-Mitteln: FinTS/HBCI vs. PSD2-Aggregator; kommerzielle Aggregatoren wären kein OSS. (E10)
4. **ELSTER/UStVA**: Die offizielle ERiC-Bibliothek ist nicht quelloffen – Umgang (Export-XML + manuelle Übermittlung vs. ERiC-Integration). (E09)
5. **AI-Gateway-Sprache**: Rust im Backend oder separater TypeScript/Node.js-Dienst? (E14)
6. **Keycloak je Mandant oder geteilt**: Isolation vs. Betriebsaufwand. (E02, E12)
7. **Zeitstempel/Revisionssicherheit**: Reicht Hash-Kette oder qualifizierter Zeitstempel (RFC 3161)? (E08)
8. **Projektlizenz** (siehe `LICENSE`) vs. Geschäftsmodell Hosting. (E00)
9. **Domain des JSON-LD-Vokabulars** (z. B. `fedifinance.org`). (E05)
10. **Zielmärkte** außer Deutschland (Österreich/Schweiz) – beeinflusst Kontenrahmen und Steuerlogik. (E09)

## Änderungsprotokoll

- Erstfassung der Planung.
