---
name: project-continuity
description: Initialiser, maintenir, reprendre ou poursuivre un projet avec plan.md/progress.md. Utiliser aussi lorsqu'il faut déterminer où en est un projet existant, retrouver la prochaine action, reprendre après interruption, effectuer un handoff ou mettre à jour sa continuité. Inclut notamment '# TASK PROMPT' « commence ce projet », « continue », « reprends », « où en est le projet ? » et « poursuis le travail »
---

# Continuité de projet

Le principal possède stratégie, état global, décisions, validations et Git. Un worker exécute seulement son unité déléguée et ne modifie jamais `plan.md` ni `progress.md`.

## Sources de vérité

- `plan.md` : objectif, invariants, roadmap durable, IDs stables, dépendances et validations.
- `progress.md` : état courant compact et une seule `NEXT ACTION`.
- Git local : transaction, diff et rollback.
- GitHub : historique durable partagé, seul checkpoint qui survit à la machine.
- Tests/contrôles : preuves techniques.
- Conversation et contexte worker : temporaires.
- Second Brain : seulement si une mémoire personnelle, historique ou inter-projet indispensable manque au dépôt.

Ne pas dupliquer une information. Claude Code et Codex sont pairs : aucun ne possède le projet, et rien d'indispensable ne reste enfermé dans le contexte conversationnel de l'un d'eux. Le handoff doit être reconstructible depuis ces fichiers, Git et les tests, sans transcript et sans adaptation au harness qui reprend.

## Preflight

Avant le premier travail substantiel d'une session, quel que soit le harness. Existence n'est pas conformité, et conformité n'est pas exactitude.

1. **Structure.** `plan.md` et `progress.md` existent ; `progress.md` porte les sections du contrat et exactement une `NEXT ACTION` ; chaque unité de `plan.md` porte `Objectif`, `Dépendances`, `Tâches` et `Validation`.
2. **Sémantique.** La `NEXT ACTION` est unique, concrète et rattachée à un ID du plan ; `progress.md` décrit un état, pas un journal ; aucune trace obsolète ne subsiste.
3. **Corroboration.** Confronter l'état déclaré au réel : `git status`, branche, HEAD, derniers commits, remote, et la validation que le plan associe à la dernière tâche cochée. Une tâche déclarée terminée dont la validation échoue, ou dont le travail n'est ni commité ni poussé, n'est pas terminée.
4. **Réparation.** Toute non-conformité ou contradiction se répare avant de poursuivre : décocher ce qui n'est pas prouvé, réécrire le snapshot, redéfinir la `NEXT ACTION`. En cas de conflit, l'ordre de confiance est tests, puis Git/GitHub, puis fichiers réels, puis `progress.md` en dernier.

Absence totale de continuité dans un vrai projet : initialiser. État partiel ou dérivé : réparer, jamais repartir de zéro sur ce qui est réellement prouvé.

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

Cycle : `NEXT ACTION` → travail → test proportionné → preuve → checkbox ciblée → contrôle de continuité → remplacement de `progress.md` → checkpoint Git sûr → push → prochaine action.

Le contrôle de continuité est le preflight en miniature, rejoué après chaque PASS : le snapshot décrit-il encore l'état réel, la `NEXT ACTION` est-elle toujours unique et juste, une checkbox cochée est-elle encore prouvée ? Sinon, réparer immédiatement. C'est ce qui empêche une session de plusieurs heures de dériver sans que rien ne le signale.

Le principal vérifie le résultat du worker. En PASS, cocher exactement la tâche prouvée et poursuivre. En échec, garder la tâche ouverte, corriger la régression et obtenir PASS avant d’avancer. Après l’initialisation, modifier la roadmap future seulement lorsqu’une preuve invalide, précise ou complète les dépendances, tâches ou validations déjà définies. Ne pas utiliser cette règle pour différer la définition initiale des phases futures.

## Git et GitHub

À l’ouverture, relever seulement si utile : HEAD, branche, remote, `git status --short`, diff ciblé et index. Tout changement initial appartient à l’utilisateur ; ne jamais l’écraser, le restaurer, le désindexer ni l’inclure implicitement. Indexer uniquement chemins/hunks dont l’ownership est certain ; jamais `git add .`, `git add -A` ou `git commit -a`.

Le principal seul possède branche, staging, commit et push. Un checkpoint Git ambigu peut rester PARTIAL/BLOCKED sans arrêter les travaux indépendants. Git reste la source de vérité ; `progress.md` ne conserve qu’un statut nécessaire à la reprise.

Tout vrai projet persistant a un remote GitHub, privé par défaut. Un commit local non poussé n'est pas un checkpoint durable : il ne survit ni à la machine ni au passage à l'autre harness. Granularité : commit par unité validée, push par checkpoint, PR par phase ou fonctionnalité cohérente — jamais par micro-tâche. Un remote existant n'est jamais remplacé, un dépôt n'est jamais rendu public, aucun secret n'est poussé.

Charger [references/git-delivery.md](references/git-delivery.md) si la tâche implique réellement branche de livraison, push, PR, merge, branche protégée, conflit, publication complexe, nettoyage de branche, `--force-with-lease`, ou l'initialisation GitHub d'un projet qui n'a pas encore de remote.

## Checkpoint, reprise et arrêt

Après chaque PASS, actualiser `plan.md` ciblé et remplacer `progress.md`, puis continuer automatiquement toute prochaine action claire, sûre, dans le périmètre et sans décision utilisateur. Un checkpoint, commit, push, phase terminée ou durée de run n’est pas une condition d’arrêt.

Rendre la main seulement si :

- l’objectif complet est satisfait ;
- une décision/information indispensable manque ;
- une confirmation destructive ou sensible est requise ;
- un blocage technique réel persiste après diagnostic raisonnable ;
- le contexte est devenu assez bruité pour menacer la fiabilité et l’état persistant permet une reprise non ambiguë.

## Handoff et frontière de session

Avant une frontière de contexte — changement de conversation, de session ou de harness — `progress.md` contient état validé, décisions actives, fichiers utiles, dernière preuve, blocage ou `Aucun.`, puis une seule `NEXT ACTION`, et le travail est commité puis poussé. Il n'y a pas d'autre artefact de handoff : ni `handoff.md`, ni résumé de conversation, ni note hors dépôt.

Le test du handoff est simple : l'autre harness, ouvert sur le seul dépôt, doit pouvoir reprendre sans poser de question. Si quelque chose d'indispensable n'existe que dans la conversation en cours, il manque à `plan.md` ou à `progress.md`.

N'utiliser qu'un signal de contexte ou de quota réellement exposé par le harness ; ne jamais en estimer un. Quand le budget se resserre : finir l'unité atomique en cours, valider, persister, pousser, puis repartir sur un contexte neuf plutôt qu'ouvrir une grande unité. Ne jamais automatiser `/clear`, `/compact` ou `/rewind`.
