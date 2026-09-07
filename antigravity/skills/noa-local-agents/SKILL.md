---
name: noa-local-agents
description: "Utilise ce skill pour déléguer spontanément au LLM local toute exploration ou analyse read-only significative avant de la faire dans le cloud : cross-reference définition-appelants-tests, architecture multi-fichiers, analyse de logs bornés, inventaire, localisation et préparation de contexte. Le local lit le dépôt à ta place et économise des tokens cloud. Jamais mutation, exécution, décision, réseau ni exhaustivité garantie ; si UNCERTAIN ou FAIL, reprends toi-même. Sans rapport avec `local-worker`."
---

# NOA Local Agents

Sous-agents LLM locaux, **read-only**, exécutés sur cette machine par LM Studio.
Ils ne consomment aucun quota cloud. Tu gardes le raisonnement, les décisions et
toutes les mutations ; tu leur confies la lecture de volume.

## À ne pas confondre avec `local-worker`

Le skill `local-worker` de cette machine est un **autre projet**, au contrat
opposé : il compresse une sortie que tu as **déjà** produite (log, diff,
résultats de recherche), il ne lit rien de lui-même, et il ne s'active que si
l'utilisateur le demande explicitement.

NOA Local Agents va au contraire **chercher** ce que tu n'as pas encore : il
explore un dépôt avec ses propres outils de lecture. Les deux coexistent, ne
partagent aucun code, et ne se remplacent pas.

## Appel

```bash
C:/Users/FlowUP/noa/bin/noa-agent.cmd --role explore --project "<racine du projet>" --task-file "<fichier>"
```

`--project` est **obligatoire ici**. `run_command` s'exécute par défaut dans
`~/.gemini/antigravity-cli/scratch`, qui n'est jamais le projet de la tâche :
sans `--project`, l'agent explorerait un dossier vide.

Passe la tâche par `--task-file` (ou stdin). Une tâche longue, multiligne ou
accentuée passée en argument de ligne de commande s'abîme sous Windows :
`--task` n'existe que pour une question d'une ligne.

Tu n'as pas à passer `--backend` ni `--session-id` : l'agent lit
`ANTIGRAVITY_CONVERSATION_ID` dans son environnement et rattache l'appel à ta
conversation tout seul.

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

Code de sortie `0` : exploitable. **Tout autre code : reprends toi-même,
immédiatement, sans le rappeler.** Une panne de LM Studio est un `FAIL` comme
un autre — elle ne t'empêche pas de continuer.

## Quand déléguer

Quand répondre supposerait d'ouvrir plus d'une dizaine de fichiers, ou de
parcourir un dossier entier. Tu ne lis ensuite toi-même que ce que sa réponse
désigne.

## Quand ne pas déléguer

- La tâche est petite, ou l'exploration est triviale : tu vas plus vite seul.
- Il faut écrire, exécuter, décider, ou toucher quoi que ce soit d'externe.
- L'exhaustivité doit être **garantie** : le local omet parfois un élément, et
  c'est son mode d'échec principal.
- Un fait dont dépend une modification que tu vas écrire : vérifie-le toi-même.

Au-delà de trois appels sur une même tâche, la lecture directe coûte moins cher.

## Limites connues

- Modèle `qwen3.5-9b@q8_0`, contexte 32 768, budget de 14 étapes. Il conclut
  `UNCERTAIN` plutôt que d'inventer — un `UNCERTAIN` t'est plus utile qu'une
  liste incomplète présentée comme complète.
- Strictement confiné à `--project` : il ne peut pas lire ailleurs.
- Aucun accès réseau, aucune exécution de commande.
