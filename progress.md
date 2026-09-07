# PROGRESS — ai-stack

## Phase actuelle

Phase I — optimisation Pareto de la stack. Branche `ai/pareto-optimisation`,
partie de `main` (`46d2737`). Phase H reste ouverte sur H3 seul, bloqué par le
quota Codex.

## Tâche actuelle

I3 — compléter `continuity-check.sh` pour qu'il couvre réellement le contrat de
`progress.md`.

## Dernière tâche validée

I2 — `parity.sh` détecte désormais un miroir Git périmé.

Validation :

- `bash ~/.agents/parity.sh` : `PARITÉ OK`, exit 0, live et miroir alignés.
- Le contrôle a lui-même détecté sa propre copie miroir périmée avant
  resynchronisation — première détection réelle, non simulée.
- Trois tests négatifs, chacun suivi d'une restauration vérifiée par `diff` :
  miroir passé à `sonnet` → `FAIL miroir : Claude : opus` ; live passé à
  `sonnet` → `FAIL Claude : opus attendu` ; `caveman` réactivé dans le live
  Codex → `FAIL Codex : caveman devait être false`. Exit 1 dans les trois cas.
- I1 : le live n'a qu'une couche de settings applicable — ni `settings.local.json`,
  ni settings administrés, ni `ANTHROPIC_MODEL` — portant `model: opus` et
  `effortLevel: high`. Le miroir seul était faux, périmé depuis `cc6e9d2`.

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

I3.1 — étendre `~/.agents/continuity-check.sh` pour exiger `## Tâche actuelle`
et une preuve non vide sous `## Dernière tâche validée`, en conservant
l'unicité de `## NEXT ACTION`, puis prouver par quatre fixtures — section
absente, preuve absente, deux `NEXT ACTION`, snapshot conforme — que les trois
premières échouent et que la dernière passe.
