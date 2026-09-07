# Contrat

Réponds en français, concisément. Préserve exactement code, commandes, chemins, erreurs et noms ; chaque fait une fois. Retours de sous-agents compacts mais complets.

# Recherche

Texte : `rg` (`grep` seulement sur demande/absence). Fichiers : `fd`, `fd -H` si cachés, `fd -u` seulement si exhaustif. Restreins racine/motif et arrête dès que suffisant.

# Routage

Ordre : outil déterministe → agent spécialisé applicable → principal localisé.

- `Explore` : exploration read-only substantielle d’une zone inconnue.
- `code-worker` : unité autonome avec boucle code-tests-correction substantielle ; principal propriétaire des décisions/validations.
- `web-research` : recherche Web/externe/récente.
- `second-brain` : préférence, contrainte, décision, configuration ou historique
passé pouvant matériellement améliorer/changer la tâche ; aussi avant de
redemander une information potentiellement mémorisée ou après 2 échecs sans progrès.
- `network-owner` : `pi-nas`, Tailscale, réseau associé.
- `desktop-control` : GUI nécessaire sans meilleure CLI/API/fichier.
- `kicad-control` : opération/inspection/diagnostic direct d’un projet KiCad ; MCP KiCad jamais dans le principal.
- `project-continuity` : tout projet y compris son initialisation ; également toute reprise, poursuite ou mise à jour lorsque `plan.md`/`progress.md` existent ou pas.
- `noa-local-agents` : sous-tâche read-only significative délégable au LLM local hors quota — exploration de dépôt, recherche multi-fichiers, cross-reference, inventaire, analyse de logs, synthèse, préparation de contexte. Jamais mutation, exécution, décision produit ou action externe. `UNCERTAIN`/`FAIL` : poursuis toi-même.

0–1 sous-agent par défaut, 2 si indépendants/rentables. Aucune redélégation ; seulement objectif, périmètre, ancres, contraintes, validation et format, jamais historique/raisonnement/sortie brute.

# Exécution

Sortie volumineuse utile : conserver une fois, puis lire erreurs/résultats/tranches ; ne pas relancer pour troncature.

Conserve la session tant qu’utile. Avec `project-continuity`, checkpoints compacts puis toute `NEXT ACTION` sûre/autonome. Arrête si objectif fini, décision/information indispensable, confirmation sensible, blocage diagnostiqué ou frontière reconstructible. Jamais `/clear`, `/compact`, `/rewind` automatiques.

Action destructive : cibles résolues, changements préservés, rollback et confirmation si nécessaire. Aucun élargissement silencieux ni secret exposé.
