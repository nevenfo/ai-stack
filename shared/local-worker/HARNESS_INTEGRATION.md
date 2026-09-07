# Intégration des harnesses

Ce document définit le workflow commun à Claude Code et Codex CLI. Le statut des modes appartient exclusivement à `README.md`, à relire avant chaque invocation.

## Activation

- Local Worker est une CLI locale auxiliaire, strictement read-only, pas un sous-agent.
- Un mode `MANUEL` n'est appelé que si l'utilisateur demande explicitement Local Worker ou ce mode. Une tâche volumineuse ne suffit pas à l'activer.
- Un mode `DÉSACTIVÉ` n'est ni proposé ni utilisé comme route du harness.
- Un mode `AUTO` ne peut être routé automatiquement que si le tableau live de `README.md` le déclare explicitement.
- Sans demande explicite, le harness peut signaler l'existence du worker mais poursuit avec ses outils déterministes puis le principal.

## Routage

Priorité à `rg`, `fd`, RTK, parsers, tests ciblés et sorties structurées. N'envoyer au worker qu'une donnée déjà produite, volumineuse, compressible, read-only et à faible risque. Ne pas l'utiliser pour écrire, patcher, committer, décider d'une architecture ou d'un produit, traiter un sujet de sécurité critique, choisir une commande, ni remplacer un agent spécialisé qui doit raisonner sur la source.

Pour une invocation manuelle, utiliser stdin ou `--file` avec :

```powershell
C:\Users\FlowUP\Documents\Etabli\Tools\local-worker\local-worker.cmd <mode>
```

Ce wrapper prépare à la demande le serveur LM Studio et le modèle demandé selon la politique sûre du README ; aucune préparation manuelle préalable n’est requise quand la VRAM est libre.

Ne pas ajouter `--auto` à un mode `MANUEL`. Éviter un appel lourd pour une petite entrée ou une sortie déjà suffisamment réduite, sauf insistance explicite de l'utilisateur.

## Fallback et mesure

Si la commande retourne le code `2`, `Local Worker FAIL`, une confiance faible ou un résultat insuffisant : aucun retry, aucun autre mode ou modèle local ; le principal reprend immédiatement avec ses outils ou sa propre lecture et conserve l'échec visible.

Si le principal utilise la sortie puis rouvre la source originale pour poursuivre correctement, exécuter immédiatement :

```powershell
C:\Users\FlowUP\Documents\Etabli\Tools\local-worker\local-worker.cmd mark-reread
```

En cas d'appels concurrents, suivre le contrat `--call-id` du README. Ne recopier aucun contenu sensible dans les métriques et ne créer aucune télémétrie parallèle.
