#!/usr/bin/env bash
set -Eeuo pipefail

brain_root="/mnt/ssd_ssk/second-brain"
inbox_dir="$brain_root/raw/inbox"
ingested_log="$brain_root/raw/.ingested.log"
run_log="$brain_root/weekly-ingest.log"
lock_file="$brain_root/.maintenance.lock"
codex_bin="/usr/bin/codex"

exec 9>"$lock_file"
if ! flock -n 9; then
  printf '[%s] exécution déjà en cours\n' "$(date '+%Y-%m-%dT%H:%M:%S%z')" >> "$run_log"
  exit 0
fi

timestamp() {
  date '+%Y-%m-%dT%H:%M:%S%z'
}

write_log() {
  printf '[%s] %s\n' "$(timestamp)" "$1" >> "$run_log"
}

if [[ ! -d "$inbox_dir" || ! -f "$brain_root/AGENTS.md" || ! -x "$codex_bin" ]]; then
  write_log "ERREUR : structure du second cerveau absente ou incomplète"
  exit 1
fi

touch "$ingested_log"

new_sources=()
while IFS= read -r -d '' source_path; do
  relative_path="${source_path#"$brain_root"/}"
  if [[ "$relative_path" == *$'\n'* ]]; then
    write_log "ERREUR : nom de fichier contenant un saut de ligne ignoré"
    continue
  fi
  if ! grep -Fqx -- "$relative_path" "$ingested_log"; then
    new_sources+=("$relative_path")
  fi
done < <(find "$inbox_dir" -maxdepth 1 -type f -print0 | sort -z)

if (( ${#new_sources[@]} == 0 )); then
  write_log "rien de nouveau"
  exit 0
fi

for relative_path in "${new_sources[@]}"; do
  write_log "début ingest : $relative_path"

  prompt="Traite exactement le fichier source '$relative_path' selon la procédure Ingest définie dans AGENTS.md. Commence par lire AGENTS.md puis index.md. Respecte l'immuabilité de raw/inbox, ne traite aucun autre fichier source, n'utilise aucun accès réseau, mets à jour les pages wiki pertinentes, index.md et log.md, puis applique la procédure Save."

  if "$codex_bin" exec \
    --sandbox workspace-write \
    --cd "$brain_root" \
    --skip-git-repo-check \
    --ephemeral \
    "$prompt"
  then
    printf '%s\n' "$relative_path" >> "$ingested_log"
    write_log "ingest réussi : $relative_path"
  else
    status=$?
    write_log "ERREUR ingest (code $status) : $relative_path"
    exit "$status"
  fi
done
