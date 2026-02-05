---
description: RPI Plan phase - Create batch structure and Claude Tasks based on research.md. Use after /rpi:research completion.
allowed-tools: Read, Write, TaskCreate, TaskUpdate, TaskList, TaskGet, AskUserQuestion
---

# RPI Plan Phase

## Overview

Plan is the second phase of the RPI workflow. Create a structured implementation plan with batches and register Claude Tasks for tracking.

**Goal**: Design implementation steps and create trackable Tasks before coding.

## Prerequisites

- Research phase must be complete
- `docs/research/[branch]/...-research.md` must exist
- User should have run `/clear` after research

## Rule Loading

No rules to load - reference research.md only (minimize context)

## Input

- `@docs/research/[branch]/...-research.md` (only input needed)

## Workflow

```mermaid
flowchart TB
    Start[User: /rpi:plan] --> Load[Load research.md]
    Load --> Analyze[Analyze scope & complexity]
    Analyze --> Design[Design batch structure]
    Design --> Write[Write plan.md]
    Write --> Tasks[Create Claude Tasks]
    Tasks --> Deps[Set task dependencies]
    Deps --> Verify[Verify with TaskList]
    Verify --> Approval[Ask user approval]
    Approval --> Export[Guide CLAUDE_CODE_TASK_LIST_ID export]
    Export --> Clear[Guide user to /clear]
```

## Batch Design Guidelines

Group tasks by complexity:

| Task Complexity | Batch Size | Example |
|-----------------|-----------|---------|
| High (new files, architecture) | 2-3 tasks | Core modules, schemas |
| Medium (modify existing) | 4-5 tasks | Services, handlers |
| Low (simple changes) | 5-7 tasks | Imports, config changes |

### Typical Batch Order

1. **Core/Domain** - Entities, interfaces, types (high complexity)
2. **Data/Infrastructure** - Models, repositories, services (medium)
3. **Presentation/API** - Controllers, views, routes (medium)
4. **Integration** - Wiring, configuration (low)
5. **Tests** - Unit tests, integration tests (varies)

## Task Registration

After plan.md is written, register each Step as a Claude Task:

```
TaskCreate for each Step:
- subject: "Step N: [Step Name]"
- description: |
    File: path/to/file
    Action: Create | Modify | Delete
    Changes: [description]
    Verification: [how to verify]
- activeForm: "Implementing [Step Name]"
- metadata: { "parallel": true/false, "batch": N }

TaskUpdate for dependencies:
- Dependent tasks → addBlockedBy: [prerequisite task IDs]
- Independent tasks within batch → no blockedBy (parallel eligible)
```

### Parallel vs Sequential

| Condition | Parallel? | blockedBy |
|-----------|-----------|-----------|
| Different files, no shared types | Yes | empty |
| Same file | No | previous task |
| Uses type from another task | No | that task |
| Independent tests | Yes | empty |

### Example

```
Batch 1: Core Layer
- Task 1: "Create User model" parallel:Yes (no blockedBy)
- Task 2: "Create Product model" parallel:Yes (no blockedBy)
- Task 3: "Create UserRepository interface" blockedBy:[1]

Tasks 1,2 can run in parallel via Sub-Agents
Task 3 waits for Task 1
```

## Output Files

### 1. plan.md

Location: `docs/plans/[branch-name]/YYYY-MM-DD-[feature]-plan.md`

Use template: `~/.claude/rpi/plan-template.md`

Must include:
- Objective
- Prerequisites
- Batch structure with Steps
- Each Step: File, Action, Changes, Verification
- Batch checkpoints
- Test plan
- Risk assessment
- Task registration section

### 2. Update rpi-main.md

Update with:
- Plan document: Approved
- Task List ID: [from TaskList]
- Current Session: Implement

## TaskList Persistence (CRITICAL)

<CRITICAL>
After creating Tasks, you MUST guide user to set environment variable:

```bash
# Get task_list_id from TaskList output, then:
export CLAUDE_CODE_TASK_LIST_ID="[task_list_id]"
```

**Without this, Tasks will be lost on /clear!**
</CRITICAL>

## Exit Conditions

Before guiding user to `/clear`:

- [ ] plan.md complete with batch structure
- [ ] All Steps have TaskCreate called
- [ ] Dependencies set via TaskUpdate
- [ ] User approved the plan
- [ ] User ran `export CLAUDE_CODE_TASK_LIST_ID="..."`
- [ ] rpi-main.md updated with Task List ID

## Exit Message Template

```
Plan phase complete.

Documents:
- `docs/plans/[branch]/[date]-[feature]-plan.md`
- Updated `docs/rpi/[branch]/rpi-main.md`

Tasks created: N tasks across M batches
Task List ID: [id]

CRITICAL: Before running /clear, run this command:
export CLAUDE_CODE_TASK_LIST_ID="[id]"

Next steps:
1. Copy and run the export command above
2. Run `/clear` to start fresh session
3. Run `/rpi:implement` to start implementation
```

## Approval Flow

Use `AskUserQuestion` to get approval:
- Present plan summary
- Show batch structure
- List total tasks and parallel opportunities
- Ask for approval

## Red Flags - STOP

- Planning without research.md
- Creating tasks without dependencies analysis
- Skipping TaskCreate for any Step
- Forgetting to guide TaskList ID export
- Not getting user approval before proceeding
