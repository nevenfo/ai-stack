#!/usr/bin/env python3
"""Hook `SessionEnd` de Codex CLI — flush KPI puis export de session.

Câblage (`~/.codex/config.toml`, à la suite du hook `conv-exporter` déjà en
place, jamais à sa place) :

    [[hooks.SessionEnd.hooks]]
    type = "command"
    command = "python C:/Users/FlowUP/noa/hooks/codex_session_end.py"
    command_windows = "python C:/Users/FlowUP/noa/hooks/codex_session_end.py"
    timeout = 3

Codex fournit sur stdin un JSON portant `session_id`, `transcript_path`,
`cwd`, `hook_event_name`, `reason`, `model` et `permission_mode`.

Deux contraintes propres à Codex, absentes chez Claude :

1. **Le budget est de trois secondes au maximum.** L'ingestion écrit donc ses
   événements en un seul bloc (`events.append_many`) au lieu d'un `fsync` par
   ligne, et la recherche des rollouts de sous-agents est bornée au dossier du
   jour. Un dépassement tuerait le hook, pas la session.
2. **Un sous-agent Codex a son propre rollout**, que ce hook ne reçoit pas.
   Ses tokens sont pourtant dépensés par la session. On les rattrape en
   parcourant les rollouts frères qui déclarent la même session racine.

**Ce hook sort toujours en 0** (INV-P4). Codex dit lui-même de ses hooks
`SessionEnd` qu'ils sont consultatifs ; il n'y a donc rien à gagner à signaler
un échec par un code de sortie, et tout à perdre à teinter la fermeture d'une
session pour une raison qui ne concerne pas l'utilisateur. Ce qui a échoué est
écrit dans `metrics/hook.log`, et les événements déjà écrits pendant la
session restent intacts : cet export n'est pas leur seule copie (INV-P6).
"""
from __future__ import annotations

import json
import sys
import traceback
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent / "src"))

BACKEND = "codex"


def _log(message: str) -> None:
    try:
        from noa_kpi import events
        path = events.metrics_dir() / "hook.log"
        path.parent.mkdir(parents=True, exist_ok=True)
        with path.open("a", encoding="utf-8") as handle:
            handle.write(message.rstrip() + "\n")
    except Exception:
        pass


def _payload() -> dict:
    try:
        raw = sys.stdin.read()
    except Exception:
        return {}
    if not raw or not raw.strip():
        return {}
    try:
        data = json.loads(raw)
    except Exception:
        return {}
    return data if isinstance(data, dict) else {}


def main() -> int:
    try:
        run(_payload())
    except Exception:
        _log("CODEX SESSION_END HOOK FAILED\n" + traceback.format_exc())
        sys.stderr.write("NOA KPI EXPORT FAILED (voir metrics/hook.log)\n")
    return 0


def run(data: dict) -> None:
    from noa_kpi import events, ingest_codex, session_export
    from noa_agents.config import CONFIG_VERSION

    session_id = data.get("session_id") or data.get("sessionId")
    transcript = data.get("transcript_path")
    reason = data.get("reason") or data.get("hook_event_name")
    project = events.project_name(data.get("cwd"))

    if transcript and not Path(transcript).exists():
        # Codex ne garantit pas que le chemin annoncé existe sur disque dans
        # toutes ses versions : on le vérifie plutôt que de le supposer.
        _log(f"transcript_path annoncé mais absent: {transcript}")
        transcript = None
    if not transcript and session_id:
        found = ingest_codex.find_transcript(session_id)
        transcript = str(found) if found else None

    written = skipped = 0
    cloud_tokens = 0
    ingested_files = 0

    if transcript:
        report = ingest_codex.ingest(transcript, config_version=CONFIG_VERSION)
        written += report.get("written") or 0
        skipped += report.get("skipped") or 0
        cloud_tokens += report.get("cloud_tokens") or 0
        ingested_files += 1
        session_id = session_id or report.get("session_id")
    else:
        _log(f"rollout introuvable pour la session {session_id!r}")

    # Sous-agents : leurs rollouts portent la même session racine mais un
    # thread distinct. Ils sont ingérés sous leur propre session — la même —
    # et se distinguent par `is_sidechain`.
    if session_id:
        for extra in ingest_codex.related_transcripts(session_id, transcript):
            report = ingest_codex.ingest(extra, config_version=CONFIG_VERSION)
            written += report.get("written") or 0
            skipped += report.get("skipped") or 0
            cloud_tokens += report.get("cloud_tokens") or 0
            ingested_files += 1

    if not session_id:
        _log("aucun session_id : ni export ni événement de fin")
        return

    rows = events.read_events()
    mine = [r for r in rows if r.get("session_id") == session_id]
    calls = [r for r in mine if r.get("event") == "local_agent_call"]
    statuses = [r.get("status") for r in calls]
    turns = [r for r in mine if r.get("event") == "cloud_turn"]

    # Un `session_end` par session, pas un par relance du hook : sans cela,
    # rejouer la fermeture gonflerait les comptages de session sans qu'aucun
    # `source_uuid` ne l'empêche.
    if any(r.get("event") == "session_end" for r in mine):
        _log(f"session_end déjà enregistré pour {session_id} : pas de doublon")
    else:
        events.record(
            "session_end",
            backend=BACKEND,
            session_id=session_id,
            project=project,
            config_version=CONFIG_VERSION,
            exit_reason=reason,
            local_agent_calls=len(calls) or None,
            local_success=statuses.count("SUCCESS") or None,
            local_uncertain=statuses.count("UNCERTAIN") or None,
            local_fail=statuses.count("FAIL") or None,
            cloud_tokens=cloud_tokens or None,
            turns=len(turns) or None,
        )

    path = session_export.write(session_id, BACKEND, exit_reason=reason)
    _log(f"OK codex session={session_id} fichiers={ingested_files} "
         f"ingérés={written} ignorés={skipped} export={path}")


if __name__ == "__main__":
    raise SystemExit(main())
