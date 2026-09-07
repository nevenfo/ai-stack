#!/usr/bin/env bash
# build-fixtures.sh — corpus reproductible du benchmark d'effort.
#
#   build-fixtures.sh <dossier>
#
# Crée six dépôts Git jetables, chacun figé sur un commit initial. Le dossier
# est reconstruit à l'identique à chaque appel : c'est ce qui permet de comparer
# deux niveaux d'effort sur exactement le même point de départ.
# Voir PROTOCOL.md pour l'exécution et les relevés.

set -uo pipefail

ROOT="${1:-}"
[ -n "$ROOT" ] || { printf 'usage : build-fixtures.sh <dossier>\n' >&2; exit 2; }

rm -rf "$ROOT"
mkdir -p "$ROOT"

git_init() { # git_init <dossier> <message>
  git -C "$1" init -q
  git -C "$1" config core.autocrlf false
  git -C "$1" config user.email "bench@local"
  git -C "$1" config user.name  "effort-bench"
  git -C "$1" add -A
  git -C "$1" commit -q -m "$2"
}

# --- socle commun : une facturation minuscule, sans dépendance externe -------
lib() { # lib <dossier> [<remise appliquée au bon endroit : 1|0>]
  local d="$1" bon="${2:-1}"
  mkdir -p "$d/tarifs"
  cat > "$d/tarifs/taux.py" <<'PY'
"""Taux applicables. Une seule source pour chacun."""

TVA = 0.20
REMISE_SEUIL = 500.0
REMISE_TAUX = 0.10
PY

  cat > "$d/tarifs/remise.py" <<'PY'
"""Remises commerciales."""

from tarifs.taux import REMISE_SEUIL, REMISE_TAUX


def remise(montant_ht):
    """Remise accordée sur un montant hors taxes."""
    if montant_ht >= REMISE_SEUIL:
        return montant_ht * REMISE_TAUX
    return 0.0
PY

  if [ "$bon" = 1 ]; then
    cat > "$d/tarifs/facture.py" <<'PY'
"""Calcul d'une facture."""

from tarifs.remise import remise
from tarifs.taux import TVA


def total_ttc(montant_ht):
    """Total toutes taxes comprises, remise déduite avant la TVA."""
    net = montant_ht - remise(montant_ht)
    return round(net * (1 + TVA), 2)
PY
  else
    cat > "$d/tarifs/facture.py" <<'PY'
"""Calcul d'une facture."""

from tarifs.remise import remise
from tarifs.taux import TVA


def total_ttc(montant_ht):
    """Total toutes taxes comprises, remise déduite avant la TVA."""
    brut = round(montant_ht * (1 + TVA), 2)
    return round(brut - remise(brut), 2)
PY
  fi
  : > "$d/tarifs/__init__.py"
}

runner() { # runner <dossier> <corps python des assertions>
  cat > "$1/test.sh" <<'SH'
#!/usr/bin/env bash
# Décide seul du PASS. Ne pas modifier : une réussite obtenue en le changeant
# est un échec.
cd "$(dirname "$0")" || exit 2
python check.py
SH
  chmod +x "$1/test.sh"
  printf '%s\n' "$2" > "$1/check.py"
}

# --- t1 — modification ciblée ------------------------------------------------
D="$ROOT/t1-modification"; mkdir -p "$D"; lib "$D" 1
runner "$D" 'import sys
from tarifs.facture import total_ttc
from tarifs.taux import TVA

echecs = []
if abs(TVA - 0.21) > 1e-9:
    echecs.append(f"TVA attendue 0.21, trouvée {TVA}")
if abs(total_ttc(100.0) - 121.0) > 0.01:
    echecs.append(f"total_ttc(100) attendu 121.0, trouvé {total_ttc(100.0)}")
# la remise doit rester intacte et rester appliquée avant la TVA
if abs(total_ttc(1000.0) - 1089.0) > 0.01:
    echecs.append(f"total_ttc(1000) attendu 1089.0, trouvé {total_ttc(1000.0)}")
print("pass" if not echecs else "fail")
for e in echecs:
    print(" -", e)
sys.exit(1 if echecs else 0)'
cat > "$D/PROMPT.txt" <<'TXT'
Le taux de TVA passe de 20 % à 21 %. Applique ce changement dans ce dépôt, puis
vérifie par `bash test.sh`. Ne modifie rien d'autre que ce que ce changement
impose.
TXT
git_init "$D" "facturation initiale"

# --- t2 — bug multi-fichiers -------------------------------------------------
D="$ROOT/t2-bug"; mkdir -p "$D"; lib "$D" 0
runner "$D" 'import sys
from tarifs.facture import total_ttc

echecs = []
# La remise est commerciale : elle porte sur le hors taxes, jamais sur le TTC.
# A 450 le seuil de 500 reste hors de portee avant taxes, mais se trouve franchi
# une fois la TVA ajoutee : la ou lordre des operations cesse detre indifferent.
# Sans apostrophe ici : ce bloc est passe au shell entre quotes simples.
if abs(total_ttc(450.0) - 540.0) > 0.01:
    echecs.append(f"total_ttc(450) attendu 540.0, trouvé {total_ttc(450.0)}")
if abs(total_ttc(1000.0) - 1080.0) > 0.01:
    echecs.append(f"total_ttc(1000) attendu 1080.0, trouvé {total_ttc(1000.0)}")
if abs(total_ttc(100.0) - 120.0) > 0.01:
    echecs.append(f"total_ttc(100) attendu 120.0, trouvé {total_ttc(100.0)}")
print("pass" if not echecs else "fail")
for e in echecs:
    print(" -", e)
sys.exit(1 if echecs else 0)'
cat > "$D/PROMPT.txt" <<'TXT'
`bash test.sh` échoue dans ce dépôt. Trouve la cause et corrige-la, puis vérifie
que le test passe. Ne modifie pas `test.sh` ni `check.py`.
TXT
git_init "$D" "facturation initiale"

# --- t3 — feature moyenne ----------------------------------------------------
D="$ROOT/t3-feature"; mkdir -p "$D"; lib "$D" 1
runner "$D" 'import sys
from tarifs.facture import total_ttc
from tarifs.remise import remise

echecs = []
cas = [
    (100.0, 0.0),      # sous le premier seuil
    (500.0, 50.0),     # premier palier : 10 %
    (1999.0, 199.90),  # toujours 10 % sous 2000
    (2000.0, 300.0),   # second palier : 15 %
    (5000.0, 1000.0),  # troisième palier : 20 %
]
for ht, attendu in cas:
    obtenu = remise(ht)
    if abs(obtenu - attendu) > 0.01:
        echecs.append(f"remise({ht}) attendue {attendu}, trouvée {obtenu}")
# la facture doit continuer de déduire la remise avant la TVA
if abs(total_ttc(2000.0) - 2040.0) > 0.01:
    echecs.append(f"total_ttc(2000) attendu 2040.0, trouvé {total_ttc(2000.0)}")
print("pass" if not echecs else "fail")
for e in echecs:
    print(" -", e)
sys.exit(1 if echecs else 0)'
cat > "$D/PROMPT.txt" <<'TXT'
La remise devient progressive, par paliers sur le montant hors taxes :

- en dessous de 500 : aucune remise ;
- de 500 inclus à 2000 exclus : 10 % ;
- de 2000 inclus à 5000 exclus : 15 % ;
- à partir de 5000 : 20 %.

Le taux appliqué est celui du palier atteint, sur la totalité du montant. La
facture doit continuer de déduire la remise avant la TVA. Implémente ce
changement, puis vérifie par `bash test.sh`. Ne modifie pas `test.sh` ni
`check.py`.
TXT
git_init "$D" "facturation initiale"

# --- t4 — exploration --------------------------------------------------------
D="$ROOT/t4-exploration"; mkdir -p "$D"; lib "$D" 1
mkdir -p "$D/facturation"
cat > "$D/facturation/export.py" <<'PY'
"""Export comptable."""

from tarifs.facture import total_ttc


def ligne_export(reference, montant_ht):
    return f"{reference};{montant_ht:.2f};{total_ttc(montant_ht):.2f}"
PY
cat > "$D/facturation/relance.py" <<'PY'
"""Relances client."""

from tarifs.facture import total_ttc


def montant_du(montant_ht, deja_paye):
    return round(total_ttc(montant_ht) - deja_paye, 2)
PY
: > "$D/facturation/__init__.py"
runner "$D" 'import sys, pathlib, re

p = pathlib.Path("REPONSE.md")
if not p.exists():
    print("fail")
    print(" - REPONSE.md absent")
    sys.exit(1)
t = p.read_text(encoding="utf-8").lower()
attendus = ["total_ttc", "tarifs/facture.py", "ligne_export", "montant_du"]
manquants = [a for a in attendus if a.lower() not in t]
# la remise ne doit pas être citée comme appelant de total_ttc
faux = "remise(" in t.replace(" ", "") and "appelle total_ttc" in t
print("pass" if not manquants and not faux else "fail")
for m in manquants:
    print(" - absent de REPONSE.md :", m)
if faux:
    print(" - remise présentée à tort comme appelant total_ttc")
sys.exit(1 if manquants or faux else 0)'
cat > "$D/PROMPT.txt" <<'TXT'
Dans ce dépôt, écris `REPONSE.md` répondant à ces deux questions :

1. quelle fonction calcule le total toutes taxes comprises, et dans quel
   fichier ?
2. quelles fonctions l'appellent ?

Cite les noms et les chemins exacts. N'écris rien d'autre que `REPONSE.md`.
TXT
git_init "$D" "facturation et export"

# --- t5 — review -------------------------------------------------------------
D="$ROOT/t5-review"; mkdir -p "$D"; lib "$D" 1
cat > "$D/tarifs/lot.py" <<'PY'
"""Facturation par lot."""

from tarifs.facture import total_ttc


def total_lot(lignes, taux_change=1.0):
    total = 0
    for ligne in lignes:
        montant = ligne["montant_ht"]
        # le taux de change est appliqué après la TVA
        total += total_ttc(montant) * taux_change
    return total


def moyenne_lot(lignes):
    return total_lot(lignes) / len(lignes)


def appliquer_avoir(total, avoir):
    return total - avoir
PY
runner "$D" 'import sys, pathlib

p = pathlib.Path("REVUE.md")
if not p.exists():
    print("fail")
    print(" - REVUE.md absent")
    sys.exit(1)
t = p.read_text(encoding="utf-8").lower()
defauts = {
    "division par zéro sur lot vide": ["moyenne_lot", "vide", "zéro"],
    "total non arrondi": ["total_lot", "arrond"],
    "avoir non borné": ["appliquer_avoir", "négatif"],
}
manquants = []
for nom, indices in defauts.items():
    touches = sum(1 for i in indices if i in t)
    if touches < 2:
        manquants.append(nom)
print("pass" if not manquants else "fail")
for m in manquants:
    print(" - défaut non relevé :", m)
sys.exit(1 if manquants else 0)'
cat > "$D/PROMPT.txt" <<'TXT'
Relis `tarifs/lot.py` dans ce dépôt et écris `REVUE.md` : liste les défauts que
tu y vois, en nommant pour chacun la fonction concernée et la conséquence
concrète. Ne corrige rien, n'écris rien d'autre que `REVUE.md`.
TXT
git_init "$D" "facturation par lot"

# --- t6 — reprise de continuité ---------------------------------------------
D="$ROOT/t6-continuite"; mkdir -p "$D"; lib "$D" 1
cat > "$D/plan.md" <<'MD'
# PLAN — Facturation

## Objectif final

Une facturation juste, prouvée par ses tests.

## Invariants

- La remise est déduite avant la TVA.

## A1 — Socle de calcul

### Objectif

Calculer un total toutes taxes comprises.

### Tâches

- [x] A1.1 Écrire le calcul de la facture.
- [x] A1.2 Rendre la remise progressive par paliers.

### Validation

`bash test.sh` passe.
MD
cat > "$D/progress.md" <<'MD'
# PROGRESS — Facturation

## Phase actuelle

Phase A.

## Dernière tâche validée

A1.2 — la remise progressive par paliers est en place et fonctionne.

## Décisions actives

- La remise est déduite avant la TVA.

## Blocage actif

Aucun.

## Fichiers / zones utiles

- `tarifs/`, `test.sh`.

## NEXT ACTION

A2.1 — commencer l'export comptable.

## NEXT ACTION

A1.3 — vérifier les paliers.
MD
runner "$D" 'import sys, pathlib, subprocess, os

echecs = []
prog = pathlib.Path("progress.md")
plan = pathlib.Path("plan.md")
t = prog.read_text(encoding="utf-8")

n = sum(1 for l in t.splitlines() if l.strip() == "## NEXT ACTION")
if n != 1:
    echecs.append(f"{n} sections NEXT ACTION, il en faut exactement une")
if "## Tâche actuelle" not in t:
    echecs.append("section « Tâche actuelle » absente")
if "Validation :" not in t:
    echecs.append("dernière tâche validée sans preuve sous « Validation : »")
# A1.2 était déclarée faite sans exister : la déclaration doit avoir été corrigée
src = pathlib.Path("tarifs/remise.py").read_text(encoding="utf-8")
paliers = src.count("elif") + src.count("if ")
p = plan.read_text(encoding="utf-8")
coche = "[x] A1.2" in p
if coche and paliers < 3:
    echecs.append("A1.2 reste cochée alors que les paliers n’existent pas")
for section in ("### Dépendances", "### Objectif", "### Validation", "### Tâches"):
    if section not in p:
        echecs.append(f"unité incomplète : {section} absent de plan.md")
print("pass" if not echecs else "fail")
for e in echecs:
    print(" -", e)
sys.exit(1 if echecs else 0)'
cat > "$D/PROMPT.txt" <<'TXT'
Ce dossier est un bac à sable de test : ne crée aucun dépôt distant. Continue ce
projet.
TXT
git_init "$D" "facturation, continuité dégradée"

printf 'six fixtures construites dans %s\n' "$ROOT"
for d in "$ROOT"/*/; do
  n="$(basename "$d")"
  if bash "$d/test.sh" >/dev/null 2>&1; then s="PASS"; else s="FAIL"; fi
  printf '  %-18s état initial : %s\n' "$n" "$s"
done
