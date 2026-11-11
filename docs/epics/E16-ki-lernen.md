# E16 – KI-Personalisierung & kontinuierliches Lernen

**Phase:** 3 · **Abhängig von:** E15 · **Status:** offen

## Ziel
Das Modell passt sich je Kunde an (Terminologie, Kontierungsgewohnheiten, Stil) und verbessert sich aus Chats und Feedback – opt-in, löschbar, messbar.

## Kontext / Links
[ai.md](../ai.md) (Abschnitt „Lernen aus Chats")

## Definition of Done
- Pro Mandant können LoRA-Adapter trainiert, evaluiert, ausgerollt und zurückgerollt werden; Daten verlassen den Mandanten nicht.

## Issues
- [ ] **E16-01 Lernkonzept finalisieren** – Was wird gelernt (Stil/Tool-Nutzung/Kontierung) vs. was per RAG? Datenschutz- und GoBD-Bewertung. AK: ADR.
- [ ] **E16-02 Feedback- und Datensammlung** – Opt-in, Filter/PII-Minimierung, Trainingsdatensatz im Mandanten-Storage, Versionierung. AK: Datensatz-Export/Löschung.
- [ ] **E16-03 Trainingspipeline (LoRA/QLoRA)** – Kubernetes-Job, Konfiguration, Reproduzierbarkeit (Seed, Versionen), CPU-Fallback für kleine Modelle. AK: Adapter wird erzeugt.
- [ ] **E16-04 Evaluierung & Gate** – Automatischer Vergleich Adapter vs. Basis auf Mandanten-Testset + globalem Set; Regressionen blockieren. AK: Bericht pro Version.
- [ ] **E16-05 Adapter-Registry & Rollout** – Versionierung, Aktivierung je Mandant, Rollback, Speicherung im Mandanten-Storage. AK: Rollback getestet.
- [ ] **E16-06 Multi-LoRA-Serving** – Adapter-Wahl pro Request (vLLM, siehe E19), Fallback auf Basis. AK: Isolationstest.
- [ ] **E16-07 Kontierungs-Lernen** – Bestätigte Kontierungen als Trainings-/Retrieval-Beispiele (few-shot) zuerst, Feintuning später. AK: Verbesserung messbar.
- [ ] **E16-08 Löschung & Export** – Adapter und Trainingsdaten im Export (E13) und bei Löschung/Widerruf entfernen. AK: Test.
- [ ] **E16-09 Missbrauchs-/Vergiftungsschutz** – Filter gegen Prompt-Injection in Trainingsdaten, Review-Möglichkeit. AK: Tests.
- [ ] **E16-10 Globales Lernen (optional, explizit Opt-in)** – Anonymisierte, aggregierte Verbesserungen für das Basismodell. AK: Rechtliche Prüfung vor Umsetzung.
