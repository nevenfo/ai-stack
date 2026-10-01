# PLAN — ai-stack : miroir de configuration et parité Claude / Codex

## Objectif final

`ai-stack` est la représentation Git propre de la configuration **actuelle** de la
stack IA locale. Cette stack compte exactement deux harnesses, **pairs et
interchangeables** : Claude Code et Codex. Ils sont deux implémentations du même
harness logique — même contrat de continuité, même autonomie, même politique
Git/GitHub, même philosophie de routage — et un projet passe de l'un à l'autre
sans reconstruction manuelle de son état.

Le projet appartient à `GitHub + plan.md + progress.md + code/tests`, jamais à un
harness.

## Invariants

- **Parité sémantique.** Toute différence entre les deux configurations relève de
  (1) la syntaxe native du harness, (2) une capacité native réellement différente,
  (3) un modèle/paramètre propre à la plateforme. Toute autre divergence est un
  défaut.
- **Source canonique unique.** Le contrat commun vit dans `~/.agents/CONTRACT.md`
  et est recopié à l'identique entre marqueurs dans `~/.claude/CLAUDE.md` et
  `~/.codex/AGENTS.md`. Les skills partagés vivent une seule fois, dans
  `~/.agents/skills/`.
- **Déclenchement permanent, détails lazy.** L'invariant de continuité vit dans les
  instructions permanentes des deux harnesses ; le protocole détaillé reste dans le
  skill `project-continuity`, chargé à la demande.
- **Aucun harness secondaire.** Ni fallback, ni owner. Antigravity ne fait plus
  partie de la stack.
- **Existence n'est pas fiabilité.** `plan.md` et `progress.md` ne sont jamais crus
  sur leur seule présence ; ils sont corroborés par Git/GitHub, tests et fichiers.
- **GitHub durable.** Un commit local non poussé n'est pas un checkpoint durable.
- La source de vérité reste la configuration live ; ce dépôt en est le miroir. Ni
  secrets, ni empreintes machine réidentifiantes, ni conversations, ni caches, ni
  journaux, ni poids de modèles, ni projets utilisateurs, ni corpus.
- Les composants ayant leur propre dépôt (`noa`, `conv-exporter`, `local-worker`)
  ne sont représentés que par leur surface d'intégration et un `REFERENCE.md`.
- `AGENTS.md` est le contrat `export` du dépôt ; `CLAUDE.md` vaut `@AGENTS.md`.

## Critères globaux de réussite

- La matrice de parité est complète : chaque case implémentée, ou justifiée par une
  limite technique nommée.
- `parity-check` passe, et échoue réellement quand un côté diverge.
- Une reprise croisée Claude vers Codex et Codex vers Claude fonctionne depuis
  `progress.md` seul, sans transcript.
- Aucune dépendance fonctionnelle à Antigravity ne subsiste.
- `nevenfo/ai-stack` reflète l'état live des deux harnesses, poussé sur `main`.

---

# Phase A — Audit live et matrice de divergences

## A1 — Cartographie de l'état réel

### Objectif

Connaître les fichiers réellement chargés par chaque harness, pas ceux supposés.

### Dépendances

Aucune.

### Tâches

- [x] A1.1 Instructions globales live des deux harnesses.
- [x] A1.2 Settings, hooks, agents, skills, plugins live des deux côtés.
- [x] A1.3 Modèle et niveau d'effort réellement configurés des deux côtés.
- [x] A1.4 État Git d'`ai-stack` : branche, statut, remote, historique.
- [x] A1.5 `gh auth status` et inventaire des dépôts `nevenfo`.
- [x] A1.6 Inventaire des références Antigravity encore actives.
- [x] A1.7 Corroboration comportementale via le Second Brain.

### Validation

Chaque affirmation de la matrice A2 pointe vers un chemin de fichier live inspecté.

## A2 — Matrice de divergences

### Objectif

Nommer les écarts à corriger, en distinguant divergence légitime et défaut.

### Dépendances

A1.

### Tâches

- [x] A2.1 Divergence : aucun invariant de continuité permanent des deux côtés.
- [x] A2.2 Divergence : aucune politique GitHub-first, ni permanente ni lazy.
- [x] A2.3 Divergence : `gpt-5.6-sol` en `medium` face à `opus` en `high`.
- [x] A2.4 Divergence : skills partagés dupliqués par copie, `noa-local-agents`
      ayant déjà divergé entre `~/.agents/` et `~/.claude/`.
- [x] A2.5 Divergence : Antigravity encore câblé (dépôt, `~/.gemini/`, hooks,
      règles, contrats).

### Validation

Chaque ligne reçoit en H1 un statut Claude et un statut Codex.

---

# Phase B — Contrat canonique commun

## B1 — `~/.agents/CONTRACT.md`

### Objectif

Une source unique pour tout ce que les deux harnesses doivent dire à l'identique :
contrat de réponse, recherche, continuité, exécution et autonomie, Git/GitHub,
philosophie de routage et de skills, Second Brain, frontière de session.

### Dépendances

A2.

### Tâches

- [x] B1.1 Rédiger le bloc canonique ; la section « Continuité projet » vise
      150 à 250 tokens permanents, le reste reste compact.
- [x] B1.2 Délimiter le bloc par `<!-- BEGIN CANON -->` et `<!-- END CANON -->`.
- [x] B1.3 Ne laisser hors du bloc que le routage nommant un mécanisme natif.

### Validation

Le bloc ne contient aucun nom d'outil propre à un seul harness.

## B2 — Injection dans les deux harnesses

### Objectif

`CLAUDE.md` et `AGENTS.md` portent le bloc canonique octet pour octet.

### Dépendances

B1.

### Tâches

- [x] B2.1 Réécrire `~/.claude/CLAUDE.md` : bloc canonique et routage Claude.
- [x] B2.2 Réécrire `~/.codex/AGENTS.md` : bloc canonique et routage Codex.

### Validation

Le bloc extrait des deux fichiers est identique au caractère près à
`~/.agents/CONTRACT.md`.

---

# Phase C — `project-continuity` unique et complet

## C1 — Protocole détaillé partagé

### Objectif

Un seul `SKILL.md` couvrant initialisation, preflight, reprise, audit et réparation
de `plan.md` et `progress.md`, validation, persistance, Git, GitHub, checkpoint,
auto-poursuite, handoff et frontière de session.

### Dépendances

B1.

### Tâches

- [x] C1.1 Ajouter le preflight de continuité et l'audit corroboré avec réparation.
- [x] C1.2 Ajouter le self-healing en cours de session après chaque PASS.
- [x] C1.3 Ajouter la politique GitHub-first et la création de dépôt privé dans
      `references/git-delivery.md`.
- [x] C1.4 Écrire le contrat de handoff inter-harness, sans `handoff.md`.

### Validation

Le skill couvre les quatorze points du contrat, sans version réduite d'un côté.

## C2 — Fin de la duplication physique

### Objectif

Les skills partagés existent une seule fois sur le disque.

### Dépendances

C1.

### Tâches

- [x] C2.1 Réconcilier `noa-local-agents`, dont les deux copies ont divergé.
- [x] C2.2 Remplacer les copies sous `~/.claude/skills/` par des jonctions vers
      `~/.agents/skills/`.
- [x] C2.3 Vérifier que Claude Code résout les jonctions et charge les skills.

### Validation

Une écriture dans `~/.agents/skills/<s>/SKILL.md` est immédiatement visible depuis
`~/.claude/skills/<s>/SKILL.md`.

---

# Phase D — Modèle et effort

## D1 — Parité d'intention opérationnelle

### Objectif

Même niveau de qualité visé des deux côtés, sans valeur inventée.

### Dépendances

A1.3.

### Tâches

- [x] D1.1 Confirmer Claude sur `opus` avec `effortLevel: high`.
- [x] D1.2 Choisir le pendant Codex depuis les capacités réelles du client installé.
- [x] D1.3 Appliquer et documenter le choix dans la configuration Codex.

### Validation

Le modèle et l'effort retenus figurent dans le catalogue de modèles du client
installé.

---

# Phase E — Suppression d'Antigravity

## E1 — Décâblage

### Objectif

Aucune dépendance fonctionnelle à Antigravity dans la stack active.

### Dépendances

Aucune.

### Tâches

- [x] E1.1 Supprimer `antigravity/` du dépôt.
- [x] E1.2 Retirer Antigravity des contrats `AGENTS.md`, `README.md`, `plan.md`.
- [x] E1.3 Retirer la surface d'intégration Antigravity de `shared/`.
- [x] E1.4 Archiver `~/.gemini/` et `~/.agents/rules/` hors de la stack, sans
      désinstaller le logiciel.

### Validation

Une recherche insensible à la casse sur `antigravity`, `gemini` et `AGY` dans le
dépôt et dans la configuration active des deux harnesses ne renvoie aucun câblage
fonctionnel.

---

# Phase F — Contrôle de parité déterministe

## F1 — `parity-check`

### Objectif

Empêcher qu'un harness évolue seul. Petit, déterministe, sans templating.

### Dépendances

B2, C2, D1.

### Tâches

- [x] F1.1 Vérifier l'identité du bloc canonique dans les deux fichiers.
- [x] F1.2 Vérifier la présence des invariants clés des deux côtés.
- [x] F1.3 Vérifier que les skills partagés sont partagés et non copiés.
- [x] F1.4 Vérifier modèle et effort des deux côtés.
- [x] F1.5 Vérifier l'absence de câblage Antigravity.
- [x] F1.6 Test négatif : une divergence introduite fait échouer le contrôle.

### Validation

Sortie lisible, code de retour non nul en cas de divergence, test négatif probant.

---

# Phase G — Miroir et GitHub

## G1 — Resynchronisation d'`ai-stack`

### Objectif

Le dépôt reflète l'état live des deux harnesses après la refonte.

### Dépendances

E1, F1.

### Tâches

- [x] G1.1 Resynchroniser `claude/`, `codex/`, `shared/` et le dossier `agents/`.
- [x] G1.2 Relire le diff complet et vérifier l'absence de secret.
- [x] G1.3 Commit ciblé, push, puis intégration dans `main`.

### Validation

`git status` propre, diff relu, `main` à jour sur `nevenfo/ai-stack`.

---

# Phase H — Parité prouvée

## H1 — Matrice de parité

### Objectif

Chaque invariant reçoit un statut des deux côtés.

### Dépendances

F1.

### Tâches

- [x] H1.1 Renseigner la matrice dans `README.md`.

### Validation

Aucune case vide sans justification technique nommée.

## H2 — Tests de reprise croisée, côté Claude Code

### Objectif

Prouver sur des dépôts jetables, et non par déclaration, que Claude Code applique
le contrat : preflight, réparation, validation, checkpoint, auto-poursuite.

### Dépendances

G1.

### Tâches

- [x] H2.1 Fixture conforme initialisée par Claude Code, reprise à froid par un
      processus Claude Code sans contexte.
- [x] H2.2 `progress.md` faux — état déclaré contredit par les tests — détecté et
      réparé.
- [x] H2.3 Plan incomplet — unité sans `Objectif`, `Dépendances` ou `Validation` —
      normalisé.
- [x] H2.4 Unité PASS suivie d'un checkpoint puis d'une `NEXT ACTION`, sans arrêt
      artificiel.
- [x] H2.5 Projet persistant sans remote : logique GitHub consignée, aucun dépôt
      créé dans un bac à sable.
- [x] H2.6 Contrôle structurel déterministe des fixtures avant et après reprise.

### Validation

Pour chaque scénario : sortie de `test.sh`, `git log`, arbre propre et
`continuity-check.sh` conservés comme preuve.

## H3 — Tests de reprise croisée, côté Codex

### Objectif

Prouver la moitié symétrique : Codex reprend un état produit par Claude Code,
initialise un état que Claude Code reprend, et répare les mêmes dégradations.

### Dépendances

H2. Quota Codex disponible — épuisé le 2026-09-07, réinitialisation annoncée au
2026-09-12 09:20.

### Tâches

- [ ] H3.1 Codex reprend la fixture `t1-claude-init` et obtient `pass=6 fail=0`.
- [ ] H3.2 Codex initialise un projet neuf ; un processus Claude Code le reprend à
      froid depuis `progress.md` seul.
- [ ] H3.3 Codex répare la fixture dégradée `t5-degrade`.
- [ ] H3.4 Comparer les deux réparations : mêmes intitulés de sections, même
      structure d'unités, même granularité de commit.

### Validation

Mêmes preuves qu'en H2, plus une comparaison des états produits par les deux
harnesses sur la même fixture de départ.

---

# Phase I — Optimisation Pareto de la stack

Passe d'optimisation menée après la parité. Chaque unité est indépendante et
réversible : état avant, hypothèse, changement minimal, validation, résultat
mesuré, décision KEEP ou REVERT. Aucune métrique n'est affirmée sans mesure
réelle exposée par le client. L'architecture Claude/Codex pairs n'est pas remise
en cause. Antigravity n'est pas réintroduit.

## I1 — Vérité du modèle Claude

### Objectif

Supprimer toute affirmation contradictoire sur le modèle et l'effort Claude entre
la configuration live, le miroir, `README.md`, `progress.md` et `parity.sh`.

### Dépendances

Aucune.

### Tâches

- [x] I1.1 Établir l'état live effectif : couches de settings applicables,
      variables d'environnement, modèle réellement servi à la session.
- [x] I1.2 Corriger le côté réellement faux, sans arbitrage arbitraire.
- [x] I1.3 Représenter explicitement, si elle existe, la distinction entre modèle
      par défaut persisté et modèle choisi en session.

### Validation

Live, miroir, `README.md`, `progress.md` et `parity.sh` affirment la même chose ;
`bash agents/parity.sh` reste `PARITÉ OK` ; aucune valeur non observée.

## I2 — `parity.sh` détecte un miroir périmé

### Objectif

Le contrôle doit échouer quand le miroir Git représente autre chose que le live
sur les invariants critiques, dans les deux sens.

### Dépendances

I1.

### Tâches

- [x] I2.1 Ajouter des contrôles sémantiques ciblés — modèle et effort Claude,
      modèle et effort Codex, états critiques de plugins/MCP, identité du bloc
      canonique — sans comparaison brute des fichiers.
- [x] I2.2 Test négatif : une divergence artificielle du miroir fait échouer le
      contrôle, dans les deux sens.

### Validation

Sortie lisible, code de retour non nul en cas de divergence, test négatif probant,
aucun moteur d'export ni manifeste introduit.

## I3 — `continuity-check.sh` couvre le contrat de `progress.md`

### Objectif

Le contrôle structurel vérifie réellement le contrat, pas seulement une partie.

### Dépendances

Aucune.

### Tâches

- [x] I3.1 Exiger `## Tâche actuelle`.
- [x] I3.2 Exiger une preuve non vide sous `## Dernière tâche validée`.
- [x] I3.3 Conserver l'unicité de `## NEXT ACTION`.
- [x] I3.4 Fixtures : `Tâche actuelle` absente, preuve absente, deux
      `NEXT ACTION`, et un snapshot conforme.

### Validation

Les trois fixtures dégradées échouent, la fixture conforme passe, le script reste
un contrôle ciblé et non un analyseur Markdown généraliste.

## I4 — Baseline de la configuration Codex effective

### Objectif

Mesurer avant d'optimiser : ce que charge réellement une session Codex, prouvé et
non supposé.

### Dépendances

Aucune.

### Tâches

- [x] I4.1 Déterminer comment la version installée charge et fusionne les profils.
- [x] I4.2 Relever plugins actifs, MCP visibles, skills visibles, outils exposés.
- [x] I4.3 Vérifier si `codex exec` emprunte réellement le profil lean.
- [x] I4.4 Expliquer l'avertissement « Skill descriptions were shortened to fit
      the skills context budget ».
- [x] I4.5 Consigner une baseline compacte, sans estimation fabriquée.

### Validation

Chaque élément de la baseline provient d'une sortie réelle du client installé ;
les valeurs non mesurables sont déclarées non mesurées.

## I5 — Codex lean par défaut pour le coding

### Objectif

Une session de coding ne charge que ce qui sert à presque toutes les tâches ; les
capacités lourdes restent disponibles à la demande.

### Dépendances

I4.

### Tâches

- [x] I5.1 Confirmer l'état effectif des surfaces candidates avant toute coupe.
- [x] I5.2 Retirer du chemin CLI les surfaces inutiles au coding principal.
- [x] I5.3 Préserver Codex Desktop et toute capacité réellement utilisée.
- [x] I5.4 Préférer une base lean plus des profils spécialisés si cela ne casse
      pas Desktop.

### Validation

Session de coding fonctionnelle, agents fonctionnels, `project-continuity`
détectable, aucune perte de fonction, avertissement de budget de skills disparu
si techniquement possible.

## I6 — KiCad hors du principal Codex

### Objectif

Le principal délègue toute opération KiCad à `kicad-control`. Claude porte le MCP uniquement dans ce sous-agent. Codex 0.159.x interdit à un rôle d'ajouter un MCP absent du parent : le contournement minimal expose donc Konnect uniquement dans le profil spécialisé `cli-kicad`, avec interdiction au principal de l'appeler directement ; le child l'hérite.

### Dépendances

I4.

### Tâches

- [x] I6.1 Établir si l'exposition globale du MCP KiCad est encore imposée par la
      limitation d'héritage MCP des sous-agents.
- [x] I6.2 Retirer l'exposition globale, ou la restreindre strictement aux
      profils KiCad avec la raison exacte et le signal de levée du contournement.
- [x] I6.3 Sous quota Codex, prouver fonctionnellement qu'une tâche KiCad
      aboutit encore via l'agent `kicad-control`, profil `cli-kicad`.

### Validation

Session de coding sans MCP KiCad visible, tâche KiCad fonctionnelle via
`kicad-control`, aucune perte de capacité, coût de découverte mesuré avant et
après si le client l'expose.

Validation 2026-10-01 : base et `cli-lean` sans MCP KiCad ; `cli-kicad` expose un unique `konnect` via le bootstrap de release ; délégation réelle `cli-kicad → kicad-control → kicad_describe` = `OK`. Le code source Codex 0.159.3 confirme que les `mcp_servers` d'un rôle ne peuvent pas étendre l'autorité du parent ; supprimer le contournement seulement lorsque ce comportement upstream change et que le même smoke test passe sans MCP parent.

## I7 — Mesure intermédiaire

### Objectif

Comparer la baseline I4 après les unités I1 à I6, et décider si une optimisation
plus agressive reste justifiée.

### Dépendances

I5, I6.

### Tâches

- [x] I7.1 Rejouer exactement la baseline I4.
- [x] I7.2 Comparer et consigner les écarts réellement mesurés.
- [ ] I7.3 Vérifier coding, continuité, délégation simple et KiCad via agent.

### Validation

Aucun gain chiffré affirmé sans mesure ; si la pression de contexte a disparu,
les unités suivantes sont réévaluées plutôt que menées par principe.

## I8 — Arbitrage `caveman`

### Objectif

Déterminer si `caveman` apporte encore une fonction distincte de la concision déjà
imposée par le contrat canonique.

### Dépendances

I7.

### Tâches

- [x] I8.1 Comparer sa fonction au contrat canonique et mesurer son coût de
      découverte.
- [x] I8.2 Retirer sa découverte active si la valeur nette est nulle, sans laisser
      de plugin actif.

### Validation

Aucun plugin Caveman actif, décision fondée sur une mesure et non sur
l'affirmation de gain du skill lui-même.

## I9 — Catalogue de skills des sous-agents fermés

### Objectif

Tester si un sous-agent interdit de délégation, de Web, de MCP ou de skills peut
démarrer avec un catalogue réduit.

### Dépendances

I7.

### Tâches

- [x] I9.1 Mesurer le contexte initial de `code-worker`, `second-brain` et
      `web-research`.
- [x] I9.2 Vérifier si le harness injecte ces descriptions de façon nécessaire au
      respect du contrat.
- [x] I9.3 Adopter la réduction seulement si le gain est net et le comportement
      identique.

### Validation

Réussite, respect des interdictions et différence de tokens mesurés ; aucune
suppression si l'injection est nécessaire.

## I10 — Benchmark High contre Medium

### Objectif

Décider du niveau d'effort par défaut sur des données réelles, séparément pour
Claude et pour Codex. Le défaut reste `high` tant que la preuve manque.

### Dépendances

I7.

### Tâches

- [x] I10.1 Construire un corpus reproductible : modification ciblée, bug
      multi-fichiers, feature moyenne, exploration, review, reprise de continuité.
- [ ] I10.2 Exécuter à dépôt, commit, prompt et validations identiques.
- [ ] I10.3 Relever uniquement les données réellement exposées : tokens, durée,
      appels d'outils, tours, PASS/FAIL, corrections, tests, qualité du snapshot.
- [ ] I10.4 Décider ; `medium` ne devient le défaut qu'en cas d'économie
      significative sans baisse mesurable.

### Validation

Décision appuyée sur l'ensemble du corpus, jamais sur un seul test ; conservation
de `high` si la preuve est insuffisante.

## I11 — Compaction éventuelle de `project-continuity`

### Objectif

N'envisager une version plus compacte du skill que si un gain significatif reste
disponible après I7 et I10.

### Dépendances

I7, I10.

### Tâches

- [x] I11.1 Mesurer fréquence d'activation, coût réel au chargement et redondance
      exacte avec le bloc permanent.
- [x] I11.2 Ne produire une version candidate que si le gain le justifie.
- [x] I11.3 Conserver la version actuelle si le gain est faible ou la fiabilité
      baisse.

### Validation

Toute version candidate réussit exactement les mêmes tests de continuité et de
handoff que la version actuelle, fixtures H2 et H3 comprises.

## I12 — Retrait complet de Caveman

### Objectif

Supprimer de la stack la surface de configuration active et persistée de
Caveman, dont I8 a établi que la valeur nette était nulle. Un plugin désactivé
redevient actif d'un mot : seule l'absence protège durablement.

### Dépendances

I8.

### Tâches

- [x] I12.1 Vérifier qu'aucun composant actif n'en dépend.
- [x] I12.2 Désinstaller plugin et marketplace par les commandes du client,
      puis retirer les tables résiduelles des deux côtés.
- [x] I12.3 Supprimer le skill du socle, purger `.skill-lock.json`, retirer les
      caches et marketplaces installés.
- [x] I12.4 Remplacer dans `parity.sh` le contrôle « inactif » par un contrôle
      d'absence, avec test négatif.
- [x] I12.5 Resynchroniser le miroir et revalider l'ensemble.

### Validation

Aucun `caveman` actif ni découvrable dans la configuration live comme dans le
miroir ; `parity.sh` échoue si la moindre surface réapparaît ; `project-continuity`
et le défaut `high` sont inchangés.

## J1 — Reroutage après `BLOCKED`, cas `GUI_REQUIRED`

### Objectif

Fermer un trou de protocole : un `BLOCKED` rendu par une capacité spécialisée
arrêtait la boucle et renvoyait le geste à l'utilisateur alors qu'une autre
capacité disponible pouvait le lever. Cas observé : `kicad-control` constate que
« Mettre à jour le PCB depuis le schéma » n'est exposé ni par le MCP, ni par
l'API/IPC, ni par un fichier, mais reste faisable dans l'interface KiCad.

Le chemin correct est `capacité métier → principal → desktop-control → principal
→ capacité métier`. Aucune redélégation directe entre sous-agents n'est
introduite, et la GUI ne passe jamais devant un moyen CLI/API/MCP/fichier adapté.

### Dépendances

Phase I close. Le contrat commun a déjà sa source canonique unique.

### Tâches

- [x] J1.1 Ajouter au bloc canonique la règle générique de reroutage après
      `BLOCKED`, le statut nommé `BLOCKED: GUI_REQUIRED: <action + état attendu>`,
      la distinction ownership métier / mécanisme d'interaction, et la bornage du
      reroutage jusqu'au blocage réel.
- [x] J1.2 `kicad-control` : ownership « exclusif » remplacé par « métier »,
      obligation de vérifier l'absence de moyen non-GUI, retour
      `BLOCKED: GUI_REQUIRED:` au principal, ni demande à l'utilisateur ni appel
      d'une autre capacité, validation du nouvel état sur rappel. Claude et Codex.
- [x] J1.3 `desktop-control` : exécution d'un geste servant une opération
      appartenant à une autre capacité, sans en prendre la propriété, sans
      décider de sa stratégie, sans redéléguer ; `BLOCKED` si un moyen non-GUI
      déjà identifié suffit ou si l'instruction est trop imprécise. Claude et Codex.
- [x] J1.4 `parity.sh` : contrôles de la règle canonique des deux côtés, section
      « Reroutage GUI » sur les deux capacités appariées, et identité miroir des
      quatre définitions d'agents. Tests négatifs.
- [x] J1.5 Resynchroniser le miroir, mesurer le prompt effectif des deux
      harnesses, revalider l'ensemble.

### Validation

`parity.sh` vert, et rouge dès qu'une des surfaces du reroutage disparaît d'un
seul côté — cinq tests négatifs. Le prompt effectif porte la règle des deux
côtés : bloc canonique et catalogue de capacités pour Claude, mesure
`codex -p cli-kicad debug prompt-input` pour Codex. `Aucune redélégation` est
conservé mot pour mot, et aucune formulation d'exclusivité ne subsiste dans
`kicad-control`.
