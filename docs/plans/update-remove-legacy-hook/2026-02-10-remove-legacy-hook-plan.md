# Plan: Remove Legacy Hook System

> **Date**: 2026-02-10
> **Status**: Draft
> **Research**: `docs/research/update-remove-legacy-hook/2026-02-10-remove-legacy-hook-research.md`

## Objective

Remove the legacy `hooks/` directory and all hook-related code from install/uninstall scripts, documentation, and templates, since the Plan phase now directly assigns Task List IDs without needing a hook.

## Prerequisites

- [x] Research document reviewed
- [x] Open questions resolved (plugin.json has no hooks field - safe to delete)
- [x] Dependencies available

## Batch Design

> 3 Batches: Delete (Low) -> Modify Scripts (Medium) -> Update Docs & Templates (Low)

## Implementation Steps

### Batch 1: Delete Hook Files & Historical Docs [Complexity: Low]

#### Step 1: Delete hooks directory

**File**: `hooks/` (entire directory)
**Action**: Delete

**Changes**:
```
rm -rf hooks/session-info.py
rm -rf hooks/hooks.json
rm -rf hooks/__pycache__/
```

**Verification**:
- [ ] `hooks/` directory no longer exists
- [ ] No Python bytecode cache remains

---

#### Step 2: Delete completed feature history docs (main branch)

**File**: Multiple files in `docs/` subdirectories
**Action**: Delete

**Changes**:
```
Delete:
- docs/research/main/2026-02-10-task-list-id-auto-assign-research.md
- docs/plans/main/2026-02-10-task-list-id-auto-assign-plan.md
- docs/verify/main/2026-02-10-task-list-id-auto-assign-verify.md
- docs/research/main/2026-02-09-claude-plugin-packaging-research.md
- docs/plans/main/2026-02-09-claude-plugin-packaging-plan.md
- docs/verify/main/2026-02-09-claude-plugin-packaging-verify.md
- docs/research/main/2026-02-09-readme-workflow-alignment-research.md
- docs/rpi/main/rpi-main.md
```

**Verification**:
- [ ] Listed files deleted
- [ ] `docs/research/main/`, `docs/plans/main/`, `docs/verify/main/`, `docs/rpi/main/` directories empty or removed

---

#### Step 3: Delete completed feature history docs (update-docs-test branch)

**File**: Multiple files in `docs/` subdirectories
**Action**: Delete

**Changes**:
```
Delete:
- docs/research/update-docs-test/2026-02-10-docs-update-research.md
- docs/plans/update-docs-test/2026-02-10-docs-update-plan.md
- docs/verify/update-docs-test/2026-02-10-docs-update-verify.md
- docs/rpi/update-docs-test/rpi-main.md
```

**Verification**:
- [ ] Listed files deleted
- [ ] `docs/research/update-docs-test/`, `docs/plans/update-docs-test/`, `docs/verify/update-docs-test/`, `docs/rpi/update-docs-test/` directories empty or removed

---

**Batch 1 Checkpoint**:
- [ ] All hook files deleted
- [ ] All historical docs deleted
- [ ] No broken references in remaining files yet (will fix in Batch 2 & 3)

---

### Batch 2: Modify Install/Uninstall Scripts [Complexity: Medium]

#### Step 4: Remove hook logic from install.sh

**File**: `install.sh`
**Action**: Modify

**Changes**:
1. Remove `HOOKS_DIR` variable (line 19)
2. Remove `mkdir -p "$HOOKS_DIR"` and its echo (lines 54, 57)
3. Change step counter from `[1/6]` to `[1/4]` (adjust all step numbers)
4. Remove Step [4/6]: Install hooks section (lines 82-92)
5. Remove Step [5/6]: Register hook in settings.json section (lines 94-147)
6. Remove hook verification section (lines 172-187)

After modification, install.sh should only:
- Create directories (commands, templates)
- Install commands
- Install templates
- Verify installation (commands + templates only)

**Verification**:
- [ ] `bash -n install.sh` passes (syntax check)
- [ ] No references to hooks, HOOKS_DIR, session-info.py, or settings.json hook registration
- [ ] Step numbers are sequential [1/4] through [4/4]

---

#### Step 5: Remove hook logic from uninstall.sh

**File**: `uninstall.sh`
**Action**: Modify

**Changes**:
1. Remove `HOOKS_DIR` variable (line 16)
2. Remove `SETTINGS_FILE` and `RPI_HOOK_CMD` variables (lines 17-18)
3. Remove hooks from confirmation message (lines 34-35)
4. Change step counter from `[1/4]` to `[1/2]` (adjust all step numbers)
5. Remove Step [3/4]: Remove hooks section (lines 69-77)
6. Remove Step [4/4]: Deregister hook from settings.json section (lines 79-102)

After modification, uninstall.sh should only:
- Remove commands directory
- Remove templates directory

**Verification**:
- [ ] `bash -n uninstall.sh` passes (syntax check)
- [ ] No references to hooks, HOOKS_DIR, session-info.py, settings.json, or jq hook operations
- [ ] Step numbers are sequential [1/2] through [2/2]

---

**Batch 2 Checkpoint**:
- [ ] `bash -n install.sh` passes
- [ ] `bash -n uninstall.sh` passes
- [ ] No hook references in either script

---

### Batch 3: Update Documentation & Templates [Complexity: Low]

#### Step 6: Update README.md - Remove hook references

**File**: `README.md`
**Action**: Modify

**Changes**:
1. Plugin install section (line 115): Remove "Sets up session management hooks"
2. Plugin Structure (lines 217-219): Remove `hooks/` entries from tree
3. Manual Install Structure (lines 262-263): Remove `hooks/rpi/` entries from tree
4. Task Persistence section (line 390): Remove "Session management hook guards the ID across sessions"
5. Delete entire "Session Management Hook" section (lines 394-403)
6. Troubleshooting "Hook not running" section (lines 433-437): Delete entire section
7. Requirements (line 422): Remove "Python 3.7+ (for session management hook)"
8. Requirements (line 423): Remove "jq (optional, used by `install.sh` for hook registration)"
9. Troubleshooting "Tasks not persisting" (line 429): Remove `<session info>` reference

**Verification**:
- [ ] No references to hooks, session-info.py, `<session info>`, Python 3.7+, or jq in README.md
- [ ] Project structure trees are accurate
- [ ] All remaining sections are coherent

---

#### Step 7: Update templates/plan-template.md - Remove session info reference

**File**: `templates/plan-template.md`
**Action**: Modify

**Changes**:
1. Line 218: Remove `To verify: type \`<session info>\` to see the current Task List ID.`
2. Replace with: `To verify: check \`.claude/settings.local.json\` for \`CLAUDE_CODE_TASK_LIST_ID\`.`

**Verification**:
- [ ] No `<session info>` references in plan-template.md
- [ ] Alternative verification instruction present

---

#### Step 8: Update CONTRIBUTING.md - Remove hook testing reference

**File**: `CONTRIBUTING.md`
**Action**: Modify

**Changes**:
1. Line 116: Remove "Verify session resume after `/clear`" (hook-dependent behavior) - actually this is still valid via TaskList, keep but no hook needed
2. No hook-specific testing items found - no changes needed

Actually, CONTRIBUTING.md has no direct hook references. No modification needed.

**Verification**:
- [ ] Confirm no hook references exist in CONTRIBUTING.md

---

**Batch 3 Checkpoint**:
- [ ] No hook references in any remaining project file
- [ ] README.md structure diagrams are accurate
- [ ] Templates are updated

---

## Checkpoints

| After Batch | Verification | Expected Result |
|-------------|--------------|-----------------|
| Batch 1 | Files deleted, no broken symlinks | Clean directory structure |
| Batch 2 | `bash -n install.sh && bash -n uninstall.sh` | No syntax errors |
| Final | Grep for hook references | Zero matches outside docs/research/update-remove-legacy-hook/ |

## Test Plan

### Manual Testing

1. [ ] `bash -n install.sh` - Install script syntax valid
2. [ ] `bash -n uninstall.sh` - Uninstall script syntax valid
3. [ ] Grep entire project for `session-info.py`, `hooks.json`, `<session info>` - no references outside research docs
4. [ ] Verify plugin.json has no hooks field (already confirmed)
5. [ ] Verify remaining files have no broken cross-references

## Rollback Plan

If implementation fails:

1. `git checkout -- hooks/ install.sh uninstall.sh README.md templates/plan-template.md`
2. Restore deleted docs from git history

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| plugin.json requires hooks field | Low | Med | Confirmed plugin.json has no hooks reference |
| Users depend on `<session info>` trigger | Low | Low | TaskList command provides same info |
| install.sh breaks after edit | Med | Low | bash -n syntax check before commit |

## Task Registration

### Task Summary

| Task | Step | Batch | Parallel |
|------|------|-------|----------|
| 1 | Step 1: Delete hooks directory | 1 | Yes |
| 2 | Step 2: Delete main branch history docs | 1 | Yes |
| 3 | Step 3: Delete update-docs-test history docs | 1 | Yes |
| 4 | Step 4: Remove hook logic from install.sh | 2 | Yes |
| 5 | Step 5: Remove hook logic from uninstall.sh | 2 | Yes |
| 6 | Step 6: Update README.md | 3 | Yes |
| 7 | Step 7: Update plan-template.md | 3 | Yes |

### Parallel Analysis

- Batch 1: Steps 1-3 all independent (different directories) -> parallel
- Batch 2: Steps 4-5 different files, no shared types -> parallel
- Batch 3: Steps 6-7 different files, no shared types -> parallel

All tasks within each batch can run in parallel. No cross-batch dependencies except batch ordering for checkpoints.

## Approval

- [ ] Plan reviewed by user
- [ ] Questions answered
- [ ] **Tasks created for all Steps**
- [ ] **Task List ID auto-assigned (check settings.local.json)**
- [ ] Ready to implement

---

**Approved**: Yes
**Approval Date**: 2026-02-10
**Tasks Created**: Yes
**Task List ID**: `2026-02-10-remove-legacy-hook`
**Notes**: Step 8 (CONTRIBUTING.md) removed from plan - no hook references found, no changes needed.

---

## Task List ID (AUTO-ASSIGNED)

Task List ID is **automatically assigned** at the start of Plan phase, before Tasks are created.

- **Format**: `YYYY-MM-DD-[feature-name]` (from research.md filename)
- **Location**: `.claude/settings.local.json` -> `env.CLAUDE_CODE_TASK_LIST_ID`
- **Persistence**: Survives `/clear` -- no manual saving required

To verify: check `.claude/settings.local.json` for `CLAUDE_CODE_TASK_LIST_ID`.
