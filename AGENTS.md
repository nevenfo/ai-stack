# ai-stack

`ai-stack` est la représentation Git propre de la configuration **actuelle** de la
stack IA locale : Claude Code et Codex — deux harnesses pairs et interchangeables —
et les composants qui participent directement à leur fonctionnement. Ce n'est ni un
moteur d'export, ni une base d'état, ni une copie de projets. La source de vérité
est toujours la configuration live ; ce dépôt en est le miroir versionné.

## Parité

Les deux harnesses sont deux implémentations du même harness logique. Leur contrat
commun a une source unique, `agents/CONTRACT.md`, recopiée entre marqueurs dans
`claude/CLAUDE.md` et `codex/AGENTS.md` ; les skills partagés ont un seul
propriétaire, `agents/skills/`. Toute différence entre les deux configurations doit
relever de la syntaxe native, d'une capacité native réellement différente, ou d'un
modèle propre à la plateforme — jamais d'une divergence de politique.

`agents/parity.sh` le vérifie de façon déterministe, et `--fix` réinjecte le bloc
canonique. Le lancer fait partie d'`export` : un miroir qui enregistrerait une
divergence silencieuse entre les deux harnesses ne vaudrait rien.

## Intention `export`

Depuis la racine du dépôt, `export` demande à l'agent (Claude Code ou Codex) de
reconstruire ce miroir à partir de l'état réel de la machine. L'agent, et lui seul,
décide du périmètre — aucune règle, aucun manifeste, aucune whitelist persistés,
aucun moteur. Les outils déterministes (`rg`, `fd`, PowerShell, copie/suppression,
Git) sont des bras, jamais le lieu d'une décision de périmètre.

1. Vérifier le dépôt (`ai-stack`, branche `main`, examiner `git status`) avant toute
   écriture.
2. Inspecter la stack live en lecture seule : Claude Code, Codex, et ce qui gravite
   réellement autour de leur fonctionnement — instructions, settings,
   agents, skills, hooks, MCP, plugins, wrappers, profils shell, intégrations,
   sondes de version, sources de modèles. Partir des signaux forts (`HOME`/
   `USERPROFILE`, `APPDATA`/`LOCALAPPDATA`, `PATH`, gestionnaires de paquets),
   suivre les relations, élargir de façon bornée.
3. Suivre les références rencontrées pour découvrir les éléments liés.
4. Pour chaque élément, décider par raisonnement :
   - participe-t-il au comportement, aux capacités, au routage, aux instructions ou
     à la reconstruction de la stack ? sinon → écarter ;
   - est-ce une configuration / instruction / intégration **portable**, ou un
     contenu **personnel ou volatil** (secrets, identifiants, conversations,
     historiques, caches, journaux, sessions, artefacts, données mesurées) ? le
     second → écarter ;
   - est-ce déjà représenté ailleurs dans le dépôt ou dans un dépôt essaimé ? →
     un seul propriétaire, pas de copie.
   `UNKNOWN` veut dire « à examiner », jamais « à copier » ni « à ignorer ».
5. Ne jamais inclure : secrets, credentials, empreintes machine réidentifiantes
   (hashes de confiance, hostnames, GUID de pipes, hashes de runtime), conversations,
   caches, journaux personnels, fichiers temporaires, poids de modèles, projets
   utilisateurs, corpus / benchmarks, code métier des composants essaimés.
6. Synchroniser directement le dépôt : créer, modifier, déplacer, supprimer les
   fichiers pour refléter l'état réel. Copier les fichiers texte fidèlement ;
   normaliser uniquement les champs volatils (chemin du home → `${USERPROFILE}`,
   empreintes / hashes, hostnames, GUID) en gardant la structure lisible.
7. Ne pas écraser une modification utilisateur non commitée présente dans le
   worktree.
8. Relire l'intégralité du `git diff`.
9. Seconde passe : rechercher secret accidentel, doublon, élément obsolète, omission
   manifeste. Lancer `bash agents/parity.sh` : une parité rompue se corrige avant le
   commit, elle ne se consigne pas.
10. Si le résultat est cohérent : un commit ciblé (jamais `git add .` aveugle),
    puis `git push origin main`. Un échec de push conserve le commit local. La
    sortie finale résume changements, exclusions, sécurité, commit et push, sans
    valeur sensible.

## Composants essaimés

Certains composants de la stack ont leur propre dépôt. `ai-stack` n'en garde que la
surface d'intégration (wrappers et hooks réellement câblés dans un harness) et un
`REFERENCE.md` (remote + commit épinglé + points de câblage) :

| Dossier | Dépôt |
|---|---|
| `shared/noa/` | https://github.com/nevenfo/noa |
| `shared/conv-exporter/` | https://github.com/nevenfo/conv-exporter |
| `shared/local-worker/` | https://github.com/nevenfo/local-worker |

L'observabilité KPI (`noa-export`) a son propre contrat, distinct d'`export`, et
vit dans le dépôt NOA. `ai-stack` ne contient aucune donnée KPI.

## Archive

L'historique antérieur au 2026-09-07 (moteur d'export déterministe, `state/`,
`snapshot/projects/`) est conservé hors de ce dépôt : bundle local
`C:\Users\FlowUP\archives\ai-stack-legacy-2026-09-07.bundle` et dépôt privé
`nevenfo/ai-stack-legacy`. Le `main` actuel repart d'une racine Git neuve, sans
objet commun avec l'ancien.
