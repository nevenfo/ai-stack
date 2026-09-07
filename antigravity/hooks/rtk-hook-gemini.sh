#!/bin/bash
set -euo pipefail

# Accept both Gemini CLI BeforeTool payloads and Antigravity PreToolUse payloads.
# RTK remains the single owner of command-rewrite logic.
python -c '
import json
import subprocess
import sys

raw = sys.stdin.read()

try:
    payload = json.loads(raw)
except json.JSONDecodeError:
    payload = None

tool_call = payload.get("toolCall", {}) if isinstance(payload, dict) else {}
if tool_call.get("name") != "run_command":
    result = subprocess.run(
        ["rtk", "hook", "gemini"],
        input=raw,
        text=True,
        encoding="utf-8",
    )
    raise SystemExit(result.returncode)

args = tool_call.get("args", {})
command = args.get("CommandLine") if isinstance(args, dict) else None
if not isinstance(command, str) or not command.strip():
    print(json.dumps({"decision": "deny", "reason": "RTK hook: missing CommandLine."}))
    raise SystemExit(0)

gemini_payload = {
    "tool_name": "run_shell_command",
    "tool_input": {"command": command},
}
result = subprocess.run(
    ["rtk", "hook", "gemini"],
    input=json.dumps(gemini_payload, separators=(",", ":")),
    text=True,
    encoding="utf-8",
    capture_output=True,
)
if result.returncode != 0:
    print(json.dumps({"decision": "deny", "reason": "RTK hook failed; command blocked."}))
    raise SystemExit(0)

try:
    rtk_result = json.loads(result.stdout)
except json.JSONDecodeError:
    print(json.dumps({"decision": "deny", "reason": "RTK hook returned invalid JSON; command blocked."}))
    raise SystemExit(0)

decision = {
    "allow": "allow",
    "ask_user": "ask",
    "deny": "deny",
}.get(rtk_result.get("decision"), "ask")

response = {"decision": decision}
rewritten = (
    rtk_result.get("hookSpecificOutput", {})
    .get("tool_input", {})
    .get("command")
)
if isinstance(rewritten, str) and rewritten != command:
    response["overwrite"] = {"CommandLine": rewritten}

print(json.dumps(response, separators=(",", ":")))
'
