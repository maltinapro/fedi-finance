# Roadmap

Status: `offen` · `in Arbeit` · `fertig`. Nach jedem abgeschlossenen Epic/Issue hier und in der Epic-Datei aktualisieren.

GitHub-Issues werden **phasenweise** angelegt (Epic-Issue + Sub-Issues je Task, Labels `epic`/`task`/`phase-N`).
Angelegt: Phase 0 (E00 #2, E01 #11, E02 #22, E03 #32). Phasen 1–4 folgen, sobald die vorherige Phase abgeschlossen ist.

## Phasen

- **Phase 0 – Fundament**: E00, E01, E02, E03
- **Phase 1 – MVP (Rechnungen föderiert versenden)**: E04, E05, E06, E07, E08
- **Phase 2 – Produktreife**: E09, E10, E11, E12, E13, E17
- **Phase 3 – KI**: E14, E15, E16
- **Phase 4 – Skalierung (GPU)**: E19

## Epics

| Epic | Titel | Phase | Abhängig von | Status |
| --- | --- | --- | --- | --- |
| [E00](epics/E00-projekt-fundament.md) | Projekt-Fundament | 0 | – | offen |
| [E01](epics/E01-backend-grundgeruest.md) | Rust-Backend-Grundgerüst | 0 | E00 | offen |
| [E02](epics/E02-identity-rollen.md) | Identity, Login, SSO, Rollen & Rechte | 0 | E01 | offen |
| [E03](epics/E03-frontend.md) | Frontend-Grundgerüst | 0 | E00, E02 | offen |
| [E04](epics/E04-stammdaten-partner.md) | Stammdaten & Geschäftspartner | 1 | E01, E02, E03 | offen |
| [E05](epics/E05-foederation-activitypub.md) | Föderation mit ActivityPub | 1 | E04 | offen |
| [E06](epics/E06-buchhaltungskern.md) | Buchhaltungskern & Rechnungen | 1 | E04 | offen |
| [E07](epics/E07-pdf-e-rechnung.md) | PDF-Erzeugung (PDFCraft) & E-Rechnung | 1 | E06 | offen |
| [E08](epics/E08-gobd-archiv.md) | GoBD, Dokumentenarchiv & Aufbewahrung | 1 | E06, E07 | offen |
| [E09](epics/E09-rechtsformen-prozesse.md) | Rechtsformen & Buchhaltungsprozesse | 2 | E06, E08 | offen |
| [E10](epics/E10-bankanbindung.md) | Bankanbindung | 2 | E06 | offen |
| [E11](epics/E11-datenschutz.md) | Datenschutz (DSGVO) | 2 | E01, E08 | offen |
| [E12](epics/E12-mandanten-infrastruktur.md) | Mandanten-Infrastruktur (Kubernetes/Helm) | 2 | E01, E03 | offen |
| [E13](epics/E13-backup-export.md) | Backup, Restore & Datenexport | 2 | E08, E12 | offen |
| [E14](epics/E14-ki-plattform.md) | KI-Plattform & Datensilo (RAG) | 3 | E08, E12 | offen |
| [E15](epics/E15-ki-assistent.md) | KI-Assistent in der Anwendung | 3 | E14, E03 | offen |
| [E16](epics/E16-ki-lernen.md) | KI-Personalisierung & kontinuierliches Lernen | 3 | E15 | offen |
| [E17](epics/E17-betrieb-sicherheit.md) | Observability, Sicherheit & Betrieb | 2 | E12 | offen |
| [E19](epics/E19-gpu-betrieb.md) | GPU-Betrieb (Ampere) | 4 | E14, E16 | offen |

(E18 ist bewusst nicht vergeben; Platz für spätere Epics, z. B. Mobile, Reporting, Integrationen/DATEV.)

## Empfohlene Reihenfolge für Sessions

1. E00 → E01 → E02 → E03 (lauffähiges Skelett mit Login)
2. E04 → E06 → E07 → E08 (Rechnung erstellen, PDF, archivieren)
3. E05 (Föderation) parallel/danach, sobald E04 steht
4. E12 + E13 (Deployment, Backup) vor dem ersten echten Kunden
5. E09, E10, E11, E17
6. E14 → E15 → E16, später E19
