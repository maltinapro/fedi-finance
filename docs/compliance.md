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
- Formate: **XRechnung** und **ZUGFeRD/Factur-X (EN 16931)**. PDFCraft erzeugt das PDF/A-3; XML wird eingebettet.
- Archivierung im Originalformat (das strukturierte XML ist das maßgebliche Dokument).
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
