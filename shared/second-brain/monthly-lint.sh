#!/usr/bin/env bash
set -Eeuo pipefail

brain_root="/mnt/ssd_ssk/second-brain"
reports_dir="$brain_root/lint-reports"
run_log="$brain_root/monthly-lint.log"
lock_file="$brain_root/.maintenance.lock"
codex_bin="/usr/bin/codex"
report_date="$(date '+%Y-%m-%d')"
report_file="$reports_dir/lint-$report_date.md"

timestamp() {
  date '+%Y-%m-%dT%H:%M:%S%z'
}

write_log() {
  printf '[%s] %s\n' "$(timestamp)" "$1" >> "$run_log"
}

if [[ ! -d "$reports_dir" || ! -f "$brain_root/AGENTS.md" || ! -x "$codex_bin" ]]; then
  write_log "ERREUR : structure du second cerveau absente ou incomplète"
  exit 1
fi

exec 9>"$lock_file"
if ! flock -n 9; then
  write_log "maintenance déjà en cours, lint reporté"
  exit 0
fi

prompt="Effectue un audit du second cerveau en suivant strictement la procédure Lint décrite dans AGENTS.md. Commence par lire AGENTS.md puis index.md. Travaille entièrement en lecture seule : ne corrige, ne crée, ne déplace et ne supprime aucun contenu du vault. Recherche les contradictions, pages orphelines, liens cassés, frontmatters invalides et affirmations potentiellement obsolètes. N'utilise aucun accès réseau. Retourne un rapport Markdown autonome indiquant la date $report_date, les constats avec leur emplacement et leur gravité, puis des propositions qui nécessiteront la confirmation de l'utilisateur."

write_log "début lint : $report_file"
if "$codex_bin" exec \
  --sandbox read-only \
  --cd "$brain_root" \
  --skip-git-repo-check \
  --ephemeral \
  --output-last-message "$report_file" \
  "$prompt"
then
  write_log "lint réussi : $report_file"
else
  status=$?
  write_log "ERREUR lint (code $status) : $report_file"
  exit "$status"
fi

