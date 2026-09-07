# Second Brain — règles de maintenance

## Rôle

Ce dépôt est un wiki persistant compilé à partir des sources placées dans `raw/`.
L'agent est le seul auteur des pages de `wiki/`, de `index.md` et de `log.md`.
L'utilisateur fournit les sources, consulte le wiki et valide les corrections qui
nécessitent un jugement éditorial.

## Périmètre et structure

- `raw/inbox/` : sources reçues et non modifiables.
- `raw/.ingested.log` : registre technique géré uniquement par l'automatisation.
- `wiki/concepts/` : une page par notion distincte.
- `wiki/entities/` : une page par personne, organisation, produit ou autre entité.
- `wiki/sources/` : une page décrivant chaque source ingérée et sa provenance.
- `wiki/synthesis/` : analyses transversales reliant plusieurs pages.
- `index.md` : catalogue complet, une ligne par page wiki avec lien et résumé.
- `log.md` : journal chronologique des opérations.

Ne jamais modifier, déplacer, renommer ou supprimer un fichier source sous
`raw/inbox/`. La seule exception d'écriture dans `raw/` est le registre technique
`raw/.ingested.log`, géré par `weekly-ingest.sh` après un ingest réussi.

## Conventions

- Noms de fichiers : minuscules, mots séparés par des tirets, sans accent, espace
  ni caractère spécial. Conserver l'extension `.md`.
- Une page par concept ou entité distincte. Toujours lire `index.md` avant de
  créer une page afin d'éviter synonymes concurrents et doublons.
- Utiliser des liens Obsidian `[[chemin/sans-extension|libellé]]` quand le
  libellé diffère du titre, sinon `[[chemin/sans-extension]]`.
- Distinguer clairement faits sourcés, interprétations et incertitudes.
- Signaler les contradictions ; ne jamais les résoudre silencieusement.
- Employer des dates ISO `YYYY-MM-DD` selon le fuseau `Europe/Paris`.

Chaque fichier sous `wiki/` commence obligatoirement par :

```yaml
---
tags:
  - exemple
created: YYYY-MM-DD
updated: YYYY-MM-DD
sources:
  - raw/inbox/nom-de-la-source.ext
---
```

`tags` et `sources` sont toujours des listes YAML. `created` reste inchangé lors
d'une mise à jour ; `updated` prend la date de la modification. Chaque affirmation
substantielle doit être traçable vers au moins une entrée de `sources` ou être
explicitement qualifiée d'analyse.

## Procédure Ingest

Traiter exactement un fichier source par exécution.

1. Lire le fichier demandé sous `raw/inbox/` sans le modifier.
2. Lire `index.md` avant toute autre page du wiki.
3. Repérer les pages existantes pertinentes, puis lire uniquement celles-ci.
4. Extraire les faits, concepts, entités, relations, dates, incertitudes et
   contradictions utiles.
5. Créer ou mettre à jour les pages concernées, typiquement 3 à 15 pages. Ne pas
   créer artificiellement des pages pour atteindre ce nombre.
6. Ajouter les liens `[[...]]` pertinents et maintenir le frontmatter de chaque
   page touchée, notamment `updated` et `sources`.
7. Créer ou mettre à jour une page dans `wiki/sources/` décrivant la source, sa
   nature, son périmètre, sa fiabilité apparente et les pages alimentées.
8. Mettre à jour `index.md` : exactement une ligne par page wiki, sous la bonne
   section, au format `- [[chemin/sans-extension|Titre]] — Résumé en une ligne.`
9. Ajouter en tête de `log.md`, après son introduction, une entrée :
   `## [YYYY-MM-DD] ingest | Titre`, suivie de la source et des pages modifiées.
10. Exécuter les contrôles de la procédure Save. Un ingest n'est réussi que si
    tous ces contrôles passent.

Ne jamais grouper plusieurs sources dans un même ingest. Une source déjà inscrite
dans `raw/.ingested.log` n'est pas réingérée automatiquement.

## Procédure Query

1. Lire `index.md` en premier ; ne jamais charger tout le wiki d'un coup.
2. Identifier puis lire uniquement les pages utiles à la question.
3. Répondre à partir du wiki en citant les pages avec des liens `[[...]]`.
4. Indiquer clairement les lacunes, contradictions ou informations possiblement
   obsolètes rencontrées.
5. Si la réponse constitue une connaissance transversale durable, proposer à
   l'utilisateur de la classer dans `wiki/synthesis/`. Ne pas l'enregistrer sans
   son accord.

## Procédure Lint

Le lint est strictement en lecture seule.

1. Comparer `index.md` aux fichiers présents sous `wiki/`.
2. Chercher les liens internes cassés et les pages orphelines.
3. Vérifier noms de fichiers, frontmatter obligatoire, dates et chemins sources.
4. Relever les contradictions entre pages et les affirmations potentiellement
   obsolètes.
5. Produire uniquement un rapport avec emplacement, gravité et proposition.

Ne corriger, renommer ou supprimer quoi que ce soit pendant un lint sans
confirmation explicite de l'utilisateur.

## Procédure Save

Avant de considérer une modification terminée :

1. Vérifier que les sources brutes sont intactes.
2. Vérifier le frontmatter de toutes les pages wiki créées ou modifiées.
3. Vérifier que chaque page créée figure exactement une fois dans `index.md` et
   qu'aucune ligne d'index ne vise une page absente.
4. Vérifier les liens `[[...]]` ajoutés et l'absence de doublon évident.
5. Vérifier que `log.md` décrit fidèlement l'opération.
6. Résumer les fichiers créés ou modifiés et signaler les incertitudes restantes.