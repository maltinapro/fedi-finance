# Architektur

## Überblick

```
            ┌──────────────── Kunde A (Namespace tenant-a, Domain a.example) ───────────────┐
 Browser ──▶│ Ingress ─▶ Frontend (TS) ─▶ Backend (Rust) ─┬─▶ PostgreSQL (+pgvector)         │
            │                                             ├─▶ S3: Buckets data + archive     │
            │                                             ├─▶ PDFCraft (REST, zustandslos)   │
            │                                             ├─▶ AI-Gateway ─▶ LLM-Serving      │
            │                                             └─▶ Bank-Connector                 │
            └───────────────────────▲──────────────────────────────────────────────────────┘
                                    │ ActivityPub (HTTPS, HTTP Signatures)
            ┌───────────────────────▼──────────────────────────────────────────────────────┐
            │ Kunde B (Namespace tenant-b, Domain b.example) – identischer Aufbau           │
            └──────────────────────────────────────────────────────────────────────────────┘
 Cluster-weit: Keycloak (Realm je Mandant), Velero, Ingress, cert-manager, Monitoring, (GPU-)LLM-Serving,
               PDFCraft + Valkey (geteilt, Vorschlag; alternativ je Mandant, siehe pdfcraft.md),
               optional Peppol-Gateway (peppol.md)
```

## Komponenten

| Komponente | Technologie | Aufgabe |
| --- | --- | --- |
| Backend | Rust (Axum, SQLx, Tokio) | REST/JSON-API, Buchungslogik, Föderation, Archiv, Jobs |
| Frontend | TypeScript, React 19 + Vite wie PDFCraft; Material Design 3 mit dem PDFCraft-Design-System ([design.md](design.md)) | Web-UI, Belegeditor, KI-Chat |
| Datenbank | PostgreSQL (Betrieb via CloudNativePG) | Stammdaten, Buchungen, Audit-Log, Vektorindex (pgvector) |
| Dokumentenspeicher | S3-API (provider-neutral; im Zielcluster Ceph RGW): Bucket `data` für aktuelle Daten, Bucket `archive` mit Object Lock, hash-adressiert; nie in der DB | Uploads, Vorschauen; unveränderliche PDFs, Anhänge, Archiv |
| PDF | [PDFCraft](pdfcraft.md) (Rust, REST `/v1`, zustandslos; Valkey nur für Token/Rate-Limit) | Rendert alle PDFs (6 Belegarten, 3 Designs, PDF/A-3b mit ZUGFeRD/XRechnung); speichert nichts – Ablage macht FediFinance |
| Identity | Keycloak | Login, SSO (OIDC/SAML, externe IdPs), Rollen |
| Föderation | ActivityPub im Backend | Austausch mit anderen FediFinance-Servern |
| Peppol-Gateway (optional, Phase 2) | Access-Point-Anbindung (Provider-API oder phase4/Oxalis), geteilt, ohne Belegspeicherung ([peppol.md](peppol.md)) | Brücke zu Partnern ohne FediFinance; Backend wählt den Kanal über `DocumentTransport` |
| AI-Gateway | TypeScript/Node.js oder Rust (siehe decisions.md) | RAG, Tool-Calls, Mandantentrennung, Chatverlauf |
| LLM-Serving | vLLM (GPU) / llama.cpp (CPU, Entwicklung) | Inferenz, später LoRA je Mandant |
| Backup | Velero + DB-Backups/WAL | Cluster- und Datenbackup |

## PDF-Erzeugung und Gestaltung

FediFinance ruft das PDFCraft-Backend per REST auf (Vorschau über einen Backend-Proxy, finale Erzeugung bei der
Freigabe) und speichert die Ergebnisse; der Browser erhält nie ein PDFCraft-Token. Das Frontend übernimmt das
Material-Design-3-Fundament und den Papier-Editor von PDFCraft. Details: [pdfcraft.md](pdfcraft.md), [design.md](design.md).

## Mandantenmodell

- **Eine Instanz je Kunde**: eigener Kubernetes-Namespace `tenant-<id>`, eigener Helm-Release, eigene DB, eigene S3-Buckets (Zugangsdaten per Secret), eigenes KI-Silo.
- Provisionierung automatisch per Helm-Release (+ kleines Provisioning-Tool/Operator), Offboarding löscht Namespace und Daten.
- Teure/gemeinsame Ressourcen (GPU-Basismodell, Keycloak) werden cluster-weit geteilt, die **Daten** bleiben strikt je Mandant.
  Details zur KI: [ai.md](ai.md).
- NetworkPolicies verbieten Namespace-übergreifenden Verkehr; nur Ingress und gezielte Egress-Regeln (Föderation, Bank).

## Datenhaltung

- Strukturierte Daten in PostgreSQL. Gebuchte Datensätze sind append-only; Korrekturen via Storno-Buchung.
- PDFs und Belege im Archiv-Bucket (S3 mit Object Lock), adressiert über SHA-256; Arbeitsdaten im `data`-Bucket; Metadaten (Hash, Zeitstempel, Aufbewahrungsfrist) in der DB. Unveränderbarkeit: [compliance.md](compliance.md#technische-umsetzung-der-unveränderbarkeit-dokumentenarchiv).
- Von PDFCraft erzeugte PDFs werden bei der Freigabe einmal gerendert und mit eingebettetem XML und Render-Snapshot
  abgelegt, danach nie neu erzeugt ([pdfcraft.md](pdfcraft.md#3-integrationsarchitektur)).
- Audit-Log (unveränderlich, Hash-Kette) für alle buchungs- und sicherheitsrelevanten Aktionen.
- Datenminimierung: nur notwendige Felder; Lösch-/Sperrkonzept siehe [compliance.md](compliance.md).

## Repository-Struktur

```
backend/        Cargo workspace (api, domain, federation, archive, ...)
frontend/       TypeScript-Frontend (src/design/ = aus PDFCraft übernommenes Design-System, siehe UPSTREAM.md)
ai/             AI-Gateway, Evaluierung, Trainingspipeline
deploy/helm/    Helm-Charts (fedifinance, Cluster-Basis)
deploy/dev/     Dev-Umgebung (docker compose: Postgres, Keycloak, S3, Valkey, PDFCraft)
docs/           Dokumentation und Epics
assets/         Logo etc.
```
