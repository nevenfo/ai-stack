# Benchmark d'effort — High contre Medium

Ce corpus sert à décider, sur des données réelles, si le niveau d'effort par
défaut doit rester `high`. Il est identique pour Claude Code et pour Codex :
mêmes dépôts de départ, mêmes prompts au caractère près, mêmes validations
exécutables. Chaque harness est comparé à lui-même, jamais à l'autre — les
fournisseurs diffèrent, l'intention seule est commune.

Rien ici n'estime : une valeur non exposée par le client est relevée comme non
mesurée.

## Construire le corpus

    bash ~/.agents/effort-bench/build-fixtures.sh <dossier>

Six dépôts Git jetables y sont créés, chacun figé sur un commit initial. Le
dossier est reconstruit à l'identique à chaque appel : c'est ce qui rend une
comparaison possible. Ne jamais rejouer une tâche dans un dépôt déjà servi.

Chaque fixture porte un `PROMPT.txt` — le prompt littéral, à passer tel quel — et
un `test.sh` qui décide seul du PASS. `test.sh` ne doit jamais être modifié par
le harness testé ; une réussite obtenue en le modifiant est un échec.

## Les six tâches

| ID | Nature | Ce qui est éprouvé |
|----|--------|--------------------|
| t1 | modification ciblée | ne pas déborder d'une consigne étroite |
| t2 | bug multi-fichiers | remonter d'un symptôme à sa cause ailleurs |
| t3 | feature moyenne | implémenter une spécification donnée |
| t4 | exploration | lire une base inconnue et répondre juste |
| t5 | review | voir des défauts sans qu'on les annonce |
| t6 | reprise de continuité | preflight, réparation, `NEXT ACTION` unique |

Les six fixtures partent d'un `test.sh` qui échoue, et le PASS attendu vient de
l'intervention seule. `t4` et `t5` échouent d'abord faute du fichier de réponse
qu'elles demandent. `build-fixtures.sh` affiche l'état initial de chacune : six
`FAIL` attendus, et une fixture qui passerait déjà serait un défaut du corpus,
pas une réussite.

## Exécuter

Côté Codex, hors PowerShell, le profil est explicite :

    codex -p cli-lean -c model_reasoning_effort=<high|medium> \
      exec -C <fixture> -s workspace-write "$(cat <fixture>/PROMPT.txt)"

Côté Claude Code, la tâche est lancée dans un sous-agent, dont le harness
retourne les tokens, le nombre d'appels d'outils et la durée.

Le prompt est passé sans ajout, sans reformulation et sans contexte
supplémentaire. Aucune aide n'est apportée en cours de tâche : une tâche
interrompue par une question compte comme telle, ce fait étant lui-même une
donnée.

## Ce qui est relevé

Par tâche et par niveau d'effort, uniquement depuis ce que le client expose :

- PASS ou FAIL, décidé par `test.sh` seul ;
- tokens ;
- durée ;
- nombre d'appels d'outils ;
- nombre de tours ;
- corrections nécessaires après la première réponse ;
- pour `t6`, conformité de `progress.md` à `continuity-check.sh` et unicité de
  la `NEXT ACTION`.

Trois répétitions par cellule. Une cellule est douze exécutions par harness :
six tâches, deux niveaux. Un écart observé sur une seule tâche ne décide de
rien.

## Règle de décision

`medium` ne devient le défaut que si, pour un harness donné, il apporte une
économie franche de tokens ou de durée **sans** baisse mesurable du taux de
PASS, sans corrections supplémentaires et sans dégradation de `t6`. À égalité de
qualité et gain marginal, `high` est conservé : le défaut en place ne cède qu'à
une preuve, et l'absence de preuve n'en est pas une.

La décision est prise séparément pour Claude et pour Codex. Rien n'oblige les
deux harnesses au même niveau : leur parité porte sur l'intention, pas sur la
valeur d'un paramètre propre à chaque fournisseur.
