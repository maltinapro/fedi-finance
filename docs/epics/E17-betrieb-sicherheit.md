# E17 – Observability, Sicherheit & Betrieb

**Phase:** 2 · **Abhängig von:** E12 · **Status:** offen

## Ziel
Betriebsfähigkeit: Monitoring, Logging, Alerting, Sicherheitsmaßnahmen und Lieferketten-Sicherheit – mandantenfähig.

## Kontext / Links
[operations.md](../operations.md)

## Definition of Done
- Dashboards/Alerts je Mandant und global, zentrale Logs ohne personenbezogene Daten, Security-Scans in CI, dokumentierte Runbooks.

## Issues
- [ ] **E17-01 Metriken** – Prometheus/OpenTelemetry im Backend, Grafana-Dashboards (Latenz, Fehler, Jobs, Föderations-Queue). AK: Dashboards als Code.
- [ ] **E17-02 Logging** – Strukturierte Logs, Loki, Mandantenlabel, Retention. AK: Keine PII.
- [ ] **E17-03 Tracing** – OpenTelemetry-Traces (Tempo/Jaeger) über Frontend → Backend → Dienste. AK: Beispiel-Trace.
- [ ] **E17-04 Alerting** – Alertmanager-Regeln (Verfügbarkeit, Backup-Fehler, Integritätsfehler, Zertifikate). AK: Test-Alarme.
- [ ] **E17-05 Supply-Chain-Sicherheit** – SBOM, Image-Signierung (cosign), Trivy/Grype, `cargo audit`, `npm audit`. AK: In CI.
- [ ] **E17-06 Härtung** – Security-Header, Rate-Limiting, CSRF, Input-Validierung, Penetrationstest-Checkliste. AK: Bericht.
- [ ] **E17-07 Statusseite & SLOs** – Verfügbarkeitsziele, Healthchecks, Statusseite (OSS). AK: SLO-Dokument.
- [ ] **E17-08 Runbooks & Incident-Prozess** – Datenpannen-Meldung (72h), Eskalation. AK: Dokumente.
- [ ] **E17-09 Lasttests** – k6-Szenarien (Rechnungslauf, Föderation, PDF-Erzeugung). AK: Baseline-Bericht.
- [ ] **E17-10 Kostenüberwachung** – Ressourcennutzung je Mandant. AK: Dashboard.
