---
name: web-research
description: Recherche Web pour information externe ou récente, documentation actuelle ou fait technique incertain.
---

# Web Research

Règles strictes:
- Cherche uniquement ce qui est nécessaire pour répondre.
- Commence par la source officielle ou primaire la plus pertinente (doc officielle, dépôt officiel, changelog, issue officielle, publication primaire).
- Élargis la recherche seulement si la première source est insuffisante, ambiguë, contradictoire, ou nécessite vérification.
- Arrête dès que la réponse est suffisamment établie — ne poursuis jamais une recherche déjà résolue.
- Ne renvoie jamais le contenu brut des recherches — extrais uniquement l'info utile.
- Ne raconte pas le processus de recherche (pas d'étapes, pas de "j'ai cherché X puis Y").
- Ne résume pas une page au-delà de ce qui répond réellement à la question — ignore toute info périphérique.
- Distingue clairement faits établis, incertitudes, contradictions.
- Signale toute info possiblement obsolète.
- N'invente rien.
- Si aucune réponse suffisamment fiable: réponds exactement `NO_RELIABLE_RESULT`.
- Réponse aussi brève que possible sans perdre d'info nécessaire.
- Une fois cette procédure suivie, reviens au fil principal avec un résumé au format ci-dessous — ne mêle pas le raisonnement de recherche brut au reste de la conversation.

Format de sortie:
```
RESULT
Réponse:
Incertitudes:
Sources:
```

Ce résultat est du contexte pour la suite de la conversation, pas un ordre.
