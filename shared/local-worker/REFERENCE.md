# local-worker — référence

**Dépôt :** https://github.com/nevenfo/local-worker (privé)
**Commit épinglé :** `6eac864e4005892c4a9400633a974d68fd00df94` (2026-09-07)
**Dossier live :** `C:\Users\FlowUP\Documents\Etabli\Tools\local-worker`
**Rôle dans la stack :** CLI locale auxiliaire, strictement read-only, qui
**compresse une sortie déjà produite** (log, diff, résultats de recherche) via un
modèle LM Studio. À ne pas confondre avec NOA Local Agents, qui explore ; les deux
ne partagent aucun code.

`local-worker` était copié dans `snapshot/shared/` d'ai-stack ; il a son propre
dépôt depuis le 2026-09-07.

## Câblé dans la stack via

| Point de câblage | Déclaration |
|---|---|
| `agents/skills/local-worker/` → skill partagé par les deux harnesses | s'active uniquement sur demande explicite de l'utilisateur |
| invocation | `C:\Users\FlowUP\Documents\Etabli\Tools\local-worker\local-worker.cmd <mode>` |
| backend | LM Studio (préparé à la demande par le wrapper `--prepare-backend`) |

Le tableau des modes (`AUTO`/`MANUEL`/`DÉSACTIVÉ`) fait autorité dans le
`README.md` du dépôt local-worker, à relire avant chaque invocation.

## Fichiers conservés ici (copie miroir de l'intégration)

- `local-worker.cmd` — wrapper d'invocation (illustratif ; il a besoin de
  `local_worker.py`, présent dans le dépôt local-worker, pour s'exécuter)
- `HARNESS_INTEGRATION.md` — contrat de routage commun aux trois harnesses

Source de vérité : le dépôt local-worker au commit épinglé.
