# Architektur

## Überblick

```
            ┌──────────────── Kunde A (Namespace tenant-a, Domain a.example) ───────────────┐
 Browser ──▶│ Ingress ─▶ Frontend (TS) ─▶ Backend (Rust) ─┬─▶ PostgreSQL (+pgvector)         │
            │                                             ├─▶ Dateisystem/PVC (PDF-Archiv)   │
            │                                             ├─▶ PDFCraft (PDF-Erzeugung)       │
            │                                             ├─▶ AI-Gateway ─▶ LLM-Serving      │
            │                                             └─▶ Bank-Connector                 │
            └───────────────────────▲──────────────────────────────────────────────────────┘
                                    │ ActivityPub (HTTPS, HTTP Signatures)
            ┌───────────────────────▼──────────────────────────────────────────────────────┐
            │ Kunde B (Namespace tenant-b, Domain b.example) – identischer Aufbau           │
            └──────────────────────────────────────────────────────────────────────────────┘
 Cluster-weit: Keycloak (Realm je Mandant), Velero, Ingress, cert-manager, Monitoring, (GPU-)LLM-Serving
```

## Komponenten

| Komponente | Technologie | Aufgabe |
| --- | --- | --- |
| Backend | Rust (Axum, SQLx, Tokio) | REST/JSON-API, Buchungslogik, Föderation, Archiv, Jobs |
| Frontend | TypeScript (Vorschlag: React + Vite) | Web-UI, KI-Chat |
| Datenbank | PostgreSQL (Betrieb via CloudNativePG) | Stammdaten, Buchungen, Audit-Log, Vektorindex (pgvector) |
| Dokumentenspeicher | Dateisystem/PVC, hash-adressiert | Unveränderliche PDFs, Anhänge, Archiv |
| PDF | PDFCraft | Erzeugung aller PDFs (Rechnungen, Berichte, ggf. PDF/A, ZUGFeRD) |
| Identity | Keycloak | Login, SSO (OIDC/SAML, externe IdPs), Rollen |
| Föderation | ActivityPub im Backend | Austausch mit anderen FediFinance-Servern |
| AI-Gateway | TypeScript/Node.js oder Rust (siehe decisions.md) | RAG, Tool-Calls, Mandantentrennung, Chatverlauf |
| LLM-Serving | vLLM (GPU) / llama.cpp (CPU, Entwicklung) | Inferenz, später LoRA je Mandant |
| Backup | Velero + DB-Backups/WAL | Cluster- und Datenbackup |

## Mandantenmodell

- **Eine Instanz je Kunde**: eigener Kubernetes-Namespace `tenant-<id>`, eigener Helm-Release, eigene DB, eigener Storage, eigenes KI-Silo.
- Provisionierung automatisch per Helm-Release (+ kleines Provisioning-Tool/Operator), Offboarding löscht Namespace und Daten.
- Teure/gemeinsame Ressourcen (GPU-Basismodell, Keycloak) werden cluster-weit geteilt, die **Daten** bleiben strikt je Mandant.
  Details zur KI: [ai.md](ai.md).
- NetworkPolicies verbieten Namespace-übergreifenden Verkehr; nur Ingress und gezielte Egress-Regeln (Föderation, Bank).

## Datenhaltung

- Strukturierte Daten in PostgreSQL. Gebuchte Datensätze sind append-only; Korrekturen via Storno-Buchung.
- PDFs und Belege im Dateisystem, adressiert über SHA-256; Metadaten (Hash, Zeitstempel, Aufbewahrungsfrist) in der DB.
- Audit-Log (unveränderlich, Hash-Kette) für alle buchungs- und sicherheitsrelevanten Aktionen.
- Datenminimierung: nur notwendige Felder; Lösch-/Sperrkonzept siehe [compliance.md](compliance.md).

## Geplante Repository-Struktur

```
backend/        Cargo workspace (api, domain, federation, archive, ...)
frontend/       TypeScript-Frontend
ai/             AI-Gateway, Evaluierung, Trainingspipeline
deploy/helm/    Helm-Charts (fedifinance, Cluster-Basis)
docs/           Dokumentation und Epics
assets/         Logo etc.
```
