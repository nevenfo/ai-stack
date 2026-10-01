# PROGRESS — ai-stack

## Phase actuelle

Phases I et J fusionnées dans main (PR nevenfo/ai-stack#2, #3 et #4). I6 est clos le 2026-10-01. Restent ouvertes H3, I7.3 et I10.2 à I10.4.

## Tâche actuelle

Export complet du live vers ai-stack terminé le 2026-10-01 ; miroir resynchronisé et validé pour main.

## Dernière tâche validée

export — reconstruction du miroir à partir de la stack live actuelle.

Validation :

- Socle ~/.agents, agents/skills/hooks Claude et agents Codex : identité vérifiée avec le miroir, hors backups/caches/synced.
- Codex : base, cli-lean et cli-kicad alignés sémantiquement ; projects.*, hooks.state, état TUI et empreintes runtime restent exclus ou normalisés.
- MCP runtime vérifiés : aucun KiCad dans base/cli-lean ; un seul Konnect dans cli-kicad ; Claude conserve uniquement ses MCP globaux natifs.
- Composants essaimés NOA, conv-exporter et local-worker : commits live égaux aux commits épinglés et copies d'intégration identiques.
- Second Brain, PowerShell et LM Studio : surfaces suivies identiques au miroir.
- Dérives exportées : template ~/.rtk/filters.toml et métadonnée du marketplace Claude, avec lastUpdated normalisé car volatil.

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
- Un profil Codex se superpose à la base : cli-lean fixe explicitement gpt-6-sol / medium ; cli-kicad fixe explicitement gpt-6-astra / high.
- `codex debug prompt-input` est l'instrument de mesure ; `-p` et les options
  globales précèdent `debug`. Hors PowerShell, `codex exec` retombe sur la base :
  `-p cli-lean` est explicite, H3 compris.
- Le workaround MCP Codex reste borné à cli-kicad : le parent voit Konnect uniquement pour que kicad-control l'hérite, mais ses instructions lui interdisent tout appel direct. Signal de levée : une version Codex où un rôle peut ajouter un MCP absent du parent + smoke test privé réussi.
- Caveman est retiré, non désactivé. Défaut `high` conservé tant que I10 n'est pas
  exécuté. Aucune métrique inventée.
- Points de retour : tag `pre-parity-refactor-20260907`, sauvegardes
  `C:\Users\FlowUP\.stack-backups\20260907-parity`, `...\20260907-caveman` et
  `...\20260908-blocked-gui-required`.

## Blocage actif

Aucun blocage actif sur code-worker ni sur KiCad.

Limitation connue, non bloquante : Codex 0.159.x ne permet pas à kicad-control d'ajouter seul Konnect si le parent ne l'a pas. Le workaround validé reste strictement dans cli-kicad. La base et cli-lean restent sans KiCad.

Point indépendant encore à traiter dans son dépôt propriétaire : HARNESS_INTEGRATION.md de local-worker mentionne encore Antigravity comme troisième harness.

Le quota Codex est rétabli : les smoke tests Codex du 2026-10-01 ont exécuté normalement des sessions cli-lean et cli-kicad.
## Fichiers / zones utiles

- Socle : `~/.agents/` — `CONTRACT.md`, `parity.sh`, `continuity-check.sh`,
  `continuity-fixtures.sh`, `effort-bench/`, `skills/`, `konnect/`.
- Live : `~/.claude/{CLAUDE.md,settings.json}`, `~/.codex/{AGENTS.md,config.toml}`,
  les profils `cli-lean` / `cli-kicad`, et les définitions appariées
  `~/.claude/agents/{kicad,desktop}-control.md`,
  `~/.codex/agents/{kicad,desktop}-control.toml`.
- Dépôt : `agents/`, `claude/`, `codex/`, `shared/`, `README.md`, `AGENTS.md`.

## NEXT ACTION

H3.1 — recréer les fixtures H3 selon la description de H3 dans plan.md puis lancer la reprise de t1-claude-init par codex -p cli-lean exec -C <fixture> -s workspace-write avec la consigne de bac à sable, en vérifiant pass=6 fail=0, un arbre propre et continuity-check OK. Enchaîner H3.2 à H3.4, puis I7.3 et le benchmark I10.2 à I10.4.
