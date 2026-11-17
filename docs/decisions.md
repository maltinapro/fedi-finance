# Entscheidungen und offene Fragen

## Getroffen (Vorgaben)

| Thema | Entscheidung |
| --- | --- |
| Backend | Rust |
| Frontend | TypeScript (Node.js für Tooling) |
| Datenbank | PostgreSQL |
| Dateispeicher | Dateisystem (PVC) oder S3 mit Object Lock für PDFs, nie in der DB (siehe Vorschlag „Archiv-Storage“) |
| Identity | Keycloak (OIDC, SSO, externe IdPs) |
| Föderation | ActivityPub |
| PDF | PDFCraft als zustandslose Render-Engine über REST (`/v1`); FediFinance speichert alle Daten und PDFs ([pdfcraft.md](pdfcraft.md)) |
| Gestaltung | Material Design 3 mit dem Design-System von PDFCraft (Tokens, Komponenten, Icons, Papier-Editor), Farbschema unverändert ([design.md](design.md)) |
| Deployment | Kubernetes + Helm, ein Namespace/Release je Kunde |
| Backup | Velero (Kopia, `snapshotMoveData`) + CloudNativePG/Barman + Archiv-Replikator, **Offsite** (S3 mit Object Lock, anderer Standort, EU) + Datenexport; Rhythmen, Aufbewahrung, RPO/RTO in [operations.md](operations.md#backup-und-restore) |
| Lizenzen | Nur Open-Source-Infrastruktur |
| KI | Pro Kunde eigenes Datensilo; Start CPU, später NVIDIA Ampere |

## Vorschläge (zu bestätigen in der jeweiligen Epic)

| Thema | Vorschlag | Epic |
| --- | --- | --- |
| Rust-Webframework | Axum + Tokio, SQLx, utoipa (OpenAPI) | E01 |
| Frontend-Framework | React 19 + Vite + TypeScript wie PDFCraft, keine UI-Bibliothek, Router mit Pfaden, TanStack Query | E03 |
| Frontend-Werkzeuge | npm, Vitest, oxlint wie PDFCraft; Prettier für die Formatierung (umgesetzt in E00) | E00 |
| Frontend-Strategie | Design-Fundament aus PDFCraft kopieren (gepinnter Commit, Drift-Check), Shell/Seiten neu; Editor als gemeinsames Paket aus PDFCraft, bis dahin Portierung ([pdfcraft.md](pdfcraft.md#6-frontend-strategie)) | E03, E07 |
| PDFCraft-Deployment | Geteilter Dienst im Cluster (Token je Mandant), optional je Mandant | E07, E12 |
| Postgres-Betrieb | CloudNativePG auf Ceph-RBD (`fedifinance-block`) | E12 |
| KI-Basismodell | Qwen3 (Apache 2.0), Embeddings BGE-M3 | E14 |
| LLM-Serving | llama.cpp (CPU) → vLLM (GPU) | E14, E19 |
| Vektorsuche | pgvector in Mandanten-DB | E14 |
| Offsite-Backup-Ziel | S3 mit Object Lock und Versioning, anderer Standort/Anbieter in der EU; Referenz SeaweedFS (Object Lock getestet), Garage/MinIO scheiden aus; bestätigen mit dem Test aus E13-01 | E13 |
| Archiv-Storage | **Rook-Ceph (min. 3 Nodes, Replikation 3, RBD + RGW)**; Archiv als S3-Bucket je Mandant mit Object Lock (Compliance in Produktion, Governance in Dev/Test), Fallback PVC mit Write-once in der Anwendung; PDFs nie in der DB ([storage.md](storage.md)) | E08, E12 |
| Keycloak-Topologie | Ein Keycloak, ein Realm je Mandant | E02 |

## Offene Fragen

1. ~~**PDFCraft-Schnittstelle**~~ – geklärt (11/2026): REST-API `/v1` (OpenAPI 3.1), PDF/A-3b mit eingebettetem EN-16931-/XRechnung-XML, Token-Auth, zustandslos. Offen bleiben Deployment-Variante, Editor-Paket und die Anforderungen R1–R11 ([pdfcraft.md](pdfcraft.md)). (E07)
2. **ActivityPub in Rust**: vorhandene Bibliothek (z. B. `activitypub_federation`) oder Eigenbau? (E05)
3. **Bankanbindung** mit Open-Source-Mitteln: FinTS/HBCI vs. PSD2-Aggregator; kommerzielle Aggregatoren wären kein OSS. (E10)
4. **ELSTER/UStVA**: Die offizielle ERiC-Bibliothek ist nicht quelloffen – Umgang (Export-XML + manuelle Übermittlung vs. ERiC-Integration). (E09)
5. **AI-Gateway-Sprache**: Rust im Backend oder separater TypeScript/Node.js-Dienst? (E14)
6. **Keycloak je Mandant oder geteilt**: Isolation vs. Betriebsaufwand. (E02, E12)
7. **Zeitstempel/Revisionssicherheit**: Reicht Hash-Kette oder qualifizierter Zeitstempel (RFC 3161)? (E08)
8. **Projektlizenz** (siehe `LICENSE`) vs. Geschäftsmodell Hosting. Stand: MIT, vorläufig. MIT erlaubt proprietäre gehostete Forks; AGPL-3.0 würde das verhindern, würde aber die Einbindung in Fremdsysteme erschweren. Entscheidung beim Maintainer vor dem ersten Release; bis dahin tragen alle Manifeste `license = "MIT"`, Quelldateien brauchen keinen Lizenzkopf (Lizenz gilt über `LICENSE`). (E00)
9. **Domain des JSON-LD-Vokabulars** (z. B. `fedifinance.org`). Projektname bleibt „FediFinance“; die Domain muss vor E05 registriert bzw. festgelegt werden. (E00, E05)
10. **Zielmärkte** außer Deutschland (Österreich/Schweiz) – beeinflusst Kontenrahmen und Steuerlogik. (E09)
11. **Pflichtangaben auf Geschäftsbriefen** (§ 37a HGB, § 35a GmbHG) und Rechnungen (§ 14 UStG): Umsetzung über strukturierten Fuß (PDFCraft R10) – von Steuer-/Rechtsberatung prüfen lassen, Prüfliste in [#45](https://github.com/maltinapro/fedi-finance/issues/45). (E04, E07)
12. ~~**Archiv-Storage im Cluster**~~ – geklärt (11/2026): Start mit mindestens 3 Nodes, Rook-Ceph mit RGW und S3 Object Lock, Details und Begründung in [storage.md](storage.md). Offen zur Prüfung durch die Steuer-/Rechtsberatung: Compliance-Modus mit nicht umkehrbarer Retention und Aufbewahrung statt Löschung (Art. 17 Abs. 3 lit. b DSGVO). (E08, E11, E12)

## Änderungsprotokoll

- Erstfassung der Planung.
- 11/2026: PDFCraft geprüft (Stand `00c5e04`): Anbindung per REST, Material Design 3 und Design-System aus PDFCraft übernommen, Frontend-Strategie festgelegt; E03, E07 überarbeitet, E04/E06/E12 ergänzt.
- 11/2026: Phase-0-Issues mit den Epics abgeglichen, E03-10 als #44 angelegt, Anforderungen R1–R11 als maltinapro/pdfcraft#214–#224, Rechtsprüfung als #45.
- 11/2026: E00 umgesetzt: Monorepo-Skelett, CI, Dev-Umgebung (`make dev`), Prettier ergänzt; SeaweedFS statt MinIO in der Dev-Umgebung; Lizenz-/Namensfragen dokumentiert.
- 11/2026: Archiv-Storage geklärt (Konzept): GoBD verlangt kein bestimmtes Medium; Ceph (CephFS/RBD/RGW) ist geeignet, Unveränderbarkeit über Hash-Adressierung, Write-once und S3 Object Lock; keine PDFs in der DB. E08-01, E11-03, E12-04, compliance.md ergänzt; Rückfrage als Nr. 12.
- 11/2026: Frage 12 geklärt: freie Wahl der Storage-Software im Cluster; Vorschlag Rook-Ceph (RGW + Object Lock), Alternativen nach Clustergröße.
- 11/2026: Start mit mindestens 3 Nodes festgelegt; Storage-Entscheidungen S1–S6 in [storage.md](storage.md) dokumentiert (Rook-Ceph, Object Lock, Backup-Ziel, Offboarding); Object Lock in SeaweedFS (Dev) geprüft.
- 11/2026: Offsite-Backup entschieden: Velero mit `snapshotMoveData`, Barman, Archiv-Replikator (E13-11) in ein S3-Ziel mit Object Lock an anderem Standort; Aufbewahrung 30 Tage/12 Wochen, RPO/RTO festgelegt; Rest-Unsicherheit nur noch Standort/Anbieter des Offsite-Ziels (Betreiberentscheidung).
