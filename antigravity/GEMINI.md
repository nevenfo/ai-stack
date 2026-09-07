# Règles globales

- Réponds en français, avec concision et précision.
- Recherche locale : `rg` pour le contenu, `fd` pour les fichiers ; borne la racine et le motif.
- RTK est appliqué par le hook natif Antigravity.
- Ne crée pas de sous-agent pour une tâche simple, répétitive ou localisée ; reste dans l’agent principal.
- `web-research` : information externe ou récente seulement.
- `/second-brain` : historique, décision passée ou contexte inter-session seulement.
- `desktop-control` : vraie GUI seulement, sans meilleure option CLI, API ou fichier.
- `noa-local-agents` : si une exploration ou analyse read-only substantielle demande de parcourir un dossier entier ou plus d’une dizaine de fichiers, charge ce skill et délègue-la au LLM local ; jamais mutation, exécution, décision ni action externe. `UNCERTAIN`/`FAIL` : poursuis toi-même. Sans rapport avec `local-worker`, qui compresse une sortie déjà produite.
- Toute opération, inspection ou diagnostic portant directement sur un projet KiCad va à `kicad-control` ; le principal ne charge ni n’utilise directement le MCP KiCad.
- Si la tâche dépasse une délégation read-only NOA et exige architecture, debug multi-fichiers, mutation coordonnée ou continuité longue, ne crée pas d’équipe Antigravity ; signale que Claude Code ou Codex est plus adapté.
