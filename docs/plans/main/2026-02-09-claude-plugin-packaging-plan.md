# Plan: Claude Plugin Packaging 완성

> **Date**: 2026-02-09
> **Status**: Draft
> **Research**: `docs/research/main/2026-02-09-claude-plugin-packaging-research.md`

## Objective

RPI Workflow의 Plugin 패키징을 완성한다. 핵심 인프라(manifests, hooks.json, template 경로)는 이미 완료되어 있으므로, README와 command 파일의 불일치를 수정하여 Plugin으로서 완전한 상태를 만든다.

## Prerequisites

- [x] Research document reviewed
- [x] Plugin manifest files already exist (`.claude-plugin/plugin.json`, `marketplace.json`)
- [x] Hook registration manifest exists (`hooks/hooks.json` with `${CLAUDE_PLUGIN_ROOT}`)
- [x] Template path migration completed (commands use `templates/` relative paths)

## Current State Assessment

Research에서 식별된 작업 vs 실제 코드 상태:

| Research 식별 작업 | 현재 상태 | 남은 작업 |
|-------------------|-----------|-----------|
| `.claude-plugin/plugin.json` 생성 | **Done** (`"name": "rpi"`) | 없음 |
| `.claude-plugin/marketplace.json` 생성 | **Done** (`"name": "rpi-workflow"`) | 없음 |
| `hooks/hooks.json` 생성 | **Done** (`${CLAUDE_PLUGIN_ROOT}` 사용) | 없음 |
| Commands template 경로 변경 | **Done** (모두 `templates/` 상대 경로) | 없음 |
| `verify.md` template 참조 추가 | **미완료** | template 참조 줄 추가 |
| README Plugin Structure 다이어그램 | **불완전** | 누락 항목 추가 |
| README Manual Install Structure | **불완전** | hooks 디렉토리 추가 |
| `install.sh` 메시지 일관성 | **불일치** | README 참조로 변경 |
| `rpi-main.md` 업데이트 | **필요** | Plan 상태 반영 |

## Implementation Steps

### Batch 1: Documentation & Command Alignment [Complexity: Low]

5 Steps, 모두 단순 텍스트 수정. README 수정 2건은 같은 파일이므로 순차 실행.

#### Step 1: Add verify template reference to verify.md

**File**: `commands/verify.md`
**Action**: Modify

**Changes**:
verify.md의 Output Files > verify-report.md 섹션에 `Use template:` 줄 추가.
현재 research.md(L295-296), plan.md(L108-110), rule.md는 모두 이 패턴을 따르는데 verify.md만 누락.

추가할 내용 (Location 줄 다음):
```markdown
Use template: `templates/verify-template.md`
```

**Verification**:
- [ ] `commands/verify.md`에 `Use template:` 줄 존재

---

#### Step 2: Fix README Plugin Structure diagram

**File**: `README.md`
**Action**: Modify

**Changes**:
README L207-227의 Plugin Structure 다이어그램을 실제 파일 구조와 일치하도록 수정:
- `hooks/` 에 `session-info.py` 추가
- `templates/rules/` 하위 example 파일 추가
- `examples/`, `uninstall.sh`, `CONTRIBUTING.md`, `LICENSE` 추가

**Verification**:
- [ ] 실제 `ls` 결과와 README 다이어그램 일치

---

#### Step 3: Fix README Manual Install Structure diagram

**File**: `README.md`
**Action**: Modify

**Changes**:
README L241-257의 Manual Install Structure에 `hooks/rpi/` 디렉토리 추가.
install.sh가 `~/.claude/hooks/rpi/`에 hook 파일을 복사하지만 README에는 이 디렉토리가 누락.

**Verification**:
- [ ] Manual Install Structure에 `hooks/rpi/` 포함

---

#### Step 4: Update install.sh plugin recommendation message

**File**: `install.sh`
**Action**: Modify

**Changes**:
install.sh L22-25의 plugin 추천 메시지 수정:
- 현재: `claude plugin install github:ValseLee/RPIWorkflow`
- 변경: README.md 참조로 변경 (plugin marketplace 명령어가 미확정이므로)

**Verification**:
- [ ] install.sh 실행 시 정확한 안내 메시지 출력

---

#### Step 5: Update rpi-main.md with plan status

**File**: `docs/rpi/main/rpi-main.md`
**Action**: Modify

**Changes**:
- Documents 테이블: Plan → Complete, 경로 추가
- Research 행에 plugin packaging research 추가
- Session History: Plan 세션 추가
- Current Session: Implement

**Verification**:
- [ ] Plan document 경로가 올바름
- [ ] Session History에 Plan 기록

---

**Batch 1 Checkpoint**:
- [ ] `commands/verify.md`에 template 참조 존재
- [ ] README 두 다이어그램 모두 실제 구조와 일치
- [ ] install.sh 메시지 일관성
- [ ] rpi-main.md Plan 상태 반영

## Checkpoints

| After Batch | Verification | Expected Result |
|-------------|--------------|-----------------|
| Batch 1 | README 구조 다이어그램 vs 실제 파일 | 완전 일치 |
| Batch 1 | verify.md template 참조 | 다른 commands와 일관 |
| Batch 1 | install.sh 메시지 | README와 일치 |

## Test Plan

### Manual Testing

1. [ ] README Plugin Structure와 실제 `ls -R` 결과 비교
2. [ ] README Manual Install Structure와 install.sh 설치 경로 비교
3. [ ] `commands/verify.md`에서 `Use template:` 줄 확인
4. [ ] install.sh 실행 시 메시지 확인

## Rollback Plan

If implementation fails:

1. `git checkout -- commands/verify.md README.md install.sh docs/rpi/main/rpi-main.md`

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| README 변경이 기존 사용자 혼동 | Low | Low | 정확성 향상 방향의 변경 |
| install.sh 메시지 변경 | Low | Low | 메시지만 변경, 기능 동일 |

## Task Registration

### Parallel Analysis

| Step | File | Parallel? | blockedBy | Notes |
|------|------|-----------|-----------|-------|
| 1 | commands/verify.md | Yes | - | 독립 파일 |
| 2 | README.md | Yes | - | README 첫 번째 수정 |
| 3 | README.md | No | Step 2 | 같은 파일 |
| 4 | install.sh | Yes | - | 독립 파일 |
| 5 | rpi-main.md | No | 1,2,3,4 | 최종 상태 업데이트 |

**Total**: 5 tasks, 1 batch
**Parallel**: Steps 1, 2, 4 동시 실행 가능 → Step 3 → Step 5

---

## Approval

- [ ] Plan reviewed by user
- [ ] Questions answered
- [ ] **Tasks created for all Steps**
- [ ] **Session ID retrieved via `<session info>`**
- [ ] Ready to implement

---

**Approved**: Yes
**Approval Date**: 2026-02-09
**Tasks Created**: Yes (Tasks #11-#15)
**Session ID**: `01ec606d-edef-40b5-b898-d4e3372b9997`
**Notes**: Plugin 인프라 이미 완료, 남은 작업은 README/command 불일치 수정
