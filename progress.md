# PROGRESS — ai-stack

## Phase actuelle

Phase I — optimisation Pareto de la stack. Branche `ai/pareto-optimisation`,
partie de `main` (`46d2737`). Phase H reste ouverte sur H3 seul, bloqué par le
quota Codex.

## Tâche actuelle

I5 — vérifier ce qui reste réellement chargé en session de coding, et si les
surfaces restantes valent une coupe.

## Dernière tâche validée

I6 — le MCP KiCad ne fuit plus dans une session de coding Codex.

Validation :

- `codex -p cli-lean mcp list --json` : `kicad-agentic-mcp enabled=false`,
  `node_repl enabled=false` — plus aucun MCP actif en session de coding.
- `codex -p cli-kicad mcp list --json` : `kicad-agentic-mcp` et `konnect`
  restent `enabled=true`. Configuration de base inchangée, donc Codex Desktop
  intact.
- Coût de découverte évité, mesuré en interrogeant le serveur en JSON-RPC
  (`tools/list`) : 21 outils, 13 256 caractères de schémas. Le contexte de
  démarrage mesuré par `prompt-input` est inchangé à 24 748 caractères — les
  schémas d'outils n'y transitent pas.
- Symétrie confirmée : côté Claude, aucun `mcpServers` global ; l'agent
  `kicad-control` porte `konnect` dans son propre en-tête.

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
- Une tâche déclarée validée doit porter une preuve listée sous `Validation :` ;
  le contrôle exige le marqueur littéral et au moins une puce, sans juger la
  valeur de la preuve.
- Les intitulés de sections de `plan.md`/`progress.md` sont littéraux, accents
  compris ; `continuity-check.sh` le vérifie et reste volontairement strict.
- Aucune métrique de contexte ou de quota inventée. Chaque unité de la phase I
  est indépendante et réversible.
- Un profil Codex se **superpose** à la base (`-p` : « layer on top of the base
  user config ») : il ne masque que les tables qu'il redéfinit. Tout ce que la
  base déclare et que le profil ignore reste actif.
- `codex debug prompt-input` est l'instrument de mesure de la phase I. Les
  options globales, `-p` compris, doivent précéder `debug` ; `-c` ne surcharge
  pas une clé de plugin comportant un `@`.
- Le workaround d'héritage MCP des sous-agents reste borné au profil
  `cli-kicad`, qui seul expose `konnect` au parent. Il pourra être retiré quand
  un sous-agent Codex accédera à son MCP privé sans exposition parente ; le
  signal de levée est le test I6.3, à rejouer dès que le quota le permet.
- Le wrapper `codex` est une fonction du profil PowerShell : hors d'un shell
  PowerShell l'ayant chargé — depuis Git Bash ou un autre agent — `codex` et
  `codex exec` retombent sur la configuration de base, sans profil lean.
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

I5.1 — établir ce qui reste réellement chargé sous `cli-lean` : les huit skills
visibles, le bloc `<recommended_plugins>` de 3 336 caractères et les treize
plugins du catalogue distant marqués « installed, enabled ». Déterminer par
mesure lesquels sont réductibles sans casser Codex Desktop, puis ne couper que
ceux dont le gain est mesuré.
