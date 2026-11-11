# Epics

Jedes Epic ist eine Datei `EXX-name.md` mit Ziel, Abhängigkeiten, Definition of Done und Issues.

## Konventionen

- Issue-IDs: `EXX-NN` (z. B. `E05-03`). Status per Checkbox: `- [ ]` offen, `- [x]` fertig.
- Jedes Issue hat eine kurze Beschreibung und Akzeptanzkriterien (AK).
- Pro Session: ein Epic oder ein zusammenhängender Teil davon → ein PR (Conventional-Commit-Titel).
- Beim Abschluss: Checkboxen, `docs/roadmap.md`, betroffene Docs und `AGENTS.md` aktualisieren.
- Epics dürfen angepasst werden; Änderungen mit Begründung im PR nennen, Entscheidungen in `docs/decisions.md` festhalten.
- Querschnittsanforderungen für **jedes** Issue: Tests, Doku, Datensparsamkeit, GoBD-Unveränderbarkeit, Mandantentrennung.

## Vorlage

```markdown
# EXX – Titel

**Phase:** … · **Abhängig von:** … · **Status:** offen

## Ziel
## Kontext / Links
## Definition of Done
## Issues
- [ ] **EXX-01 Titel** – Beschreibung. AK: …
## Offene Fragen
```

## Übersicht

Siehe [../roadmap.md](../roadmap.md).
