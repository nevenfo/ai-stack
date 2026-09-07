---
name: noa-local-agents
description: "Utilise ce skill pour déléguer spontanément au LLM local toute exploration ou analyse read-only significative avant de la faire dans le cloud : cross-reference définition-appelants-tests, architecture multi-fichiers, analyse de logs bornés, inventaire, localisation et préparation de contexte. Le local lit le dépôt à ta place et économise des tokens cloud. Jamais mutation, exécution, décision, réseau ni exhaustivité garantie ; si UNCERTAIN ou FAIL, reprends toi-même."
---

# NOA Local Agents

Sous-agents LLM locaux, **read-only**, exécutés sur cette machine par LM Studio.
Ils ne consomment aucun quota cloud. Tu gardes le raisonnement, les décisions et
toutes les mutations ; tu leur confies la lecture de volume.

Ils n'ont **rien à voir** avec le projet `Local Worker`
(`Documents\Etabli\Tools\local-worker`), qui compresse une sortie déjà produite
et s'appelle autrement. Ne pas confondre les deux.

## Appel

```bash
C:/Users/FlowUP/noa/bin/noa-agent.cmd --role explore --project "<cwd>" --task-file "<fichier>"
```

Passe la tâche par `--task-file` (ou stdin). Une tâche longue, multiligne ou
accentuée passée en argument de ligne de commande s'abîme sous Windows :
`--task` n'existe que pour une question d'une ligne.

`--project` est **obligatoire en pratique** : sans lui, l'agent explore le
dossier courant du shell, qui n'est pas toujours celui de ta tâche.

Tu n'as pas à passer `--backend` ni `--session-id` : l'agent lit
`CODEX_SESSION_ID` dans son environnement et rattache l'appel à ta session tout
seul. Les passer explicitement reste possible et prioritaire.

## Rôles

| rôle | ce qu'il rend |
| --- | --- |
| `explore` | des endroits : fichiers, lignes, inventaire, localisation |
| `analyze` | un mécanisme : ce qui appelle quoi, dans quel ordre, sous quelle condition |
| `context` | un dossier prêt à modifier : fichiers à ouvrir, points d'entrée, appelants, conventions, angles morts |

## Réponse

JSON sur stdout :

- `status` — `SUCCESS`, `UNCERTAIN`, `NEEDS_DATA` ou `FAIL`
- `answer`, `findings`, `files`, `confidence`
- `evidence` — étapes, fichiers lus, tokens locaux, latence
- `split_advice` — présent **seulement** si l'appel a buté sur son
  périmètre : voir « Périmètre » plus bas

Code de sortie `0` : exploitable. **Tout autre code : reprends toi-même,
immédiatement, sans le rappeler.** Une panne de LM Studio est un `FAIL` comme
un autre — elle ne t'empêche pas de continuer.

## Quand déléguer

Quand répondre supposerait d'ouvrir plus d'une dizaine de fichiers, ou de
parcourir un dossier entier. Tu ne lis ensuite toi-même que ce que sa réponse
désigne.

Ce qui décide n'est ni le nombre de questions, ni la taille du dépôt, mais la
**forme de la sortie** que tu demandes. Une sortie *fermée* — qu'une opération
déterministe suffit à clore : localiser, lister, relier deux extrémités
nommées, agréger un journal, expliquer une cause que le symptôme désigne déjà —
est rendue 13 fois sur 15. Une sortie *ouverte* — « dans l'ordre du chemin
d'exécution », « tout ce qui casserait » — n'a **jamais** conclu, ni en un
appel ni en deux scopes (0 sur 8), quel que soit le périmètre.

| famille | déléguer ? | comment |
| --- | --- | --- |
| `locate`, `inventory` | **oui** | `explore`, un appel ; inventaire borné à un dossier ou un manifeste |
| `logs-analysis` | **oui** | `analyze`, sur un extrait déjà filtré, jamais sur un journal brut |
| `readonly-bug-analysis` | **oui** | `analyze`, si le symptôme est précis et désigne le comportement |
| `cross-reference`, `multi-files` | oui | `analyze` ; deux scopes si la chaîne traverse deux paquets |
| `architecture-summary` | ça dépend | énumératif — un composant, une phrase, ses liens — : oui. Récit ordonné : non |
| `context-preparation` | non | seule la moitié « où est-ce déclaré » passe ; « ce qui casserait », jamais |

Demande-lui des chemins **relatifs à la racine, avec des `/`**. Un chemin mal
écrit lui fait rendre `UNCERTAIN` sur une réponse par ailleurs juste, et tu
refais alors un travail déjà fait.

## Quand ne pas déléguer

- La tâche est petite, ou l'exploration est triviale : tu vas plus vite seul.
- Il faut écrire, exécuter, décider, ou toucher quoi que ce soit d'externe.
- L'exhaustivité doit être **garantie** : le local omet parfois un élément, et
  c'est son mode d'échec principal.
- Un fait dont dépend une modification que tu vas écrire : vérifie-le toi-même.

Au-delà de deux appels sur une même tâche, la lecture directe coûte moins cher.

## Périmètre : un appel, deux au plus

Un appel par défaut. Deux seulement si la tâche couvre réellement plusieurs
zones ou responsabilités indépendantes — et alors le découpage vient de la
structure de la tâche, jamais d'un partage par nombre de fichiers.

Mesuré : six responsabilités demandées en un seul appel n'ont jamais rendu de
carte (3 essais sur 3, 72 k à 175 k tokens locaux pour un handoff vide). Les
mêmes six réparties sur deux scopes de trois ont rendu 3 fois sur 3 une carte
juste, pour 131 k tokens cumulés.

**Ne compte pas les responsabilités pour décider.** Sur 22 mesures à trois
responsabilités ou moins, 11 ont conclu : exactement le hasard. Un appel a
couvert sept zones et conclu en 4 pas ; un autre en couvrait deux et n'a rien
rendu. C'est la forme de la sortie qui décide, pas le compte.

Quand un appel s'arrête sur son périmètre plutôt que sur la question, la
réponse porte `split_advice` : c'est le signal pour rappeler le local sur deux
scopes plus étroits — mais il dit qu'un appel a buté sur son périmètre, pas que
le redécouper y changera quelque chose. Sur cinq cas où il a été rendu, deux ont
été intégralement récupérés par deux scopes — dont un pour 72 % de tokens en
moins que l'appel raté — et trois ont doublé la dépense pour un handoff vide.
**Ne le suis que si la sortie demandée est fermée.**

Chaque scope reçoit **seulement** son objectif, son
périmètre, ses ancres, la contrainte read-only et le format attendu — jamais
l'historique de l'autre appel. Tu assembles ensuite les deux réponses toi-même.

Si deux scopes ne suffisent pas, reprends côté cloud. Un troisième appel local
n'a jamais été nécessaire, et son assemblage te coûte ce que la délégation
t'économisait.

## Limites connues

- Modèle `qwen3.5-9b@q8_0`, contexte 32 768, budget de 14 étapes. Il conclut
  `UNCERTAIN` plutôt que d'inventer — c'est voulu, et un `UNCERTAIN` t'est plus
  utile qu'une liste incomplète présentée comme complète.
- Strictement confiné à `--project` : il ne peut pas lire ailleurs.
- Aucun accès réseau, aucune exécution de commande.
- Il joint LM Studio en loopback. Dans un projet non approuvé, le sandbox Codex
  coupe le réseau et l'appel rend un `FAIL` immédiat : c'est un `FAIL` comme un
  autre, tu poursuis toi-même.
