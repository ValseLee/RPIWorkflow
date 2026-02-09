# Research: RPI Workflow를 Claude Plugin으로 배포

> **Date**: 2026-02-09
> **Status**: Complete
> **Project**: RPIWorkflow

## Executive Summary

RPI Workflow는 현재 shell script(`install.sh`)로 수동 설치되는 commands/templates/hooks 번들이다. Claude Code Plugin 시스템은 `.claude-plugin/plugin.json` 매니페스트 기반으로 동작하며, 이미 설치된 `everything-claude-code-ios`, `superpowers` 등의 플러그인 구조를 참조할 수 있다. RPI Workflow는 commands/templates/hooks 분리가 잘 되어 있어 플러그인 변환에 유리하나, 경로 참조 방식 변경, 매니페스트 생성, hooks.json 래퍼 추가가 필요하다.

## Parallel Exploration Results

### 1. Architecture Analysis

**Project Structure:**
```
RPIWorkflow/
├── commands/           # Skill definitions (5 files)
│   ├── research.md     # /rpi:research - 4 Explore Agent 병렬 실행
│   ├── plan.md         # /rpi:plan - 배치 구조 설계 + Task 생성
│   ├── implement.md    # /rpi:implement - Sub-Agent 병렬 실행
│   ├── verify.md       # /rpi:verify - 빌드/테스트 검증
│   └── rule.md         # /rpi:rule - 프로젝트별 규칙 관리
├── templates/          # Document templates (5 + 4 examples)
│   ├── research-template.md
│   ├── plan-template.md
│   ├── rpi-main-template.md
│   ├── verify-template.md
│   ├── rule-template.md
│   └── rules/          # Example rule files
│       ├── architecture-example.md
│       ├── dependencies-example.md
│       ├── patterns-example.md
│       └── testing-example.md
├── hooks/              # Hook scripts (1 file)
│   └── session-info.py # UserPromptSubmit hook
├── install.sh          # 설치 스크립트
├── uninstall.sh        # 제거 스크립트
├── examples/
│   └── examples.md
├── README.md
├── CONTRIBUTING.md
└── LICENSE
```

**Installation Target (현재 방식):**
```
~/.claude/
├── commands/rpi/       # Slash commands (install.sh가 복사)
├── rpi/                # Templates (install.sh가 복사)
├── hooks/rpi/          # Hooks (install.sh가 복사)
└── settings.json       # Hook 등록 (jq로 수정)
```

**Key Patterns:**
- Command 파일: YAML frontmatter(`description`, `allowed-tools`) + Markdown body
- 4-phase 워크플로: Research → Plan → Implement → Verify
- Context 관리: 배치 기반 실행, 40% 초과 시 `/clear` → 재개
- Agent 모드: Classic(Task tool) / Agent Teams(실험적)
- Task 추적: Claude Code TaskCreate/TaskUpdate API 활용

### 2. Similar Feature Analysis (기존 플러그인 구조 분석)

| Plugin | 위치 | 구조 특징 |
|--------|------|-----------|
| everything-claude-code-ios | `~/.claude/plugins/cache/.../1.0.0/` | `.claude-plugin/`, agents/, commands/, contexts/, hooks/, mcp-configs/, rules/, skills/ |
| superpowers | `~/.claude/plugins/cache/.../4.1.1/` | `.claude-plugin/`, agents/, commands/, skills/ |

**Plugin 공통 구조:**
```
plugin-name/
├── .claude-plugin/
│   ├── plugin.json          # 필수: 메타데이터
│   └── marketplace.json     # 마켓플레이스 배포용
├── commands/                # /plugin-name:command 형태
│   └── *.md
├── skills/                  # 각 skill 디렉토리별 SKILL.md
│   └── skill-name/
│       └── SKILL.md
├── agents/                  # Agent 정의
│   └── *.md
├── hooks/                   # hooks.json + 스크립트
│   └── hooks.json
├── rules/                   # 프로젝트 규칙
├── contexts/                # 컨텍스트 파일
├── .mcp.json                # MCP 서버 설정 (선택)
└── README.md
```

**plugin.json 형식:**
```json
{
  "name": "plugin-name",
  "version": "1.0.0",
  "description": "...",
  "author": {"name": "...", "url": "..."},
  "homepage": "...",
  "repository": "...",
  "license": "MIT",
  "keywords": [...]
}
```

**marketplace.json 형식:**
```json
{
  "name": "marketplace-name",
  "owner": {"name": "...", "email": "..."},
  "metadata": {"description": "...", "version": "1.0.0"},
  "plugins": [{"name": "...", "source": "./", "description": "...", "version": "1.0.0"}]
}
```

**설치 레지스트리 (`~/.claude/plugins/installed_plugins.json`):**
```json
{
  "version": 2,
  "plugins": {
    "plugin-name@marketplace": [{
      "scope": "user",
      "installPath": "/path/to/plugin",
      "version": "1.0.0",
      "installedAt": "...",
      "lastUpdated": "...",
      "gitCommitSha": "..."
    }]
  }
}
```

**설정 활성화 (`~/.claude/settings.json`):**
```json
{
  "enabledPlugins": {
    "plugin-name@marketplace-name": true
  }
}
```

### 3. Dependency Analysis

**하드코딩된 경로 (변경 필요):**

| 파일 | 경로 참조 | 변경 방향 |
|------|-----------|-----------|
| `install.sh` | `$HOME/.claude/commands/rpi`, `$HOME/.claude/rpi`, `$HOME/.claude/hooks/rpi` | Plugin 시스템이 대체 |
| `uninstall.sh` | 동일 | Plugin 시스템이 대체 |
| `hooks/session-info.py` | `~/.claude/tasks/<session_id>/`, `<project>/.claude/settings.local.json` | 유지 (Claude Code 내부 경로) |
| `commands/research.md` | `~/.claude/rpi/research-template.md`, `~/.claude/rpi/rpi-main-template.md` | Plugin 리소스 경로로 변경 |
| `commands/plan.md` | `~/.claude/rpi/plan-template.md` | Plugin 리소스 경로로 변경 |
| `commands/verify.md` | `~/.claude/rpi/verify-template.md` | Plugin 리소스 경로로 변경 |
| `commands/rule.md` | `~/.claude/rpi/rule-template.md` | Plugin 리소스 경로로 변경 |

**외부 의존성:**
- `python3` (표준 라이브러리만 사용: json, os, sys, pathlib)
- `bash` (install.sh/uninstall.sh - 플러그인 전환 시 불필요)
- `jq` (선택적, install.sh에서 사용 - 플러그인 전환 시 불필요)
- `git` (브랜치 감지용)

**환경 변수:**
- `CLAUDE_CODE_TASK_LIST_ID` - Task 지속성 (hook이 자동 저장)
- `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` - Agent Teams 모드 (선택)

**Command → Template 참조 체인:**
```
research.md → research-template.md, rpi-main-template.md
plan.md     → plan-template.md
verify.md   → verify-template.md
rule.md     → rule-template.md
```

**Phase 간 문서 참조 체인:**
```
Research → writes research.md, rpi-main.md
Plan     → reads research.md, writes plan.md, updates rpi-main.md
Implement→ reads plan.md, rpi-main.md, updates tasks
Verify   → reads plan.md, rpi-main.md, writes verify.md
```

### 4. Test Structure Analysis

**기존 테스트:** 없음 (자동화된 테스트 파일 없음)

**CI/CD:** 없음 (GitHub Actions 등 미구성)

**수동 테스트 체크리스트** (`CONTRIBUTING.md`):
- `/rpi:research` 테스트 프로젝트에서 실행
- `/rpi:plan` research 출력과 함께 실행
- `/rpi:implement` 태스크 추적 확인
- `/rpi:rule add`, `/rpi:rule list` 테스트
- `/clear` 이후 세션 재개 확인

**Verify Phase (런타임 검증):**
- 프로젝트 타입 자동 감지 (Swift, Node.js, Rust, Go, Python 등)
- 빌드/테스트 명령 실행
- 구현 vs 계획 비교

## Relevant Files

### Core Files (Must Modify)

| File | Purpose | 변경 내용 |
|------|---------|-----------|
| commands/*.md (5 files) | Skill definitions | Template 경로 참조 방식 변경 |
| hooks/session-info.py | Session tracking | Plugin context 경로 처리 검토 |
| README.md | Documentation | Plugin 설치 방법으로 업데이트 |

### Files to Create

| File | Purpose |
|------|---------|
| `.claude-plugin/plugin.json` | Plugin manifest (필수) |
| `.claude-plugin/marketplace.json` | Marketplace 배포 메타데이터 |
| `hooks/hooks.json` | Hook 등록 매니페스트 (install.sh의 jq 대체) |

### Files to Deprecate/Remove

| File | Reason |
|------|--------|
| `install.sh` | Plugin 시스템이 대체 |
| `uninstall.sh` | Plugin 시스템이 대체 |

### Reference Files (Read Only)

| File | Why Relevant |
|------|--------------|
| `~/.claude/plugins/cache/everything-claude-code-ios/.../` | Plugin 구조 참조 모델 |
| `~/.claude/plugins/cache/claude-plugins-official/superpowers/.../` | Plugin 구조 참조 모델 |
| `~/.claude/plugins/installed_plugins.json` | 설치 레지스트리 형식 |
| `~/.claude/settings.json` | enabledPlugins 형식 |

## Existing Patterns

### Plugin Manifest Pattern (from installed plugins)

```json
// .claude-plugin/plugin.json
{
  "name": "rpi-workflow",
  "version": "1.0.0",
  "description": "Research → Plan → Implement: Structured workflow for Claude Code",
  "author": {"name": "ValseLee", "url": "https://github.com/ValseLee"},
  "homepage": "https://github.com/ValseLee/RPIWorkflow",
  "repository": "https://github.com/ValseLee/RPIWorkflow",
  "license": "MIT",
  "keywords": ["workflow", "research", "planning", "implementation", "context-management", "brownfield"]
}
```

### Command Namespace Pattern

기존 플러그인의 commands:
- `everything-claude-code-ios:plan`, `everything-claude-code-ios:swift-review`
- `superpowers:brainstorming`, `superpowers:verification-before-completion`

RPI 플러그인의 commands 예상:
- `rpi-workflow:research`, `rpi-workflow:plan`, `rpi-workflow:implement`, `rpi-workflow:verify`, `rpi-workflow:rule`

**주의**: 현재 `/rpi:research` → 플러그인 후 `/rpi-workflow:research` 또는 별칭 설정 필요

### Hook Registration Pattern (from plugins)

```json
// hooks/hooks.json (everything-claude-code-ios 참조)
{
  "hooks": {
    "UserPromptSubmit": [{
      "matcher": "*",
      "hooks": [{
        "type": "command",
        "command": "${PLUGIN_DIR}/hooks/session-info.py"
      }],
      "description": "RPI session info and auto-save task list ID"
    }]
  }
}
```

## Dependencies

### Internal Dependencies
- `commands/` → `templates/` (template 경로 참조)
- `commands/` → `hooks/` (session-info 트리거 키워드)
- All phases → `docs/rpi/<branch>/rpi-main.md` (상태 추적)

### External Dependencies
- `python3` (표준 라이브러리) - hooks 실행
- `git` - 브랜치 감지
- Claude Code Task API - TaskCreate/TaskUpdate/TaskList/TaskGet
- Claude Code Hooks system - UserPromptSubmit

## Impact Analysis

### Files to Create
1. `.claude-plugin/plugin.json` - Plugin manifest
2. `.claude-plugin/marketplace.json` - Marketplace metadata
3. `hooks/hooks.json` - Hook 등록 매니페스트

### Files to Modify
1. `commands/research.md` - Template 경로 참조 변경
2. `commands/plan.md` - Template 경로 참조 변경
3. `commands/verify.md` - Template 경로 참조 변경
4. `commands/rule.md` - Template 경로 참조 변경
5. `hooks/session-info.py` - Plugin 경로 컨텍스트 검토
6. `README.md` - 설치 가이드 업데이트
7. `CONTRIBUTING.md` - 개발 환경 업데이트

### Files to Deprecate
1. `install.sh` - Plugin 시스템으로 대체 (하위 호환용 유지 가능)
2. `uninstall.sh` - Plugin 시스템으로 대체

### Potential Side Effects
- [ ] Command namespace 변경: `/rpi:*` → `/rpi-workflow:*` (기존 사용자 영향)
- [ ] Template 경로 참조 방식 변경 시 기존 프로젝트 호환성
- [ ] Hook 등록 방식 변경 (settings.json 직접 수정 → hooks.json)
- [ ] 기존 수동 설치 사용자의 마이그레이션 경로

## Constraints Discovered

1. **Plugin manifest 필수**: `.claude-plugin/plugin.json`이 없으면 Plugin으로 인식되지 않음
2. **Command namespace**: Plugin 이름이 command prefix가 됨 (`plugin-name:command`)
3. **Hook 경로**: Plugin 내 hooks는 Plugin root 기준 상대 경로 사용 가능해야 함
4. **Template 접근**: Plugin이 설치된 cache 디렉토리에서 template을 읽을 수 있어야 함
5. **하위 호환성**: install.sh 기반 사용자를 위한 마이그레이션 가이드 필요
6. **Marketplace 배포**: marketplace.json 필요, GitHub repo가 marketplace 역할

## Open Questions

- [ ] Plugin 설치 시 template 파일에 접근하는 정확한 경로 메커니즘은? (commands에서 `~/.claude/rpi/`를 참조하는 부분을 어떻게 plugin cache 경로로 변환?)
- [ ] Command namespace를 `rpi-workflow:*` 대신 `rpi:*`로 유지할 수 있는가?
- [ ] hooks.json에서 plugin root 기준 상대 경로 (`${PLUGIN_DIR}` 등) 변수가 지원되는가?
- [ ] 기존 install.sh 사용자가 plugin으로 마이그레이션할 때 충돌 방지 방법은?
- [ ] marketplace.json의 owner email은 필수인가?
- [ ] Plugin 업데이트 시 사용자의 프로젝트별 docs/ 및 .claude/rules/는 보존되는가?

## Notes

- RPI Workflow는 이미 commands/templates/hooks가 잘 분리되어 있어 Plugin 전환이 비교적 수월함
- 핵심 과제는 template 경로 참조 방식 변경과 hooks 등록 매니페스트화
- 기존 플러그인(everything-claude-code-ios, superpowers)의 구조를 그대로 따르면 됨
- install.sh/uninstall.sh는 하위 호환용으로 유지하되 README에서 Plugin 설치를 권장하는 방향
- 자동화된 테스트가 없으므로 Plugin 전환 후 수동 검증 필요
