# PROGRESS — ai-stack

## Phase actuelle

Phase H — parité prouvée. Branche `ai/claude-codex-parity`, partie de `main`
(`cc6e9d2`).

## Tâche actuelle

G1.3 — intégrer la branche dans `main`.

## Dernière tâche validée

H2 — les six scénarios de reprise côté Claude Code, sur dépôts jetables.

Validation :

- `t1b-claude-resume` : un processus Claude Code sans contexte reprend une fixture
  initialisée par Claude Code, corrige un `progress.md` qui annonçait « 4 cas sur
  5 » pour un réel 3 sur 5, livre A1.2 puis enchaîne A2.1 sans s'arrêter.
  Résultat : `pass=6 fail=0`, trois commits, arbre propre, `continuity-check` OK.
- `t5c-claude-retest` : fixture dégradée — plan sans `Objectif`/`Dépendances`/
  `Validation`, `progress.md` annonçant « tests au vert » pour un `fail=1`,
  `NEXT ACTION` renvoyant à une phase inexistante. Réparée : `pass=6 fail=0`,
  unité normalisée aux quatre sections, `NEXT ACTION` unique, arrêt sur décision
  de périmètre. `continuity-check` OK.
- Défaut trouvé puis corrigé : à la première passe (`t5b-claude`), les intitulés
  de sections avaient été désaccentués — `### Dependances`, `## Decisions
  actives`. Ce sont des ancres de handoff ; le skill impose désormais des
  intitulés littéraux et invariants. Le rejeu confirme la correction.
- Aucun dépôt distant créé dans les bacs à sable ; l'absence de checkpoint durable
  est consignée dans le `progress.md` de chaque fixture.

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

G1.3 — ouvrir la pull request de `ai/claude-codex-parity` vers `main` sur
`nevenfo/ai-stack`, la fusionner après relecture du diff complet, puis vérifier
que `main` distant porte bien la refonte.
