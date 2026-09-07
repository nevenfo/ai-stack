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
