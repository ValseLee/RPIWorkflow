# Research: Remove Legacy Hook System

> **Date**: 2026-02-10
> **Status**: Complete
> **Project**: RPIWorkflow

## Executive Summary

Plan 단계에서 TaskList ID를 직접 생성(`YYYY-MM-DD-feature-name`)하도록 변경된 이후, `hooks/session-info.py` 훅의 핵심 기능(UUID 세션 ID 자동 저장)은 불필요해졌다. 훅의 현재 역할은 RPI 포맷 ID를 UUID 덮어쓰기로부터 보호하는 가드에 불과하며, Plan이 항상 먼저 ID를 설정하므로 이 가드 역시 불필요하다. hooks 디렉토리와 관련 레거시 코드를 제거하고, 설치/제거 스크립트 및 문서를 업데이트해야 한다.

## Parallel Exploration Results

### 1. Architecture Analysis

**Project Structure:**
```
RPIWorkflow/
├── .claude/                    # Claude Code 설정
│   └── settings.local.json     # 로컬 설정 (Task List ID env)
├── .claude-plugin/             # 플러그인 메타데이터
│   ├── plugin.json
│   └── marketplace.json
├── commands/                   # 슬래시 커맨드 정의
│   ├── research.md             # /rpi:research
│   ├── plan.md                 # /rpi:plan (ID 자동 할당 포함)
│   ├── implement.md            # /rpi:implement
│   ├── verify.md               # /rpi:verify (ID 정리 포함)
│   └── rule.md                 # /rpi:rule
├── hooks/                      # ← 제거 대상
│   ├── hooks.json              # 훅 등록 매니페스트
│   ├── session-info.py         # UserPromptSubmit 훅
│   └── __pycache__/            # Python 바이트코드 캐시
├── templates/                  # 문서 템플릿
├── docs/                       # 런타임 RPI 문서 (브랜치별)
├── install.sh                  # 수동 설치 (레거시)
├── uninstall.sh                # 수동 제거 (레거시)
└── README.md
```

**Key Patterns:**
- RPI Workflow: Research → Plan → Implement → Verify 4단계 프로세스
- 플러그인 시스템: `.claude-plugin/plugin.json`이 커맨드, 템플릿, 훅을 등록
- Task List ID 라이프사이클: Plan에서 생성 → Implement에서 사용 → Verify에서 정리

**Hook 시스템 흐름:**
```
UserPromptSubmit 이벤트 발생
  → session-info.py 실행
  → 트리거 키워드 체크 (<session info>, <this session>, <rpi session>)
  → 자동 저장: 태스크 존재 시 UUID를 settings.local.json에 저장
  → RPI 포맷 가드: YYYY-MM-DD-* 패턴이면 덮어쓰기 방지
```

### 2. Similar Feature Analysis

| 기능 | 파일 | 패턴 설명 |
|------|------|-----------|
| Task List ID 자동 할당 (NEW) | `commands/plan.md` (lines 129-166) | research.md 파일명에서 feature name 추출 → `YYYY-MM-DD-feature` ID 생성 → settings.local.json에 직접 기록 |
| Task List ID 자동 저장 (OLD) | `hooks/session-info.py` (lines 53-97) | TaskCreate 후 UUID 세션 ID를 자동으로 settings.local.json에 저장 |
| RPI 포맷 가드 | `hooks/session-info.py` (lines 80-83) | regex `\d{4}-\d{2}-\d{2}-.+`로 RPI 포맷 ID 감지 → UUID 덮어쓰기 방지 |
| ID 정리 | `commands/verify.md` (lines 293-306) | 검증 성공 시 settings.local.json에서 `CLAUDE_CODE_TASK_LIST_ID` 제거 |

**OLD vs NEW 비교:**

| 측면 | OLD (Hook 기반) | NEW (Plan 직접 할당) |
|------|-----------------|---------------------|
| ID 설정 시점 | TaskCreate 이후 | TaskCreate 이전 |
| ID 포맷 | UUID | `YYYY-MM-DD-feature-name` |
| 사용자 액션 | 없음 (훅 자동) | 없음 (Plan 자동) |
| 훅 역할 | 주 설정자 | 보호 가드 (불필요) |

### 3. Dependency Analysis

**Direct Dependencies:**
- `hooks/hooks.json` → `.claude-plugin/plugin.json`에 의해 플러그인 시스템에 등록
- `hooks/session-info.py` → `.claude/settings.local.json` 읽기/쓰기
- `hooks/session-info.py` → `~/.claude/tasks/{session_id}/` 읽기
- `install.sh` → `hooks/*` 파일을 `~/.claude/hooks/rpi/`로 복사

**Impact Scope:**

| File | Change Type | Action | Risk |
|------|-------------|--------|------|
| `hooks/session-info.py` | DELETE | 훅 스크립트 전체 삭제 | Low |
| `hooks/hooks.json` | DELETE | 훅 등록 매니페스트 삭제 | Low |
| `hooks/__pycache__/` | DELETE | Python 캐시 삭제 | Low |
| `install.sh` | MODIFY | 훅 설치/등록 로직 제거 (lines 19, 54, 57, 82-147, 173-184) | Med |
| `uninstall.sh` | MODIFY | 훅 정리 로직 제거 (lines 16, 18, 34-36, 69-91) | Med |
| `README.md` | MODIFY | 훅 관련 섹션 제거/수정 (lines 115, 217-219, 262-263, 394-403, 433-437) | Low |
| `commands/plan.md` | MODIFY | `<session info>` 참조 제거 | Low |
| `templates/plan-template.md` | MODIFY | `<session info>` 참조 제거 | Low |
| `templates/rpi-main-template.md` | CHECK | 자동 할당 문구 유지 (훅 비의존) | Low |
| `docs/research/main/*.md` | DELETE | 이전 feature 관련 히스토리 문서 | Low |
| `docs/plans/main/*.md` | DELETE | 이전 feature 관련 히스토리 문서 | Low |
| `docs/verify/main/*.md` | DELETE | 이전 feature 관련 히스토리 문서 | Low |
| `docs/research/update-docs-test/*.md` | DELETE | 이전 feature 관련 히스토리 문서 | Low |
| `docs/plans/update-docs-test/*.md` | DELETE | 이전 feature 관련 히스토리 문서 | Low |
| `docs/verify/update-docs-test/*.md` | DELETE | 이전 feature 관련 히스토리 문서 | Low |
| `docs/rpi/main/rpi-main.md` | DELETE | 이전 세션 상태 문서 | Low |
| `docs/rpi/update-docs-test/rpi-main.md` | DELETE | 이전 세션 상태 문서 | Low |

### 4. Test Structure Analysis

**Test Location:** 없음 - 프로젝트에 공식 테스트 인프라가 없음

**현재 검증 방법:**
```bash
# 구문 검증만 수행
python3 -m py_compile hooks/session-info.py
bash -n install.sh
jq empty hooks/hooks.json
```

**CONTRIBUTING.md 체크리스트 (lines 106-116):**
- JSON 유효성, Python 구문, Shell 구문 수동 검증
- 자동화된 테스트 스위트 없음

## Relevant Files

### Core Files (Must Modify/Delete)

| File | Purpose | Action |
|------|---------|--------|
| `hooks/session-info.py` | UserPromptSubmit 훅 스크립트 | DELETE |
| `hooks/hooks.json` | 훅 등록 매니페스트 | DELETE |
| `hooks/__pycache__/` | Python 바이트코드 캐시 | DELETE |
| `install.sh` | 수동 설치 스크립트 | MODIFY - 훅 관련 로직 제거 |
| `uninstall.sh` | 수동 제거 스크립트 | MODIFY - 훅 관련 로직 제거 |
| `README.md` | 프로젝트 문서 | MODIFY - 훅 섹션 제거 |
| `commands/plan.md` | Plan 커맨드 정의 | MODIFY - `<session info>` 참조 제거 |
| `templates/plan-template.md` | Plan 문서 템플릿 | MODIFY - `<session info>` 참조 제거 |

### Reference Files (Read Only)

| File | Why Relevant |
|------|--------------|
| `commands/verify.md` | ID 정리 로직 확인 (훅 비의존, 수정 불필요) |
| `commands/implement.md` | ID 사용 패턴 확인 (훅 비의존, 수정 불필요) |
| `.claude-plugin/plugin.json` | 플러그인 매니페스트에 hooks 참조 여부 확인 |
| `CONTRIBUTING.md` | 검증 가이드에 훅 관련 항목 확인 |

### Historical Docs (Delete)

| File | Reason |
|------|--------|
| `docs/research/main/2026-02-10-task-list-id-auto-assign-research.md` | 완료된 feature 히스토리 |
| `docs/plans/main/2026-02-10-task-list-id-auto-assign-plan.md` | 완료된 feature 히스토리 |
| `docs/verify/main/2026-02-10-task-list-id-auto-assign-verify.md` | 완료된 feature 히스토리 |
| `docs/research/main/2026-02-09-claude-plugin-packaging-research.md` | 완료된 feature 히스토리 |
| `docs/plans/main/2026-02-09-claude-plugin-packaging-plan.md` | 완료된 feature 히스토리 |
| `docs/verify/main/2026-02-09-claude-plugin-packaging-verify.md` | 완료된 feature 히스토리 |
| `docs/research/update-docs-test/2026-02-10-docs-update-research.md` | 완료된 feature 히스토리 |
| `docs/plans/update-docs-test/2026-02-10-docs-update-plan.md` | 완료된 feature 히스토리 |
| `docs/verify/update-docs-test/2026-02-10-docs-update-verify.md` | 완료된 feature 히스토리 |
| `docs/rpi/main/rpi-main.md` | 이전 세션 상태 |
| `docs/rpi/update-docs-test/rpi-main.md` | 이전 세션 상태 |

## Existing Patterns

### Task List ID 라이프사이클 패턴

```
Plan 단계:
  1. research.md 경로에서 feature name 추출
  2. YYYY-MM-DD-feature-name 형식 ID 생성
  3. settings.local.json에 기록
  4. TaskCreate로 태스크 생성

Implement 단계:
  - settings.local.json의 CLAUDE_CODE_TASK_LIST_ID 환경변수로 자동 로드
  - /clear 후에도 지속

Verify 단계 (성공 시):
  - settings.local.json에서 CLAUDE_CODE_TASK_LIST_ID 제거
  - 다음 RPI 사이클과의 충돌 방지
```

### 설치/제거 스크립트 패턴

- `install.sh`: 커맨드 → 템플릿 → 훅 순서로 설치, jq로 settings.json 머지
- `uninstall.sh`: 역순으로 제거, jq로 settings.json에서 훅 항목 제거
- 두 스크립트 모두 "Legacy (manual installation)" 마킹됨

## Dependencies

### Internal Dependencies

- `commands/plan.md` → `settings.local.json` 직접 쓰기 (훅 불필요)
- `commands/verify.md` → `settings.local.json` 직접 정리 (훅 불필요)
- `install.sh` → `hooks/*` 파일 복사 및 등록 (제거 대상)
- `uninstall.sh` → `~/.claude/hooks/rpi/` 정리 (제거 대상)

### External Dependencies

- Python 3.7+ (session-info.py 실행에만 필요, 제거 후 불필요)
- jq (install.sh/uninstall.sh에서 JSON 머지에 사용, 훅 등록 부분만 영향)

## Impact Analysis

### Files to Delete

1. `hooks/` 디렉토리 전체 (session-info.py, hooks.json, __pycache__)
2. `docs/` 하위 히스토리 문서 (research/plans/verify/rpi 하위 이전 브랜치 문서들)

### Files to Modify

1. `install.sh` - 훅 설치/등록 로직 제거
2. `uninstall.sh` - 훅 정리 로직 제거
3. `README.md` - 훅 관련 섹션 제거, 구조도 업데이트
4. `commands/plan.md` - `<session info>` 참조 제거
5. `templates/plan-template.md` - `<session info>` 참조 제거
6. `CONTRIBUTING.md` - 훅 관련 검증 항목 확인 후 제거

### Potential Side Effects

- [x] 훅 제거 시 Plan 이전에 수동으로 TaskCreate하는 경우 UUID 자동 저장 안됨 → RPI 워크플로우에서는 발생하지 않는 시나리오
- [x] `<session info>` 트리거 키워드 사용 불가 → 대안: TaskList 직접 사용 또는 settings.local.json 읽기
- [x] 플러그인 시스템이 hooks.json 없음을 에러로 처리할 가능성 → 확인 필요

## Constraints Discovered

1. **Plugin System 호환성**: `.claude-plugin/plugin.json`이 `hooks/hooks.json`을 참조하는지 확인 필요. 플러그인 매니페스트에서 hooks 필드가 필수인지 선택인지 확인해야 함.

2. **install.sh/uninstall.sh 레거시 유지**: 이 스크립트들은 "Legacy (manual installation)"으로 마킹되어 있으나, 플러그인 미지원 환경을 위해 유지됨. 훅 부분만 제거해야 하며 전체 스크립트를 삭제하면 안됨.

3. **docs/ 히스토리 문서 정책**: 완료된 feature의 research/plan/verify 문서를 삭제할지 아카이브할지 결정 필요. .gitignore에 추가하는 방법도 있으나, 이미 커밋된 상태이므로 삭제가 깔끔함.

## Open Questions

- [ ] `.claude-plugin/plugin.json`에서 hooks 필드가 필수인지 선택인지? (hooks 디렉토리 삭제 시 플러그인 로드 실패 가능성)
- [ ] 완료된 feature의 docs/ 히스토리 문서(research, plans, verify, rpi)를 일괄 삭제할 것인지? (레거시 정리 범위)
- [ ] `CONTRIBUTING.md`에 훅 관련 검증 항목이 있는지? (있다면 함께 수정)

## Notes

- 현재 브랜치: `update/remove-legacy-hook` (main에서 분기, 아직 변경 없음)
- Hook 시스템은 2026-02-06에 도입되어 2026-02-10에 가드 역할로 전환된 단기 레거시
- Git history에서 훅 관련 주요 커밋: `819f836`, `26394fe`, `e74e726`, `522023d`, `7465bc8`
