# Plan: RPI Workflow Documentation Update

> **Date**: 2026-02-10
> **Status**: Approved
> **Research**: `docs/research/update-docs-test/2026-02-10-docs-update-research.md`

## Objective

README.md와 관련 문서를 업데이트하여 Task List ID Auto-Assign 기능 반영, Hook 시스템 문서화, 한영 혼용 정리, Troubleshooting 가이드 추가, Requirements 보완을 완료한다.

## Prerequisites

- [x] Research document reviewed
- [x] Open questions resolved (P0/P1 항목 확정)
- [x] Dependencies available

## Batch Design

> Research에서 도출된 22개 항목 중 P0-P1 (7개)를 중심으로 구성.
> P2 항목(CHANGELOG, GitHub 템플릿)은 별도 RPI 사이클로 분리.

## Implementation Steps

### Batch 1: README.md Core Updates [Complexity: Medium]

#### Step 1: Update Usage Section - Remove Manual Export

**File**: `README.md`
**Action**: Modify

**Changes**:
- Lines 175-176: `export CLAUDE_CODE_TASK_LIST_ID="[id from TaskList]"` 제거
- Step 4 설명을 "Plan phase에서 Task List ID가 자동 할당됩니다" 로 교체
- Step numbering 재정리 (5개 → 4개 스텝)

**Verification**:
- [ ] Usage section에 `export CLAUDE_CODE_TASK_LIST_ID` 없음
- [ ] 스텝 순서가 자연스러움

---

#### Step 2: Update Task Persistence Section

**File**: `README.md`
**Action**: Modify

**Changes**:
- Lines 384-389: 수동 export 안내를 자동 할당 설명으로 교체
- Auto-assign 동작 설명 추가 (Plan phase → settings.local.json)
- Hook guard 설명 간략 추가

**Verification**:
- [ ] Task Persistence 섹션이 auto-assign을 정확히 설명
- [ ] 수동 export 안내 제거됨

---

#### Step 3: Add Hook System Documentation

**File**: `README.md`
**Action**: Modify

**Changes**:
- Key Concepts 섹션에 "Session Management Hook" 서브섹션 추가
- session-info.py 기능 설명: auto-save, trigger keywords, RPI format guard
- 트리거 키워드 목록: `<session info>`, `<this session>`, `<rpi session>`

**Verification**:
- [ ] Hook 설명이 README Key Concepts에 존재
- [ ] session-info.py 동작이 정확히 기술됨

---

#### Step 4: Update Requirements Section

**File**: `README.md`
**Action**: Modify

**Changes**:
- Python 3.7+ 추가 (hooks/session-info.py 실행용)
- 선택사항으로 jq 추가 (install.sh에서 사용)

**Verification**:
- [ ] Requirements에 Python 3.7+ 명시
- [ ] jq가 optional로 표기됨

---

#### Step 5: Standardize Korean/English in Usage Examples

**File**: `README.md`
**Action**: Modify

**Changes**:
- Line 165: 한국어 코멘트를 영어로 교체 또는 영어 대안 병기
- Line 172: 동일 처리
- 패턴: `# "Start RPI research for [feature]"` (영어 우선)

**Verification**:
- [ ] Usage 예시가 영어 우선으로 통일
- [ ] 한국어 대안이 필요 시 주석으로 병기

---

**Batch 1 Checkpoint**:
- [ ] README.md 마크다운 렌더링 정상
- [ ] Mermaid diagram 영향 없음
- [ ] 내부 링크 정상

---

### Batch 2: Supporting Documents Update [Complexity: Low]

#### Step 6: Update examples/examples.md - Remove Manual Export

**File**: `examples/examples.md`
**Action**: Modify

**Changes**:
- Lines 209-213: Quick Reference의 `export CLAUDE_CODE_TASK_LIST_ID` 제거
- Lines 217-219: Context Management의 "Tasks persist if env var is set" 업데이트
- Session 2: Plan 예시에 auto-assign 언급 추가

**Verification**:
- [ ] examples.md에 수동 export 참조 없음
- [ ] Auto-assign이 자연스럽게 언급됨

---

#### Step 7: Update templates/rpi-main-template.md - Quick Resume

**File**: `templates/rpi-main-template.md`
**Action**: Modify

**Changes**:
- Quick Resume 섹션에서 `export CLAUDE_CODE_TASK_LIST_ID` 제거
- "Task List ID는 Plan 단계에서 자동 할당되어 settings.local.json에 저장됩니다" 안내로 교체

**Verification**:
- [ ] Quick Resume에 수동 export 없음
- [ ] 자동 할당 안내 존재

---

#### Step 8: Add Troubleshooting Section to README

**File**: `README.md`
**Action**: Modify

**Changes**:
- Requirements 섹션 아래에 Troubleshooting 섹션 추가
- 항목: Tasks not persisting, Hook not running, Context overflow, Plugin install issues

**Verification**:
- [ ] Troubleshooting 섹션이 README에 존재
- [ ] 최소 4개 FAQ 항목 포함

---

**Batch 2 Checkpoint**:
- [ ] 모든 수정 파일 마크다운 렌더링 정상
- [ ] README ↔ examples ↔ templates 간 일관성 확인

---

## Checkpoints

| After Batch | Verification | Expected Result |
|-------------|--------------|-----------------|
| Batch 1 | README.md 렌더링 확인 | Mermaid 정상, 링크 정상 |
| Batch 2 | Cross-reference 확인 | 3개 파일 간 일관성 |
| Final | 전체 검토 | 수동 export 참조 0건 |

## Test Plan

### Manual Testing

1. [ ] README.md를 GitHub preview로 렌더링 확인
2. [ ] `export CLAUDE_CODE_TASK_LIST_ID` 문자열이 README, examples, template에서 제거 확인
3. [ ] Hook 설명이 session-info.py 실제 동작과 일치하는지 대조
4. [ ] Troubleshooting 항목이 실제 도움이 되는지 검토
5. [ ] 한영 혼용이 정리되었는지 Usage 섹션 확인

## Rollback Plan

If implementation fails:

1. Revert files: `README.md`, `examples/examples.md`, `templates/rpi-main-template.md`
2. `git checkout -- README.md examples/examples.md templates/rpi-main-template.md`

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| 기존 북마크/링크 깨짐 | Low | Low | 섹션 이름 최소 변경 |
| Mermaid 호환성 이슈 | Low | Medium | 기존 diagram 구조 유지 |
| 한국어 제거로 사용자 혼란 | Low | Low | 영어 우선 + 한국어 주석 병기 |

## Task Registration

### Task Creation Summary

| Task | Step | File | Parallel | blockedBy |
|------|------|------|----------|-----------|
| 1 | Step 1: Update Usage Section | README.md | No | - |
| 2 | Step 2: Update Task Persistence | README.md | No | 1 |
| 3 | Step 3: Add Hook Documentation | README.md | No | 2 |
| 4 | Step 4: Update Requirements | README.md | No | 3 |
| 5 | Step 5: Standardize i18n in Usage | README.md | No | 4 |
| 6 | Step 6: Update examples.md | examples/examples.md | Yes | 5 |
| 7 | Step 7: Update rpi-main-template | templates/rpi-main-template.md | Yes | 5 |
| 8 | Step 8: Add Troubleshooting | README.md | No | 5 |

> Batch 1 (Steps 1-5): Sequential — 동일 파일(README.md) 수정이므로 순차 실행
> Batch 2 (Steps 6-8): Steps 6, 7은 병렬 가능 (서로 다른 파일). Step 8은 README.md 수정이나 Batch 1 완료 후 별도 섹션 추가이므로 Steps 6, 7과 병렬 가능

## Approval

- [ ] Plan reviewed by user
- [ ] Questions answered
- [ ] **Tasks created for all Steps**
- [ ] **Task List ID auto-assigned (check settings.local.json)**
- [ ] Ready to implement

---

**Approved**: Yes
**Approval Date**: 2026-02-10
**Tasks Created**: Yes (8 tasks, IDs #1-#8)
**Task List ID**: 2026-02-10-docs-update
**Notes**: P2 항목(CHANGELOG, GitHub 템플릿 등)은 별도 RPI 사이클로 분리

---

## Task List ID (AUTO-ASSIGNED)

Task List ID is **automatically assigned** at the start of Plan phase, before Tasks are created.

- **Format**: `YYYY-MM-DD-[feature-name]` (from research.md filename)
- **Location**: `.claude/settings.local.json` → `env.CLAUDE_CODE_TASK_LIST_ID`
- **Persistence**: Survives `/clear` — no manual saving required

To verify: type `<session info>` to see the current Task List ID.
