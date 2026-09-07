# Livraison Git/GitHub

Charger cette référence seulement pour une livraison impliquant branche, push, pull request, merge, protection, conflit, publication complexe, nettoyage, `--force-with-lease` ou l'initialisation GitHub d'un projet sans remote.

## Initialisation GitHub

Tout vrai projet persistant a un remote GitHub. Un dossier jetable, un bac à sable ou un fixture de test n'en est pas un.

Remote déjà présent : vérifier `origin`, ne pas le remplacer, ne pas toucher à la visibilité du dépôt, et poursuivre.

Remote absent :

1. `gh --version` puis `gh auth status`. Absent ou non authentifié : Git local continue, l'initialisation GitHub est `BLOCKED`, et l'utilisateur est informé — ne jamais installer `gh` ni lancer un login interactif.
2. Vérifier qu'aucun dépôt du compte ne correspond déjà au projet ; un doublon est pire que l'absence de remote.
3. Vérifier qu'aucun secret, credential, `.env`, clé ou empreinte machine ne serait poussé. Un `.gitignore` adapté précède le premier commit.
4. Créer le dépôt **privé**, sans exception : `gh repo create <nom> --private --source . --remote origin`. Ne jamais créer public, ne jamais faire passer un dépôt existant en public.
5. Premier commit ciblé — `plan.md`, `progress.md` et le contenu réel du projet — puis `git push -u origin <branche>`.

La création d'un dépôt privé pour un vrai projet persistant nouveau est une action autonome. Rendre un dépôt public, transférer, archiver ou supprimer un dépôt exige une décision utilisateur.

## État initial et ownership

Avant une modification significative, relever HEAD, branche, remotes, branche par défaut si identifiable, `git status --short`, diff non indexé, diff indexé et fichiers non suivis. Ce snapshot distingue l’état utilisateur préexistant ; ne pas le persister en gros fichier.

Tout changement initial appartient à l’utilisateur, y compris index et fichiers non suivis. Ne jamais l’écraser, le restaurer, le désindexer ou le capturer implicitement. Avant commit, identifier les fichiers/hunks de la tâche, inspecter leur diff, indexer explicitement seulement les chemins ou hunks certains, puis relire `git diff --cached`. Ne pas utiliser `git add .`, `git add -A` ni `git commit -a`.

Si agent et utilisateur ont modifié le même fichier, n’indexer que les hunks certains. Sinon préserver tout, ne pas committer le fichier entier et marquer le checkpoint `PARTIAL/BLOCKED`. Un index préexistant ambigu interdit le commit automatique, pas les travaux locaux sûrs.

## Branche, commit et push

Avec un remote, si la branche courante est par défaut/protégée avant modification significative, créer `ai/<id-ou-phase>-<slug>`. Réutiliser une branche de travail pertinente ; une branche couvre une unité cohérente, pas chaque micro-tâche. Sans remote, conserver la branche appropriée.

Après un checkpoint réellement validé et un staging sûr, créer sans confirmation un commit logique non vide. Viser une tâche validée par commit, regrouper seulement les corrections indissociables et respecter la convention existante ; sinon `<ID>: <résumé court>`.

Après commit, pousser vers le remote approprié : `git push -u <remote> <branch>` puis `git push`. En cas d’échec réseau/remote, conserver le commit local, signaler le push en attente, éviter les retries agressifs et poursuivre les tâches indépendantes.

## Pull request et merge GitHub

Si le remote est GitHub, vérifier `gh --version` et `gh auth status`. Ne jamais installer `gh` ni lancer un login interactif automatiquement. Si absent/non authentifié, Git local et push continuent ; PR `BLOCKED`.

À la fin d’une unité cohérente, chercher la PR de la branche. La créer si absente, sinon la mettre à jour par push. Titre avec ID/phase ; description compacte : objectif, changements, tests, risques/limites observés.

Activer/effectuer le merge automatique seulement si checks requis PASS, aucun conflit, aucune review obligatoire manquante, PR conforme et GitHub autorise le merge sans contourner protection/ruleset. Si review requise, laisser ouverte et poursuivre ce qui est indépendant. Ne jamais affaiblir une protection.

Après merge, mettre à jour la branche par défaut locale seulement si l’état est non ambigu ; nettoyer uniquement une branche inutile et entièrement fusionnée. Ne jamais supprimer une branche contenant du travail non fusionné.

## Conflits et garde-fous

Résoudre automatiquement un conflit de pull/rebase/merge seulement si le sens est clair, validable par tests et ne sacrifie aucun changement utilisateur ambigu. Sinon `BLOCKED`. Ne jamais choisir arbitrairement `ours`/`theirs`.

Interdits par défaut : `git reset --hard`, `git clean -fd`, `git clean -fdx`, `git push --force`, `git push -f`, rebase d’un historique publié, suppression distante arbitraire de branches/tags et modification rétroactive de commits partagés. Ne pas contourner par alias. `--force-with-lease` reste exceptionnel et exige une décision utilisateur.

## Continuité de livraison

Le cycle reste : action → travail → tests → plan/progress → commit → push → prochaine action. Commit, push, PR ou merge réussi n’est jamais une condition d’arrêt. À la reprise, corroborer `progress.md` avec statut Git, branche et quelques commits ciblés ; Git conserve les détails, pas `progress.md`.

