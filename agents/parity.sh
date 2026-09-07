#!/usr/bin/env bash
# parity.sh — contrôle de parité Claude Code / Codex.
#
#   parity.sh          vérifie ; code de retour non nul si un côté a divergé
#   parity.sh --fix    réinjecte le bloc canonique dans les deux harnesses
#
# Claude Code et Codex sont deux implémentations du même harness logique. Ce
# contrôle existe pour qu'ils ne puissent pas dériver l'un de l'autre en silence.
# Il reste volontairement petit : il compare, il ne génère pas.

set -uo pipefail

HOME_DIR="${USERPROFILE:-$HOME}"
HOME_DIR="${HOME_DIR//\\//}"
AGENTS_DIR="$HOME_DIR/.agents"
CONTRACT="$AGENTS_DIR/CONTRACT.md"
CLAUDE_MD="$HOME_DIR/.claude/CLAUDE.md"
CODEX_MD="$HOME_DIR/.codex/AGENTS.md"
CLAUDE_SETTINGS="$HOME_DIR/.claude/settings.json"
CODEX_CONFIG="$HOME_DIR/.codex/config.toml"

# Intention opérationnelle commune : le modèle le plus capable de chaque
# fournisseur, à un niveau de raisonnement élevé. Les identifiants diffèrent
# parce que les fournisseurs diffèrent ; l'intention, non.
CLAUDE_MODEL="opus"
CLAUDE_EFFORT="high"
CODEX_MODEL="gpt-6-astra"
CODEX_EFFORT="high"

# Skills partagés : une seule copie physique, sous ~/.agents/skills.
SHARED_SKILLS="project-continuity local-worker noa-local-agents"

FIX=0
[ "${1:-}" = "--fix" ] && FIX=1

fail=0
ok()   { printf '  ok    %s\n' "$1"; }
bad()  { printf '  FAIL  %s\n' "$1"; fail=1; }

extract() { # extract <file> -> contenu strictement entre les marqueurs
  awk '/^<!-- BEGIN CANON -->$/{f=1;next} /^<!-- END CANON -->$/{f=0} f' "$1"
}

inject() { # inject <file> <bloc>
  local target="$1" block="$2" tmp
  tmp="$(mktemp)"
  awk -v blockfile="$block" '
    /^<!-- BEGIN CANON -->$/ { print; while ((getline line < blockfile) > 0) print line; skip=1; next }
    /^<!-- END CANON -->$/   { skip=0 }
    !skip { print }
  ' "$target" > "$tmp" && mv "$tmp" "$target"
}

for f in "$CONTRACT" "$CLAUDE_MD" "$CODEX_MD"; do
  [ -f "$f" ] || { printf 'introuvable : %s\n' "$f" >&2; exit 2; }
done

CANON="$(mktemp)"; trap 'rm -f "$CANON"' EXIT
extract "$CONTRACT" > "$CANON"
[ -s "$CANON" ] || { printf 'bloc canonique vide dans %s\n' "$CONTRACT" >&2; exit 2; }

if [ "$FIX" = 1 ]; then
  inject "$CLAUDE_MD" "$CANON"
  inject "$CODEX_MD"  "$CANON"
  printf 'bloc canonique réinjecté dans les deux harnesses.\n\n'
fi

printf 'Bloc canonique\n'
diff -q <(extract "$CLAUDE_MD") "$CANON" >/dev/null 2>&1 \
  && ok "Claude identique à CONTRACT.md" || bad "Claude a divergé de CONTRACT.md"
diff -q <(extract "$CODEX_MD") "$CANON" >/dev/null 2>&1 \
  && ok "Codex identique à CONTRACT.md"  || bad "Codex a divergé de CONTRACT.md"

printf 'Invariants\n'
check_both() { # check_both <libellé> <motif>
  local label="$1" pat="$2" c=0 x=0
  grep -qF -- "$pat" "$CLAUDE_MD" && c=1
  grep -qF -- "$pat" "$CODEX_MD"  && x=1
  if [ "$c" = 1 ] && [ "$x" = 1 ]; then ok "$label — Claude et Codex"
  elif [ "$c" = 1 ]; then bad "$label — présent côté Claude, absent côté Codex"
  elif [ "$x" = 1 ]; then bad "$label — présent côté Codex, absent côté Claude"
  else bad "$label — absent des deux côtés"; fi
}
check_both "continuity invariant" "# Continuité projet"
check_both "preflight"            "vérifier l'existence **et la conformité**"
check_both "audit / repair"       "il est faux et se répare"
check_both "NEXT ACTION unique"   "exactement une \`NEXT ACTION\`"
check_both "CONTINUE par défaut"  "\`CONTINUE\` est la valeur par défaut"
check_both "GitHub-first"         "a un remote GitHub, privé par défaut"
check_both "checkpoint durable"   "n'est pas un checkpoint"
check_both "validation"           "sa validation est réellement passée"
check_both "sous-agents"          "0–1 sous-agent par défaut"
check_both "skills lazy"          "chargé à la demande"
check_both "Second Brain"         "jamais le wiki entier"
check_both "handoff"              "sans adaptation ni transcript"
check_both "frontière de session" "# Frontière de session"
check_both "pas de métrique inventée" "jamais une estimation"

printf 'Skills partagés\n'
for s in $SHARED_SKILLS; do
  src="$AGENTS_DIR/skills/$s"
  dst="$HOME_DIR/.claude/skills/$s"
  if [ ! -d "$src" ]; then bad "$s — absent de ~/.agents/skills"
  elif [ ! -e "$dst" ]; then bad "$s — absent de ~/.claude/skills"
  elif [ "$(cd "$src" && pwd -P)" = "$(cd "$dst" && pwd -P)" ]; then ok "$s — partagé"
  else bad "$s — copié, non partagé (dérive possible)"; fi
done

printf 'Modèle et effort\n'
grep -q "\"model\": *\"$CLAUDE_MODEL\"" "$CLAUDE_SETTINGS" \
  && ok "Claude : $CLAUDE_MODEL" || bad "Claude : $CLAUDE_MODEL attendu"
grep -q "\"effortLevel\": *\"$CLAUDE_EFFORT\"" "$CLAUDE_SETTINGS" \
  && ok "Claude : effort $CLAUDE_EFFORT" || bad "Claude : effort $CLAUDE_EFFORT attendu"
grep -q "^model *= *\"$CODEX_MODEL\"" "$CODEX_CONFIG" \
  && ok "Codex : $CODEX_MODEL" || bad "Codex : $CODEX_MODEL attendu"
grep -q "^model_reasoning_effort *= *\"$CODEX_EFFORT\"" "$CODEX_CONFIG" \
  && ok "Codex : effort $CODEX_EFFORT" || bad "Codex : effort $CODEX_EFFORT attendu"

printf 'Antigravity\n'
agy="$(grep -ril -e antigravity -e gemini \
        "$CLAUDE_MD" "$CODEX_MD" "$CONTRACT" "$CLAUDE_SETTINGS" "$CODEX_CONFIG" \
        "$AGENTS_DIR/skills" "$HOME_DIR/.claude/agents" "$HOME_DIR/.codex/agents" \
        2>/dev/null | grep -v -e '\.bak' -e '\.disabled' || true)"
[ -z "$agy" ] && ok "aucun câblage actif" || bad "encore câblé : $(echo "$agy" | tr '\n' ' ')"

printf '\n'
if [ "$fail" = 0 ]; then printf 'PARITÉ OK\n'; else printf 'PARITÉ ROMPUE\n'; fi
exit "$fail"
