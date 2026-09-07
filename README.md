# ai-stack

Miroir Git de la configuration de la stack IA locale : **Claude Code et Codex**,
deux harnesses pairs et interchangeables, et les composants directement impliqués
dans leur fonctionnement.

Ouvrir ce dépôt, c'est voir comment la stack est configurée aujourd'hui. Rien
d'autre : ni moteur d'export, ni base d'état, ni copie de projets, ni corpus.

## Structure

```
agents/        socle canonique commun     (CONTRACT.md, parity.sh, skills partagés)
claude/        configuration Claude Code  (CLAUDE.md, settings, agents, hooks, plugins)
codex/         configuration Codex CLI    (AGENTS.md, config.toml, profils, agents)
shared/        ressources transverses     (konnect, lmstudio, rtk, powershell,
                                           second-brain)
shared/noa/            surface d'intégration + REFERENCE.md  →  github.com/nevenfo/noa
shared/conv-exporter/  surface d'intégration + REFERENCE.md  →  github.com/nevenfo/conv-exporter
shared/local-worker/   surface d'intégration + REFERENCE.md  →  github.com/nevenfo/local-worker
```

`agents/` est l'unique propriétaire de ce qui est partagé : le contrat commun et
les skills que les deux harnesses chargent. Sur la machine il vit dans
`~/.agents/` ; Claude Code y accède par des jonctions depuis `~/.claude/skills/`,
Codex le lit nativement.

## Parité Claude / Codex

Un projet appartient à `GitHub + plan.md + progress.md + code/tests`, jamais à un
harness. On peut le commencer avec l'un, le continuer avec l'autre, revenir au
premier, sans reconstruire son état à la main.

| invariant | Claude Code | Codex | mécanisme |
|---|:---:|:---:|---|
| contrat commun octet pour octet | ✓ | ✓ | `agents/CONTRACT.md` entre marqueurs |
| invariant de continuité permanent | ✓ | ✓ | bloc canonique |
| preflight de continuité | ✓ | ✓ | `project-continuity` |
| audit et réparation de `plan.md` | ✓ | ✓ | `project-continuity` |
| audit et réparation de `progress.md` | ✓ | ✓ | `project-continuity` |
| `CONTINUE` par défaut | ✓ | ✓ | bloc canonique |
| self-healing après chaque PASS | ✓ | ✓ | `project-continuity` |
| GitHub-first | ✓ | ✓ | bloc canonique |
| création de dépôt privé | ✓ | ✓ | `references/git-delivery.md` |
| boucle de validation | ✓ | ✓ | bloc canonique |
| philosophie de sous-agents | ✓ | ✓ | bloc canonique |
| philosophie de skills | ✓ | ✓ | bloc canonique |
| politique Second Brain | ✓ | ✓ | bloc canonique |
| handoff de session | ✓ | ✓ | `project-continuity` |
| protocole `project-continuity` | ✓ | ✓ | `agents/skills/`, un seul fichier |
| qualité de modèle visée | `opus` + `high` | `gpt-6-astra` + `high` | divergence légitime : fournisseurs différents |
| filtrage RTK des sorties | hook `PreToolUse` | appel explicite `rtk` | divergence légitime : Codex n'a pas de hook équivalent |
| Web hors du principal | hook de refus | `web_search = "disabled"` | divergence légitime : deux mécanismes natifs |

```bash
bash agents/parity.sh          # vérifie ; sort en erreur si un côté a divergé
bash agents/parity.sh --fix    # réinjecte le bloc canonique dans les deux
```

Le contrôle porte sur les deux configurations live **et** sur ce dépôt. Il ne
compare pas les fichiers brut à brut — le miroir normalise volontairement les
chemins de projets et les empreintes machine — mais il exige l'identité des
fichiers du socle et l'égalité des valeurs sémantiques critiques : modèle et
effort des deux côtés, états critiques de plugins et de MCP. Un miroir périmé
échoue donc au même titre qu'un harness qui dérive. `PARITY_MIRROR` désigne le
dépôt si celui-ci ne se trouve pas dans `~/ai-stack`.

Attention à une source de dérive : côté Claude Code, `/model` écrit le modèle
choisi dans `~/.claude/settings.json` et l'y laisse. Ce champ est donc à la fois
le défaut persisté et le dernier choix de session — un `/model sonnet` ponctuel
devient le nouveau défaut. C'est ainsi que le miroir a affirmé `sonnet` alors
que la stack visait `opus`.

Le contrat commun ne s'édite que dans `agents/CONTRACT.md`, jamais directement dans
un harness : `parity.sh` rattraperait la modification à la vérification suivante.

## `export`

Depuis la racine, l'intention `export` demande à Claude Code ou à Codex d'inspecter
la machine en lecture seule, de décider par raisonnement de ce qui appartient à la
configuration de la stack, de resynchroniser ce dépôt, de relire le diff, de
vérifier l'absence de secret et la parité, puis de committer et pousser sur `main`.

Le contrat complet est dans [`AGENTS.md`](AGENTS.md). `CLAUDE.md` s'y résume à
`@AGENTS.md`.

## Archive

L'ancienne architecture (moteur d'export Python, `export.rules.json`, `state/`,
`snapshot/projects/`) et son historique sont conservés hors de ce dépôt, dans
`nevenfo/ai-stack-legacy` et un bundle local. Ce `main` repart d'une racine Git
neuve le 2026-09-07.

Antigravity a fait partie de la stack jusqu'au 2026-09-07. Son câblage — contrats,
settings, hooks, agents, skills, commandes — a été retiré du dépôt et de la
machine ; l'application elle-même n'a pas été désinstallée et son runtime reste
intact sous `~/.gemini/antigravity-cli/`. La configuration retirée est archivée
dans `~/.stack-backups/20260907-parity/`.
