# Epics

Jedes Epic ist eine Datei `EXX-name.md` mit Ziel, Abhängigkeiten, Definition of Done und Issues.

## Konventionen

- Issue-IDs: `EXX-NN` (z. B. `E05-03`). Status per Checkbox: `- [ ]` offen, `- [x]` fertig.
- Jedes Issue hat eine kurze Beschreibung und Akzeptanzkriterien (AK).
- Pro Session: ein Epic oder ein zusammenhängender Teil davon → ein PR (Conventional-Commit-Titel).
- Beim Abschluss: Checkboxen, `docs/roadmap.md`, betroffene Docs und `AGENTS.md` aktualisieren.
- Epics dürfen angepasst werden; Änderungen mit Begründung im PR nennen, Entscheidungen in `docs/decisions.md` festhalten.
- Querschnittsanforderungen für **jedes** Issue: Tests, Doku, Datensparsamkeit, GoBD-Unveränderbarkeit, Mandantentrennung.

## GitHub-Issues und Board

- Die Markdown-Dateien sind die Quelle der Wahrheit für Scope und Akzeptanzkriterien; GitHub-Issues dienen der Steuerung.
- Pro Epic ein Issue (Label `epic`), pro Task ein Sub-Issue (Label `task`), dazu `phase-0` … `phase-4`.
- Issues werden phasenweise angelegt; der aktuelle Stand steht in [../roadmap.md](../roadmap.md).
- Das Kanban-Board (GitHub Project „FediFinance", Spalten Backlog / Ready / In progress / In review / Done) wird manuell in den GitHub-Projects angelegt.
- Beim Abschluss eines Tasks: Issue per PR schließen (`Closes #N`) und die Checkbox in der Epic-Datei abhaken.

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
