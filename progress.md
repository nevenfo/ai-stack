# PROGRESS — ai-stack

## Phase actuelle

Phases I et J fusionnées dans `main` (PR `nevenfo/ai-stack#2`, `#3` et `#4`),
branches de travail supprimées. Ne restent ouvertes que les unités suspendues au
quota Codex : H3, I6.3, I7.3 et I10.2 à I10.4. Le miroir a été resynchronisé sur
la stack live le 2026-09-18.

## Tâche actuelle

`export` du 2026-09-18 terminé. Deux dérives du live, reflétées fidèlement par le
miroir, attendent une décision : voir « Blocage actif ».

## Dernière tâche validée

`export` — resynchronisation du miroir sur l'état réel des deux harnesses, du
socle `~/.agents/` et des composants transverses.

Validation :

- `parity.sh` vert et `continuity-check.sh .` vert après resynchronisation.
- Diff intégral relu. Seconde passe : aucun secret, aucune empreinte machine
  résiduelle (`<runtime-hash>`, `<cli-hash>`, `<sha256>`, `<pipe-guid>`), aucun
  `.bak`, aucune table `[projects.*]` ni `[hooks.state]`.
- Sept fichiers actualisés : `codex/config.toml` (`service_tier`, trois plugins
  `codex-app-tools` / `unified-computer-use` / `computer-use` activés,
  `conversationDetailMode = STEPS_PROSE`, environnement `node_repl` du nouveau
  runtime), `codex/cli-lean.config.toml`, `codex/cli-kicad.config.toml`,
  `codex/version.json` (0.154.0), `claude/plugins/known_marketplaces.json`,
  `shared/konnect/konnect-bootstrap.ps1` (correctif de culture sur les dates de
  release, CRLF conservé par `.gitattributes`),
  `shared/local-worker/HARNESS_INTEGRATION.md`.
- Côté Claude — `CLAUDE.md`, `settings.json`, agents, hooks, skills, plugins — et
  socle `~/.agents/` déjà identiques au live : aucune écriture.
- Commits épinglés de `noa`, `conv-exporter` et `local-worker` inchangés.
- Écartés comme état ou contenu fournisseur : `~/.claude/.claude.json` et
  `~/.codex/rtk-cli/.claude.json` (identité machine, caches), `skills/synced/` et
  `plugins/synced/`, `~/.codex/skills/.system/`, `~/.claude/skills/.trash/`,
  marketplaces en cache, journaux et bases SQLite.

## Décisions actives

- Deux harnesses pairs. Aucun fallback, aucun propriétaire de projet.
- Ownership métier ≠ mécanisme d'interaction. Une capacité métier décide, connaît
  les invariants et valide ; exécuter un geste GUI pour son compte n'en rend
  jamais propriétaire. La GUI ne passe pas devant un moyen CLI/API/MCP/fichier.
- Un sous-agent ne redélègue jamais : le seul chemin est
  `capacité métier → principal → desktop-control → principal → capacité métier`.
- Le reroutage est borné : une même cause ne se rejoue qu'avec une information ou
  un état nouveau ; sans capacité restante, le blocage est réel et se rend.
- `~/.agents/` est le socle canonique. Le miroir le représente dans `agents/`,
  copie physique donc surface de dérive : `parity.sh` en exige l'identité, pour le
  socle comme pour les quatre définitions d'agents appariées.
- Le miroir n'est jamais comparé brut au live : il omet `[projects.*]`,
  `[hooks.state]` et `[tui.model_availability_nux]`, et normalise les empreintes.
- Le miroir reflète le live, il ne le corrige pas : une dérive constatée est
  reflétée puis signalée, jamais maquillée.
- Les deux clients persistent un choix de session dans leur configuration :
  `/model` dans `~/.claude/settings.json` côté Claude, modèle et effort dans le
  profil `cli-lean` côté Codex. `parity.sh` ne couvre que la base Codex.
- Une tâche déclarée validée porte une preuve listée sous `Validation :`.
- Un profil Codex se superpose à la base : il ne masque que ce qu'il redéfinit.
- `codex debug prompt-input` est l'instrument de mesure ; `-p` et les options
  globales précèdent `debug`. Hors PowerShell, `codex exec` retombe sur la base :
  `-p cli-lean` est explicite, H3 compris.
- Le workaround d'héritage MCP reste borné à `cli-kicad`. Signal de levée : I6.3.
- Caveman est retiré, non désactivé. Défaut `high` conservé tant que I10 n'est pas
  exécuté. Aucune métrique inventée.
- Points de retour : tag `pre-parity-refactor-20260907`, sauvegardes
  `C:\Users\FlowUP\.stack-backups\20260907-parity`, `...\20260907-caveman` et
  `...\20260908-blocked-gui-required`.

## Blocage actif

Deux décisions utilisateur, révélées par l'`export` du 2026-09-18 :

1. Le profil `cli-lean` live est repassé à `gpt-5.6-sol` / `medium` — l'état que
   A2.3 avait nommé comme défaut — alors que la base Codex reste `gpt-6-astra` /
   `high`. Le client l'a réécrit en y persistant un choix de session. À trancher :
   restaurer `gpt-6-astra` / `high` dans le profil, ou assumer un profil de coding
   plus léger et l'inscrire dans `README.md`.
2. `HARNESS_INTEGRATION.md` du dépôt `local-worker` mentionne encore Antigravity
   comme troisième harness. La correction appartient à ce dépôt, pas à `ai-stack`.

Le quota Codex, épuisé le 2026-09-07, était annoncé en réinitialisation au
2026-09-12 09:20 ; il n'a pas été revérifié. Fixtures H3 `t1-claude-init` et
`t5-degrade` très probablement expirées avec leur scratchpad de session ; corpus
I10 dans `agents/effort-bench/`.

## Fichiers / zones utiles

- Socle : `~/.agents/` — `CONTRACT.md`, `parity.sh`, `continuity-check.sh`,
  `continuity-fixtures.sh`, `effort-bench/`, `skills/`, `konnect/`.
- Live : `~/.claude/{CLAUDE.md,settings.json}`, `~/.codex/{AGENTS.md,config.toml}`,
  les profils `cli-lean` / `cli-kicad`, et les définitions appariées
  `~/.claude/agents/{kicad,desktop}-control.md`,
  `~/.codex/agents/{kicad,desktop}-control.toml`.
- Dépôt : `agents/`, `claude/`, `codex/`, `shared/`, `README.md`, `AGENTS.md`.

## NEXT ACTION

H3.1 — vérifier d'abord que le quota Codex est rétabli, puis recréer les fixtures
H3 selon la description de H3 dans `plan.md` (celles du scratchpad de session ont
expiré) et lancer la reprise de `t1-claude-init` par
`codex -p cli-lean exec -C <fixture> -s workspace-write "Ce dossier est un bac à
sable de test : ne crée aucun dépôt distant. Continue."`, en vérifiant
`pass=6 fail=0`, un arbre propre et `continuity-check` OK. Enchaîner H3.2 à H3.4,
puis I6.3, I7.3 et le benchmark I10.2 à I10.4 sur le corpus déjà construit.
