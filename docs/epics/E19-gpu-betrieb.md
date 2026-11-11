# E19 – GPU-Betrieb (NVIDIA Ampere)

**Phase:** 4 · **Abhängig von:** E14, E16 · **Status:** offen

> Erst umsetzen, wenn Budget für Server vorhanden ist und PDFCraft/Digitalrechnung über Abos genügend Kunden hat.

## Ziel
KI-Betrieb auf Servern mit NVIDIA-Ampere-GPUs (z. B. A100/A30/A10) mit vLLM, Multi-LoRA und GPU-Scheduling im Kubernetes-Cluster.

## Kontext / Links
[ai.md](../ai.md)

## Definition of Done
- Größere Modelle laufen performant auf GPU, mehrere Mandanten teilen das Basismodell mit eigenen Adaptern, Kosten pro Mandant sind bekannt.

## Issues
- [ ] **E19-01 Hardware- und Kapazitätsplanung** – GPU-Typ, VRAM-Bedarf je Modellgröße/Quantisierung (bf16/INT8/INT4, kein FP8 auf Ampere), Durchsatz je Nutzer. AK: Planungsdokument.
- [ ] **E19-02 GPU-Nodes im Cluster** – NVIDIA GPU Operator, Treiber, Taints/Tolerations, Node-Labels, optional MIG (A100/A30). AK: Test-Pod sieht GPU.
- [ ] **E19-03 vLLM-Deployment** – Helm-Komponente, Modell-Cache (PVC), Autoscaling, Health. AK: Benchmark.
- [ ] **E19-04 Multi-LoRA** – Dynamisches Laden von Mandanten-Adaptern, LRU-Eviction, Isolation (kein geteilter Prefix-Cache über Mandanten). AK: Isolationstest.
- [ ] **E19-05 Modell-Upgrade auf größere Modelle** – Evaluierung (E14-02) gegen kleinere Modelle, Entscheidung. AK: ADR.
- [ ] **E19-06 Trainings-Jobs auf GPU** – Scheduling (Kueue/Volcano, OSS), Queue, Priorisierung, Kostenverrechnung. AK: Adapter-Training < Zielzeit.
- [ ] **E19-07 Monitoring GPU** – DCGM-Exporter, Dashboards, Alerts. AK: Dashboards.
- [ ] **E19-08 Preis-/Leistungsmodell** – Kosten je Mandant, Fair-Use-Limits, Paket-Stufen. AK: Dokument.
- [ ] **E19-09 Ausfallsicherheit** – Fallback auf CPU/kleineres Modell bei GPU-Ausfall. AK: Failover-Test.
