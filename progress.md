# PROGRESS — ai-stack

## Phase actuelle

Phase H — parité prouvée.
Branche `ai/claude-codex-parity`, partie de `main` (`cc6e9d2`).

## Tâche actuelle

H2 — tests de reprise croisée sur dépôts jetables.

## Dernière tâche validée

E1 et H1 — Antigravity décâblé, matrice de parité publiée dans `README.md`.

Validation :

- Dépôt : `antigravity/` supprimé, `shared/conv-exporter/hooks/antigravity_hook.py`
  retiré, mentions purgées d'`AGENTS.md`, `README.md` et des trois `REFERENCE.md`.
- Machine : `~/.gemini/{GEMINI.md,settings.json,config,commands,hooks}` et leurs
  `.bak` déplacés dans `.stack-backups/20260907-parity/gemini-decable/` ;
  `~/.agents/rules/` archivé. Seul `~/.gemini/antigravity-cli/` subsiste — runtime
  de l'application, non désinstallée.
- Recherche insensible à la casse sur `antigravity`, `gemini`, `AGY` : aucun
  câblage dans le dépôt ni dans la configuration active des deux harnesses ; seule
  occurrence restante, le contrôle qui vérifie cette absence.
- `bash ~/.agents/parity.sh` : `PARITÉ OK`.
- Checkpoint poussé : `63b3054` sur `origin/ai/claude-codex-parity`.

## Décisions actives

- Deux harnesses pairs. Aucun fallback, aucun propriétaire de projet.
- `~/.agents/` est le socle canonique commun : `CONTRACT.md`, `parity.sh`,
  `skills/`. Le miroir le représente dans `agents/`, seul propriétaire des skills
  partagés — `claude/skills/` ne les duplique plus.
- Le bloc canonique ne s'édite que dans `CONTRACT.md`, jamais dans un harness.
- `agents/skills/project-continuity/agents/openai.yaml` est le packaging Codex du
  skill ; encodage latin-1 hérité, laissé tel quel, hors périmètre.
- Aucune métrique de contexte ou de quota inventée : la frontière de session
  s'appuie sur un signal réellement exposé par le harness.
- Point de retour : tag `pre-parity-refactor-20260907` ; sauvegarde des configs
  live dans `C:\Users\FlowUP\.stack-backups\20260907-parity`.

## Blocage actif

Aucun.

## Fichiers / zones utiles

- Socle : `~/.agents/{CONTRACT.md,parity.sh,skills/}`.
- Live : `~/.claude/{CLAUDE.md,settings.json}`, `~/.codex/{AGENTS.md,config.toml}`.
- Dépôt : `agents/`, `README.md` (matrice de parité), `AGENTS.md` (contrat export).
- Bac à sable des tests : `%TEMP%/claude/.../scratchpad`.

## NEXT ACTION

H2 — exécuter les huit scénarios de reprise croisée sur des dépôts jetables :
initialisation par un harness et reprise par l'autre dans les deux sens,
réparation d'un `progress.md` faux de chaque côté, normalisation d'un plan
incomplet, absence d'arrêt artificiel après un PASS, contradiction entre
`progress.md` et les tests, et projet persistant sans remote GitHub. Conserver
pour chaque test une preuve vérifiable.
