# PROGRESS — ai-stack

## Phase actuelle

Phase H — parité prouvée. Branche `ai/claude-codex-parity`, partie de `main`
(`cc6e9d2`).

## Tâche actuelle

H3 — tests de reprise croisée côté Codex, en attente de quota.

## Dernière tâche validée

G1 — le miroir reflète l'état live des deux harnesses, et `main` porte la refonte.

Validation :

- PR `nevenfo/ai-stack#1` fusionnée ; `main` distant est à `4c67e94`, arbre local
  propre, branche de travail supprimée.
- Diff relu avant chaque commit, aucun secret ni empreinte machine ajoutés.
- `bash agents/parity.sh` : `PARITÉ OK`. `bash agents/continuity-check.sh .` :
  `CONTINUITÉ STRUCTURELLE OK`.
- Claude confirmé sur `opus` + `effortLevel: high` (`~/.claude/settings.json`,
  `CLAUDE_EFFORT=high` dans l'environnement). Aucun autre fichier de settings ne
  contredit ce réglage.

## Décisions actives

- Deux harnesses pairs. Aucun fallback, aucun propriétaire de projet.
- `~/.agents/` est le socle canonique : `CONTRACT.md`, `parity.sh`,
  `continuity-check.sh`, `skills/`. Le miroir le représente dans `agents/`, seul
  propriétaire des skills partagés.
- Le bloc canonique ne s'édite que dans `CONTRACT.md`, jamais dans un harness.
- Les intitulés de sections de `plan.md`/`progress.md` sont littéraux, accents
  compris ; `continuity-check.sh` le vérifie et reste volontairement strict.
- Aucune métrique de contexte ou de quota inventée.
- Point de retour : tag `pre-parity-refactor-20260907` ; configuration live
  sauvegardée dans `C:\Users\FlowUP\.stack-backups\20260907-parity`.

## Blocage actif

H3 — les tests côté Codex sont bloqués : quota épuisé le 2026-09-07,
réinitialisation annoncée par le client au 2026-09-12 09:20. Le lancement a
toutefois confirmé la configuration : `model: gpt-6-astra`, `reasoning effort:
high`, hooks chargés. Fixtures prêtes et intactes : `t1-claude-init` et
`t5-degrade` dans le scratchpad de session.

Point d'attention distinct, sans action : Codex signale « Skill descriptions were
shortened to fit the skills context budget ». Des descriptions tronquées dégradent
le routage ; réduire le nombre de plugins activés relève d'un arbitrage
utilisateur.

## Fichiers / zones utiles

- Socle : `~/.agents/{CONTRACT.md,parity.sh,continuity-check.sh,skills/}`.
- Live : `~/.claude/{CLAUDE.md,settings.json}`, `~/.codex/{AGENTS.md,config.toml}`.
- Dépôt : `agents/`, `README.md` (matrice de parité), `AGENTS.md` (contrat export).
- Fixtures : `%TEMP%/claude/.../scratchpad/parity-tests/`.

## NEXT ACTION

H3.1 — dès la réinitialisation du quota Codex (annoncée au 2026-09-12 09:20),
lancer `codex exec -C <scratchpad>/parity-tests/t1-claude-init -s workspace-write
"Ce dossier est un bac à sable de test : ne crée aucun dépôt distant. Continue."`
et vérifier `pass=6 fail=0`, un arbre propre et `continuity-check` OK, puis
enchaîner H3.2 à H3.4. Si le scratchpad de session a expiré, recréer les fixtures
selon la description de H3 avant de lancer.
