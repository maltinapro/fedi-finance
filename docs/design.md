# Design-Leitfaden

FediFinance wird wie [PDFCraft](https://github.com/maltinapro/pdfcraft) in **Material Design 3** gestaltet und
übernimmt dessen Design-System. Verbindliche Grundlage ist der
[PDFCraft-Design-Guide](https://github.com/maltinapro/pdfcraft/blob/main/docs/16-design-guide.md) (Prinzipien,
Farben, Typografie, Abstände, Komponenten, Barrierefreiheit, PDF-Designs). Dieses Dokument beschreibt nur, was
FediFinance **übernimmt, ergänzt oder abweicht**. Jede UI-Änderung richtet sich danach; Abweichungen werden hier im
selben PR dokumentiert.

Umsetzung: Fundament und Shell in [E03](epics/E03-frontend.md), Belegeditor und PDF-Designs in
[E07](epics/E07-pdf-e-rechnung.md). Herkunft und Abgleich des übernommenen Codes: [pdfcraft.md](pdfcraft.md#6-frontend-strategie).
Die Spalte „Ort in FediFinance" beschreibt die Kopie; bei Nutzung des Pakets `@maltinapro/pdfcraft-design` (E03-10)
kommen dieselben Dateien aus dem Paket.

## 1. Übernommen (unverändert)

| Bereich | Aus PDFCraft | Ort in FediFinance |
| --- | --- | --- |
| Farbrollen hell/dunkel, hoher Kontrast, `forced-colors` | `frontend/src/styles/tokens.css` (Guide 4.1, 8.1) | `frontend/src/design/tokens.css` |
| Kontrasttest aller Rollenpaare (≥ 4,5:1 Text, ≥ 3:1 UI) | `tokens.test.mjs` | `frontend/src/design/` |
| Typografie: Inter Variable (self-hosted), Skala `display` … `label-m`, `tabular-nums` für Beträge | Guide 4.2 | Tokens |
| Abstände (4-px-Raster), Radien, tonale Elevation, Motion inkl. `prefers-reduced-motion` | Guide 4.3 | Tokens |
| Komponenten: gefüllte Textfelder/Selects/Textareas, Buttons (filled, tonal, text, icon, danger tonal), Segmented Button, Chips, Banner, Snackbar, Dialog, Menü, Bottom Sheet, Card, Empty State | `components/ui/` | `frontend/src/design/ui/` |
| Icons: ein Outline-Set als Inline-SVG (24-px-Raster, 1,75 px Strich), keine Emojis als Icons | `components/icons.tsx` | `frontend/src/design/icons.tsx` |
| Theme: *System* (Standard), *Hell*, *Dunkel*; gesetzt vor dem ersten Paint | `lib/theme.ts` | `frontend/src/design/theme.ts` |
| Barrierefreiheit: WCAG 2.2 AA, 48-px-Touch-Ziele, sichtbarer Fokusring (2 px `primary`), Farbe nie einziges Signal | Guide 8 | überall |
| Papier-Editor mit vier Zonen und Zonenfarben (violett, koralle, bernstein, grün) | Guide 2 | Belegeditor (E07-06) |
| PDF-Designs *Classic*, *Modern Minimal*, *Contrast* | Guide 10 | Erscheinungsbild (E07-03) |

### Farben und Logo

Das FediFinance-Logo (Navy `#1D0E69`, Koralle `#EA8E6B`, Gold `#E6BC61`) passt zum PDFCraft-Schema: Im HCT-Farbmodell
von Material liegt das Navy bei Farbton 290, der PDFCraft-Seed `#4A2FB0` bei 294 (gleiche Tonalität). Das Schema
(Seed `#4A2FB0`, `SchemeFidelity`) wird deshalb **unverändert** übernommen; beide Produkte sehen wie eine Familie aus.

- Koralle (2,3:1) und Gold (1,7:1) erreichen auf `surface` keinen AA-Kontrast: nur Logo und Landing-Hero, nie für
  Text oder Bedienelemente.
- Die PDF-Akzentfarbe eines Mandanten ist Belegeinhalt und färbt nie die App.
- Belegarten und Kontenarten bekommen keine eigenen Farben (Guide 4.1): Icon + Label.

## 2. Ergänzt (FediFinance-spezifisch)

### 2.1 Navigation

Globale Ziele mit Ein-Wort-Labels (≤ 10 Zeichen), wie in PDFCraft unten als Navigationsleiste (< 840 px) und als
Tabs in der oberen Leiste (≥ 840 px). Maximal fünf Ziele:

| Ziel | DE | EN | Inhalt |
| --- | --- | --- | --- |
| Start | Start | Home | Belege erstellen, Aufgaben (Freigaben, Eingänge, offene Posten), Erste Schritte |
| Belege | Belege | Documents | Ausgangs- und Eingangsbelege, Angebote … Lieferscheine, Archiv, ZIP-Download, Storno, Folgebelege |
| Partner | Partner | Partners | Kunden, Lieferanten, föderierte Partner, Artikel (Tabs) |
| Buchhaltung | Buchhaltung | Accounting | Journal, Konten, Bank, Auswertungen, Umsatzsteuer, Abschluss (Tabs) |
| Mehr | Mehr | More | Unternehmen & Erscheinungsbild, Benutzer & Rollen, Export, E-Rechnung prüfen, Einstellungen, Hilfe, Rechtliches |

- Untergliederung innerhalb eines Ziels über Tabs bzw. Segmented Buttons, nicht über weitere Navigationsebenen.
- Ziele und Aktionen ohne Berechtigung werden ausgeblendet; sichtbar, aber gesperrt nur mit erklärendem Hinweis
  (z. B. „Festgeschrieben – Korrektur per Storno").
- Obere Leiste rechts: höchstens eine Primäraktion, Benachrichtigungen (Föderations-Eingang, Freigaben) als Badge,
  Überlaufmenü mit Mandant, Benutzer, Sprache, Theme, Abmelden. Mandantenlogo/-name links neben dem Seitentitel
  (kompakt nur Logo).
- Der KI-Assistent (E15) öffnet als Side Sheet rechts (≥ 840 px) bzw. Vollbild-Dialog (kompakt), nicht als
  eigenes Navigationsziel.

### 2.2 Neue Komponenten

| Komponente | Regeln |
| --- | --- |
| **Datentabelle** | Für Journal, Konten, offene Posten, Belegliste ≥ 840 px: Zeilenhöhe 48 px (kompakt 40 px wählbar), Kopf `label-l`, sticky; Beträge rechtsbündig mit `tabular-nums`, Soll/Haben getrennte Spalten; Sortierung per Kopf (`aria-sort`), Filter-Chips über der Tabelle, Zeilenaktionen im Überlaufmenü; Auswahlmodus für Massenaktionen; Export CSV. < 840 px: M3-Listeneinträge (zwei Zeilen: Titel + Betrag, Untertitel). Keine Zebra-Streifen, Trennlinien `outline-variant`. |
| **Status-Chip** | Belegstatus mit Icon + Text: *Entwurf*, *Freigegeben*, *Festgeschrieben* (Schloss), *Storniert*, *Versendet*, *Zugestellt* (Föderation), *Bezahlt*, *Überfällig*. Farben nur über `success`/`warning`/`error`-Container; neutral sonst. |
| **Partner-Herkunft** | Badge *föderiert* (mit Domain, z. B. `f1.com`) vs. *lokal*; Synchronisationszeitpunkt als Supporting Text. |
| **Buchungszeilen-Editor** | Soll/Haben-Zeilen als Karten wie die Positionskarten des Editors; Konto-Auswahl mit Suche (Nummer + Name), Live-Saldo „Differenz 0,00 €" als Summenkarte; Speichern erst bei Saldo 0. |
| **Historie/Audit** | Zeitleiste (Datum, Benutzer, Aktion) in einer Card; festgeschriebene Stände sind nicht editierbar. |
| **Unveränderlichkeits-Hinweis** | Bei festgeschriebenen Belegen: Banner mit Schloss-Icon, Hash (gekürzt, kopierbar), Archivdatum; Aktionen *Stornieren* / *Gutschrift erstellen*, nie *Bearbeiten*. |

### 2.3 Belegeditor

Der Papier-Editor aus PDFCraft (Zonen, Stepper, Klick auf das PDF, Splitter, Formular/Vorschau-Tabs) wird für alle
Belegarten übernommen. Ergänzungen:

- **Zone 1 *Absender & Aussehen*** zeigt die Unternehmensdaten und das Erscheinungsbild **nur lesend** mit Link zu
  *Mehr → Unternehmen & Erscheinungsbild* (Rolle nötig). Pro Beleg wählbar sind höchstens Design und Texte, falls das
  Unternehmen es erlaubt.
- **Zone 2 *Empfänger*** wählt einen Partner (Suche über Stammdaten und föderierte Partner); freie Eingabe legt auf
  Wunsch einen Partner an.
- **Zone 4 *Positionen*** nutzt den Artikelstamm; Steuerfälle (Reverse Charge, Kleinunternehmer, steuerfrei) erzeugen
  die Pflichthinweise automatisch.
- **Primäraktion** am Ende ist *Freigeben* (statt „PDF erstellen"); vorher ein Bestätigungsdialog mit Belegnummer,
  Empfänger, Betrag, Versandweg. Nach der Freigabe zeigt die Seite das **archivierte PDF** (nicht neu gerendert)
  mit Unveränderlichkeits-Hinweis.
- Vorschau-PDFs tragen „Entwurf"; das XML im Vorschau-Dialog ist als Entwurf gekennzeichnet.
- Speicherstatus bezieht sich auf den **Server** („Entwurf gespeichert"), nicht auf den Browser.

## 3. Abweichungen von PDFCraft

| PDFCraft | FediFinance | Grund |
| --- | --- | --- |
| Prinzip „Local-first trust": Daten im Browser, Sicherungs-Erinnerung | Server ist Quelle der Wahrheit; im Browser nur UI-Präferenzen (Theme, Sprache, Splitter-Position), keine Beleg- oder Kundendaten | GoBD, Mehrbenutzer, DSGVO |
| Ziele Start / Belege / Kunden / Mehr | Start / Belege / Partner / Buchhaltung / Mehr | Buchhaltungsfunktionen |
| „PDF erstellen" als letzte Aktion | „Freigeben" (Nummer, Festschreibung, Archiv) | GoBD |
| Free-Token, Kaufseite, Landing/SEO-Seiten | entfällt; Login über Keycloak | anderes Produkt |
| Hash-Router | Router mit echten Pfaden und Auth-Guards (E03-01) | Deep-Links, Rollen |
| Nur Formulare und Listen | zusätzlich Datentabellen (2.2) | Buchhaltungsdaten |

## 4. Sprache und Inhalte

- Deutsch zuerst, Englisch vollständig (E03-06). Labels kurz, Verb zuerst bei Buttons („Beleg freigeben").
- Fachbegriffe (Leitweg-ID, EN 16931, Festschreibung, Reverse Charge) werden im Supporting Text erklärt.
- Beträge, Daten und Prozente nach Locale; Währung mit geschütztem Leerzeichen.
- Keine Beispieldaten-Generatoren; nur die Demo-Instanz enthält gekennzeichnete Musterdaten.
- Compliance ehrlich: nur behaupten, was geprüft ist (z. B. „EN 16931/XRechnung, in CI validiert"); keine
  Zertifikats- oder „GoBD-zertifiziert"-Aussagen ohne Prüfung.

## 5. Prüfung

- Kontrasttest (Tokens) in CI.
- Screenshot-Matrix wie in PDFCraft: 320/390/768/1440 px, DE/EN, Hell/Dunkel für jede Seite (E03-08); bei Änderungen
  an PDF-Ausgabe zusätzlich gerasterte PDFs ansehen.
- Nichts in der oberen Leiste oder Navigation bricht zwischen 320 und 1440 px um.
