# Plan: [Feature Name]

> **Date**: YYYY-MM-DD
> **Status**: Draft | Approved
> **Research**: `docs/research/[git-branch-name]/[YYYY-MM-DD-feature]-research.md`

## Objective

<!-- One sentence describing what this plan accomplishes -->

## Prerequisites

- [ ] Research document reviewed
- [ ] Open questions resolved
- [ ] Dependencies available

## Batch Design

> Batch size depends on task complexity:
> - High (new files, architecture): 2-3 tasks
> - Medium (modify existing): 4-5 tasks
> - Low (simple changes): 5-7 tasks

## Implementation Steps

### Batch 1: [Layer/Component Name] [Complexity: High/Medium/Low]

#### Step 1: [Step Name]

**File**: `path/to/file`
**Action**: Create | Modify | Delete

**Changes**:
```
// Code to add/change
```

**Verification**:
- [ ] How to verify this step is complete

---

#### Step 2: [Step Name]

**File**: `path/to/file`
**Action**: Create | Modify | Delete

**Changes**:
```
// Code to add/change
```

**Verification**:
- [ ] How to verify this step is complete

---

**Batch 1 Checkpoint**:
- [ ] Build/lint succeeds
- [ ] Tests pass (if applicable)
- [ ] Ready for next batch or Compact

---

### Batch 2: [Layer/Component Name] [Complexity: High/Medium/Low]

#### Step 3: [Step Name]

**File**: `path/to/file`
**Action**: Create | Modify | Delete

**Changes**:
```
// Code to add/change
```

**Verification**:
- [ ] How to verify this step is complete

---

**Batch 2 Checkpoint**:
- [ ] Build/lint succeeds
- [ ] Tests pass (if applicable)
- [ ] Ready for next batch or Compact

---

<!-- Add more batches as needed -->

## Checkpoints

| After Batch | Verification | Expected Result |
|-------------|--------------|-----------------|
| Batch 1 | Build project | No errors |
| Batch 2 | Run tests | All pass |
| Final | Manual test | Feature works |

## Test Plan

### Unit Tests

1. `test_functionName_condition_expectedResult`
   - Setup: ...
   - Action: ...
   - Assert: ...

### Integration Tests

1. Test scenario description

### Manual Testing

1. [ ] Test case 1: Steps to verify
2. [ ] Test case 2: Steps to verify

## Rollback Plan

If implementation fails:

1. Revert files: `file1`, `file2`
2. Remove new files: `newFile`

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Risk 1 | Low/Med/High | Low/Med/High | How to mitigate |

## Task Registration

After plan approval, create Claude Tasks for tracking:

### Task Creation Commands

```
# For each Step in each Batch:
TaskCreate:
  subject: "Step N: [Step Name]"
  description: |
    File: path/to/file
    Action: Create | Modify | Delete
    Changes: [brief description]
    Verification: [how to verify]
  activeForm: "Implementing [Step Name]"
  metadata: { "parallel": true/false, "batch": N }

# Set dependencies for sequential tasks:
TaskUpdate:
  taskId: [dependent task ID]
  addBlockedBy: [prerequisite task IDs]
```

### Parallel vs Sequential

| Condition | Parallel? | blockedBy |
|-----------|-----------|-----------|
| Different files, no shared types | Yes | empty |
| Same file | No | previous task |
| Uses type from another task | No | that task |
| Independent tests | Yes | empty |

### Example with Parallel Marking

```
Batch 1: Core Layer
- Task 1: "Create User model" parallel:Yes (no blockedBy)
- Task 2: "Create Product model" parallel:Yes (no blockedBy)
- Task 3: "Create UserRepository interface" blockedBy:[1]

→ Tasks 1,2 can run in parallel via Sub-Agents
→ Task 3 waits for Task 1

Batch 2: Data Layer
- Task 4: "Create UserMapper" blockedBy:[1]
- Task 5: "Create ProductMapper" blockedBy:[2]
- Task 6: "Create UserService" blockedBy:[1,4]

→ Tasks 4,5 can run in parallel (different blockers resolved)
```

### Implement Phase: Parallel Execution

```
# In Implement session, launch parallel tasks together:
Task(prompt="Execute Task 1: Create User model...")
Task(prompt="Execute Task 2: Create Product model...")

# Single message = parallel execution
```

## Approval

- [ ] Plan reviewed by user
- [ ] Questions answered
- [ ] **Tasks created for all Steps**
- [ ] **Task List ID auto-assigned (check settings.local.json)**
- [ ] Ready to implement

---

**Approved**: Yes / No
**Approval Date**: YYYY-MM-DD
**Tasks Created**: Yes / No
**Task List ID**: [auto-assigned, YYYY-MM-DD-feature-name format]
**Notes**: Any conditions or modifications to the plan

---

## Task List ID (AUTO-ASSIGNED)

Task List ID is **automatically assigned** at the start of Plan phase, before Tasks are created.

- **Format**: `YYYY-MM-DD-[feature-name]` (from research.md filename)
- **Location**: `.claude/settings.local.json` → `env.CLAUDE_CODE_TASK_LIST_ID`
- **Persistence**: Survives `/clear` — no manual saving required

To verify: check `.claude/settings.local.json` for `CLAUDE_CODE_TASK_LIST_ID`.
