# RPI Workflow Examples

Detailed conversation examples for different scenarios.

---

## Example 1: Bug Fix

### Session 1: Research

**User**: "Let's fix the date calculation bug using RPI"

**Claude**: "Starting Research session. Running 4 Explore Agents in parallel."

[4 Agents run in parallel]

**Claude**:
"Research complete. Findings:

**Architecture**: Clean Architecture (Domain/Data/Presentation)
**Similar Feature**: Found DateCalculator, TimeUtils patterns
**Dependencies**: DateService → DateRepository → DateModel
**Test Structure**: Jest/Vitest with mock patterns

Created research.md and rpi-main.md.
Run `/clear` to start Plan session."

**User**: /clear

---

### Session 2: Plan

**User**: "@docs/research/fix-date-calc/2026-01-20-date-research.md - create plan"

**Claude**: "Creating plan.

## Batch 1: Core Logic [Complexity: Medium]
- Step 1: Fix DateCalculator logic
- Step 2: Add edge case handling
- Step 3: Update validation

## Batch 2: Test & Verification [Complexity: Low]
- Step 4: Add failing test for bug
- Step 5: Verify fix passes test
- Step 6: Add regression tests

Approve?"

**User**: Approved

**Claude**: "plan.md saved. Run `/clear` to start Implement session."

**User**: /clear

---

### Session 3: Implement

**User**: "@docs/rpi/fix-date-calc/rpi-main.md - start implementation"

**Claude**: "Starting Implement session. Beginning with Batch 1.

**Step 1: Fix DateCalculator logic**
[Sub-Agent executes]

**Step 2: Add edge case handling**
[Sub-Agent executes]

**Step 3: Update validation**
[Sub-Agent executes]

Batch 1 complete. Check context usage in Status Line. Over 40%?"

**User**: No, 25%

**Claude**: "Good. Continuing with Batch 2.

[Batch 2 executes...]

All batches complete. Implementation finished!"

---

## Example 2: New Feature

### Session 1: Research

**User**: "RPI - add notification feature"

**Claude**: "Starting Research session..."

[4 Explore Agents run]

- **Architecture**: Service layer pattern, event-driven
- **Similar Feature**: Found EmailService, existing notification patterns
- **Dependencies**: NotificationService → MessageQueue → Templates
- **Test Structure**: Unit tests with mocks, integration tests

**User**: /clear

---

### Session 2: Plan

[Batch structure created]

**Batch 1**: Core (Entity, Interface) - 3 tasks
**Batch 2**: Data (Model, Repository, Service) - 4 tasks
**Batch 3**: Presentation (Controller, Routes) - 4 tasks
**Batch 4**: Integration & Config - 3 tasks

**User**: Approved + /clear

---

### Session 3: Implement (with Compact)

**User**: "@rpi-main.md - start implementation"

[Batch 1, 2 executed]

**Claude**: "Batch 2 complete. Context over 40%?"

**User**: Yes, 45%

**Claude**: "Running Compact Protocol. Updating progress...

Done. After `/clear`, resume with:
`@rpi-main.md - continue RPI`"

**User**: /clear

**User**: "@docs/rpi/feature-notification/rpi-main.md - continue RPI"

**Claude**: "Checking progress. Resuming from Batch 3..."

---

## Example 3: Refactoring

### Session 1: Research

**User**: "RPI - refactor UserRepository to clean architecture"

[Current vs target structure analyzed]

- **Current**: Repository returns models directly
- **Target**: Entity/Model separation, add Mapper

---

### Session 2: Plan

**Batch 1**: Domain Entity creation [High]
**Batch 2**: Mapper implementation [Medium]
**Batch 3**: Repository Protocol separation [Medium]
**Batch 4**: Migrate existing code [Medium]
**Batch 5**: Update tests [Low]

---

### Session 3: Implement

[5 Batches executed across 2-3 Compact cycles]

---

## Recovery Example

### Scenario: Session crashed during Implement

**Situation**: Session terminated in the middle of Batch 2

**Recovery**:

**User**: "@docs/rpi/feature-x/rpi-main.md - continue RPI"

**Claude**: "Checking rpi-main.md:
- Current Session: Implement #1
- Last Batch: 2 (In Progress)

Running `git status` to check current state...

Modified files:
- src/models/Feature.ts (committed)
- src/services/FeatureService.ts (uncommitted)

Resume from where we left off?"

**User**: Yes

**Claude**: "Resuming Batch 2 from Step 4..."

---

## Quick Reference

### Commands

| Phase | Command | Input |
|-------|---------|-------|
| Research | `/rpi:research` | Feature description |
| Plan | `/rpi:plan` | `@research.md` |
| Implement | `/rpi:implement` | `@rpi-main.md` or TaskList |
| Verify | `/rpi:verify` | `@rpi-main.md` |

### Key Environment Variable

```bash
# Set before /clear to persist tasks
export CLAUDE_CODE_TASK_LIST_ID="[id]"
```

### Context Management

- Check Status Line after each batch
- Over 40%? Run `/clear` and resume
- Tasks persist if env var is set
