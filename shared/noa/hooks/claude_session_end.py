#!/usr/bin/env python3
"""Hook `SessionEnd` de Claude Code — flush KPI puis export de session.

Câblage (`~/.claude/settings.json`) :

    "SessionEnd": [
      {"matcher": "*", "hooks": [{"type": "command",
        "command": "python C:/Users/FlowUP/noa/hooks/claude_session_end.py"}]}
    ]

Claude Code fournit sur stdin un JSON portant `session_id`, `transcript_path`,
`cwd` et `reason`. `SessionEnd` se déclenche **une fois**, à la fermeture réelle
de la session — contrairement à `Stop`, qui se déclenche à chaque tour.

**Ce hook sort toujours en 0** (INV-P4). Une panne d'observabilité ne doit ni
teinter la fermeture de Claude, ni faire apparaître une erreur à l'utilisateur
pour une raison qui ne le concerne pas. Ce qui a échoué est écrit dans
`metrics/hook.log`, et les événements déjà écrits pendant la session restent
intacts : cet export n'est pas leur seule copie (INV-P6).
"""
from __future__ import annotations

import json
import sys
import traceback
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent / "src"))

BACKEND = "claude"


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
        _log("SESSION_END HOOK FAILED\n" + traceback.format_exc())
        # Signalé sur stderr, sans code d'échec : le message reste visible pour
        # qui le cherche, la fermeture de Claude n'en est pas affectée.
        sys.stderr.write("NOA KPI EXPORT FAILED (voir metrics/hook.log)\n")
    return 0


def run(data: dict) -> None:
    from noa_kpi import events, ingest_claude, session_export
    from noa_agents.config import CONFIG_VERSION

    session_id = data.get("session_id") or data.get("sessionId")
    transcript = data.get("transcript_path")
    reason = data.get("reason") or data.get("hook_event_name")
    project = events.project_name(data.get("cwd"))

    if not transcript and session_id:
        found = ingest_claude.find_transcript(session_id)
        transcript = str(found) if found else None

    report = {"written": 0, "skipped": 0}
    if transcript:
        report = ingest_claude.ingest(transcript, session_id, CONFIG_VERSION)
        session_id = session_id or report.get("session_id")
    else:
        _log(f"transcript introuvable pour la session {session_id!r}")

    if not session_id:
        _log("aucun session_id : ni export ni événement de fin")
        return

    rows = events.read_events()
    mine = [r for r in rows if r.get("session_id") == session_id]
    calls = [r for r in mine if r.get("event") == "local_agent_call"]
    statuses = [r.get("status") for r in calls]

    # Un `session_end` par session, pas un par relance du hook : l'ingestion
    # est protégée par les `uuid` déjà vus, cet événement-ci ne l'est par rien.
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
            cloud_tokens=report.get("cloud_tokens") or None,
            turns=report.get("written") or None,
        )

    # Relecture après l'événement de fin : l'export doit le contenir.
    path = session_export.write(session_id, BACKEND, exit_reason=reason)
    _log(f"OK session={session_id} ingérés={report.get('written')} "
         f"ignorés={report.get('skipped')} export={path}")


if __name__ == "__main__":
    raise SystemExit(main())
