# Markt, Wettbewerb und Positionierung

Arbeitsstand 24.11.2026. Vergleich von FediFinance mit DATEV, Odoo, sevDesk, Lexware und weiteren Anbietern,
Herausarbeitung der Alleinstellungsmerkmale und Vorschlag für die Marktpositionierung.

> **Quellenlage:** ✔ = am 24.11.2026 in Primärquellen geprüft (Quellcode/Lizenz auf GitHub, Links unten).
> ◐ = Marktwissen, **nicht** live geprüft (Herstellerseiten waren bei der Recherche nicht erreichbar). Preise,
> Eigentümer, Hosting-Standorte und Zertifikate vor jeder Veröffentlichung (Website, Pitch) auf den Herstellerseiten
> prüfen. FediFinance selbst ist im Stadium Konzept + Fundament (E00); Funktionen sind geplant, nicht fertig.

## 1. Marktüberblick

Der deutsche Markt für Buchhaltungssoftware kleiner und mittlerer Unternehmen teilt sich in vier Segmente:

| Segment | Anbieter (Auswahl) | Kern des Angebots |
| --- | --- | --- |
| Kanzlei-Ökosystem | DATEV | Steuerberatung als Zentrum; DATEV-Format ist der De-facto-Austauschstandard |
| SaaS für Selbstständige/KMU | Lexware Office (früher lexoffice), sevDesk, Buchhaltungsbutler, Billomat, FastBill | Einfache Bedienung, Bankabgleich, Belegerfassung, Abo-Preis |
| Spezial-SaaS | Candis (Eingangsrechnungen), Qonto (Bank + Rechnungen), Agicap (Liquidität) | Teilprozesse, ergänzend zur Buchhaltung |
| ERP / Open Source | Odoo, ERPNext, Haben, Invoice Ninja, Akaunting | Selbst betreibbar, funktionsreich; deutsche Compliance oft per Zusatzmodul |

Treiber 2025–2028:

- **E-Rechnungspflicht** (§ 14 UStG): Empfang seit 1.1.2025, Versand ab 2027 bzw. 2028 (siehe [compliance.md](compliance.md#e-rechnung)).
  Jedes Produkt muss XRechnung/ZUGFeRD können – das ist **Pflicht, kein Alleinstellungsmerkmal**.
- **ViDA** (EU): E-Rechnung nach EN 16931 und digitale Meldepflichten für innergemeinschaftliche Umsätze ab 2030;
  Peppol wird in mehreren Ländern zum Standardtransport ◐.
- **Digitale Souveränität**: Wunsch nach EU-/Eigenbetrieb, Sorge vor US-Zugriff (CLOUD Act) und Abhängigkeit von
  einzelnen Plattformen; der EU Data Act verlangt den einfachen Anbieterwechsel ◐.
- **KI**: Belegerkennung und Buchungsvorschläge sind bei SaaS-Anbietern Standard ◐; Open-Source-Projekte setzen auf
  optionale, lokale KI ✔ (Haben).
- **Steuerberatung bleibt Türsteher**: Ohne DATEV-Export ist ein Produkt für die meisten Mandanten nicht wählbar.

## 2. Wettbewerber

### DATEV ◐

- **Wer:** Genossenschaft (eG, Nürnberg) der Steuerberater; Marktführer in Kanzleien.
- **Modell:** Mandant erfasst in *DATEV Unternehmen online* (Belege, Rechnungen, Bankumsätze), die Kanzlei bucht.
  Für den Mittelstand zusätzlich eigene Rechnungswesen-Produkte. Betrieb im DATEV-Rechenzentrum (Deutschland) oder vor Ort.
- **Stärken:** Vertrauen, Vollständigkeit (Lohn, Steuern, Jahresabschluss), Prüfsicherheit, DATEV-Format als Standard,
  Schnittstellen (DATEVconnect, Marktplatz).
- **Schwächen:** Kanzlei-zentriert (Unternehmen haben wenig eigene Kontrolle), geschlossenes Ökosystem, Partnerzulassung
  für Schnittstellen, Bedienung gilt als komplex, regelmäßige Preisanpassungen.
- **Bezug zu FediFinance:** Kein direkter Gegner, sondern **Pflicht-Schnittstelle**. FediFinance führt die Bücher im
  Unternehmen und liefert per DATEV-Export an die Kanzlei.

### Odoo ✔/◐

- **Wer:** Odoo S.A. (Belgien); modulares ERP von CRM bis Lager.
- **Lizenz:** Community **LGPL-3** ✔, Enterprise proprietär ◐; viele Funktionen (u. a. Teile der deutschen Berichte,
  Bank-Synchronisation, OCR) nur in Enterprise oder über Partner/OCA-Module ◐.
- **Deutschland:** `l10n_de` mit SKR03/SKR04, Audit-Trail für GoBD standardmäßig erzwungen ✔, XRechnung 3.0 ✔,
  ZUGFeRD ✔; DATEV-Export über Enterprise oder OCA-Module (`datev_export`) ✔.
- **Peppol:** Modul `account_peppol` ✔, läuft aber über Odoos eigenen Proxy-Dienst (IAP) ✔ – der Zugangspunkt bleibt
  bei Odoo S.A.
- **Stärken:** Funktionsbreite, große Community, selbst betreibbar.
- **Schwächen:** Einführung meist über Partner, Abo pro Benutzer ◐, Buchhaltung ist ein Modul unter vielen,
  deutsche Tiefe (UStVA/ELSTER, Verfahrensdokumentation) uneinheitlich ◐.
- **Bezug zu FediFinance:** Konkurrent bei Unternehmen, die ein komplettes ERP wollen. FediFinance ist schmaler
  (Buchhaltung + Belege) und tiefer in GoBD-Archiv, Föderation und Datenhoheit. Odoo-Kunden sind über Peppol bzw.
  später einen ActivityPub-Connector erreichbar.

### sevDesk ◐

- **Wer:** Anbieter aus Offenburg; reines SaaS für Selbstständige und kleine Unternehmen.
- **Stärken:** Einfache Bedienung, Bankabgleich, KI-Belegerfassung, öffentliche REST-API ✔ (Drittanbieter-SDKs),
  DATEV-Export und Steuerberater-Zugang.
- **Schwächen:** Nur Cloud, Daten beim Anbieter, Preiserhöhungen und Lock-in werden häufig kritisiert.
  Eigentümerstruktur und Hosting-Standort vor Aussagen dazu prüfen.

### Lexware Office und Lexware classic ◐

- **Wer:** Haufe Group (Freiburg). *Lexware Office* (bis 2024 lexoffice) ist SaaS, *Lexware classic*
  (buchhaltung, financial office) Desktop-Software für Windows.
- **Stärken:** Bekannte Marke, breite Funktionalität inkl. Lohn (classic), DATEV-Export, E-Rechnung, Steuerberater-Anbindung.
- **Schwächen:** Öffentliche API laut Drittquelle nur im höchsten Tarif ✔ (Haben-Migrationsdoku); nach Kündigung
  liegt die Aufbewahrungspflicht beim Kunden, ein vollständiger Export ist aufwändig ✔ (dieselbe Quelle).
  Desktop-Linie mit veralteter Architektur ◐.

### Weitere SaaS-Anbieter ◐

| Anbieter | Fokus | Bezug zu FediFinance |
| --- | --- | --- |
| Buchhaltungsbutler | Bankabgleich, Belege, Steuerberatung | wie sevDesk/Lexware: Cloud, Daten beim Anbieter |
| Candis | Eingangsrechnungen, Freigaben, KI-Kontierung | ergänzend, keine Buchhaltung; zeigt Bedarf an KI-Kontierung |
| Billomat, FastBill | Rechnungsstellung | schmaler; Wettbewerb nur beim Rechnungsversand |
| Qonto, Agicap | Bank bzw. Liquidität | angrenzend; zeigen den Trend „Finanzen aus einer Hand“ |

### Open Source und selbst betreibbar ✔

| Projekt | Lizenz | Stand | Bezug zu FediFinance |
| --- | --- | --- | --- |
| **Haben** | AGPL-3.0 | Beta, seit 10/2026, ca. 800 Sterne, aktiv | **Nächster Wettbewerber:** selbst gehostet für Selbstständige bis kleine GmbH; E-Rechnung (KoSIT-Validator), Festschreibung per DB-Trigger, Änderungsprotokoll als Hashkette, Verfahrensdokumentation, DATEV-Export, ELSTER (ERiC), Bank (FinTS, Enable Banking), optionale KI (MCP), Lesezugang für die Steuerberatung, Migration aus lexoffice/sevDesk/FastBill/Buchhaltungsbutler, Partnerprogramm für Hoster und Kanzleien. Laut README **keine Föderation und kein Peppol** |
| ERPNext/Frappe | GPL-3 / MIT | reif; deutsche Funktionen als Zusatz-Apps | wie Odoo, deutsche Compliance über Community-Apps (DATEV-Export, E-Rechnung); ELSTER und Bank-EBICS unfertig bzw. kostenpflichtig |
| Invoice Ninja | Elastic License 2.0 (nicht OSI) | reif | Nur Rechnungen; XRechnung/ZUGFeRD und Peppol vorhanden; Betrieb als Dienst für Dritte verboten |
| Akaunting | BSL 1.1 (nicht OSI) | reif | Kostenlos nur für ≤ 2 Benutzer/1 Firma; keine deutsche E-Rechnung im Kern gefunden |

## 3. Vergleich

Legende: ● vorhanden · ◑ teilweise/kostenpflichtiges Zusatzmodul · ○ nicht vorhanden · *geplant (Epic)* bei FediFinance.
Angaben zu den Wettbewerbern ◐ außer bei Odoo-/Open-Source-Lizenzen und -Modulen.

| Kriterium | FediFinance | DATEV | Odoo | sevDesk | Lexware Office | Haben |
| --- | --- | --- | --- | --- | --- | --- |
| Betrieb | eigene Instanz je Firma (Kubernetes/Helm), selbst oder gehostet | DATEV-Rechenzentrum / vor Ort | SaaS oder selbst | SaaS | SaaS | selbst (Docker) |
| Open Source | ● (OSI, Lizenz offen: #8) | ○ | ◑ (Community) | ○ | ○ | ● (AGPL) |
| Datenhoheit beim Unternehmen | ● | ◑ (über Kanzlei) | ◑ | ○ | ○ | ● |
| **Direkter Austausch mit Geschäftspartnern** (Stammdaten, Belege, Status) | ● *E05* | ○ | ○ | ○ | ○ | ○ |
| **Partner per Domain finden, Stammdaten automatisch aktuell** | ● *E04/E05* | ○ | ○ | ○ | ○ | ○ |
| E-Rechnung XRechnung/ZUGFeRD | ● *E07* (PDFCraft) | ● | ● | ● | ● | ● |
| Peppol | ◑ *E18* (optional) | ◑ | ● (über Odoo-Proxy) | ? | ? | ○ |
| GoBD-Archiv mit technischer Sperre (Object Lock, Hash) | ● *E08* | ● | ◑ | ● | ● | ◑ (DB-Trigger, Hashkette) |
| DATEV-Export | ● *E20* | ● | ◑ | ● | ● | ● |
| ELSTER (UStVA) | ● *E21 (ERiC)* | ● | ◑ | ● | ● | ● |
| Bankanbindung | ● *E10* | ● | ◑ | ● | ● | ● |
| KI im eigenen Datensilo (Open-Weights, eigene GPU) | ● *E14–E16, E19* | ○ (Cloud-KI) | ◑ (IAP) | ○ | ○ | ◑ (optional, eigenes Modell) |
| Mandantenbetrieb für Hoster/Kanzleien | ● *E12* (Namespace je Mandant, automatisch) | ● | ◑ | – | – | ◑ (Partnerprogramm, Instanz je Kunde) |
| Lohn | ○ | ● | ◑ | ○ | ◑ | ○ |
| Reife | Konzept/Fundament | sehr hoch | hoch | hoch | hoch | Beta |

## 4. Alleinstellungsmerkmale

Ehrlich getrennt nach „nur FediFinance“, „selten“ und „Standard“.

### Nur FediFinance (Kern-USP)

1. **Buchhaltung, die mit den Geschäftspartnern spricht.** Jedes Unternehmen ist ein Knoten im Netz; Partner werden
   über ihre Domain gefunden (`f1.com`), nach Handshake werden Stammdaten (Adresse, USt-IdNr., Bankverbindung)
   **automatisch übernommen und aktuell gehalten** ([federation.md](federation.md)). Keine Abtipp- oder Bankdatenfehler,
   weniger Rechnungsbetrug durch gefälschte Bankverbindungen.
2. **Geschlossener Belegkreislauf zwischen zwei Buchhaltungen.** Rechnung, Empfangsbestätigung, Ablehnung und
   **Zahlungsbestätigung** laufen als strukturierte Nachrichten (`ff:InvoiceStatus`). Die Ausgangsrechnung beim Absender
   wird beim Empfänger direkt zur Eingangsrechnung (Entwurf) – ohne OCR, ohne Postfach. Peppol transportiert nur das
   Dokument, SaaS-Anbieter versenden E-Mails.
3. **Kein Plattformbetreiber in der Mitte.** Zustellung direkt von Server zu Server wie bei E-Mail oder Mastodon:
   kein Access-Point-Entgelt je Rechnung, kein zentraler Datenpool, kein Anbieter, der das Netz abschalten oder
   verteuern kann. Das Vokabular ist offen und versioniert, Dritte (ERP-Hersteller) können es implementieren.

### Selten (Differenzierung, aber nicht exklusiv)

4. **Datenhoheit ohne Selbstbetriebs-Zwang:** eigene Instanz je Unternehmen (eigene DB, eigene Buckets, eigenes KI-Silo),
   wahlweise beim Unternehmen, bei einem Hoster oder einer Kanzlei; vollständiger Export als Archiv (E13). Haben bietet
   Selbstbetrieb und ein Partnerprogramm für Hoster, aber keine automatisierte Mandanten-Plattform (Kubernetes/Helm);
   SaaS-Anbieter bieten Komfort, aber keine Datenhoheit.
5. **KI im eigenen Datensilo:** RAG mit Quellenangabe, Open-Weights-Modelle (Apache 2.0), optional eigene GPU,
   Personalisierung je Mandant ohne Datenabfluss ([ai.md](ai.md)). SaaS-Anbieter nutzen in der Regel Cloud-KI ◐.
6. **Revisionssicheres Archiv „by design“:** hash-adressiert, write-once, S3 Object Lock, Hash-Kette im Audit-Log,
   generierte Verfahrensdokumentation ([compliance.md](compliance.md)) – nachvollziehbar statt Blackbox-Versprechen.
7. **Konsequent Open Source bis in die Infrastruktur** (Rust, PostgreSQL, Keycloak, Ceph, vLLM) – im Gegensatz zu
   „Open Core“ (Odoo) oder source-available (Invoice Ninja, Akaunting).
8. **Ein Netz, drei Wege:** ActivityPub zu FediFinance-Partnern, Peppol zu allen anderen E-Rechnungs-Teilnehmern,
   E-Mail/Download als Rückfall – automatisch je Partner gewählt ([peppol.md](peppol.md)).

### Standard (Pflicht, kein Verkaufsargument)

XRechnung/ZUGFeRD, GoBD-Konformität, SKR03/SKR04, Bankabgleich, DATEV-Export, UStVA, Steuerberater-Zugang.
Hier muss FediFinance mithalten, kann sich aber nicht abheben.

## 5. Schwächen und Risiken

| Risiko | Wirkung | Gegenmaßnahme |
| --- | --- | --- |
| **Netzwerkeffekt-Kaltstart:** Föderation nützt erst, wenn Partner auch FediFinance nutzen | Kern-USP am ersten Tag kaum spürbar | Peppol- und E-Mail-Brücke machen das Produkt allein nutzbar; Einladungslink in jeder E-Mail-Rechnung; Start in Clustern (siehe §6) |
| Reife: Konzept, kein Code für Fachlogik | Kein Wettbewerb in den nächsten Monaten | MVP-Fokus Phase 1, Pilotkunden aus einem Cluster |
| DATEV-Export war nur „optional“ (E09-10) | Ausschlusskriterium für Steuerberatungen | Pflicht und vorgezogen: E20 (vor dem ersten echten Kunden) |
| ELSTER: ERiC nicht quelloffen, Hersteller-ID je Betreiber | Aufwand und Ausnahme vom OSS-Grundsatz | Entschieden: ERiC isoliert im optionalen Dienst (E21, [elster.md](elster.md)); Rückfall XML für Mein ELSTER bzw. DATEV-Export |
| Kein Import aus anderen Systemen (außer PDFCraft) | Wechselhürde | Migration aus lexoffice/sevDesk/DATEV-Buchungsstapel: E20-05 bis E20-08 |
| Betriebsaufwand (Kubernetes, Ceph, 3 Nodes) | Für Einzelunternehmer zu schwer | Gehostetes Angebot durch Betreiber/Partner (E12-13); Selbstbetrieb nur für IT-affine Kunden |
| Haben als Open-Source-Alternative mit Vorsprung | Kampf um dieselbe Community | Nicht auf Freelancer zielen, sondern auf vernetzte KMU (siehe §6); ggf. Kooperation (gemeinsames Vokabular) |
| MIT-Lizenz erlaubt proprietäre gehostete Forks | Geschäftsmodell Hosting angreifbar | Lizenzentscheidung #8 mit Blick auf die Positionierung treffen |
| Rechtliche Aussagen ungeprüft | Vertrauensverlust | Prüfung durch Steuerberatung (#45, E08-12); kein „GoBD-zertifiziert“ ohne Testat (z. B. IDW PS 880) |

## 6. Positionierungsvorschlag

**Kategorie:** Föderiertes Rechnungs- und Buchhaltungsnetz für den Mittelstand – nicht „noch eine Buchhaltungs-App“.

**Positionierungssatz (Entwurf):**
Für kleine und mittlere Unternehmen, die viele Rechnungen mit festen Geschäftspartnern austauschen und ihre Daten
selbst kontrollieren wollen, ist FediFinance die Buchhaltung, die Belege direkt mit den Buchhaltungen der Partner
austauscht – revisionssicher, ohne Plattform in der Mitte und auf dem eigenen oder einem vertrauten Server.
Anders als Lexware oder sevDesk gehören Daten und Netz dem Unternehmen; anders als DATEV steht das Unternehmen im
Mittelpunkt, die Kanzlei bekommt trotzdem alles im DATEV-Format.

**Claims (Entwurf):** „Rechnungen von Buchhaltung zu Buchhaltung.“ · „Deine Bücher. Dein Server. Dein Netz.“ ·
„E-Rechnung ohne Postfach und ohne Abtippen.“

### Zielgruppen (Reihenfolge)

| Priorität | Zielgruppe | Warum FediFinance hier gewinnt |
| --- | --- | --- |
| 1 | **Unternehmensgruppen** (Holding mit mehreren GmbHs, Franchise, Filialnetze) | Netz entsteht sofort intern: konzerninterne Rechnungen und Verrechnungen automatisch, beidseitig gebucht; kein Kaltstart |
| 2 | **Lieferketten-Cluster und Verbände** (Genossenschaften, Einkaufsverbünde, Handwerk mit festen Partnern) | Hohe Rechnungsfrequenz zwischen wenigen Partnern, ein Mitglied zieht die anderen nach |
| 3 | **Hoster, IT-Dienstleister und Kanzleien als Betreiber** | Mandantenbetrieb per Helm, Open Source ohne Lizenzkosten, eigenes Angebot „souveräne Buchhaltung“; Kanzleien behalten DATEV im Hintergrund. Haben wirbt hier bereits mit einem Partnerprogramm – Unterschied: Netz zwischen den Mandanten |
| 4 | Öffentliche Hand und souveränitätsorientierte Organisationen | Open Source, EU-Betrieb, XRechnung/Peppol; passt zu Open-Source-Strategien der Verwaltung ◐ |
| später | Selbstständige/Freelancer | Preis- und Komfortwettbewerb mit SaaS und Haben; nur über günstiges gehostetes Angebot |

### Folgerungen für die Roadmap

Umgesetzt in der Roadmap (24.11.2026) sind Nr. 1–5 und 7; Nr. 6 bleibt offene Entscheidung (decisions.md Nr. 8).

1. **DATEV-Export vorziehen und verpflichtend machen** → [E20](epics/E20-steuerberatung-umstieg.md) (E09-10 dorthin verschoben).
2. **Migrationsimport** aus lexoffice/Lexware Office, sevDesk und DATEV-Buchungsstapel → E20-05 bis E20-08.
3. **Viraler Rückfallweg:** E-Mail-Rechnungen mit Einladung „direkt empfangen mit FediFinance“; Kennzahl:
   Anteil föderierter Zustellungen → E05-11.
4. **Konzern-/Intercompany-Szenario** als erstes Demo- und Pilotszenario (mehrere Instanzen, gegenseitige Rechnungen,
   Zahlungsbestätigung) – zeigt den Kern-USP ohne fremde Partner → E05-13.
5. **Gehostetes Angebot** (Betreiber oder Partner) definieren, bevor Endkunden adressiert werden → E12-13.
6. **Lizenz (#8)** im Licht des Hosting-Geschäftsmodells entscheiden; Haben nutzt AGPL-3.0.
7. Vokabular früh als offene Spezifikation veröffentlichen (Domain, decisions.md Nr. 9), damit ERP-Hersteller und
   Projekte wie Haben oder Odoo-Module andocken können – das Netz wird größer als das Produkt → E05-02.

## 7. Offene Prüfpunkte

- Preise, Tarife, Eigentümer und Hosting-Standorte von DATEV, sevDesk, Lexware, Odoo, Buchhaltungsbutler, Candis,
  Billomat, FastBill auf den Herstellerseiten prüfen und hier nachtragen.
- Peppol-Angebot von DATEV, sevDesk und Lexware prüfen.
- Ob Odoos Peppol in der Community-Edition kostenlos nutzbar ist.
- Rechtliche Aussagen (E-Rechnungs-Fristen, GoBD-Testat, EU Data Act) durch Steuer-/Rechtsberatung bestätigen (#45).
- Primärzielgruppe als Entscheidung festhalten ([decisions.md](decisions.md), offene Frage Nr. 15).

## Quellen (geprüft 24.11.2026)

- Odoo: [LICENSE](https://github.com/odoo/odoo/blob/master/LICENSE),
  [l10n_de Manifest](https://github.com/odoo/odoo/blob/master/addons/l10n_de/__manifest__.py),
  [GoBD-Audit-Trail](https://github.com/odoo/odoo/blob/master/addons/l10n_de/models/res_company.py),
  [XRechnung](https://github.com/odoo/odoo/blob/master/addons/account_edi_ubl_cii/models/account_edi_xml_ubl_xrechnung.py),
  [Peppol](https://github.com/odoo/odoo/blob/master/addons/account_peppol/__manifest__.py),
  [OCA l10n-germany (DATEV)](https://github.com/OCA/l10n-germany)
- Haben: [Repository](https://github.com/Speicherstadt/haben),
  [Migration lexoffice](https://github.com/Speicherstadt/haben/blob/main/docs/lexoffice.md)
- ERPNext: [Lizenz](https://github.com/frappe/erpnext/blob/develop/license.txt),
  [erpnext_germany](https://github.com/alyf-de/erpnext_germany), [erpnext_datev](https://github.com/alyf-de/erpnext_datev)
- Invoice Ninja: [Lizenz](https://github.com/invoiceninja/invoiceninja/blob/v5-stable/LICENSE),
  [E-Rechnung/Peppol](https://github.com/invoiceninja/invoiceninja/tree/v5-stable/app/Services/EDocument/Standards)
- Akaunting: [Lizenz](https://github.com/akaunting/akaunting/blob/master/LICENSE.txt)
- sevDesk-API (Drittanbieter): [mcp-sevdesk](https://github.com/nikolausm/mcp-sevdesk)
