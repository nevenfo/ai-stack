# PROGRESS — ai-stack

## Phase actuelle

Phase I fusionnée dans `main` par la PR `nevenfo/ai-stack#2` ; branche de travail
supprimée, arbre propre. Ne restent ouvertes que les unités suspendues au quota
Codex : H3, I6.3, I7.3 et I10.2 à I10.4.

## Tâche actuelle

Phase I close pour ce qui est mesurable sans quota. Reste I6.3, I7.3, I10.2 à
I10.4 et H3, tous suspendus au retour du quota Codex.

## Dernière tâche validée

I10.1 et I11 — corpus du benchmark d'effort livré, compaction du skill écartée.

Validation :

- `bash ~/.agents/effort-bench/build-fixtures.sh <dossier>` construit six dépôts
  Git figés. Les six échouent à l'état initial, et chacune passe avec une
  solution de référence appliquée puis annulée : le corpus est à la fois non
  trivial et résoluble.
- Un défaut du corpus a été trouvé et corrigé avant livraison : `t2` passait
  d'emblée, les deux ordres de calcul coïncidant sur des montants
  proportionnels. Le cas discriminant est 450, où le seuil de remise n'est
  franchi qu'après la TVA.
- I11 : le skill `project-continuity` ne pèse en permanence que sa description,
  484 caractères sur 22 613. Son texte complet, 10 767 caractères, n'est chargé
  qu'à la demande, et la section permanente qu'il prolonge en fait 1 104. Le
  gain d'une compaction est donc faible et porterait sur le seul mécanisme qui
  garantit preflight, réparation et handoff : version actuelle conservée.

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
- Corpus du benchmark d'effort : `agents/effort-bench/`, protocole et
  générateur de fixtures.
- Dépôt : `agents/`, `README.md` (matrice de parité), `AGENTS.md` (contrat export).
- Fixtures H3 : `%TEMP%/claude/.../scratchpad/parity-tests/`.

## NEXT ACTION

H3.1 — dès la réinitialisation du quota Codex, annoncée au 2026-09-12 09:20,
lancer la reprise de la fixture `t1-claude-init` par
`codex -p cli-lean exec -C <fixture> -s workspace-write "Ce dossier est un bac à
sable de test : ne crée aucun dépôt distant. Continue."` et vérifier
`pass=6 fail=0`, un arbre propre et `continuity-check` OK. Enchaîner H3.2 à
H3.4, puis I6.3, I7.3 et le benchmark I10.2 à I10.4 sur le corpus déjà
construit. Si les fixtures H3 ont expiré, les recréer selon la description de
H3 avant de lancer.
