# ai-stack

Miroir Git de la configuration de la stack IA locale — Claude Code, Codex,
Antigravity, et les composants directement impliqués dans leur fonctionnement.

Ouvrir ce dépôt, c'est voir comment la stack est configurée aujourd'hui. Rien
d'autre : ni moteur d'export, ni base d'état, ni copie de projets, ni corpus.

## Structure

```
claude/        configuration Claude Code   (CLAUDE.md, settings, agents, skills, hooks, plugins)
codex/         configuration Codex CLI     (AGENTS.md, config.toml, profils, agents, computer-use)
antigravity/   configuration Antigravity   (GEMINI.md, settings, config, agents, skills, hooks)
shared/        ressources transverses      (skills partagés, konnect, lmstudio, rtk,
                                            powershell, second-brain)
shared/noa/            surface d'intégration + REFERENCE.md  →  github.com/nevenfo/noa
shared/conv-exporter/  surface d'intégration + REFERENCE.md  →  github.com/nevenfo/conv-exporter
shared/local-worker/   surface d'intégration + REFERENCE.md  →  github.com/nevenfo/local-worker
```

## `export`

Depuis la racine, l'intention `export` demande à Claude Code ou Codex d'inspecter
la machine en lecture seule, de décider par raisonnement de ce qui appartient à la
configuration de la stack, de resynchroniser ce dépôt, de relire le diff, de
vérifier l'absence de secret, puis de committer et pousser sur `main`.

Le contrat complet est dans [`AGENTS.md`](AGENTS.md). `CLAUDE.md` s'y résume à
`@AGENTS.md`.

## Archive

L'ancienne architecture (moteur d'export Python, `export.rules.json`, `state/`,
`snapshot/projects/`) et son historique sont conservés hors de ce dépôt, dans
`nevenfo/ai-stack-legacy` et un bundle local. Ce `main` repart d'une racine Git
neuve le 2026-09-07.
