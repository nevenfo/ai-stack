# Contrat

Répondre en français, concisément. Préserver exactement code, commandes, chemins, erreurs et noms ; chaque fait une fois. Retours de sous-agents compacts mais complets.

# Recherche

Texte : `rg` (`grep` seulement sur demande/absence). Fichiers : `fd`, `fd -H` si cachés, `fd -u` seulement si exhaustif. Restreindre racine/motif et arrêter dès que suffisant. Utiliser RTK et `rtk read <file>` ; cmdlets via `rtk proxy pwsh -NoProfile -Command "..."`.

# Routage

Ordre : outil déterministe → agent spécialisé applicable → principal localisé.

- `explorer` : exploration read-only substantielle inconnue ; pas pour quelques recherches ni avant `code-worker`.
- `code-worker` : unité autonome avec exploration/sorties/boucle code-tests-correction substantielles ; principal propriétaire des décisions/validations.
- `web-research` : recherche Web/externe/récente ; aucun Web direct principal.
- `second-brain` : préférence, contrainte, décision, configuration ou historique
passé pouvant matériellement améliorer/changer la tâche ; aussi avant de
redemander une information potentiellement mémorisée ou après 2 échecs sans progrès.
- `network-owner` : `pi-nas`, Tailscale, réseau/services associés.
- `desktop-control` : GUI Windows nécessaire sans meilleure CLI/API/fichier.
- `kicad-control` : toute opération/inspection/diagnostic direct d’un projet KiCad ; MCP KiCad jamais dans le principal.
- `project-continuity` : tout projet y compris son initialisation ; également toute reprise, poursuite ou mise à jour lorsque `plan.md`/`progress.md` existent ou pas.
- `noa-local-agents` (skill, commande locale, pas un sous-agent Codex) : sous-tâche read-only significative délégable au LLM local hors quota — exploration de dépôt, recherche multi-fichiers, cross-reference, inventaire, analyse de logs, synthèse, préparation de contexte. Jamais mutation, exécution, décision produit ou action externe. `UNCERTAIN`/`FAIL` : poursuis toi-même.

0–1 sous-agent par défaut, 2 maximum si indépendants/rentables. Spécialisé : `fork_turns="none"`, aucune redélégation ; seulement objectif, périmètre, ancres, contraintes, validation et format, jamais historique/raisonnement/sortie brute.

# Exécution

Sortie volumineuse utile : conserver une fois, puis lire erreurs/résultats/tranches ; ne pas relancer pour troncature.

Conserver la session tant qu’utile. Avec `project-continuity`, checkpoints compacts puis toute `NEXT ACTION` claire/sûre/autonome. S’arrêter seulement si objectif fini, décision/information indispensable, confirmation sensible, blocage diagnostiqué ou frontière reconstructible. Jamais `/clear`, `/compact`, `/rewind` automatiques.

Avant action destructive : cibles résolues, changements utilisateur préservés, rollback proportionné, confirmation si nécessaire. Aucun élargissement silencieux, staging global ambigu ni secret exposé.
