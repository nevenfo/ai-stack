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

# Miroir Git de la stack. Il n'est pas comparé brut au live : certaines tables
# (chemins de projets, empreintes machine) y sont volontairement normalisées.
# Seules les valeurs sémantiques critiques et les fichiers du socle sont vérifiés.
MIRROR="${PARITY_MIRROR:-$HOME_DIR/ai-stack}"

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


printf 'Miroir Git\n'
mirror_file() { # mirror_file <libellé> <chemin relatif> <fichier live>
  local label="$1" rel="$2" live="$3"
  if [ ! -f "$MIRROR/$rel" ]; then bad "miroir : $rel absent"
  elif diff -q "$live" "$MIRROR/$rel" >/dev/null 2>&1; then ok "miroir : $label"
  else bad "miroir : $label — périmé par rapport au live"; fi
}
mirror_value() { # mirror_value <libellé> <chemin relatif> <motif ERE attendu>
  local label="$1" rel="$2" pat="$3"
  if [ ! -f "$MIRROR/$rel" ]; then bad "miroir : $rel absent"
  elif grep -qE -- "$pat" "$MIRROR/$rel"; then ok "miroir : $label"
  else bad "miroir : $label — le miroir représente autre chose"; fi
}

if [ ! -d "$MIRROR/.git" ]; then
  bad "miroir introuvable : $MIRROR (définir PARITY_MIRROR)"
else
  # Fichiers du socle : aucune normalisation, l'identité stricte est exigible.
  mirror_file "CONTRACT.md"         "agents/CONTRACT.md"          "$CONTRACT"
  mirror_file "parity.sh"           "agents/parity.sh"            "$AGENTS_DIR/parity.sh"
  mirror_file "continuity-check.sh" "agents/continuity-check.sh"  "$AGENTS_DIR/continuity-check.sh"
  mirror_file "continuity-fixtures.sh" "agents/continuity-fixtures.sh" "$AGENTS_DIR/continuity-fixtures.sh"
  mirror_file "effort-bench/PROTOCOL.md" "agents/effort-bench/PROTOCOL.md" "$AGENTS_DIR/effort-bench/PROTOCOL.md"
  mirror_file "effort-bench/build-fixtures.sh" "agents/effort-bench/build-fixtures.sh" "$AGENTS_DIR/effort-bench/build-fixtures.sh"

  # Valeurs sémantiques critiques. Les constantes ci-dessus sont l'attendu
  # commun : le live est contrôlé plus haut, le miroir l'est ici, si bien qu'une
  # dérive de l'un ou de l'autre échoue.
  mirror_value "Claude : $CLAUDE_MODEL"      "claude/settings.json" "\"model\": *\"$CLAUDE_MODEL\""
  mirror_value "Claude : effort $CLAUDE_EFFORT" "claude/settings.json" "\"effortLevel\": *\"$CLAUDE_EFFORT\""
  mirror_value "Codex : $CODEX_MODEL"        "codex/config.toml"    "^model *= *\"$CODEX_MODEL\""
  mirror_value "Codex : effort $CODEX_EFFORT" "codex/config.toml"   "^model_reasoning_effort *= *\"$CODEX_EFFORT\""
fi

printf 'Composants retirés\n'
agy="$(grep -ril -e antigravity -e gemini \
        "$CLAUDE_MD" "$CODEX_MD" "$CONTRACT" "$CLAUDE_SETTINGS" "$CODEX_CONFIG" \
        "$AGENTS_DIR/skills" "$HOME_DIR/.claude/agents" "$HOME_DIR/.codex/agents" \
        2>/dev/null | grep -v -e '\.bak' -e '\.disabled' || true)"
[ -z "$agy" ] && ok "Antigravity — aucun câblage actif" \
  || bad "Antigravity encore câblé : $(echo "$agy" | tr '\n' ' ')"

# Caveman a été retiré de la stack le 2026-09-07 : ni configuration, ni skill
# découvrable, ni marketplace déclaré. Le contrôle porte donc sur son absence,
# et non sur un état inactif — un plugin désactivé redevient actif d'un mot.
cav="$(grep -ril caveman \
        "$CLAUDE_MD" "$CODEX_MD" "$CONTRACT" "$CLAUDE_SETTINGS" \
        "$AGENTS_DIR/skills" "$HOME_DIR/.claude/agents" "$HOME_DIR/.codex/agents" \
        "$HOME_DIR/.claude/plugins/installed_plugins.json" \
        "$HOME_DIR/.claude/plugins/known_marketplaces.json" \
        2>/dev/null | grep -v -e '\.bak' -e '\.disabled' || true)"
# Dans la configuration Codex, un chemin de projet peut porter ce nom sans que
# rien ne soit câblé : d'anciens dossiers de mesure s'appellent encore ainsi.
# Seules les tables comptent.
grep -i caveman "$CODEX_CONFIG" 2>/dev/null | grep -qv '^\[projects\.' \
  && cav="$cav $CODEX_CONFIG"
[ -e "$AGENTS_DIR/skills/caveman" ] && cav="$cav $AGENTS_DIR/skills/caveman"
[ -z "$(echo "$cav" | tr -d "[:space:]")" ] && ok "Caveman — retiré de la stack" \
  || bad "Caveman subsiste : $(echo "$cav" | tr '\n' ' ')"

printf '\n'
if [ "$fail" = 0 ]; then printf 'PARITÉ OK\n'; else printf 'PARITÉ ROMPUE\n'; fi
exit "$fail"
