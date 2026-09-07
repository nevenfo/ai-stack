#!/usr/bin/env python3
"""
hooks/antigravity_hook.py
Called by Antigravity's hook system after a conversation ends.

Antigravity hooks are configured in:
  %USERPROFILE%\\.gemini\\config\\hooks.json

Expected hook configuration:
  {
    "on_session_end": {
      "command": "python C:\\\\Users\\\\FlowUP\\\\Documents\\\\conv-exporter\\\\hooks\\\\antigravity_hook.py",
      "env": {}
    }
  }

The hook receives the conversation ID via the ANTIGRAVITY_CONVERSATION_ID
environment variable (or via --conv-id argument fallback).

NOTE: Antigravity's hook API may not support on_session_end on all versions.
See MAINTENANCE.md for the manual fallback instructions.
"""

from __future__ import annotations

import json
import logging
import os
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent))

from src.adapter_antigravity import (
    export_current_antigravity_session,
    export_latest_antigravity_session,
)

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [agy-hook] %(message)s",
    handlers=[
        logging.FileHandler(
            Path(__file__).parent.parent / "spool" / "agy_hook.log",
            encoding="utf-8",
        )
    ],
)
logger = logging.getLogger(__name__)


def main() -> int:
    # Try to get conversation ID from environment (Antigravity hook standard)
    conv_id = os.environ.get("ANTIGRAVITY_CONVERSATION_ID") or \
               os.environ.get("AGY_CONVERSATION_ID")

    # Try CLI argument fallback
    if not conv_id and len(sys.argv) > 1:
        conv_id = sys.argv[1]

    # Try stdin JSON
    if not conv_id:
        try:
            payload = json.loads(sys.stdin.read() or "{}")
            conv_id = payload.get("conversation_id") or payload.get("conversationId")
        except Exception:
            pass

    logger.info("Antigravity hook triggered. conv_id=%s", conv_id or "unknown")

    if conv_id:
        stem = export_current_antigravity_session(conv_id)
    else:
        logger.warning("No conversation ID found, falling back to latest.")
        stem = export_latest_antigravity_session()

    if stem:
        logger.info("Exported: %s", stem)
    else:
        logger.info("Nothing to export.")

    return 0


if __name__ == "__main__":
    sys.exit(main())
