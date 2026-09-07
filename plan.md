# PLAN — ai-stack, miroir de configuration

## Objectif

`ai-stack` est **uniquement** la représentation Git propre et utile de la
configuration actuelle de la stack IA (Claude Code, Codex, Antigravity) et des
composants qui participent directement à son fonctionnement.

`export` est une procédure 100 % agentique : l'IA ré-inspecte le PC en lecture
seule à chaque invocation, raisonne sur le périmètre, synchronise le dépôt, relit
le diff, vérifie l'absence de secret, commit ciblé, push `main`. Contrat unique :
`AGENTS.md`.

## Invariants

- Aucune décision de périmètre déterministe : ni `export.rules.json`, ni manifeste,
  ni whitelist, ni moteur Python. Les outils (`rg`, `fd`, PowerShell, Git) sont des
  bras.
- La source de vérité est la configuration live. Le dépôt en est le miroir ; il ne
  contient aucune seconde représentation dérivée (pas de `state/`, pas de doc
  générée).
- Ni secrets, ni empreintes machine réidentifiantes, ni conversations, ni caches,
  ni journaux, ni poids de modèles, ni projets utilisateurs, ni corpus/benchmarks.
- Les composants ayant leur propre dépôt (`noa`, `conv-exporter`, `local-worker`)
  ne sont représentés que par leur surface d'intégration + `REFERENCE.md`.
- `AGENTS.md` est le contrat unique ; `CLAUDE.md` = `@AGENTS.md`.
- `main` repart d'une racine Git neuve (2026-09-07), sans objet commun avec
  l'ancien dépôt, archivé dans `nevenfo/ai-stack-legacy` + bundle local.

## Refonte 2026-09-07 — faite

- [x] Archive de l'ancien dépôt : bundle local validé par clone + `nevenfo/ai-stack-legacy`.
- [x] NOA extrait avec son historique → `nevenfo/noa` ; chemins rendus autonomes ;
      wiring live des 3 harnesses mis à jour.
- [x] `conv-exporter`, `local-worker` : `git init` des dossiers live → `nevenfo/conv-exporter`,
      `nevenfo/local-worker`.
- [x] Aplatissement `snapshot/<harness>` → `<harness>/` ; `shared/` réduit à la glu.
- [x] Suppression : moteur (`src/`, `tests/`, `export.ps1`, `export.rules.json`,
      `pyproject.toml`), `state/`, `docs/`, `snapshot/projects/`, `pareto-validation.md`.
- [x] Assainissement `codex/config.toml`, `antigravity/config/config.json`.
- [x] Réécriture `AGENTS.md`, `README.md`, `plan.md`, `progress.md`, `.gitignore`.
- [x] Racine Git neuve + `nevenfo/ai-stack` recréé vierge + push `main`.

## NEXT ACTION

Maintenance : lancer `export` après tout changement de configuration de la stack.
Voir `progress.md` pour l'état courant.
