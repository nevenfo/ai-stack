# PROGRESS — ai-stack

## Phase actuelle

Refonte « miroir de configuration » — 2026-09-07.

## Dernière tâche validée

Refonte structurelle complète (voir `plan.md` § Refonte). Racine Git neuve,
dépôt `nevenfo/ai-stack` recréé vierge, `main` poussé. Trois composants essaimés
dans leurs propres dépôts privés. Ancien historique archivé dans
`nevenfo/ai-stack-legacy` + `C:\Users\FlowUP\archives\ai-stack-legacy-2026-09-07.bundle`.

## Décisions actives

- `export` ≠ `noa-export`. Aucune donnée KPI dans ce dépôt.
- Chemins gérés : `claude/`, `codex/`, `antigravity/`, `shared/`, plus les fichiers
  de contrat racine.
- `shared/noa/`, `shared/conv-exporter/`, `shared/local-worker/` = surface
  d'intégration + `REFERENCE.md` uniquement.
- `.gitattributes` `* -text` conservé pour la fidélité d'octets des configs miroir.

## Points d'attention (dette connue)

- Dépôt `nevenfo/noa` : `parents[2]` corrigé dans `noa_kpi/events.py`, mais la
  suite de tests NOA (~237) et les modules `aiv2/*` hérités n'ont pas été
  re-validés sous la nouvelle racine. À faire dans une session NOA.
- Les résultats de benchmark non suivis de l'ancien `noa/corpus/**` et
  `noa/research/*.json` (déjà gitignorés) n'ont pas été transférés ; ils sont
  régénérables via les scripts `corpus/*.py` présents dans `nevenfo/noa`.
- `codex/config.toml` du miroir : bloc `[mcp_servers.node_repl]` (plomberie
  computer-use) conservé avec empreintes templatisées ; à réévaluer au prochain
  `export` (est-ce de la config intentionnelle ?).

## NEXT ACTION

Lancer un `export` complet pour réconcilier le miroir avec l'état live des trois
harnesses et confirmer que le contrat `AGENTS.md` est autosuffisant.
