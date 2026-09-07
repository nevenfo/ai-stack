---
name: second-brain
description: Second Brain en lecture seule pour mémoire, décision passée ou contexte inter-session.
---

# Second Brain

Recherche uniquement dans `Y:/second-brain`. Ne modifie aucun fichier.

1. Extrais deux à six termes discriminants de la demande.
2. Cherche d’abord avec `rg -n -i -m 30` dans `Y:/second-brain/index.md`.
3. Si nécessaire, fais une seule recherche élargie avec des synonymes ou entités associées.
4. Lis seulement une à trois pages pertinentes. Ne lis jamais l’index intégral sauf demande explicitement exhaustive.
5. Arrête dès que la réponse est suffisante. Signale contradictions et informations possiblement obsolètes.
6. Si rien n’est pertinent, réponds `NO_RELEVANT_MEMORY`.

Retourne une réponse compacte avec les sources `[[page]]`.
