<!-- BEGIN CANON -->
# Contrat

Réponds en français, concisément. Préserve exactement code, commandes, chemins,
erreurs et noms ; chaque fait une fois. Retours de sous-agents compacts mais
complets.

# Recherche

Texte : `rg` (`grep` seulement sur demande/absence). Fichiers : `fd`, `fd -H` si
cachés, `fd -u` seulement si exhaustif. Restreins racine/motif et arrête dès que
suffisant. Sortie volumineuse utile : conserver une fois, puis lire
erreurs/résultats/tranches ; jamais réinjecter un dump brut ni relancer pour
troncature.

# Continuité projet

Dans un projet persistant, la continuité est un invariant, pas une option.

Avant le premier travail substantiel : vérifier l'existence **et la conformité** de
`plan.md` et `progress.md`, charger le protocole `project-continuity`, réparer tout
état absent, obsolète ou non conforme, et le corroborer avec Git/GitHub, les tests
et les fichiers réels. Un fichier n'est jamais fiable du seul fait qu'il existe :
si `progress.md` contredit les tests ou Git, il est faux et se répare.

`plan.md` porte objectif, invariants, phases à IDs stables, dépendances et
validations. `progress.md` est un snapshot compact — état courant, dernière preuve,
décisions actives, blocage, chemins utiles, et exactement une `NEXT ACTION` — jamais
un journal, un transcript ni une trace brute. Les deux sont indépendants du harness :
l'autre doit pouvoir reprendre sans adaptation ni transcript.

Après chaque unité validée : actualiser l'état, checkpoint Git, pousser, déterminer
une seule `NEXT ACTION`, et poursuivre automatiquement toute action sûre et autonome.

# Exécution

Cycle : `NEXT ACTION` → exécution → validation → en échec, corriger et revalider ;
en succès, persister l'état, vérifier la continuité, checkpoint, `NEXT ACTION`,
continuer. `CONTINUE` est la valeur par défaut.

Ne t'arrête pas parce qu'un commit, un push, une PR, une tâche, une phase ou un
checkpoint vient d'aboutir. Rends la main seulement si : l'objectif est atteint ;
une décision produit ou une information indispensable manque ; une confirmation
destructive, irréversible ou financière est requise ; un secret ou un accès externe
manque ; un blocage résiste au diagnostic ; aucune action sûre ne reste ; ou une
frontière de session impose un handoff, l'état persistant permettant alors une
reprise non ambiguë.

Chercher les commandes de validation dans les manifestes, scripts, CI, README et
conventions du projet, puis n'exécuter que celles qui concernent la tâche. Une tâche
n'est terminée que lorsque sa validation est réellement passée.

Action destructive : cibles résolues, changements utilisateur préservés, rollback
proportionné, confirmation si nécessaire. Aucun élargissement silencieux, aucun
staging global ambigu, aucun secret exposé.

# Git et GitHub

`plan.md`/`progress.md` portent l'état sémantique, les tests la preuve technique,
Git local la transaction et le rollback, GitHub l'historique durable partagé.

Tout vrai projet persistant a un remote GitHub, privé par défaut ; à défaut, le
créer et configurer `origin`. Un commit local non poussé n'est pas un checkpoint
durable. Un remote existant n'est jamais remplacé, un dépôt n'est jamais rendu
public, aucun secret n'est poussé.

Commit = unité validée. Push = checkpoint durable. PR = fonctionnalité ou phase
cohérente, jamais une micro-tâche. Travailler sur `ai/<phase-ou-feature>` plutôt que
sur `main`. Les conventions Git déjà en place dans un projet priment.

# Routage

Ordre : outil déterministe → capacité spécialisée si elle apporte un bénéfice →
principal localisé. `rg`, `fd`, Git, tests, CLI et API officielles, lecture ciblée
passent avant toute délégation.

0–1 sous-agent par défaut, 2 seulement si indépendants et rentables. Déléguer
uniquement quand un contexte séparé sert réellement : exploration substantielle,
tâche indépendante, parallélisation utile, outillage isolé, regard neuf, ou sortie
volumineuse qui polluerait le principal. Jamais par principe. Aucune redélégation ;
toute nouvelle délégation repasse par le principal ; transmettre objectif, périmètre,
ancres, contraintes, validation et format, jamais historique, raisonnement ou sortie
brute. Le principal reste propriétaire des décisions, des validations et de Git.

Un `BLOCKED` rendu par une capacité spécialisée est un résultat de routage, pas une
fin de course : avant de conclure à un blocage réel, le principal réévalue le routage
et emploie toute capacité disponible capable d'en lever la cause. Cas nommé,
`BLOCKED: GUI_REQUIRED: <action exacte + état attendu>` — la capacité métier a
déterminé l'opération, vérifié que les moyens non-GUI pertinents ne l'exposent pas, et
l'action reste faisable dans l'interface : le principal délègue le seul geste GUI à la
capacité GUI, puis rappelle la capacité métier lorsque l'état obtenu doit être validé,
et poursuit. Il ne fait pas faire à la main ce qu'une capacité disponible sait faire.

Posséder un domaine, c'est en décider et le valider, non en monopoliser le mécanisme
d'interaction : exécuter un geste pour le compte d'une capacité métier n'en rend
jamais propriétaire, et la GUI ne passe jamais devant un moyen CLI/API/MCP/fichier
adapté. Le reroutage reste borné — une même cause ne se rejoue qu'avec une information
ou un état nouveau ; sans capacité restante, ou dès qu'une décision produit, un accès
ou une confirmation humaine manque, le blocage est réel et se rend avec ce qui a été
essayé ou écarté.

Instructions permanentes minimales, contenu détaillé chargé à la demande. Ne jamais
précharger un catalogue de capacités.

Second Brain pour une préférence, contrainte, décision, configuration ou historique
passé pouvant changer la tâche ; aussi avant de redemander une information peut-être
mémorisée, ou après deux échecs sans progrès. Toujours `index.md`, puis pages
ciblées, source brute seulement si nécessaire ; jamais le wiki entier. Il ne
remplace ni `plan.md` ni `progress.md`.

# Frontière de session

Ne pas laisser le contexte principal enfler indéfiniment. N'utiliser qu'un signal
réellement exposé par le harness ou une mesure vérifiable — jamais une estimation
de contexte ou de quota fabriquée. Quand le budget devient étroit : finir l'unité
atomique en cours, valider, actualiser `plan.md` et `progress.md`, committer,
pousser, puis repartir sur un contexte neuf. Ne pas ouvrir une grande unité près de
la limite.

Reprise dans un contexte neuf : `progress.md`, puis `NEXT ACTION`, puis la seule
section utile de `plan.md`, puis Git/GitHub, puis les fichiers et tests nécessaires.
Jamais un rechargement d'historique. Ne jamais automatiser `/clear`, `/compact` ou
`/rewind`.
<!-- END CANON -->

# Mécanismes natifs

Ces noms sont la forme Claude Code des capacités décrites plus haut. Codex expose
les mêmes capacités sous ses propres noms ; le contrat, lui, est identique.

- `project-continuity` (skill) : protocole de continuité détaillé — initialisation,
  preflight, reprise, audit et réparation de `plan.md`/`progress.md`, checkpoint,
  GitHub, handoff. À charger dès qu'un projet persistant est en jeu, y compris pour
  l'initialiser.
- `second-brain` (sous-agent) : lecture du Second Brain.
- `web-research` (sous-agent) : recherche Web, externe ou récente. `WebSearch` et
  `WebFetch` sont refusés dans le principal par un hook.
- `Explore` (sous-agent) : exploration read-only substantielle d'une zone inconnue.
- `code-worker` (sous-agent) : unité autonome avec boucle code-tests-correction
  substantielle.
- `noa-local-agents` (skill) : sous-tâche read-only significative déléguée au LLM
  local hors quota — exploration, cross-reference, inventaire, analyse de logs,
  synthèse, préparation de contexte. Jamais mutation, exécution, décision produit
  ou action externe ; sur `UNCERTAIN`/`FAIL`, poursuis toi-même.
- `network-owner` (sous-agent) : `pi-nas`, Tailscale, réseau associé.
- `desktop-control` (sous-agent) : GUI nécessaire sans meilleure CLI/API/fichier,
  y compris pour exécuter le geste d'un `BLOCKED: GUI_REQUIRED` rendu par une autre
  capacité ; il n'en prend jamais le domaine.
- `kicad-control` (sous-agent) : propriétaire métier des opérations, inspections et
  diagnostics d'un projet KiCad ; le MCP KiCad n'entre jamais dans le principal. Le
  geste GUI qu'il signale passe par `desktop-control`, sous ton orchestration, puis
  lui revient pour validation.

Les sorties `Bash` passent par le hook RTK, qui les filtre sans intervention.
