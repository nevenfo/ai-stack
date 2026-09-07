# conv-exporter — référence

**Dépôt :** https://github.com/nevenfo/conv-exporter (privé)
**Commit épinglé :** `b69164e68c53188c2c1cccbe3c40253678506fad` (2026-09-07)
**Rôle dans la stack :** à la fin de chaque session Claude Code ou Codex,
exporte la conversation en un `.md` unique dans l'inbox du Second
Brain (`Y:\second-brain\raw\inbox`). La reconstruction JSON brute reste locale
dans `spool/` du dépôt, hors du Second Brain.

`conv-exporter` était copié dans `snapshot/shared/` d'ai-stack ; il a son propre
dépôt depuis le 2026-09-07 (dossier live : `C:\Users\FlowUP\Documents\Etabli\Tools\conv-exporter`).

## Câblé dans la stack via

| Point de câblage | Déclaration |
|---|---|
| `claude/settings.json` → `hooks.SessionEnd` | `python C:/Users/FlowUP/Documents/Etabli/Tools/conv-exporter/hooks/claude_stop_hook.py` |
| `codex/config.toml` → `[[hooks.SessionEnd.hooks]]` | `python C:/Users/FlowUP/Documents/Etabli/Tools/conv-exporter/hooks/codex_session_end_hook.py` (premier hook SessionEnd, avant NOA) |

## Fichiers conservés ici (copie miroir de l'intégration)

- `hooks/claude_stop_hook.py` — hook `SessionEnd` Claude Code (nom historique)
- `hooks/codex_session_end_hook.py` — hook `SessionEnd` Codex

Source de vérité : le dépôt conv-exporter au commit épinglé.
