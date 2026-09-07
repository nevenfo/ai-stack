#!/usr/bin/env bash
# continuity-check.sh — contrôle structurel de plan.md / progress.md.
#
#   continuity-check.sh [dossier]     défaut : dossier courant
#
# Ce contrôle est déterministe et volontairement borné. Il vérifie la FORME :
# présence, sections, unicité de la NEXT ACTION, absence de journal, taille.
# Il ne dit jamais si la NEXT ACTION est la bonne, ni si une case cochée est
# réellement prouvée : cela demande le modèle, Git, les tests et les fichiers.
# Un PASS ici n'est donc pas un preflight — c'en est la première étape.

set -uo pipefail
DIR="${1:-.}"
PLAN="$DIR/plan.md"
PROGRESS="$DIR/progress.md"

fail=0
ok()  { printf '  ok    %s\n' "$1"; }
bad() { printf '  FAIL  %s\n' "$1"; fail=1; }

printf 'progress.md\n'
if [ ! -f "$PROGRESS" ]; then
  bad "absent"
else
  head -1 "$PROGRESS" | grep -q '^# PROGRESS' \
    && ok "en-tête # PROGRESS" || bad "première ligne n'est pas '# PROGRESS'"

  n=$(grep -c '^## NEXT ACTION[[:space:]]*$' "$PROGRESS")
  case "$n" in
    1) ok "exactement une section NEXT ACTION" ;;
    0) bad "aucune section NEXT ACTION" ;;
    *) bad "$n sections NEXT ACTION — il en faut exactement une" ;;
  esac

  if [ "$n" = 1 ]; then
    body=$(sed -n '/^## NEXT ACTION[[:space:]]*$/,$p' "$PROGRESS" | tail -n +2 | grep -c '[^[:space:]]')
    [ "$body" -gt 0 ] && ok "NEXT ACTION non vide" || bad "NEXT ACTION vide"
  fi

  for s in "## Phase actuelle" "## Tâche actuelle" "## Dernière tâche validée" \
           "## Décisions actives" "## Blocage actif" "## Fichiers / zones utiles"; do
    grep -q "^$s" "$PROGRESS" && ok "section « ${s#\#\# } »" || bad "section manquante : « ${s#\#\# } »"
  done

  # Une tâche déclarée validée sans preuve listée n'est pas validée. Le contrôle
  # exige le marqueur littéral « Validation : » puis au moins une puce non vide ;
  # il ne juge pas la valeur de la preuve, seulement son existence.
  if grep -q '^## Dernière tâche validée[[:space:]]*$' "$PROGRESS"; then
    sec=$(sed -n '/^## Dernière tâche validée[[:space:]]*$/,/^## /p' "$PROGRESS" | sed '1d')
    if ! printf '%s\n' "$sec" | grep -qE '^Validation *:'; then
      bad "dernière tâche validée sans « Validation : »"
    else
      proof=$(printf '%s\n' "$sec" | sed -n '/^Validation *:/,$p' | tail -n +2 \
                | grep -cE '^[[:space:]]*[-*] +[^[:space:]]')
      [ "$proof" -gt 0 ] && ok "preuve de la dernière tâche validée ($proof point(s))" \
        || bad "« Validation : » ne liste aucune preuve"
    fi
  fi

  words=$(wc -w < "$PROGRESS")
  if   [ "$words" -gt 900 ]; then bad "snapshot trop long ($words mots) — il dérive vers le journal"
  elif [ "$words" -lt 40 ]; then bad "snapshot trop court ($words mots) pour permettre une reprise"
  else ok "taille du snapshot ($words mots)"; fi

  noise=""
  grep -qE '^\s*(Traceback|File ".*", line [0-9]+)' "$PROGRESS" && noise="$noise stack-trace"
  grep -qE '^\s*(\$|>|PS [A-Z]:)' "$PROGRESS"                   && noise="$noise historique-de-commandes"
  grep -qE '^(\+\+\+|---|@@ )' "$PROGRESS"                      && noise="$noise diff"
  [ "$(grep -cE '^#{2,3} +[0-9]{4}-[0-9]{2}-[0-9]{2}' "$PROGRESS")" -gt 1 ] && noise="$noise entrées-datées"
  [ -z "$noise" ] && ok "aucune trace brute" || bad "traces à retirer :$noise"
fi

printf 'plan.md\n'
if [ ! -f "$PLAN" ]; then
  bad "absent"
else
  for s in "^# PLAN" "^## Objectif" "^## Invariants"; do
    grep -qE "$s" "$PLAN" && ok "en-tête « $(echo "$s" | tr -d '^#' | sed 's/^ *//') »" \
      || bad "en-tête manquant : « $(echo "$s" | tr -d '^#' | sed 's/^ *//') »"
  done

  # Une unité est un titre de niveau 2 portant un ID et un tiret cadratin.
  units=$(grep -nE '^## [A-Z][A-Za-z0-9]* — ' "$PLAN" | cut -d: -f1)
  if [ -z "$units" ]; then
    bad "aucune unité « ## <ID> — <titre> »"
  else
    total=0; broken=0
    ends=$(printf '%s\n' $units | tail -n +2; wc -l < "$PLAN")
    set -- $ends
    for start in $units; do
      end="$1"; shift
      total=$((total + 1))
      name=$(sed -n "${start}p" "$PLAN" | sed 's/^## //')
      miss=""
      for sec in Objectif Dépendances Tâches Validation; do
        sed -n "${start},${end}p" "$PLAN" | grep -q "^### $sec" || miss="$miss $sec"
      done
      [ -n "$miss" ] && { bad "unité « $name » — sections manquantes :$miss"; broken=$((broken + 1)); }
    done
    [ "$broken" = 0 ] && ok "$total unités complètes (Objectif, Dépendances, Tâches, Validation)"
  fi
fi

printf '\n'
if [ "$fail" = 0 ]; then printf 'CONTINUITÉ STRUCTURELLE OK — %s\n' "$DIR"
else printf 'CONTINUITÉ STRUCTURELLE NON CONFORME — %s\n' "$DIR"; fi
exit "$fail"
