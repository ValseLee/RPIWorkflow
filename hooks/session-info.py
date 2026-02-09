#!/usr/bin/env python3
"""
RPI Session Info Hook

UserPromptSubmit hook that:
1. Auto-saves session ID to .claude/settings.local.json when tasks exist
2. Verifies task creation in ~/.claude/tasks/<session_id>/
3. Provides session info and verification when triggered by keywords

Trigger keywords: <session info>, <this session>, <rpi session>

Auto-save: Runs on every prompt. When tasks exist for the current session,
automatically saves the session ID to settings.local.json so it persists
across /clear boundaries without manual intervention.
"""
import json
import os
import sys
from pathlib import Path

try:
    input_data = json.load(sys.stdin)
except json.JSONDecodeError:
    sys.exit(1)

prompt = input_data.get("prompt", "").lower()
session_id = input_data.get("session_id", "unknown")

# --- Paths ---
home = Path.home()
tasks_dir = home / ".claude" / "tasks" / session_id
settings_path = Path(os.getcwd()) / ".claude" / "settings.local.json"

# --- Trigger keywords ---
TRIGGER_KEYWORDS = ["<session info>", "<this session>", "<rpi session>"]


def get_tasks():
    """Read all .json task files from the session's task directory."""
    if not tasks_dir.exists():
        return []
    tasks = []
    for f in sorted(tasks_dir.glob("*.json")):
        try:
            with open(f) as fh:
                tasks.append(json.load(fh))
        except (json.JSONDecodeError, OSError):
            pass
    return tasks


def auto_save_session_id():
    """Save session ID to settings.local.json if current session has tasks.

    Returns:
        (bool, str): (whether saved, status message)
    """
    if session_id == "unknown":
        return False, "unknown session"

    tasks = get_tasks()
    if not tasks:
        return False, "no tasks"

    # Read existing settings
    settings = {}
    if settings_path.exists():
        try:
            with open(settings_path) as f:
                settings = json.load(f)
        except (json.JSONDecodeError, OSError):
            settings = {}

    # Check if already saved with this session ID
    env = settings.get("env", {})
    if env.get("CLAUDE_CODE_TASK_LIST_ID") == session_id:
        return False, "already saved"

    # Merge and save
    if "env" not in settings:
        settings["env"] = {}
    settings["env"]["CLAUDE_CODE_TASK_LIST_ID"] = session_id

    try:
        settings_path.parent.mkdir(parents=True, exist_ok=True)
        with open(settings_path, "w") as f:
            json.dump(settings, f, indent=2)
            f.write("\n")
        return True, "saved"
    except OSError as e:
        return False, f"write error: {e}"


def verify_tasks():
    """Verify tasks exist and return a status report."""
    if not tasks_dir.exists():
        return (
            f"Task directory not found: `~/.claude/tasks/{session_id}/`\n"
            "Tasks have not been created yet in this session."
        )

    tasks = get_tasks()
    if not tasks:
        return (
            f"Task directory exists but contains no task files.\n"
            f"Path: `~/.claude/tasks/{session_id}/`"
        )

    # Count by status
    statuses = {}
    for t in tasks:
        status = t.get("status", "unknown")
        statuses[status] = statuses.get(status, 0) + 1

    status_lines = [f"  - {s}: {c}" for s, c in sorted(statuses.items())]
    task_subjects = [
        f"  {t.get('id', '?')}. {t.get('subject', 'untitled')} [{t.get('status', '?')}]"
        for t in tasks
    ]

    return (
        f"**{len(tasks)}** tasks verified in `~/.claude/tasks/{session_id}/`\n\n"
        f"**Status Summary**:\n"
        + "\n".join(status_lines)
        + "\n\n**Task List**:\n"
        + "\n".join(task_subjects)
    )


# === Always run: Auto-save ===
saved, save_reason = auto_save_session_id()

# === Trigger keywords: Show info + verification ===
if any(keyword in prompt for keyword in TRIGGER_KEYWORDS):
    verification = verify_tasks()

    tasks = get_tasks()
    if saved:
        save_status = "Auto-saved to `.claude/settings.local.json`"
    elif save_reason == "already saved":
        save_status = "Already saved in `.claude/settings.local.json`"
    elif save_reason == "no tasks":
        save_status = "No tasks yet - will auto-save when tasks are created"
    else:
        save_status = f"Not saved ({save_reason})"

    output = {
        "hookSpecificOutput": {
            "hookEventName": "UserPromptSubmit",
            "additionalContext": f"""
## RPI Session Info (from hook)

**Session ID**: `{session_id}`
**Save Status**: {save_status}

### Task Verification
{verification}

Session ID is **auto-saved** to `.claude/settings.local.json` when tasks are created.
No manual saving required.
"""
        }
    }
    print(json.dumps(output))

elif saved:
    # Notify silently that auto-save happened
    output = {
        "hookSpecificOutput": {
            "hookEventName": "UserPromptSubmit",
            "additionalContext": f"""
## RPI Auto-Save (from hook)

Session ID `{session_id}` auto-saved to `.claude/settings.local.json` as `CLAUDE_CODE_TASK_LIST_ID`.
{len(get_tasks())} tasks detected in `~/.claude/tasks/{session_id}/`.
"""
        }
    }
    print(json.dumps(output))

sys.exit(0)
