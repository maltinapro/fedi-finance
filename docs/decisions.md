# Entscheidungen und offene Fragen

## Getroffen (Vorgaben)

| Thema | Entscheidung |
| --- | --- |
| Backend | Rust |
| Frontend | TypeScript (Node.js für Tooling) |
| Datenbank | PostgreSQL |
| Dateispeicher | S3 (Buckets `data` und `archive` mit Object Lock) für PDFs und Belege, nie in der DB und nicht auf PVCs ([storage.md](storage.md)) |
| Identity | Keycloak (OIDC, SSO, externe IdPs) |
| Föderation | ActivityPub |
| PDF | PDFCraft als zustandslose Render-Engine über REST (`/v1`); FediFinance speichert alle Daten und PDFs ([pdfcraft.md](pdfcraft.md)) |
| Gestaltung | Material Design 3 mit dem Design-System von PDFCraft (Tokens, Komponenten, Icons, Papier-Editor), Farbschema unverändert ([design.md](design.md)) |
| Deployment | Kubernetes + Helm, ein Namespace/Release je Kunde |
| Backup | Velero (Kopia, `snapshotMoveData`) + CloudNativePG/Barman + Archiv-Replikator, **Offsite** (S3 mit Object Lock, anderer Standort, EU) + Datenexport; Rhythmen, Aufbewahrung, RPO/RTO in [operations.md](operations.md#backup-und-restore) |
| Lizenzen | Nur Open-Source-Infrastruktur; einzige Ausnahme: ERiC für ELSTER (isoliert, optional, nicht im Repository/Image, [elster.md](elster.md)) |
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
| Dokumentenspeicher | **S3 only, provider-neutral:** zwei Buckets je Mandant, `data` (aktuelle Daten) und `archive` (Object Lock, hash-adressiert); Zugangsdaten als Secret im Mandanten-Namespace per Operator/Provisioner; kein PVC-Backend für Dokumente ([storage.md](storage.md)) | E08, E12 |
| Cluster-Storage | Rook-Ceph (min. 3 Nodes, Replikation 3): RBD für PVCs, RGW als S3-Dienst; für die Anwendung irrelevant ([storage.md](storage.md#6-cluster-storage-rook-ceph)) | E12 |
| Peppol | Optionale Brücke neben ActivityPub für Partner ohne FediFinance, nicht als Ersatz; Transport-Abstraktion im Backend (`DocumentTransport`), Kanalwahl ActivityPub → Peppol → E-Mail/Download; kein eigener Access Point je Mandant ([peppol.md](peppol.md)) | E18, E05 |
| Keycloak-Topologie | Ein Keycloak, ein Realm je Mandant | E02 |
| ELSTER | Direktübermittlung per ERiC in `elster-service` (Rust, `libloading`) je Mandant, Zertifikat des Unternehmens, PIN nicht gespeichert; Nachweise im Archiv ([elster.md](elster.md)) | E21 |
| Steuerberatung & Umstieg | DATEV-Export (Buchungsstapel + Belege) ist Pflicht, nicht optional; Import aus DATEV-Buchungsstapel, Lexware Office und sevDesk; beides vor dem ersten echten Kunden ([market.md](market.md)) | E20 |

## Offene Fragen

1. ~~**PDFCraft-Schnittstelle**~~ – geklärt (11/2026): REST-API `/v1` (OpenAPI 3.1), PDF/A-3b mit eingebettetem EN-16931-/XRechnung-XML, Token-Auth, zustandslos. Offen bleiben Deployment-Variante und Editor-Paket; die Anforderungen R1–R11 sind upstream umgesetzt und mit PDFCraft `v0.34.0` released ([pdfcraft.md](pdfcraft.md#7-anforderungen-an-pdfcraft-upstream)). (E07)
2. **ActivityPub in Rust**: vorhandene Bibliothek (z. B. `activitypub_federation`) oder Eigenbau? (E05)
3. **Bankanbindung** mit Open-Source-Mitteln: FinTS/HBCI vs. PSD2-Aggregator; kommerzielle Aggregatoren wären kein OSS. (E10)
4. ~~**ELSTER/UStVA**~~ – entschieden (24.11.2026): Direktübermittlung über ERiC als begrenzte Ausnahme vom Open-Source-Grundsatz, in einem optionalen Dienst je Mandant; ERiC stellt der Betreiber bereit, der auch die Hersteller-ID hält; Rückfall XML für Mein ELSTER bzw. DATEV-Export ([elster.md](elster.md)). Offen in E21-01: Bereitstellungsweg; in E21-14: Übermittlung im Auftrag (§ 87d AO). (E09, E21)
5. **AI-Gateway-Sprache**: Rust im Backend oder separater TypeScript/Node.js-Dienst? (E14)
6. **Keycloak je Mandant oder geteilt**: Isolation vs. Betriebsaufwand. (E02, E12)
7. **Zeitstempel/Revisionssicherheit**: Reicht Hash-Kette oder qualifizierter Zeitstempel (RFC 3161)? (E08)
8. **Projektlizenz** (siehe `LICENSE`) vs. Geschäftsmodell Hosting. Stand: MIT, vorläufig. MIT erlaubt proprietäre gehostete Forks; AGPL-3.0 würde das verhindern, würde aber die Einbindung in Fremdsysteme erschweren. Entscheidung beim Maintainer vor dem ersten Release; bis dahin tragen alle Manifeste `license = "MIT"`, Quelldateien brauchen keinen Lizenzkopf (Lizenz gilt über `LICENSE`). (E00)
9. **Domain des JSON-LD-Vokabulars** (z. B. `fedifinance.org`). Projektname bleibt „FediFinance“; die Domain muss vor E05 registriert bzw. festgelegt werden. (E00, E05)
10. **Zielmärkte** außer Deutschland (Österreich/Schweiz) – beeinflusst Kontenrahmen und Steuerlogik. (E09)
11. **Pflichtangaben auf Geschäftsbriefen** (§ 37a HGB, § 35a GmbHG) und Rechnungen (§ 14 UStG): Umsetzung über strukturierten Fuß (PDFCraft R10) – von Steuer-/Rechtsberatung prüfen lassen, Prüfliste in [#45](https://github.com/maltinapro/fedi-finance/issues/45). (E04, E07)
12. ~~**Archiv-Storage im Cluster**~~ – geklärt (11/2026): Start mit mindestens 3 Nodes, Rook-Ceph mit RGW und S3 Object Lock, Details und Begründung in [storage.md](storage.md). Offen zur Prüfung durch die Steuer-/Rechtsberatung: Compliance-Modus mit nicht umkehrbarer Retention und Aufbewahrung statt Löschung (Art. 17 Abs. 3 lit. b DSGVO). (E08, E11, E12)
13. **Peppol-Betriebsmodell**: externer Access Point per Provider-API (Datenverarbeitung durch Dritte, AVV, Opt-in) oder Betreiber-Gateway als Peppol-Service-Provider (z. B. phoss-ap/phoss-smp, Java; Aufnahme, MLS- und Reporting-Pflichten bei OpenPeppol zu klären)? (E18-01)
14. **UBL-Erzeugung für Peppol BIS Billing 3.0**: Peppol schreibt UBL vor (CII nur optional, wenn der Empfänger es im SMP registriert); PDFCraft erzeugt bisher CII; UBL-Ausgabe als neue Upstream-Anforderung R12 ([pdfcraft.md](pdfcraft.md#7-anforderungen-an-pdfcraft-upstream)) oder Konvertierung im Gateway? Dazu Validierung (XSD/Schematron: phive-rules-peppol, KoSIT). (E18-04, E18-05)
15. **Marktpositionierung und Primärzielgruppe**: Vorschlag „föderiertes Rechnungs- und Buchhaltungsnetz für den Mittelstand“ mit Start bei Unternehmensgruppen (Intercompany), Lieferketten-Clustern und Betreibern (Hoster/Kanzleien) statt Freelancern; daraus folgen DATEV-Export als Pflicht, Migrationsimport und ein gehostetes Angebot ([market.md](market.md#6-positionierungsvorschlag)). Entscheidung beim Maintainer; beeinflusst auch Nr. 8 (Lizenz). Zielgruppenunabhängige Folgerungen sind bereits in der Roadmap (E20, E05-02, E05-11, E05-13, E12-13). (E04, E05, E09, E12)

## Änderungsprotokoll

- Erstfassung der Planung.
- 11/2026: PDFCraft geprüft (Stand `00c5e04`): Anbindung per REST, Material Design 3 und Design-System aus PDFCraft übernommen, Frontend-Strategie festgelegt; E03, E07 überarbeitet, E04/E06/E12 ergänzt.
- 11/2026: Phase-0-Issues mit den Epics abgeglichen, E03-10 als #44 angelegt, Anforderungen R1–R11 als maltinapro/pdfcraft#214–#224, Rechtsprüfung als #45.
- 21.11.2026: PDFCraft erneut geprüft (Stand `6fbc2e6`): R1–R11 umgesetzt (maltinapro/pdfcraft#230–#240), aber noch nicht released (maltinapro/pdfcraft#244); Veröffentlichung der npm-Pakete `@pdfcraft/design`/`@pdfcraft/editor` blockiert (maltinapro/pdfcraft#243).
- 22.11.2026: PDFCraft `v0.34.0` geprüft: Image, OCI-Chart und npm-Pakete (umbenannt in `@maltinapro/pdfcraft-design`/`@maltinapro/pdfcraft-editor`, GitHub Packages) veröffentlicht; Smoke-Test der neuen Endpunkte erfolgreich; Dev-Umgebung auf `0.34.0` gehoben; Nacharbeiten in maltinapro/pdfcraft#251.
- 11/2026: E00 umgesetzt: Monorepo-Skelett, CI, Dev-Umgebung (`make dev`), Prettier ergänzt; SeaweedFS statt MinIO in der Dev-Umgebung; Lizenz-/Namensfragen dokumentiert.
- 11/2026: Archiv-Storage geklärt (Konzept): GoBD verlangt kein bestimmtes Medium; Ceph (CephFS/RBD/RGW) ist geeignet, Unveränderbarkeit über Hash-Adressierung, Write-once und S3 Object Lock; keine PDFs in der DB. E08-01, E11-03, E12-04, compliance.md ergänzt; Rückfrage als Nr. 12.
- 11/2026: Frage 12 geklärt: freie Wahl der Storage-Software im Cluster; Vorschlag Rook-Ceph (RGW + Object Lock), Alternativen nach Clustergröße.
- 11/2026: Start mit mindestens 3 Nodes festgelegt; Storage-Entscheidungen S1–S6 in [storage.md](storage.md) dokumentiert (Rook-Ceph, Object Lock, Backup-Ziel, Offboarding); Object Lock in SeaweedFS (Dev) geprüft.
- 11/2026: Offsite-Backup entschieden: Velero mit `snapshotMoveData`, Barman, Archiv-Replikator (E13-11) in ein S3-Ziel mit Object Lock an anderem Standort; Aufbewahrung 30 Tage/12 Wochen, RPO/RTO festgelegt; Rest-Unsicherheit nur noch Standort/Anbieter des Offsite-Ziels (Betreiberentscheidung).
- 11/2026: Storage auf „S3 only“ umgestellt: Anwendung kennt nur S3 (Ceph ist Infrastruktur), PVC-Dokumentenbackend entfällt, zwei Buckets je Mandant (`data`, `archive`), Zugangsdaten per Operator/Provisioner als Secrets (Rook-OBC für `data`, Provisioner-Job für `archive`, Spike zu Object Lock in OBC in E12-04).
- 11/2026: Peppol bewertet: optionale Brücke zusätzlich zu ActivityPub (kein Wechsel der Ausrichtung), neues Epic E18 in Phase 2, Konzept in [peppol.md](peppol.md); Transport-Abstraktion schon in E05-08 vorgesehen; Fragen Nr. 13–14, Anforderung R12 an PDFCraft vorgeschlagen.
- 24.11.2026: Peppol-Konzept gegen die aktuellen OpenPeppol-Spezifikationen geprüft und korrigiert: CII ist in BIS 3.0 optional (UBL Pflicht), MLS ersetzt MLR, Invoice Response nur im optionalen Profil 02; Details in [peppol.md](peppol.md#geprüfter-stand).
- 24.11.2026: Markt- und Wettbewerbsanalyse ([market.md](market.md)): Vergleich mit DATEV, Odoo, sevDesk, Lexware, Haben u. a.; Kern-USP ist der direkte Belegkreislauf zwischen Buchhaltungen (Föderation), nicht die E-Rechnung; Positionierungsvorschlag als offene Frage Nr. 15.
- 24.11.2026: Roadmap an die Marktanalyse angepasst: neues Epic E20 (Steuerberatung & Umstieg: DATEV-Export als Pflicht, Import aus DATEV/Lexware Office/sevDesk), E09-10 nach E20 verschoben; E05-02 (Vokabular früh veröffentlichen), E05-11 (Einladungshinweis im E-Mail-Fallback), neu E05-13 (Demo Unternehmensgruppe) und E12-13 (gehostetes Angebot). Zielgruppe (Nr. 15) bleibt offen.
- 24.11.2026: ELSTER-Anbindung entschieden (Nr. 4): ERiC als einzige Ausnahme vom Open-Source-Grundsatz, isoliert im optionalen `elster-service`; Konzept [elster.md](elster.md), neues Epic E21; Grundlage u. a. die ELSTER-Doku von Haben (Drittquelle, amtlich prüfen in E21-01).
