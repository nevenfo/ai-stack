# PROGRESS — ai-stack

## Phase actuelle

Phase I — optimisation Pareto de la stack. Branche `ai/pareto-optimisation`,
partie de `main` (`46d2737`). Phase H reste ouverte sur H3 seul, bloqué par le
quota Codex.

## Tâche actuelle

I4 — mesurer la configuration Codex réellement effective, avant toute coupe.

## Dernière tâche validée

I3 — `continuity-check.sh` couvre désormais le contrat de `progress.md`.

Validation :

- `bash ~/.agents/continuity-fixtures.sh` : `pass=4 fail=0`. Les trois fixtures
  dégradées échouent en exit 1, la conforme passe en exit 0, et chacune échoue
  sur sa seule cause — le test rejette une fixture qui produirait plus d'un
  `FAIL`.
- `bash ~/.agents/continuity-check.sh .` : `CONTINUITÉ STRUCTURELLE OK`, dont
  « section « Tâche actuelle » » et « preuve de la dernière tâche validée ».
- `bash ~/.agents/parity.sh` : `PARITÉ OK`, miroir compris.

## Décisions actives

- Deux harnesses pairs. Aucun fallback, aucun propriétaire de projet.
- `~/.agents/` est le socle canonique : `CONTRACT.md`, `parity.sh`,
  `continuity-check.sh`, `skills/`. Le miroir le représente dans `agents/`, seul
  propriétaire des skills partagés. `agents/` est une copie physique, donc une
  surface de dérive : `parity.sh` en exige maintenant l'identité stricte.
- Le miroir n'est jamais comparé brut au live : `codex/config.toml` y normalise
  volontairement les tables `[projects.*]`. Seules les valeurs sémantiques
  critiques sont contrôlées.
- Côté Claude Code, `/model` persiste son choix dans `~/.claude/settings.json` :
  défaut et dernier choix de session sont un seul et même champ. Documenté dans
  `README.md` comme source de dérive connue.
- Le bloc canonique ne s'édite que dans `CONTRACT.md`, jamais dans un harness.
- Une tâche déclarée validée doit porter une preuve listée sous `Validation :` ;
  le contrôle exige le marqueur littéral et au moins une puce, sans juger la
  valeur de la preuve.
- Les intitulés de sections de `plan.md`/`progress.md` sont littéraux, accents
  compris ; `continuity-check.sh` le vérifie et reste volontairement strict.
- Aucune métrique de contexte ou de quota inventée. Chaque unité de la phase I
  est indépendante et réversible.
- Point de retour : tag `pre-parity-refactor-20260907` ; configuration live
  sauvegardée dans `C:\Users\FlowUP\.stack-backups\20260907-parity`.

## Blocage actif

H3 — les tests de reprise croisée côté Codex sont bloqués : quota épuisé le
2026-09-07, réinitialisation annoncée par le client au 2026-09-12 09:20. Le
lancement a confirmé la configuration : `model: gpt-6-astra`, `reasoning effort:
high`, hooks chargés. Fixtures `t1-claude-init` et `t5-degrade` prêtes dans le
scratchpad de session. La phase I n'en dépend pas et se poursuit.

## Fichiers / zones utiles

- Socle : `~/.agents/{CONTRACT.md,parity.sh,continuity-check.sh,skills/}`.
- Live : `~/.claude/{CLAUDE.md,settings.json}`, `~/.codex/{AGENTS.md,config.toml}`.
- Profils Codex : `~/.codex/config.toml` plus `codex/cli-lean.config.toml` et
  `codex/cli-kicad.config.toml` dans le miroir.
- Dépôt : `agents/`, `README.md` (matrice de parité), `AGENTS.md` (contrat export).
- Fixtures H3 : `%TEMP%/claude/.../scratchpad/parity-tests/`.

## NEXT ACTION

I4.1 — établir comment la version Codex installée charge et fusionne
`config.toml` et les profils `cli-lean` / `cli-kicad` : lire l'aide et la
documentation du client installé, puis relever sur une session réelle les
plugins actifs, les MCP visibles et les skills visibles, sans rien supposer de
l'effet d'un `enabled = false` sur une table héritée.
