# PROGRESS — ai-stack

## Phase actuelle

Phase I. Le gros a été fusionné dans `main` par la PR `nevenfo/ai-stack#2` ;
I12 suit sur la branche `ai/retrait-caveman`. Ne restent ensuite ouvertes que
les unités suspendues au quota Codex : H3, I6.3, I7.3 et I10.2 à I10.4.

## Tâche actuelle

I12 terminée. Rien d'autre n'est exécutable sans le quota Codex.

## Dernière tâche validée

I12 — Caveman retiré de la stack, configuration active et persistée comprise.

Validation :

- Aucune dépendance : ni `CONTRACT.md`, ni `CLAUDE.md`, ni `AGENTS.md`, ni
  `README.md` ne le mentionnaient. Vérifié avant toute suppression.
- Codex : `codex plugin remove` puis `codex plugin marketplace remove`, tables
  résiduelles retirées de `config.toml` et des deux profils, `codex doctor` sans
  échec. Claude : plugin, marketplace, registres et caches supprimés ; comparé au
  point de retour, seules les clés Caveman ont disparu.
- Socle : `skills/caveman/` supprimé, `.skill-lock.json` purgé.
- `parity.sh` contrôle désormais une absence, non un état inactif. Deux tests
  négatifs — skill recréé, puis plugin réintroduit — `FAIL` et exit 1 dans les
  deux cas, `PARITÉ OK` après restauration.
- Effet de bord pris au vol : retirer d'abord le `[[skills.config]]` qui masquait
  le skill l'a rendu découvrable, la source existant encore. La suppression du
  dossier du socle a rétabli l'ordre, confirmé par la mesure.

## Décisions actives

- Deux harnesses pairs. Aucun fallback, aucun propriétaire de projet.
- `~/.agents/` est le socle canonique. Le miroir le représente dans `agents/`,
  copie physique donc surface de dérive : `parity.sh` en exige l'identité.
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
- Caveman est retiré, non désactivé : un plugin désactivé redevient actif d'un
  mot. Six entrées `[projects.*]` portent encore ce nom — chemins de dossiers de
  mesure, sans câblage ; le contrôle les ignore.
- Défaut `high` conservé tant que I10 n'est pas exécuté. Aucune métrique inventée.
- Points de retour : tag `pre-parity-refactor-20260907`, et les sauvegardes
  `C:\Users\FlowUP\.stack-backups\20260907-parity` et `...\20260907-caveman`.

## Blocage actif

Quota Codex épuisé le 2026-09-07, réinitialisation annoncée au 2026-09-12 09:20.
Il bloque H3, I6.3, I7.3 et le benchmark I10.2 à I10.4. Fixtures H3
`t1-claude-init` et `t5-degrade` dans le scratchpad de session ; corpus I10 dans
`agents/effort-bench/`.

## Fichiers / zones utiles

- Socle : `~/.agents/` — `CONTRACT.md`, `parity.sh`, `continuity-check.sh`,
  `continuity-fixtures.sh`, `effort-bench/`, `skills/`.
- Live : `~/.claude/{CLAUDE.md,settings.json}`, `~/.codex/{AGENTS.md,config.toml}`
  et les profils `cli-lean` / `cli-kicad`.
- Dépôt : `agents/`, `README.md`, `AGENTS.md`.

## NEXT ACTION

H3.1 — dès la réinitialisation du quota Codex, annoncée au 2026-09-12 09:20,
lancer la reprise de la fixture `t1-claude-init` par
`codex -p cli-lean exec -C <fixture> -s workspace-write "Ce dossier est un bac à
sable de test : ne crée aucun dépôt distant. Continue."` et vérifier
`pass=6 fail=0`, un arbre propre et `continuity-check` OK. Enchaîner H3.2 à H3.4,
puis I6.3, I7.3 et le benchmark I10.2 à I10.4 sur le corpus déjà construit. Si
les fixtures H3 ont expiré, les recréer selon la description de H3 avant de
lancer.
