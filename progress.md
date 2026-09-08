# PROGRESS — ai-stack

## Phase actuelle

Phases I et J fusionnées dans `main` (PR `nevenfo/ai-stack#2`, `#3` et `#4`),
branches de travail supprimées, arbre propre. Ne restent ouvertes que les unités
suspendues au quota Codex : H3, I6.3, I7.3 et I10.2 à I10.4.

## Tâche actuelle

J1 terminée et fusionnée. Rien d'autre n'est exécutable sans le quota Codex.

## Dernière tâche validée

J1 — un `BLOCKED` rendu par une capacité spécialisée n'arrête plus la boucle tant
qu'une autre capacité peut le lever ; cas nommé `BLOCKED: GUI_REQUIRED:` routé par
le principal vers `desktop-control`, puis rendu à la capacité métier pour
validation.

Validation :

- `parity.sh` vert. Cinq tests négatifs, chacun cassant une seule surface :
  `GUI_REQUIRED` retiré de `kicad-control` Claude, `desktop-control` cité dans
  `kicad-control` Codex, interdiction de redéléguer retirée de `desktop-control`
  Claude, paragraphe `BLOCKED` retiré de `CLAUDE.md`, miroir `desktop-control`
  périmé — `FAIL` et exit 1 dans les cinq cas, `PARITÉ OK` après restauration.
- Prompt effectif mesuré des deux côtés. Codex :
  `codex -p cli-kicad debug prompt-input` porte les quatre motifs de la règle,
  `Aucune redélégation`, et le catalogue à jour des deux capacités. Claude : bloc
  canonique et descriptions `kicad-control` / `desktop-control` à jour dans le
  contexte chargé.
- `Aucune redélégation` conservé mot pour mot ; plus aucune formulation
  d'exclusivité dans `kicad-control` — le contrôle l'exige comme une absence.
- Dérive prise au vol : le miroir portait encore l'ancienne `description` de
  `desktop-control` des deux côtés. `parity.sh` ne comparait aucune définition
  d'agent au live ; il exige désormais l'identité des quatre.

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
- Le miroir n'est jamais comparé brut au live : `codex/config.toml` y normalise
  les tables `[projects.*]` et omet `[hooks.state]`.
- Côté Claude, `/model` persiste son choix dans `settings.json` : défaut et
  dernier choix de session sont un seul champ.
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

Quota Codex épuisé le 2026-09-07, réinitialisation annoncée au 2026-09-12 09:20.
Il bloque H3, I6.3, I7.3 et le benchmark I10.2 à I10.4. `debug prompt-input` reste
utilisable : il ne consomme pas le quota. Fixtures H3 `t1-claude-init` et
`t5-degrade` dans le scratchpad de session ; corpus I10 dans `agents/effort-bench/`.

## Fichiers / zones utiles

- Socle : `~/.agents/` — `CONTRACT.md`, `parity.sh`, `continuity-check.sh`,
  `continuity-fixtures.sh`, `effort-bench/`, `skills/`.
- Live : `~/.claude/{CLAUDE.md,settings.json}`, `~/.codex/{AGENTS.md,config.toml}`,
  les profils `cli-lean` / `cli-kicad`, et les définitions appariées
  `~/.claude/agents/{kicad,desktop}-control.md`,
  `~/.codex/agents/{kicad,desktop}-control.toml`.
- Dépôt : `agents/`, `claude/agents/`, `codex/agents/`, `README.md`, `AGENTS.md`.

## NEXT ACTION

H3.1 — dès la réinitialisation du quota Codex, annoncée au 2026-09-12 09:20,
lancer la reprise de la fixture `t1-claude-init` par
`codex -p cli-lean exec -C <fixture> -s workspace-write "Ce dossier est un bac à
sable de test : ne crée aucun dépôt distant. Continue."` et vérifier
`pass=6 fail=0`, un arbre propre et `continuity-check` OK. Enchaîner H3.2 à H3.4,
puis I6.3, I7.3 et le benchmark I10.2 à I10.4 sur le corpus déjà construit. Si
les fixtures H3 ont expiré, les recréer selon la description de H3 avant de
lancer.
