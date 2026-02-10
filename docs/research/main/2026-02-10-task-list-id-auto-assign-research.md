# Research: TaskList ID Auto-Assign

> **Date**: 2026-02-10
> **Status**: Complete
> **Project**: RPIWorkflow

## Executive Summary

현재 `CLAUDE_CODE_TASK_LIST_ID`는 `session-info.py` 훅이 TaskCreate 이후 UUID 기반으로 자동 저장한다. 이 기능은 `/rpi:plan` 실행 시 TaskCreate **이전에** RPI 문서 네이밍 규칙(`YYYY-MM-DD-[feature-name]`)으로 ID를 생성하여 `.claude/settings.local.json`의 `env`에 직접 할당하는 것을 목표로 한다.

## Parallel Exploration Results

### 1. Architecture Analysis

**Project Structure:**
- Plugin Metadata: `.claude-plugin/` (plugin.json, marketplace.json)
- Commands (Slash Commands): `commands/` (5개 phase: research, plan, implement, verify, rule)
- Templates: `templates/` (5개 + 4개 rule examples)
- Hooks: `hooks/` (hooks.json, session-info.py)
- Runtime Docs: `docs/[type]/[branch]/` (research, plans, verify, rpi)

**Key Patterns:**

1. Command 파일: YAML frontmatter + Markdown
```yaml
---
description: Brief description
allowed-tools: Read, Write, TaskCreate, ...
---
```

2. Template 참조: `templates/[name]-template.md` 경로 사용
3. Hook 등록: `${CLAUDE_PLUGIN_ROOT}/hooks/session-info.py`
4. 문서 네이밍: `YYYY-MM-DD-[feature-name]-[phase].md`
5. Settings 수정: JSON read → merge → write 패턴 (`session-info.py:52-91`)

**Environment Variables:**
- `CLAUDE_CODE_TASK_LIST_ID`: TaskList 세션 간 유지 (Plan에서 설정, Verify에서 제거)
- `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS`: Agent Teams 모드 활성화

### 2. Similar Feature Analysis

| Similar Feature | Files | Pattern Notes |
|-----------------|-------|---------------|
| Session ID Auto-Save | `hooks/session-info.py:52-91` | Tasks 존재 시 UUID 형태의 session ID를 `settings.local.json`에 저장 |
| Settings JSON Merge | `hooks/session-info.py:66-88` | 기존 settings 보존하며 `env` 키만 추가/갱신 |
| Hook Registration | `hooks/hooks.json` | `UserPromptSubmit` 이벤트에 matcher `*`로 등록 |
| Install Validation | `install.sh:150-187` | 파일 존재 + jq로 JSON 검증 패턴 |
| Verify Cleanup | `commands/verify.md:296-302` | 성공 시 `CLAUDE_CODE_TASK_LIST_ID` 제거 |

**기존 auto-save 코드 (session-info.py):**
```python
def auto_save_session_id():
    tasks = get_tasks()
    if not tasks:
        return False, "no tasks"

    settings = {}
    if settings_path.exists():
        settings = json.load(f)

    if env.get("CLAUDE_CODE_TASK_LIST_ID") == session_id:
        return False, "already saved"

    settings["env"]["CLAUDE_CODE_TASK_LIST_ID"] = session_id
    json.dump(settings, f, indent=2)
```

### 3. Dependency Analysis

**Data Flow (현재):**
```
/rpi:plan → TaskCreate → UserPromptSubmit Hook → session-info.py → auto_save(UUID)
```

**Data Flow (목표):**
```
/rpi:plan → research.md 경로에서 feature name 추출 → YYYY-MM-DD-[feature] ID 생성
         → settings.local.json에 env.CLAUDE_CODE_TASK_LIST_ID 직접 할당
         → TaskCreate (이 ID를 사용)
         → session-info.py 훅은 이미 설정됨을 감지하고 스킵
```

**Impact Scope:**

| File | Change Type | Risk |
|------|-------------|------|
| `commands/plan.md` | Modify | Medium - 핵심 워크플로우 변경 |
| `hooks/session-info.py` | Modify | Medium - 기존 auto-save와 충돌 방지 필요 |
| `templates/plan-template.md` | Modify | Low - 문서 업데이트 |
| `commands/implement.md` | Reference | None - 변수 소비자 |
| `commands/verify.md` | Reference | None - 정리 로직은 포맷 무관 |
| `templates/rpi-main-template.md` | Reference | None - 포맷 호환 |

### 4. Test Structure Analysis

**Test Infrastructure:** 공식 테스트 프레임워크 없음

**현재 검증 방법:**
- Shell 문법 검증: `bash -n install.sh`
- Python 문법 검증: `python3 -m py_compile hooks/session-info.py`
- JSON 검증: `jq empty plugin.json`
- 파일 존재 확인: `install.sh:150-187`
- Self-verification: `session-info.py:94-127` (`verify_tasks()`)
- 수동 체크리스트: `CONTRIBUTING.md:106-116`

**Naming Convention:** 해당 없음 (테스트 파일 없음)

## Relevant Files

### Core Files (Must Modify)

| File | Purpose | Key Patterns |
|------|---------|--------------|
| `commands/plan.md` | Plan phase 워크플로우 정의 | TaskCreate 이전에 ID 할당 로직 추가 필요 (L129-187) |
| `hooks/session-info.py` | Session ID 자동 저장 훅 | RPI 포맷 ID가 이미 설정된 경우 UUID 덮어쓰기 방지 (L52-91) |
| `templates/plan-template.md` | Plan 문서 템플릿 | 자동 ID 할당 관련 문서 업데이트 (L217-227) |

### Reference Files (Read Only)

| File | Why Relevant |
|------|--------------|
| `hooks/hooks.json` | Hook 트리거 방식 참조 |
| `commands/implement.md` | CLAUDE_CODE_TASK_LIST_ID 사용 패턴 참조 (L18, 164, 222) |
| `commands/verify.md` | ID 정리 로직 참조 (L296-302) |
| `templates/rpi-main-template.md` | Task List ID 표시 포맷 참조 (L6) |
| `install.sh` | 설치 스크립트 (변경 불필요) |
| `.claude/settings.local.json` | 대상 파일 (생성/갱신됨) |

## Existing Patterns

### Settings JSON Merge Pattern

```python
# hooks/session-info.py:66-88
settings = {}
if settings_path.exists():
    with open(settings_path) as f:
        settings = json.load(f)

if "env" not in settings:
    settings["env"] = {}
settings["env"]["CLAUDE_CODE_TASK_LIST_ID"] = new_id

settings_path.parent.mkdir(parents=True, exist_ok=True)
with open(settings_path, "w") as f:
    json.dump(settings, f, indent=2)
    f.write("\n")
```

### Naming Conventions

- Documents: `YYYY-MM-DD-[feature-name]-[phase].md` (kebab-case)
- 예: `2026-02-09-claude-plugin-packaging-research.md`
- Feature name 추출: research.md 파일명에서 날짜와 `-research.md` 접미사 제거

## Dependencies

### Internal Dependencies

- `commands/plan.md` → `templates/plan-template.md` (문서 생성)
- `commands/plan.md` → `docs/research/[branch]/*-research.md` (입력)
- `hooks/session-info.py` → `.claude/settings.local.json` (읽기/쓰기)
- `commands/verify.md` → `.claude/settings.local.json` (정리)

### External Dependencies

- Python 3 (hooks 실행)
- `jq` (JSON 검증, 선택적)
- Claude Code TaskList API (`TaskCreate`, `TaskList`, `TaskUpdate`)

## Impact Analysis

### Files to Create

없음 (기존 파일 수정만 필요)

### Files to Modify

1. `commands/plan.md` - TaskCreate 이전에 ID 생성/할당 로직 추가
2. `hooks/session-info.py` - RPI 포맷 ID 감지 시 UUID 덮어쓰기 방지
3. `templates/plan-template.md` - 자동 ID 할당 관련 문서 업데이트

### Potential Side Effects

- [ ] `session-info.py`가 UUID 대신 RPI 포맷 ID가 설정되었을 때 정상 동작 확인
- [ ] 같은 날 여러 feature 작업 시 ID 충돌 가능성 (feature name이 다르므로 낮음)
- [ ] `commands/verify.md` 정리 로직이 새 포맷에서도 작동하는지 확인

## Constraints Discovered

1. **Hook 실행 순서**: `session-info.py`는 모든 `UserPromptSubmit`에서 실행됨 → Plan 명령어에서 ID 설정 후 Hook이 UUID로 덮어쓰지 않도록 해야 함
2. **Feature Name 추출 의존성**: research.md 파일 경로에서 feature name을 추출하므로, `/rpi:plan` 호출 시 research.md 참조가 필수
3. **settings.local.json은 gitignored**: `.gitignore`에 포함되어 있어 프로젝트별 설정이므로 안전
4. **기존 UUID 세션과의 호환**: 이미 UUID로 설정된 기존 세션은 영향 없음 (새 plan부터 적용)

## Open Questions

- [x] Feature name은 어디서 추출할 것인가? → research.md 파일명에서 추출
- [x] 같은 날 동일 feature 이름의 충돌은? → feature name이 고유하므로 낮은 위험
- [ ] `session-info.py`에서 RPI 포맷 ID를 어떻게 감지할 것인가? (정규식 `\d{4}-\d{2}-\d{2}-` 패턴?)
- [ ] Plan 명령 내에서 `settings.local.json`에 직접 쓰는 방식 vs Hook을 통한 방식?

## Notes

- 현재 `CLAUDE_CODE_TASK_LIST_ID`는 UUID 포맷 (`01ec606d-edef-40b5-b898-d4e3372b9997`)
- 새 포맷은 `2026-02-10-task-list-id-auto-assign` 형태 (RPI 문서 네이밍과 동일)
- `plan.md` 명령어 내에서 직접 `settings.local.json`을 수정하는 것이 가장 자연스러운 접근
- Hook 수정은 최소화: 기존 auto-save가 새 포맷 ID를 덮어쓰지 않도록 조건만 추가
