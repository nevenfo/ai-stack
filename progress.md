# PROGRESS — ai-stack

## Phase actuelle

Phase E — suppression d'Antigravity.
Branche `ai/claude-codex-parity`, partie de `main` (`cc6e9d2`).

## Tâche actuelle

E1 — décâbler Antigravity du dépôt, des contrats et de la configuration active.

## Dernière tâche validée

F1 — contrôle de parité déterministe, avec son test négatif. Les phases B, C, D et
F sont closes : le contrat canonique est unique et injecté des deux côtés, le skill
`project-continuity` est partagé physiquement et complet, modèle et effort sont
alignés.

Validation :

- `bash ~/.agents/parity.sh` : `PARITÉ OK`, code de retour 0. Bloc canonique
  identique des deux côtés, 14 invariants présents, 3 skills partagés, modèle et
  effort conformes.
- Test négatif : un accent retiré dans le bloc côté Claude donne `PARITÉ ROMPUE`
  et un code de retour 1 ; `parity.sh --fix` restaure et repasse à 0.
- Jonctions : `sha256sum` identique via `~/.agents/skills/<s>` et
  `~/.claude/skills/<s>` pour les trois skills ; une écriture dans la source est
  vue immédiatement depuis `~/.claude`. Claude Code a rechargé les skills à
  travers les jonctions.
- `project-continuity` : les quatorze points du protocole sont couverts, vérifiés
  motif par motif ; `SKILL.md` fait 9 805 octets, `git-delivery.md` 5 414.
- Codex : `model = "gpt-6-astra"`, `model_reasoning_effort = "high"`, présents dans
  `~/.codex/models_cache.json` du client `0.153.4`.

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
- À décâbler : `antigravity/`, `shared/conv-exporter/hooks/antigravity_hook.py`,
  `~/.gemini/`, `~/.agents/rules/`, mentions dans `AGENTS.md` et `README.md`.

## NEXT ACTION

E1 — supprimer `antigravity/` du dépôt, retirer Antigravity des contrats
`AGENTS.md`, `README.md` et de `shared/`, archiver `~/.gemini/` et
`~/.agents/rules/` dans `.stack-backups` sans désinstaller le logiciel, puis
vérifier par recherche insensible à la casse qu'aucun câblage fonctionnel ne
subsiste.
