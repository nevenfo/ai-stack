#!/usr/bin/env bash
# continuity-fixtures.sh — test négatif de continuity-check.sh.
#
#   continuity-fixtures.sh
#
# Construit quatre snapshots dans un dossier temporaire — trois dégradés, un
# conforme — et vérifie que le contrôle échoue exactement sur les premiers.
# Un contrôle qui ne sait pas échouer ne prouve rien ; ce script est la preuve
# qu'il sait. Il ne laisse aucun état derrière lui.

set -uo pipefail

HOME_DIR="${USERPROFILE:-$HOME}"
HOME_DIR="${HOME_DIR//\\//}"
CHECK="${CONTINUITY_CHECK:-$HOME_DIR/.agents/continuity-check.sh}"
[ -f "$CHECK" ] || { printf 'introuvable : %s\n' "$CHECK" >&2; exit 2; }

ROOT="$(mktemp -d)"
trap 'rm -rf "$ROOT"' EXIT

PLAN='# PLAN — Fixture

## Objectif final

Éprouver le contrôle structurel de continuité.

## Invariants

- Le contrôle est déterministe.

## A1 — Unité de test

### Objectif

Fournir une unité complète.

### Dépendances

Aucune.

### Tâches

- [x] A1.1 Écrire la fixture.

### Validation

Le contrôle se prononce.
'

HEAD_OK='# PROGRESS — Fixture

## Phase actuelle

Phase A.

## Tâche actuelle

A1 — unité de test.

'

HEAD_SANS_TACHE='# PROGRESS — Fixture

## Phase actuelle

Phase A.

'

VALID_OK='## Dernière tâche validée

A1.1 — la fixture existe.

Validation :

- Le fichier est présent et lisible.

'

VALID_SANS_PREUVE='## Dernière tâche validée

A1.1 — la fixture existe.

'

TAIL_OK='## Décisions actives

- Le contrôle reste borné à la forme.

## Blocage actif

Aucun.

## Fichiers / zones utiles

- `plan.md`, `progress.md`.

## NEXT ACTION

A1.2 — poursuivre la fixture puis relancer le contrôle.
'

mk() { # mk <nom> <corps de progress.md>
  mkdir -p "$ROOT/$1"
  printf '%s' "$PLAN" > "$ROOT/$1/plan.md"
  printf '%s' "$2"    > "$ROOT/$1/progress.md"
}

mk sans-tache-actuelle "$HEAD_SANS_TACHE$VALID_OK$TAIL_OK"
mk sans-preuve         "$HEAD_OK$VALID_SANS_PREUVE$TAIL_OK"
mk deux-next           "$HEAD_OK$VALID_OK$TAIL_OK
## NEXT ACTION

A1.3 — action concurrente.
"
mk conforme            "$HEAD_OK$VALID_OK$TAIL_OK"

pass=0; fail=0
expect() { # expect <fixture> <code attendu> <motif de la cause attendue>
  local out got
  out="$(bash "$CHECK" "$ROOT/$1" 2>&1)"; got=$?
  if [ "$got" != "$2" ]; then
    printf '  FAIL  %-20s exit=%s attendu=%s\n' "$1" "$got" "$2"; fail=$((fail + 1)); return
  fi
  # Un échec doit venir de sa cause, pas d'un effet de bord de la fixture.
  if [ "$2" != 0 ]; then
    local causes
    causes="$(printf '%s\n' "$out" | grep -c 'FAIL')"
    if [ "$causes" != 1 ] || ! printf '%s\n' "$out" | grep -q "$3"; then
      printf '  FAIL  %-20s cause inattendue (%s FAIL)\n' "$1" "$causes"
      printf '%s\n' "$out" | grep 'FAIL' | sed 's/^/          /'
      fail=$((fail + 1)); return
    fi
  fi
  printf '  ok    %-20s exit=%s\n' "$1" "$got"; pass=$((pass + 1))
}

printf 'Fixtures de continuité\n'
expect sans-tache-actuelle 1 'section manquante : « Tâche actuelle »'
expect sans-preuve         1 'sans « Validation : »'
expect deux-next           1 '2 sections NEXT ACTION'
expect conforme            0 ''

printf '\npass=%s fail=%s\n' "$pass" "$fail"
exit "$fail"
