# RPI Main: [Feature Name]

> **Branch**: [branch-name]
> **Created**: YYYY-MM-DD
> **Current Session**: Research | Plan | Implement | Verify | Complete
> **Task List ID**: [from Plan session - set CLAUDE_CODE_TASK_LIST_ID before /clear]
> **Last Updated**: YYYY-MM-DD HH:MM

## Documents

| Document | Status | Path |
|----------|--------|------|
| Research | Pending / In Progress / Complete | `docs/research/[branch]/...` |
| Plan | Pending / In Progress / Approved | `docs/plans/[branch]/...` |
| Progress | - / Active | `docs/progress/[branch]/...` |
| Verify | Pending / Passed / Failed | `docs/verify/[branch]/...` |

## Session History

| Session | Started | Ended | Outcome |
|---------|---------|-------|---------|
| Research | YYYY-MM-DD HH:MM | YYYY-MM-DD HH:MM | Complete |
| Plan | YYYY-MM-DD HH:MM | YYYY-MM-DD HH:MM | Approved |
| Implement #1 | YYYY-MM-DD HH:MM | YYYY-MM-DD HH:MM | Compact (Batch N done) |
| Implement #2 | YYYY-MM-DD HH:MM | YYYY-MM-DD HH:MM | Complete |
| Verify | YYYY-MM-DD HH:MM | YYYY-MM-DD HH:MM | Passed / Failed (N issues) |

## Batch Progress

| Batch | Description | Status | Checkpoint |
|-------|-------------|--------|------------|
| 1 | [Layer/Component] | Pending / In Progress / Complete | Build / Test |
| 2 | [Layer/Component] | Pending / In Progress / Complete | Build / Test |

## Quick Resume

To resume from current state:
```bash
# 1. Set environment variable to preserve TaskList (required after Plan session)
export CLAUDE_CODE_TASK_LIST_ID="[Task List ID above]"

# 2. After starting Claude Code
@docs/rpi/[branch]/rpi-main.md - continue RPI
```

## Notes

<!-- Any important context for resuming -->
