# Plan: TaskList ID Auto-Assign

> **Date**: 2026-02-10
> **Status**: Draft
> **Research**: `docs/research/main/2026-02-10-task-list-id-auto-assign-research.md`

## Objective

`/rpi:plan` 실행 시 TaskCreate **이전에** research.md 파일명에서 feature name을 추출하여 `YYYY-MM-DD-[feature-name]` 포맷의 Task List ID를 생성하고, `.claude/settings.local.json`에 직접 할당한다. `session-info.py` 훅은 RPI 포맷 ID가 이미 설정된 경우 UUID로 덮어쓰지 않도록 수정한다.

## Prerequisites

- [x] Research document reviewed
- [x] Open questions resolved (feature name 추출: research.md 파일명 기반)
- [x] Dependencies available (python3, Claude Code TaskList API)

## Implementation Steps

### Batch 1: Core Logic & Hook Guard [Complexity: Medium]

3 Steps. `commands/plan.md`와 `hooks/session-info.py`는 독립 파일이므로 Step 1, 2 병렬 실행 가능. Step 3(template)도 독립 파일.

#### Step 1: Add Task List ID auto-assign to plan.md

**File**: `commands/plan.md`
**Action**: Modify

**Changes**:

1. **Workflow 다이어그램 수정** (L30-43): TaskCreate 이전에 ID 생성/할당 단계 추가

기존 흐름:
```
Start → Load → Analyze → Design → Write → Tasks → Deps → Verify → Approval → Session → Save → Clear
```

새 흐름:
```
Start → Load → ExtractID → AssignID → Analyze → Design → Write → Tasks → Deps → Verify → Approval → Clear
```

- `Session` 단계 제거 (수동 `<session info>` 불필요)
- `Save` 단계 제거 (Plan 실행 초반에 자동 할당)
- `ExtractID` 추가: research.md 파일명에서 feature name 추출
- `AssignID` 추가: `settings.local.json`에 `CLAUDE_CODE_TASK_LIST_ID` 할당

2. **"Session ID as Task List ID" 섹션 교체** (L129-185): 기존 auto-save 설명을 RPI 포맷 ID 자동 할당으로 교체

새 섹션 내용:
```markdown
## Task List ID Auto-Assign

Plan phase automatically assigns a Task List ID **before** creating Tasks.

### ID Format

`YYYY-MM-DD-[feature-name]`

- Date: from research.md filename
- Feature name: from research.md filename (date and `-research.md` removed)
- Example: `2026-02-10-task-list-id-auto-assign`

### How It Works

1. Extract feature name from research.md path:
   - Input: `docs/research/main/2026-02-10-task-list-id-auto-assign-research.md`
   - Extract: `2026-02-10-task-list-id-auto-assign`

2. Write to `.claude/settings.local.json`:
   ```json
   {
     "env": {
       "CLAUDE_CODE_TASK_LIST_ID": "2026-02-10-task-list-id-auto-assign"
     }
   }
   ```
   Use Read to check existing settings, merge `env` key, Write back.

3. Record in rpi-main.md and plan.md footer.

4. Proceed with TaskCreate (Tasks will use the assigned ID).

### Fallback

If research.md path is not provided or filename cannot be parsed:
- Ask user for feature name via AskUserQuestion
- Generate ID as `YYYY-MM-DD-[user-provided-name]` (today's date)
```

3. **Exit Conditions 수정** (L187-197): `<session info>` 관련 항목 제거, auto-assign 확인으로 교체

기존:
```
- [ ] Session ID auto-saved (verify with `<session info>` if needed)
- [ ] Session ID recorded in rpi-main.md (backup)
- [ ] Session ID appended to plan.md footer (reference)
```

변경:
```
- [ ] Task List ID auto-assigned to settings.local.json
- [ ] Task List ID recorded in rpi-main.md
- [ ] Task List ID recorded in plan.md footer
```

4. **Exit Message Template 수정** (L199-219): Session ID → Task List ID 용어 변경

5. **Red Flags 수정** (L229-236): `<session info>` 관련 항목을 ID 할당 관련으로 교체

**Verification**:
- [ ] Workflow 다이어그램에 ExtractID, AssignID 단계 존재
- [ ] `<session info>` 트리거 의존성 제거됨
- [ ] 자동 할당 워크플로우 설명이 명확함
- [ ] Fallback 절차 명시됨

---

#### Step 2: Add RPI format guard to session-info.py

**File**: `hooks/session-info.py`
**Action**: Modify

**Changes**:

`auto_save_session_id()` 함수 (L52-91)에 RPI 포맷 ID 감지 로직 추가:

기존 (L74-77):
```python
# Check if already saved with this session ID
env = settings.get("env", {})
if env.get("CLAUDE_CODE_TASK_LIST_ID") == session_id:
    return False, "already saved"
```

변경:
```python
# Check if already saved with this session ID
env = settings.get("env", {})
if env.get("CLAUDE_CODE_TASK_LIST_ID") == session_id:
    return False, "already saved"

# Guard: Do not overwrite RPI-format ID with UUID session ID
import re
existing_id = env.get("CLAUDE_CODE_TASK_LIST_ID", "")
if existing_id and re.match(r"\d{4}-\d{2}-\d{2}-.+", existing_id):
    return False, "rpi-format id preserved"
```

이 가드는:
- 기존에 `CLAUDE_CODE_TASK_LIST_ID`가 RPI 포맷(`YYYY-MM-DD-*`)인 경우 UUID로 덮어쓰지 않음
- RPI 포맷 패턴: `\d{4}-\d{2}-\d{2}-.+` (ISO 날짜로 시작)
- UUID 세션 ID는 통과 (기존 동작 유지)

추가: `re` import는 함수 내부에 배치하여 기존 코드에 미치는 영향 최소화. 또는 파일 상단 imports에 추가.

**Verification**:
- [ ] RPI 포맷 ID (`2026-02-10-feature-name`)가 설정된 상태에서 hook 실행 시 UUID로 덮어쓰지 않음
- [ ] UUID가 설정된 상태에서 hook 실행 시 기존대로 동작
- [ ] 빈 설정 상태에서 hook 실행 시 기존대로 UUID 저장
- [ ] `python3 -m py_compile hooks/session-info.py` 통과

---

#### Step 3: Update plan-template.md session handoff section

**File**: `templates/plan-template.md`
**Action**: Modify

**Changes**:

1. **"Session Handoff (CRITICAL)" 섹션 교체** (L210-227):

기존:
```markdown
## Session Handoff (CRITICAL)

After Tasks are created, retrieve session ID and save it:

### Step 1: Get Session ID
Type `<session info>` to trigger the hook and get the current session ID.

### Step 2: Save to settings.local.json
```json
// .claude/settings.local.json
{
  "env": {
    "CLAUDE_CODE_TASK_LIST_ID": "[session_id from hook]"
  }
}
```

**Without this step, Tasks will be lost on /clear!**
```

변경:
```markdown
## Task List ID (AUTO-ASSIGNED)

Task List ID is **automatically assigned** at the start of Plan phase, before Tasks are created.

- **Format**: `YYYY-MM-DD-[feature-name]` (from research.md filename)
- **Location**: `.claude/settings.local.json` → `env.CLAUDE_CODE_TASK_LIST_ID`
- **Persistence**: Survives `/clear` — no manual saving required

To verify: type `<session info>` to see the current Task List ID.
```

2. **Approval 체크리스트 수정** (L196-198):

기존:
```markdown
- [ ] **Session ID retrieved via `<session info>`**
```

변경:
```markdown
- [ ] **Task List ID auto-assigned (check settings.local.json)**
```

3. **Footer 수정** (L202-207):

기존:
```markdown
**Session ID**: [from session info hook]
```

변경:
```markdown
**Task List ID**: [auto-assigned, YYYY-MM-DD-feature-name format]
```

**Verification**:
- [ ] 수동 Session Handoff 절차 제거됨
- [ ] 자동 할당 설명으로 교체됨
- [ ] Approval 체크리스트에 auto-assign 확인 항목

---

**Batch 1 Checkpoint**:
- [ ] `commands/plan.md`의 워크플로우에 ID 자동 할당 반영
- [ ] `hooks/session-info.py`에 RPI 포맷 가드 추가
- [ ] `templates/plan-template.md`에서 수동 핸드오프 제거
- [ ] `python3 -m py_compile hooks/session-info.py` 통과

## Checkpoints

| After Batch | Verification | Expected Result |
|-------------|--------------|-----------------|
| Batch 1 | Python syntax check | `py_compile` 통과 |
| Batch 1 | plan.md 워크플로우 검토 | ExtractID → AssignID 흐름 명확 |
| Batch 1 | template 일관성 | 수동 핸드오프 제거, 자동 할당 반영 |

## Test Plan

### Manual Testing

1. [ ] `/rpi:plan` 실행 시 research.md 경로에서 feature name 추출 확인
2. [ ] `settings.local.json`에 `YYYY-MM-DD-feature-name` 포맷 ID 저장 확인
3. [ ] `<session info>` 트리거 시 RPI 포맷 ID 표시 확인
4. [ ] Hook이 RPI 포맷 ID를 UUID로 덮어쓰지 않는지 확인
5. [ ] `/clear` 후 TaskList로 Task 복구 확인

### Syntax Verification

1. [ ] `python3 -m py_compile hooks/session-info.py`
2. [ ] `commands/plan.md` YAML frontmatter 유효성

## Rollback Plan

If implementation fails:

1. `git checkout -- commands/plan.md hooks/session-info.py templates/plan-template.md`

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Hook이 RPI ID를 인식 못함 | Low | Medium | 정규식 패턴 `\d{4}-\d{2}-\d{2}-.+` 충분히 구분적 |
| 기존 UUID 세션 호환성 | Low | Low | 가드는 RPI 포맷만 보호, UUID는 기존대로 동작 |
| research.md 경로 파싱 실패 | Medium | Low | Fallback: 사용자에게 feature name 질문 |

## Task Registration

### Parallel Analysis

| Step | File | Parallel? | blockedBy | Notes |
|------|------|-----------|-----------|-------|
| 1 | commands/plan.md | Yes | - | 독립 파일, 핵심 워크플로우 변경 |
| 2 | hooks/session-info.py | Yes | - | 독립 파일, 가드 로직 추가 |
| 3 | templates/plan-template.md | Yes | - | 독립 파일, 문서 업데이트 |

**Total**: 3 tasks, 1 batch
**Parallel**: 모든 Step 동시 실행 가능 (서로 다른 파일, 공유 타입 없음)

---

## Approval

- [ ] Plan reviewed by user
- [ ] Questions answered
- [ ] **Tasks created for all Steps**
- [ ] **Task List ID auto-assigned**
- [ ] Ready to implement

---

**Approved**: Yes
**Approval Date**: 2026-02-10
**Tasks Created**: Yes (Tasks #16-#18)
**Task List ID**: `2026-02-10-task-list-id-auto-assign`
**Notes**: 3 tasks, 1 batch, 모두 병렬 실행 가능
