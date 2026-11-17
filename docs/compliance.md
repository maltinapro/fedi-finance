# Compliance: GoBD, Aufbewahrung, E-Rechnung, DSGVO

> Arbeitsstand, kein Rechtsrat. Fristen und Pflichten vor Produktivstart durch Steuerberatung prüfen lassen und
> konfigurierbar halten.

## GoBD – Anforderungen und technische Umsetzung

| Grundsatz | Umsetzung |
| --- | --- |
| Nachvollziehbarkeit / Nachprüfbarkeit | Belegprinzip, lückenlose Verknüpfung Beleg ↔ Buchung, Audit-Log |
| Vollständigkeit | Fortlaufende Nummernkreise ohne Lücken, Prüfungen auf fehlende Belege |
| Richtigkeit | Validierungen (Soll = Haben, Steuer, Pflichtangaben nach UStG) |
| Zeitgerechte Buchung | Buchungs- und Belegdatum getrennt, Warnungen bei Rückdatierung, Periodensperre |
| Ordnung | Kontenrahmen (SKR03/SKR04), Journal- und Kontensicht |
| Unveränderbarkeit | Festschreibung; append-only; Storno statt Änderung; Hashwerte der Dokumente; Änderungsprotokoll |
| Verfahrensdokumentation | Generierte Dokumentation je Instanz (Verfahren, Rollen, IKS, Datensicherung) |
| Datenzugriff (Z1–Z3) | Export im Format der Betriebsprüfung (Beschreibungsstandard/`index.xml`), Prüferrolle (read-only) |
| Aufbewahrung | Fristen pro Dokumentenart, Sperrung gegen Löschung, Löschvorschlag nach Ablauf |

## Technische Umsetzung der Unveränderbarkeit (Dokumentenarchiv)

Die GoBD schreiben **keine bestimmte Technik** vor (kein WORM-Zwang). Die Unveränderbarkeit darf hardwaremäßig,
softwaremäßig oder organisatorisch sichergestellt werden; Änderungen müssen protokolliert werden und der Originalzustand
muss erkennbar bleiben (GoBD Rz. 107 ff., Randziffern von der Steuerberatung prüfen lassen). Konformität entsteht daher
aus dem **Verfahren** (siehe Verfahrensdokumentation), nicht aus dem Speichermedium. Ein gewöhnliches PVC (CephFS, RBD,
lokaler Storage) ist für sich genommen **nicht** unveränderbar: Ein Admin oder ein kompromittierter Pod könnte Dateien
überschreiben. Deshalb werden mehrere Schichten kombiniert; PDFs, XML und Render-Snapshots liegen **nicht** in der Datenbank
(DB-Admins könnten ebenso ändern, und Blobs blähen Backups und WAL auf):

| Schicht | Maßnahme | Epic |
| --- | --- | --- |
| 1. Hash-adressierte Ablage | Objektname = SHA-256 des Inhalts; die DB hält nur Metadaten (Hash, Zeitstempel, Aufbewahrungsfrist, Beleg-ID) | E08-01 |
| 2. Write-once in der Anwendung | Nur „neu anlegen, nie überschreiben“; kein Code-Pfad zum Ändern oder Löschen vor Fristablauf | E08-01 |
| 3. Technische Sperre im Storage | **S3 Object Lock** (Compliance-Modus) mit Retention bis Fristende, z. B. Ceph RGW; auch Admins können dann nicht ändern oder löschen. Bei reinem PVC nur schwächere Ersatzmaßnahmen (Rechte, Read-only-Mount) | E08-01, E12-04 |
| 4. Integritätsprüfung | Hash-Kette im Audit-Log, periodischer Hash-Abgleich, optional RFC-3161-Zeitstempel | E08-04, E08-05 |
| 5. Backup | Velero und DB-Backups auf getrenntes Ziel; ein einzelner Storage-Cluster (auch Ceph) ist kein Backup | E13 |
| 6. Verfahrensdokumentation | Beschreibung, wie Unveränderbarkeit, Zugriff und Aufbewahrung umgesetzt sind; Konformitätsnachweis | E08-08 |

Hinweis: Object Lock im Compliance-Modus ist nicht umkehrbar. Fehlerhaft abgelegte Objekte und Löschwünsche nach DSGVO
vor Fristablauf lassen sich dann nicht entfernen; das Lösch-/Sperrkonzept (E11-03) muss das berücksichtigen (Sperrung
statt Löschung, Löschung erst nach Fristende). Die Retention wird erst bei der Freigabe des Belegs gesetzt, nicht bei
Entwürfen oder Vorschauen.

## Aufbewahrungsfristen (Richtwerte Deutschland)

| Art | Frist |
| --- | --- |
| Bücher, Jahresabschlüsse, Inventare, Bilanzen | 10 Jahre |
| Buchungsbelege (inkl. Rechnungen) | 8 Jahre (seit 2025, zuvor 10) |
| Handels-/Geschäftsbriefe | 6 Jahre |

Fristen laufen ab Ende des Kalenderjahres der Entstehung. Alle Werte sind pro Dokumentart konfigurierbar; nach Ablauf
wird nicht automatisch gelöscht, sondern ein Löschvorschlag erzeugt (Freigabe + Protokoll). Verknüpfte KI-Indizes werden mitgelöscht.

## Rechtsformen und Prozesse

| Rechtsform | Gewinnermittlung | Besonderheiten |
| --- | --- | --- |
| Einzelunternehmen, Freiberufler, GbR | EÜR | Anlagenverzeichnis, ggf. Kleinunternehmerregelung (§ 19 UStG) |
| OHG, KG | Bilanz (doppelte Buchführung) | Gesellschafterkonten |
| UG, GmbH | Bilanz, Jahresabschluss | Offenlegung, E-Bilanz, Gesellschafterdarlehen |
| e. V. (optional, später) | Einnahmen-/Ausgabenrechnung / Bilanz | Sphären, Spendenquittungen |

Gemeinsame Prozesse: Rechnungsstellung, Eingangsrechnungen, Zahlungsabgleich, Mahnwesen, Umsatzsteuer-Voranmeldung,
Periodenabschluss, Jahresabschluss, Anlagenbuchhaltung. Der Funktionsumfang wird je Rechtsform über Profile/Feature-Flags gesteuert.

## E-Rechnung

- Empfangspflicht für inländische B2B-Rechnungen seit 1.1.2025; Ausstellungspflicht schrittweise (ab 2027 bzw. 2028).
- Formate: **XRechnung** und **ZUGFeRD/Factur-X (EN 16931)**. PDFCraft erzeugt PDF/A-3b mit eingebettetem XML
  (CII; in der PDFCraft-CI für einen festen Korpus mit Mustang validiert). Bettet PDFCraft wegen fehlender Angaben nur
  `invoice-draft.xml` ein, ist die Freigabe gesperrt; FediFinance validiert zusätzlich einen eigenen Korpus (E07-08).
- Archivierung im Originalformat (das strukturierte XML ist das maßgebliche Dokument); FediFinance legt PDF und XML
  getrennt mit Hash ab. Ein festgeschriebener Beleg wird nie neu gerendert – Designänderungen betreffen nur neue Belege.
- Pflichtangaben auf Rechnungen (§ 14 UStG) und Geschäftsbriefen (§ 37a HGB, § 35a GmbHG) kommen aus den Stammdaten
  (E04-01) – von der Steuerberatung prüfen lassen ([#45](https://github.com/maltinapro/fedi-finance/issues/45)).
- Der Transport über ActivityPub ist ein zusätzlicher Übertragungsweg; Fremdsysteme werden z. B. per E-Mail/Download bedient.

## DSGVO

- **Datenminimierung** und Zweckbindung je Datenfeld; Verzeichnis der Verarbeitungstätigkeiten als Vorlage.
- **Rollen**: Kunde = Verantwortlicher, Betreiber = Auftragsverarbeiter (AVV-Vorlage); Unterauftragnehmer dokumentieren.
- **Betroffenenrechte**: Auskunft, Berichtigung, Einschränkung, Export (Art. 15, 16, 18, 20). Löschung kollidiert mit der
  Aufbewahrungspflicht → Sperrung statt Löschung bis Fristablauf.
- Verschlüsselung: TLS überall, Verschlüsselung im Ruhezustand (Volume/DB), Secrets in Kubernetes-Secrets bzw. externem Secret-Store.
- Protokollierung ohne unnötige personenbezogene Daten; definierte Log-Retention.
- KI: keine Nutzung von Kundendaten außerhalb des Mandanten, Training nur opt-in, Löschbarkeit (siehe [ai.md](ai.md)).
- Hosting in der EU, keine Drittanbieter-SaaS für Kundendaten.
