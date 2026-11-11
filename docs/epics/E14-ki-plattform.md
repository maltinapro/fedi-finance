# E14 – KI-Plattform & Datensilo (RAG)

**Phase:** 3 · **Abhängig von:** E08, E12 · **Status:** offen

## Ziel
Technische Basis der KI: Modell-Serving, Embedding-Pipeline, mandantenisoliertes Datensilo und Retrieval mit Quellenangaben.

## Kontext / Links
[ai.md](../ai.md)

## Definition of Done
- Pro Mandant: Dokumente/Buchungen werden indiziert, Fragen werden mit Quellenangabe beantwortet; keine Datenlecks zwischen Mandanten (Test).

## Issues
- [ ] **E14-01 Modellauswahl & Evaluierung** – Kandidaten (Qwen3, Mistral Small, …) auf deutschem Buchhaltungs-Testset vergleichen (Qualität, Tool-Calling, Speed, Lizenz). AK: ADR in decisions.md.
- [ ] **E14-02 Evaluierungs-Testset** – Fragen/Antworten zu Beispielbuchhaltungen, automatisierte Auswertung. AK: Reproduzierbar in CI/Job.
- [ ] **E14-03 LLM-Serving (CPU-Start)** – llama.cpp-Server im Cluster, OpenAI-kompatible API, quantisierte Modelle. AK: Helm-Komponente.
- [ ] **E14-04 AI-Gateway** – Dienst je Mandant: Auth, Rate Limit, Prompt-Assembly, Tool-Calling, Chat-Verlauf; Sprachentscheidung (decisions.md Nr. 5). AK: Mandanten-ID in jedem Request.
- [ ] **E14-05 Embeddings & Vektorspeicher** – BGE-M3, pgvector in Mandanten-DB, Chunking-Strategie, Metadaten (Rechte, Quelle). AK: Retrieval-Tests.
- [ ] **E14-06 Indexierungs-Pipeline** – Events (neuer Beleg/Buchung/Partner) → Text-Extraktion/OCR → Chunks → Index; Reindex, Löschung bei Dokumentlöschung. AK: Konsistenztests.
- [ ] **E14-07 OCR/Dokumentenverständnis** – Tesseract/docling für Scans, Extraktion strukturierter Rechnungsdaten. AK: Testkorpus.
- [ ] **E14-08 Retrieval mit Berechtigungen** – Filter nach Benutzerrechten, Quellenangaben in Antworten. AK: Negativtests (kein Zugriff auf fremde Daten).
- [ ] **E14-09 Fachwissen-Index (global)** – Dokumentation, Kontenrahmen, GoBD-Hinweise als gemeinsamer, mandantenunabhängiger Index. AK: Aktualisierbar.
- [ ] **E14-10 Mandantenisolation testen** – Automatisierte Tests/Red-Team (Prompt-Injection, Cross-Tenant-Abfragen, Cache-Leaks). AK: Testbericht.
- [ ] **E14-11 Sicherheit** – Prompt-Injection-Schutz, Tool-Whitelist, Audit-Log der KI-Aktionen. AK: Review.
- [ ] **E14-12 Datenschutz KI** – DSFA, Opt-ins, Löschung/Export von Chats und Index. AK: Verknüpfung E11/E13.
