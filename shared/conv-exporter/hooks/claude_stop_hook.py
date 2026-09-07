#!/usr/bin/env python3
"""
hooks/claude_stop_hook.py
Called by Claude Code's SessionEnd hook when a session truly terminates.

IMPORTANT (fixed 2026-08-08): this used to be wired to the "Stop" event.
Stop fires after EVERY turn (once per response), not once per conversation.
Combined with core.py's dedup-by-session_id logic, that meant the FIRST Stop
event of a session would export a partial, mid-conversation transcript and
permanently block any later, more complete export for that session_id (the
inbox write is immutable and the dedup log is keyed on session_id, not on
turn count). SessionEnd fires exactly once, when the session actually closes
(exit, logout, clear, prompt_input_exit, other) — this is the correct
"conversation truly done, won't resume" signal for Claude Code 2.1.226.
See https://code.claude.com/docs/en/hooks for the authoritative event list.

Claude Code hook integration (settings.json):
  {
    "hooks": {
      "SessionEnd": [
        {
          "matcher": "*",
          "hooks": [
            {
              "type": "command",
              "command": "python C:\\\\Users\\\\FlowUP\\\\Documents\\\\conv-exporter\\\\hooks\\\\claude_stop_hook.py"
            }
          ]
        }
      ]
    }
  }

The SessionEnd hook receives a JSON payload on stdin (same common fields as
all Claude Code hook events):
  {
    "session_id": "<uuid>",
    "transcript_path": "<path>",
    "reason": "clear" | "logout" | "prompt_input_exit" | "other" | ...,
    ...
  }
"""

from __future__ import annotations

import json
import logging
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent))

from src.adapter_claude import export_claude_session

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [claude-stop-hook] %(message)s",
    handlers=[
        logging.FileHandler(
            Path(__file__).parent.parent / "spool" / "claude_hook.log",
            encoding="utf-8",
        )
    ],
)
logger = logging.getLogger(__name__)


def main() -> int:
    # Read hook payload from stdin
    try:
        payload_raw = sys.stdin.read()
        payload = json.loads(payload_raw) if payload_raw.strip() else {}
    except Exception as e:
        logger.warning("Failed to parse hook payload: %s", e)
        payload = {}

    logger.info(
        "Claude SessionEnd hook triggered. reason=%s, payload keys: %s",
        payload.get("reason"), list(payload.keys())
    )

    # Try to find session from payload
    session_id = payload.get("session_id")
    transcript_path = payload.get("transcript_path")

    if transcript_path:
        session_file = Path(transcript_path)
        if session_file.exists():
            stem = export_claude_session(session_file)
            if stem:
                logger.info("Exported: %s", stem)
            else:
                logger.info("Nothing to export (already done or empty).")
            return 0

    # Fallback: export latest session
    from src.adapter_claude import export_latest_claude_session
    stem = export_latest_claude_session()
    if stem:
        logger.info("Exported (latest fallback): %s", stem)
    else:
        logger.info("Nothing to export.")

    # Claude Code Stop hook: output must be valid JSON if needed
    # Return 0 to not block Claude Code
    return 0


if __name__ == "__main__":
    sys.exit(main())
