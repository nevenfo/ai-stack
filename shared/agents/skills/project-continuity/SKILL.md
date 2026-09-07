---
name: project-continuity
description: Initialiser, maintenir, reprendre ou poursuivre un projet avec plan.md/progress.md. Utiliser aussi lorsqu'il faut déterminer où en est un projet existant, retrouver la prochaine action, reprendre après interruption, effectuer un handoff ou mettre à jour sa continuité. Inclut notamment '# TASK PROMPT' « commence ce projet », « continue », « reprends », « où en est le projet ? » et « poursuis le travail »
---

# Continuité de projet

Le principal possède stratégie, état global, décisions, validations et Git. Un worker exécute seulement son unité déléguée et ne modifie jamais `plan.md` ni `progress.md`.

## Sources de vérité

- `plan.md` : objectif, invariants, roadmap durable, IDs stables, dépendances et validations.
- `progress.md` : état courant compact et une seule `NEXT ACTION`.
- Git : historique et preuve secondaire.
- Tests/contrôles : preuves techniques.
- Conversation et contexte worker : temporaires.
- Second Brain : seulement si une mémoire personnelle, historique ou inter-projet indispensable manque au dépôt.

Ne pas dupliquer une information. Le handoff Claude ↔ Codex doit être reconstructible depuis ces fichiers, Git et les tests, sans transcript.

## Initialiser

Pour un vrai projet sans continuité :

1. Comprendre objectif, exigences, invariants, risques et critères globaux.
2. Inspecter documentation, structure et Git strictement pertinents.
3. Créer un `plan.md` raisonnablement complet avec IDs stables, dépendances, tâches et validations.
4. Créer `progress.md` avec la première action.

Une checkbox signifie preuve, jamais intention. Ne pas renuméroter ni réécrire silencieusement un élément validé ; ajouter les découvertes avec un nouvel ID.

Chaque unité du plan contenant des tâches — qu'elle soit nommée phase, `P0`, `A1` ou autrement — contient explicitement `Objectif`, `Dépendances`, `Tâches` et `Validation`, y compris pour les unités futures. `Aucune` est une valeur valide pour `Dépendances` ; ne jamais omettre une de ces sections. À l'initialisation, définir les dépendances et validations prévisibles avec les informations disponibles. Ne pas laisser volontairement les phases futures sous-spécifiées sous prétexte qu'elles seront précisées plus tard.

Structure minimale du plan :

```markdown
# PLAN — Projet
## Objectif final
## Invariants
## Critères globaux de réussite
# Phase A — ...
## A1 — ...
### Objectif
### Dépendances
### Tâches
- [ ] A1.1 ...
### Validation
```

## Contrat de progress.md

Snapshot normalement de 300 à 800 tokens :

```markdown
# PROGRESS
## Phase actuelle
## Tâche actuelle
## Dernière tâche validée
Validation :
- ...
## Décisions actives
## Blocage actif
Aucun.
## Fichiers / zones utiles
## NEXT ACTION
A1.2 — Action concrète puis validation précise.
```

Remplacer le snapshot à chaque checkpoint, jamais append-only. Supprimer l’obsolète. Ne stocker ni logs, stack traces, diffs, historique de commandes, contenu de fichiers ni copie du plan. Un blocage garde seulement symptôme, cause probable, faits exclus et prochaine tentative. Terminer par exactement une `NEXT ACTION` liée au plan.

## Reprendre une session

Ordre strict :

1. Lire `progress.md`, extraire ID actif et `NEXT ACTION`.
2. Si Git existe, corroborer par `git status`, branche/HEAD et quelques commits ciblés seulement.
3. Localiser ensuite l’ID dans `plan.md` avec `rg` ; lire seulement section, dépendances et validation.
4. Charger uniquement les fichiers nécessaires, puis continuer.

Ne lire tout le plan que si l’extraction ciblée ne suffit réellement pas. Utiliser `fd`/`rg` avant exploration large. À la reprise inter-harness, ne créer aucun `handoff.md`.

## Exécuter et valider

Maintenir une seule tâche active, sans limiter le nombre de tâches par tour. Rester dans le principal si le contexte est localisé ; déléguer seulement une unité autonome rentable avec ID, objectif, contraintes, ancres, dépendances et validation.

Cycle : `NEXT ACTION` → travail → test proportionné → preuve → checkbox ciblée → remplacement de `progress.md` → checkpoint Git sûr → prochaine action.

Le principal vérifie le résultat du worker. En PASS, cocher exactement la tâche prouvée et poursuivre. En échec, garder la tâche ouverte, corriger la régression et obtenir PASS avant d’avancer. Après l’initialisation, modifier la roadmap future seulement lorsqu’une preuve invalide, précise ou complète les dépendances, tâches ou validations déjà définies. Ne pas utiliser cette règle pour différer la définition initiale des phases futures.

## Git minimal

À l’ouverture, relever seulement si utile : HEAD, branche, remote, `git status --short`, diff ciblé et index. Tout changement initial appartient à l’utilisateur ; ne jamais l’écraser, le restaurer, le désindexer ni l’inclure implicitement. Indexer uniquement chemins/hunks dont l’ownership est certain ; jamais `git add .`, `git add -A` ou `git commit -a`.

Le principal seul possède branche, staging, commit et push. Un checkpoint Git ambigu peut rester PARTIAL/BLOCKED sans arrêter les travaux indépendants. Git reste la source de vérité ; `progress.md` ne conserve qu’un statut nécessaire à la reprise.

Charger [references/git-delivery.md](references/git-delivery.md) seulement si la tâche implique réellement branche de livraison, push, PR, merge, branche protégée, conflit, publication complexe, nettoyage de branche ou `--force-with-lease`.

## Checkpoint, reprise et arrêt

Après chaque PASS, actualiser `plan.md` ciblé et remplacer `progress.md`, puis continuer automatiquement toute prochaine action claire, sûre, dans le périmètre et sans décision utilisateur. Un checkpoint, commit, push, phase terminée ou durée de run n’est pas une condition d’arrêt.

Rendre la main seulement si :

- l’objectif complet est satisfait ;
- une décision/information indispensable manque ;
- une confirmation destructive ou sensible est requise ;
- un blocage technique réel persiste après diagnostic raisonnable ;
- le contexte est devenu assez bruité pour menacer la fiabilité et l’état persistant permet une reprise non ambiguë.

Avant une frontière de contexte, `progress.md` contient état validé, décisions, fichiers utiles, tests, blocage ou `Aucun.`, puis une seule `NEXT ACTION`. Ne jamais automatiser `/clear`, `/compact` ou `/rewind`.
