#!/usr/bin/env python3
"""
hooks/codex_session_end_hook.py
Called by Codex CLI's native SessionEnd hook (config.toml [[hooks.SessionEnd]]).

Codex CLI >= 0.124 ships a stable hooks engine (config.toml [hooks] table),
with a Windows-specific "command_windows" override, and a "SessionEnd" event
that fires exactly once when the whole Codex session terminates. This
supersedes the prior attempt's process-wrapper approach (hooks/codex_wrapper.cmd),
which required shadowing `codex` on PATH and was never actually installed.

Verified against Codex CLI 0.147.0 docs (learn.chatgpt.com/docs/hooks,
learn.chatgpt.com/docs/config-file/config-reference), 2026-08-08:
  - Hook events: SessionStart, SessionEnd, UserPromptSubmit, PreToolUse,
    PostToolUse, PermissionRequest, PreCompact, PostCompact, SubagentStart,
    SubagentStop, Stop.
  - SessionEnd fires once per session (matcher currently only supports "other").
  - stdin JSON payload: {"session_id", "transcript_path", "cwd",
    "hook_event_name": "SessionEnd", "reason": "other", "model",
    "permission_mode"}.
  - CAVEAT: "SessionEnd hooks are advisory. Their output won't steer Codex or
    keep the thread open." Default timeout is 1s, max configurable is 3s —
    this script must stay fast (single small JSONL parse + one file write).

config.toml registration (see backups/config.toml.<ts>.bak for the pre-change
version):

  [[hooks.SessionEnd]]

  [[hooks.SessionEnd.hooks]]
  type = "command"
  command = "python C:\\Users\\FlowUP\\Documents\\conv-exporter\\hooks\\codex_session_end_hook.py"
  command_windows = "python C:\\Users\\FlowUP\\Documents\\conv-exporter\\hooks\\codex_session_end_hook.py"
  timeout = 3

NOTE on transcript_path: Codex's SessionEnd payload may report a rollout path
that does not exactly match Codex's own on-disk naming in all builds. If
transcript_path is missing/unusable this hook falls back to exporting the
most recently modified rollout-*.jsonl file, mirroring the Claude hook's
fallback behavior.
"""

from __future__ import annotations

import json
import logging
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent))

from src.adapter_codex import export_codex_session, export_latest_codex_session

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [codex-session-end-hook] %(message)s",
    handlers=[
        logging.FileHandler(
            Path(__file__).parent.parent / "spool" / "codex_hook.log",
            encoding="utf-8",
        )
    ],
    force=True,
)
logger = logging.getLogger(__name__)


def main() -> int:
    try:
        payload_raw = sys.stdin.read()
        payload = json.loads(payload_raw) if payload_raw.strip() else {}
    except Exception as e:
        logger.warning("Failed to parse hook payload: %s", e)
        payload = {}

    logger.info(
        "Codex SessionEnd hook triggered. reason=%s, payload keys: %s",
        payload.get("reason"), list(payload.keys())
    )

    transcript_path = payload.get("transcript_path")
    if transcript_path:
        session_file = Path(transcript_path)
        if session_file.exists():
            stem = export_codex_session(session_file)
            logger.info("Exported: %s", stem if stem else "(nothing, already done or empty)")
            return 0
        logger.warning("transcript_path from payload does not exist on disk: %s", session_file)

    # Fallback: export the most recently modified rollout file.
    stem = export_latest_codex_session()
    logger.info("Exported (latest fallback): %s", stem if stem else "(nothing)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
