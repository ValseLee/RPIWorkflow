#!/usr/bin/env python3
"""
RPI Session Info Hook

UserPromptSubmit hook that provides session ID when triggered.
Trigger keywords: <session info>, <this session>, <rpi session>

Usage in conversation:
  User: <session info>
  Claude: Session ID: abc123-def456-...

This session ID can be used as CLAUDE_CODE_TASK_LIST_ID for task persistence.
"""
import json
import sys

try:
    input_data = json.load(sys.stdin)
except json.JSONDecodeError:
    sys.exit(1)

prompt = input_data.get("prompt", "").lower()

# Trigger keywords for session info retrieval
TRIGGER_KEYWORDS = ["<session info>", "<this session>", "<rpi session>"]

if any(keyword in prompt for keyword in TRIGGER_KEYWORDS):
    session_id = input_data.get("session_id", "unknown")

    output = {
        "hookSpecificOutput": {
            "hookEventName": "UserPromptSubmit",
            "additionalContext": f"""
## RPI Session Info (from hook)

**Session ID**: `{session_id}`

This session ID can be used as `CLAUDE_CODE_TASK_LIST_ID` for task list persistence.

To save for Implement phase:
1. Save to `.claude/settings.local.json`:
   ```json
   {{
     "env": {{
       "CLAUDE_CODE_TASK_LIST_ID": "{session_id}"
     }}
   }}
   ```
2. Record in `rpi-main.md` as backup
"""
        }
    }
    print(json.dumps(output))

sys.exit(0)
