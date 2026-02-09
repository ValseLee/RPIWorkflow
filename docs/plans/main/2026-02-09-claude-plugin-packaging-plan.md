# Plan: RPI Workflow를 Claude Plugin으로 배포

> **Date**: 2026-02-09
> **Status**: Draft
> **Research**: `docs/research/main/2026-02-09-claude-plugin-packaging-research.md`

## Objective

RPI Workflow를 Claude Code Plugin 시스템으로 패키징하여 `claude plugin install` 명령으로 설치 가능하게 변환한다.

## Prerequisites

- [x] Research document reviewed
- [x] Open questions resolved (plugin path mechanism: `${CLAUDE_PLUGIN_ROOT}` 확인)
- [x] Dependencies available (기존 플러그인 구조 참조 가능)

## Key Discovery: Path Resolution

Research의 Open Questions 해결:
- **Template 경로**: Commands에서 `~/.claude/rpi/` 대신 plugin 내부 `templates/` 디렉토리를 직접 참조
  - Plugin commands는 별도 경로 변환 불필요 (commands/*.md 내 텍스트 참조만 변경)
  - Claude가 template을 읽을 때 plugin root 기준 상대 경로 사용
- **Hook 경로**: `${CLAUDE_PLUGIN_ROOT}/hooks/session-info.py` (hooks.json에서 사용)
- **Command namespace**: plugin.json의 `name` 필드가 prefix가 됨 → `rpi` 이름 사용 시 `/rpi:research` 유지 가능

## Batch Design

> 총 3 Batches, 10 Steps

## Implementation Steps

### Batch 1: Plugin Infrastructure [Complexity: High]

Plugin으로 인식되기 위한 필수 파일 생성

#### Step 1: Create plugin.json

**File**: `.claude-plugin/plugin.json`
**Action**: Create

**Changes**:
```json
{
  "name": "rpi",
  "version": "1.0.0",
  "description": "Research → Plan → Implement: Structured workflow for Claude Code",
  "author": {"name": "ValseLee", "url": "https://github.com/ValseLee"},
  "homepage": "https://github.com/ValseLee/RPIWorkflow",
  "repository": "https://github.com/ValseLee/RPIWorkflow",
  "license": "MIT",
  "keywords": ["workflow", "research", "planning", "implementation", "context-management", "brownfield"]
}
```

**Verification**:
- [ ] `.claude-plugin/plugin.json` 존재 및 valid JSON
- [ ] `name` 필드가 `rpi` (namespace 유지)

---

#### Step 2: Create marketplace.json

**File**: `.claude-plugin/marketplace.json`
**Action**: Create

**Changes**:
```json
{
  "name": "rpi-workflow",
  "owner": {"name": "ValseLee"},
  "metadata": {
    "description": "Research → Plan → Implement: Structured workflow for Claude Code",
    "version": "1.0.0"
  },
  "plugins": [{
    "name": "rpi",
    "source": "./",
    "description": "Research → Plan → Implement: Structured workflow for Claude Code",
    "version": "1.0.0"
  }]
}
```

**Verification**:
- [ ] `.claude-plugin/marketplace.json` 존재 및 valid JSON

---

#### Step 3: Create hooks.json

**File**: `hooks/hooks.json`
**Action**: Create

**Changes**:
```json
{
  "hooks": {
    "UserPromptSubmit": [{
      "matcher": "*",
      "hooks": [{
        "type": "command",
        "command": "${CLAUDE_PLUGIN_ROOT}/hooks/session-info.py"
      }],
      "description": "RPI session info and auto-save task list ID"
    }]
  }
}
```

**Verification**:
- [ ] `hooks/hooks.json` 존재 및 valid JSON
- [ ] `${CLAUDE_PLUGIN_ROOT}` 변수 사용 확인

---

**Batch 1 Checkpoint**:
- [ ] 3개 매니페스트 파일 모두 valid JSON
- [ ] Plugin 디렉토리 구조 확인

---

### Batch 2: Command Template Path Migration [Complexity: Medium]

Commands에서 `~/.claude/rpi/` 경로를 plugin 내부 `templates/` 경로로 변경

#### Step 4: Update research.md template references

**File**: `commands/research.md`
**Action**: Modify

**Changes**:
- `~/.claude/rpi/research-template.md` → `templates/research-template.md` (plugin root 기준)
- `~/.claude/rpi/rpi-main-template.md` → `templates/rpi-main-template.md` (plugin root 기준)

**Verification**:
- [ ] `~/.claude/rpi/` 경로 참조 없음
- [ ] `templates/` 기준 경로로 변경됨

---

#### Step 5: Update plan.md template reference

**File**: `commands/plan.md`
**Action**: Modify

**Changes**:
- `~/.claude/rpi/plan-template.md` → `templates/plan-template.md`

**Verification**:
- [ ] `~/.claude/rpi/` 경로 참조 없음

---

#### Step 6: Update verify.md template reference

**File**: `commands/verify.md`
**Action**: Modify

**Changes**:
- `~/.claude/rpi/verify-template.md` → `templates/verify-template.md`

**Verification**:
- [ ] `~/.claude/rpi/` 경로 참조 없음

---

#### Step 7: Update rule.md template reference

**File**: `commands/rule.md`
**Action**: Modify

**Changes**:
- `~/.claude/rpi/rule-template.md` → `templates/rule-template.md`

**Verification**:
- [ ] `~/.claude/rpi/` 경로 참조 없음

---

**Batch 2 Checkpoint**:
- [ ] `grep -r "~/.claude/rpi/" commands/` 결과 없음
- [ ] 모든 template 참조가 `templates/` 기준

---

### Batch 3: Documentation & Cleanup [Complexity: Low]

README 업데이트, install.sh/uninstall.sh 정리, rpi-main.md 갱신

#### Step 8: Update README.md

**File**: `README.md`
**Action**: Modify

**Changes**:
- Installation 섹션: Plugin 설치 방법을 primary로 변경
  ```bash
  # Plugin 설치 (권장)
  claude plugin install github:ValseLee/RPIWorkflow

  # 기존 방식 (호환용)
  git clone ... && ./install.sh
  ```
- Project Structure 섹션: Plugin 구조 반영
- Usage 섹션: `/rpi:research` 등 namespace 유지 설명
- Manual Install의 hooks 설정 추가 (install.sh가 처리하던 부분)

**Verification**:
- [ ] Plugin 설치 방법이 첫 번째로 표시
- [ ] 기존 install.sh 방식도 하위 호환으로 남아있음

---

#### Step 9: Deprecate install.sh / uninstall.sh

**File**: `install.sh`, `uninstall.sh`
**Action**: Modify

**Changes**:
- 두 파일 상단에 deprecation notice 추가:
  ```bash
  echo "⚠️  Note: Plugin installation is now recommended."
  echo "   Run: claude plugin install github:ValseLee/RPIWorkflow"
  echo "   This script is maintained for backward compatibility."
  echo ""
  ```
- 기존 기능은 그대로 유지 (하위 호환)

**Verification**:
- [ ] Deprecation 메시지 표시 확인
- [ ] 기존 기능 정상 동작 유지

---

#### Step 10: Update rpi-main.md

**File**: `docs/rpi/main/rpi-main.md`
**Action**: Modify

**Changes**:
- Plan status: Approved
- Session ID 기록
- Current Session: Implement

**Verification**:
- [ ] Plan document status가 Approved

---

**Batch 3 Checkpoint**:
- [ ] README에 Plugin 설치 방법 포함
- [ ] install.sh에 deprecation notice 추가
- [ ] rpi-main.md 업데이트됨

---

## Checkpoints

| After Batch | Verification | Expected Result |
|-------------|--------------|-----------------|
| Batch 1 | JSON validation | All 3 manifests valid |
| Batch 2 | grep for old paths | No `~/.claude/rpi/` in commands/ |
| Final | Manual `/rpi:research` test | Plugin commands work correctly |

## Test Plan

### Manual Testing

1. [ ] Plugin 구조 검증: `.claude-plugin/plugin.json` 존재 확인
2. [ ] Hook 등록 검증: `hooks/hooks.json` valid, `${CLAUDE_PLUGIN_ROOT}` 사용
3. [ ] Template 경로 검증: `grep -r "~/.claude/rpi/" commands/` 결과 없음
4. [ ] 기존 install.sh 실행 시 deprecation notice 표시 후 정상 동작
5. [ ] README에 Plugin 설치 가이드 포함 확인

### Post-Deploy Testing (Plugin 설치 후)

1. [ ] `claude plugin install` 로 설치
2. [ ] `/rpi:research` 실행 → 4 agent 병렬 실행
3. [ ] `/rpi:plan` 실행 → template 정상 로딩
4. [ ] Hook 자동 등록 → `<session info>` 트리거
5. [ ] `/rpi:rule list` 실행 → template 경로 정상

## Rollback Plan

If implementation fails:

1. Revert command files: `commands/research.md`, `commands/plan.md`, `commands/verify.md`, `commands/rule.md`
2. Remove new files: `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`, `hooks/hooks.json`
3. Revert install.sh, uninstall.sh (remove deprecation notice)

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Template 경로 변경으로 기존 설치 사용자 break | Medium | Medium | install.sh 하위 호환 유지, 두 경로 모두 문서화 |
| Command namespace 변경 (`/rpi:*` → `/rpi-workflow:*`) | Low | High | plugin.json name을 `rpi`로 설정하여 namespace 유지 |
| hooks.json `${CLAUDE_PLUGIN_ROOT}` 미지원 | Low | High | 기존 플러그인에서 동일 패턴 사용 중 확인됨 |
| marketplace.json 형식 오류 | Low | Low | 기존 플러그인 형식 그대로 복사 |

## Task Registration

### Parallel Analysis

| Step | Batch | Parallel? | blockedBy |
|------|-------|-----------|-----------|
| 1 (plugin.json) | 1 | Yes | - |
| 2 (marketplace.json) | 1 | Yes | - |
| 3 (hooks.json) | 1 | Yes | - |
| 4 (research.md) | 2 | Yes | - |
| 5 (plan.md) | 2 | Yes | - |
| 6 (verify.md) | 2 | Yes | - |
| 7 (rule.md) | 2 | Yes | - |
| 8 (README.md) | 3 | Yes | - |
| 9 (install/uninstall) | 3 | Yes | - |
| 10 (rpi-main.md) | 3 | No | All above |

**Total**: 10 tasks, 3 batches
**Parallel opportunities**: Batch 1 (3 parallel), Batch 2 (4 parallel), Batch 3 (2 parallel + 1 sequential)

---

## Approval

- [ ] Plan reviewed by user
- [ ] Questions answered
- [ ] **Tasks created for all Steps**
- [ ] **Session ID retrieved via `<session info>`**
- [ ] Ready to implement

---

**Approved**: Pending
**Approval Date**: -
**Tasks Created**: No
**Session ID**: -
**Notes**: -
