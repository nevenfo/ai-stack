# NOA — référence

**Dépôt :** https://github.com/nevenfo/noa (privé)
**Commit épinglé :** `9f42e185e59b198014108be1a0ba78e1e855fb7e` (2026-09-07)
**Rôle dans la stack :** sous-agents LLM locaux read-only que Claude Code, Codex
et Antigravity appellent volontairement pour l'exploration/analyse de volume,
plus l'observabilité KPI append-only de toute la stack.

NOA a été extrait d'`ai-stack` le 2026-09-07 (historique P5→P8 préservé). Son
code métier, ses tests, ses corpus et son observabilité vivent désormais dans son
propre dépôt. `ai-stack` n'en garde que la surface d'intégration ci-dessous.

## Câblé dans la stack via

| Point de câblage | Déclaration |
|---|---|
| `claude/settings.json` → `permissions.allow` | `Bash(C:/Users/FlowUP/noa/bin/noa-agent.cmd:*)` |
| `claude/settings.json` → `hooks.SessionEnd` | `python C:/Users/FlowUP/noa/hooks/claude_session_end.py` |
| `codex/config.toml` → `[[hooks.SessionEnd.hooks]]` | `python C:/Users/FlowUP/noa/hooks/codex_session_end.py` (à la suite du hook conv-exporter) |
| `claude/skills/noa-local-agents/`, `shared/agents/` (Codex), `antigravity/skills/noa-local-agents/` | skills qui instruisent l'appel de `noa-agent.cmd` |

Le modèle local, la fenêtre de contexte, le budget d'étapes et les rôles
(`explore`/`analyze`/`context`) sont définis dans `noa_agents/config.py` et
`roles.py` du dépôt NOA. Les KPI sont écrits dans `<dépôt noa>/metrics/events.jsonl`
et exportés par `noa-export.cmd`.

## Fichiers conservés ici (copie miroir de l'intégration)

- `bin/noa-agent.cmd`, `bin/noa-export.cmd` — wrappers appelés par les harnesses
- `hooks/claude_session_end.py`, `hooks/codex_session_end.py` — hooks `SessionEnd`

Source de vérité : le dépôt NOA au commit épinglé. Ces copies sont un reflet de
l'état câblé, resynchronisé par `export`.
