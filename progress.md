# PROGRESS — ai-stack

## Phase actuelle

Phase I — optimisation Pareto de la stack. Branche `ai/pareto-optimisation`,
partie de `main` (`46d2737`). Phase H reste ouverte sur H3 seul, bloqué par le
quota Codex.

## Tâche actuelle

I8 — arbitrage `caveman` : mesurer son coût de découverte réel des deux côtés
avant toute décision.

## Dernière tâche validée

I7 — mesure intermédiaire, baseline I4 rejouée à l'identique.

Validation :

- Session de coding, `cli-lean` : 24 748 → 22 613 caractères, 8 → 3 skills,
  2 → 0 MCP actifs, plus les 21 outils et 13 256 caractères de schémas du MCP
  KiCad qui ne sont plus découverts.
- Base inchangée à 31 943 caractères, 18 skills, 2 MCP : Codex Desktop intact.
  `cli-kicad` inchangé à 24 745 caractères, `kicad-agentic-mcp` et `konnect`
  toujours actifs.
- Aucun avertissement de budget de skills dans aucune des trois configurations.
- `project-continuity` reste visible sous `cli-lean` avec sa description
  entière, non tronquée, et `[agents] enabled = true`.
- Reste non mesuré faute de quota : le comportement réel d'une session de
  coding, d'une délégation et d'une tâche KiCad. C'est I7.3, à rejouer avec H3.

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
- La pression de contexte constatée en début de phase a disparu : plus aucun
  avertissement de budget, et le contexte de coding restant est surtout le
  contrat lui-même. Les unités I8 à I11 ne se mènent donc que si une mesure leur
  donne un objet.
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
  `codex exec` retombent sur la configuration de base, sans profil lean. Tout
  appel hors PowerShell porte donc `-p cli-lean` explicitement, H3 compris.
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

I8.1 — mesurer le coût de découverte actuel de `caveman` des deux côtés :
vérifier qu'aucun plugin n'est actif et qu'aucun skill n'est découvert, puis
comparer au coût mesuré lorsqu'il est réactivé — +20 skills et 4 840 caractères
côté Codex — pour décider s'il reste quelque chose à retirer.
