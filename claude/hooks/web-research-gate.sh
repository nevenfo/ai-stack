#!/usr/bin/env bash
python -c '
import json, sys
d = json.load(sys.stdin)
tool = d.get("tool_name")
agent = d.get("agent_type")
if tool in ("WebSearch", "WebFetch"):
    if agent == "web-research":
        print(json.dumps({"decision": "allow"}))
    else:
        print(json.dumps({
            "decision": "deny",
            "reason": "Delegue au sous-agent web-research (Task, subagent_type=web-research) au lieu d appeler WebSearch/WebFetch directement depuis le thread principal."
        }))
else:
    print("{}")
'
