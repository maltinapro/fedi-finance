# KI-Konzept

> Modellnamen/Versionen ändern sich schnell – vor der Umsetzung (Epic E14) Lizenz, Benchmarks und
> GPU-Speicherbedarf neu prüfen und als Entscheidung in [decisions.md](decisions.md) festhalten.

## Anforderungen

1. Pro Kunde ein eigenes **Datensilo** (PDFs, Rechnungen, Buchungen, Chats). Keine Vermischung zwischen Kunden.
2. Die KI beantwortet Fragen zur Buchhaltung und zu den Kundendaten, kann suchen und bei der Bedienung der Anwendung helfen.
3. Die KI hat vollen Lesezugriff auf die Kundendaten – aber nur im Rahmen der Rechte des angemeldeten Benutzers.
4. Sie soll sich anhand der Chats/Daten weiterentwickeln.
5. Betrieb zunächst ohne GPU (kleine Modelle/CPU, Entwicklung), später NVIDIA-Ampere-GPUs.
6. Nur Open-Source-Komponenten (Open-Weights-Modelle mit kommerziell nutzbarer Lizenz).

## Empfohlener Ansatz: RAG zuerst, Feintuning ergänzend

„Training mit den Kundendaten" ist für Fakten (Beträge, Rechnungen, Partner) **nicht** der richtige Hebel:

- Fakten im Modellgewicht sind ungenau (Halluzinationen), nicht aktuell und **nicht löschbar** – das kollidiert mit DSGVO
  (Löschung, Sperrung) und GoBD (Nachvollziehbarkeit, Quellenangabe).
- **RAG (Retrieval-Augmented Generation)** mit Quellenangaben ist genau, sofort aktuell, je Mandant isoliert und löschbar.

Deshalb drei Ebenen:

| Ebene | Inhalt | Mechanismus |
| --- | --- | --- |
| 1. Wissen des Kunden | PDFs, Belege, Buchungen, Partner | RAG: Chunks + Embeddings in pgvector (Mandanten-DB) + SQL-/Such-Tools (Function Calling) |
| 2. Produkt- und Fachwissen | Bedienung, Buchhaltungsregeln, Hilfe | Gemeinsamer, mandantenunabhängiger Wissensindex (Doku, Kontenrahmen, GoBD-Hinweise) |
| 3. Personalisierung | Sprachstil, Terminologie, Kontierungsgewohnheiten, Tool-Nutzung | **LoRA-Adapter je Mandant**, opt-in, aus freigegebenen Chats und Feedback; löschbar (Adapter-Datei) |

Zusätzlich: Strukturierte Aufgaben (Kontierungsvorschlag, Belegerkennung) sind klassifizierende Funktionen mit Feedback-Schleife
(Vorschlag → Nutzer bestätigt/korrigiert → Lernbeispiel), nicht freier Chat.

## Modellempfehlung (Stand Planung)

| Zweck | Empfehlung | Lizenz | Begründung |
| --- | --- | --- | --- |
| Chat/Reasoning (Start) | **Qwen3** (z. B. 8B/14B, später 32B) | Apache 2.0 | Gutes Deutsch, Tool-Calling, strukturierte Ausgabe, viele Größen |
| Alternative | **Mistral Small** (24B-Klasse) | Apache 2.0 | EU-Anbieter, starkes Deutsch/Französisch |
| Embeddings | **BGE-M3** oder Qwen3-Embedding | MIT / Apache 2.0 | Mehrsprachig, lange Kontexte |
| Reranker (optional) | BGE-Reranker | MIT/Apache 2.0 | Qualität der Treffer |
| OCR/Beleglesen | Tesseract / docling / PaddleOCR; später VLM | Apache 2.0 | Eingangsrechnungen und Scans |

Llama- und Gemma-Lizenzen sind keine OSI-Open-Source-Lizenzen und daher nicht Standard.

## Serving

- **Entwicklung/Start**: llama.cpp mit quantisierten Modellen auf CPU.
- **Produktion (Ampere, z. B. A100/A30/A10)**: **vLLM** (Apache 2.0) mit Multi-LoRA (ein Basismodell, viele Mandanten-Adapter).
  Ampere unterstützt bf16/INT8/INT4 (AWQ/GPTQ), aber **kein FP8** – Quantisierung entsprechend wählen.
- GPU-Nodes im Cluster mit NVIDIA GPU Operator, Scheduling per Taints/Tolerations; Basismodell cluster-weit geteilt.
- Mandantentrennung im Serving: Request trägt Mandanten-ID, Adapter wird pro Request gewählt, kein gemeinsamer Prompt-/KV-Cache über Mandanten.

## Datensilo-Prinzip

- Index (Embeddings), Chatverlauf und Adapter liegen **im Namespace des Mandanten** (DB + PVC).
- Das AI-Gateway läuft pro Mandant; es ruft das geteilte LLM nur mit Kontext aus dem eigenen Silo auf.
- Zugriffsrechte: Retrieval filtert nach den Berechtigungen des Benutzers (Rollen aus Keycloak).
- Export enthält Chats, Index-Metadaten und Adapter; Löschung des Mandanten löscht alles.

## Lernen aus Chats

1. Opt-in je Mandant, Datenschutzhinweis.
2. Chats/Feedback werden gefiltert (PII-Minimierung) und als Trainingsdatensatz im Mandanten-Storage abgelegt.
3. Periodische Trainingsjobs (LoRA/QLoRA, später GPU-Job) erzeugen Adapter-Versionen.
4. Automatische Evaluierung gegen ein Test-Set; Rollout nur bei Verbesserung, Rollback möglich.
5. Kein Training mit Daten eines Mandanten für einen anderen Mandanten (kein gemeinsames Feintuning ohne explizite Einwilligung).

## Sicherheit der KI

- Prompt-Injection-Schutz (Dokumentinhalt ist nicht vertrauenswürdig), Tool-Calls nur mit Benutzerrechten, Schreibaktionen nur nach Bestätigung.
- Jede Antwort nennt Quellen (Dokument/Buchung). Keine buchungsrelevanten Änderungen ohne menschliche Freigabe.
- Tool-Aufrufe werden im Audit-Log protokolliert.
