# E15 – KI-Assistent in der Anwendung

**Phase:** 3 · **Abhängig von:** E14, E03 · **Status:** offen

## Ziel
Chat-Assistent im Frontend, der Fragen zu Buchhaltung und Kundendaten beantwortet, Dokumente sucht und bei der Bedienung hilft.

## Kontext / Links
[ai.md](../ai.md)

## Definition of Done
- Benutzer stellt Fragen im Chat, erhält Antworten mit Quellenlinks; Assistent führt auf Wunsch Navigationen/Entwürfe aus (mit Bestätigung).

## Issues
- [ ] **E15-01 Chat-UI** – Streaming, Verlauf, Quellenkarten, Feedback (👍/👎), Kontext-Sidebar. AK: Barrierefrei, Tests.
- [ ] **E15-02 Tools für Datenabfragen** – Lese-Tools: Rechnungen suchen, Salden, offene Posten, Partner, Dokumente (mit Benutzerrechten). AK: Tool-Schemas + Tests.
- [ ] **E15-03 Bedienungshilfe** – Hilfe-Wissen (Docs), kontextbezogene Antworten („Wie storniere ich…?"), Deep-Links in die UI. AK: Evaluationsfälle.
- [ ] **E15-04 Aktionen mit Bestätigung** – Entwürfe (z. B. Rechnung, Kontierung) erzeugen; nie direkte Festschreibung; Vorschau + Freigabe. AK: Audit-Log.
- [ ] **E15-05 Kontierungsvorschläge** – Klassifikation für Eingangsrechnungen, Konfidenz, Feedback-Schleife. AK: Genauigkeit gemessen.
- [ ] **E15-06 Belegerkennung** – Extraktion aus hochgeladenen PDFs in Erfassungsmaske, Nutzer prüft. AK: Testkorpus.
- [ ] **E15-07 Antwortqualität & Guardrails** – „Ich weiß es nicht", Quellenpflicht, Haftungshinweise (kein Steuerrat). AK: Tests.
- [ ] **E15-08 Chat-Verwaltung** – Verlauf je Benutzer, Löschen, Export, Retention. AK: DSGVO-konform.
- [ ] **E15-09 Mehrsprachigkeit** – Deutsch zuerst, Englisch. AK: Evaluationsset je Sprache.
