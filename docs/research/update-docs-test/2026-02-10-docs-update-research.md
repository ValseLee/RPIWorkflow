# Research: RPI Workflow Documentation Update

> **Date**: 2026-02-10
> **Status**: Complete
> **Project**: RPIWorkflow

## Executive Summary

RPI Workflow의 README.md와 각 단계(Research/Plan/Implement/Verify/Rule) 문서를 전수 조사한 결과, 최근 구현된 Task List ID Auto-Assign 기능이 README에 반영되지 않은 것이 가장 큰 Gap이며, 한국어/영어 혼용 예시 정리, Troubleshooting 가이드 부재, Hook 시스템 미문서화, CHANGELOG 부재 등 총 22개 개선 항목을 도출했다.

## Parallel Exploration Results

### 1. Architecture Analysis

**Project Structure:**
```
RPIWorkflow/
├── .claude-plugin/
│   ├── plugin.json            # Plugin manifest (name: "rpi", v1.0.0)
│   └── marketplace.json       # Marketplace metadata (owner: CelanLee)
├── commands/                  # 5 slash command definitions
│   ├── research.md            # /rpi:research (353 lines, 2 execution modes)
│   ├── plan.md                # /rpi:plan (219 lines, auto-assign feature)
│   ├── implement.md           # /rpi:implement (251 lines, sub-agent execution)
│   ├── verify.md              # /rpi:verify (370 lines, 9+ project type detection)
│   └── rule.md                # /rpi:rule (166 lines, 4 rule types)
├── hooks/
│   ├── hooks.json             # UserPromptSubmit hook registration
│   └── session-info.py        # Auto-save session ID + RPI format guard (187 lines)
├── templates/                 # 5 templates + 4 rule examples
│   ├── rpi-main-template.md   # Session tracking (49 lines)
│   ├── research-template.md   # 4-agent findings (140 lines)
│   ├── plan-template.md       # Batch structure + tasks (219 lines)
│   ├── verify-template.md     # Validation report (107 lines)
│   ├── rule-template.md       # Project rules (46 lines)
│   └── rules/                 # Example rules (architecture, patterns, dependencies, testing)
├── examples/
│   └── examples.md            # 3 workflow examples + recovery (220 lines)
├── docs/                      # Living documents from past RPI sessions
├── install.sh                 # Legacy manual installation
├── uninstall.sh               # Legacy manual uninstallation
├── README.md                  # Main documentation (416 lines)
├── CONTRIBUTING.md            # Contribution guidelines
└── LICENSE                    # MIT License
```

**Key Patterns:**
- YAML frontmatter in command files (`description`, `allowed-tools`)
- Template placeholder system (`[feature-name]`, `YYYY-MM-DD`, `[branch-name]`)
- Branch-based output directories (`docs/{type}/[branch]/`)
- Consistent Red Flags sections in all command files

### 2. Similar Feature Analysis

| Document Type | Location | Pattern Notes |
|---------------|----------|---------------|
| README.md | `/README.md` (416 lines) | Mermaid diagrams, dual install methods, Key Concepts section |
| examples.md | `/examples/examples.md` (220 lines) | 3 scenarios (bug fix, new feature, refactoring) + recovery |
| CONTRIBUTING.md | `/CONTRIBUTING.md` | Conventional commits, manual testing checklist |
| Past Research | `docs/research/main/` | 3 research docs exist from previous sessions |
| Past Plans | `docs/plans/main/` | 2 plan docs exist |
| Past Verify | `docs/verify/main/` | 2 verify reports exist |
| rpi-main.md | `docs/rpi/main/rpi-main.md` | Living status tracker with session history |

**Reference Patterns from Past Docs:**
- `2026-02-10-task-list-id-auto-assign-research.md`: 한영 혼용, 4개 에이전트 결과 구조화
- `2026-02-10-task-list-id-auto-assign-plan.md`: Before/after 코드 블록, 3개 태스크 모두 병렬

### 3. Dependency Analysis

**README.md와 실제 구현의 차이점 (Discrepancies):**

| Area | README Claims | Actual State | Gap |
|------|--------------|-------------|-----|
| Task Persistence | `export CLAUDE_CODE_TASK_LIST_ID="[id]"` (수동) | Plan 단계에서 자동 할당 (YYYY-MM-DD-[feature]) | **Critical** |
| Usage Step 4 | `export CLAUDE_CODE_TASK_LIST_ID="[id from TaskList]"` | 자동 할당으로 export 불필요 | **Critical** |
| Hook System | 언급 없음 | session-info.py가 매 프롬프트마다 실행, `<session info>` 트리거 | **High** |
| Plugin Install | `/plugin install rpi@rpi-workflow` | plugin.json name = "rpi", marketplace = "rpi-workflow" | **Medium** |
| Korean Text | Usage 예시에 한국어 포함 (line 165, 172) | 영어 대안 없음 | **Medium** |
| Troubleshooting | 없음 | 사용자 문의 시 대응 불가 | **High** |
| CHANGELOG | 없음 | Git 히스토리만 존재 | **Medium** |
| Requirements | Claude Code + Git만 명시 | Python 3.7+ (hooks), jq (optional) 필요 | **Medium** |

**Direct Dependencies (README 업데이트 시 함께 수정 필요):**
- `README.md` → Usage section (lines 152-185)
- `README.md` → Task Persistence section (lines 384-389)
- `README.md` → Key Concepts 전체 review
- `examples/examples.md` → 수동 export 예시 제거 필요
- `templates/rpi-main-template.md` → Quick Resume의 export 안내 검토

### 4. Test Structure Analysis

**Documentation Quality Testing Approach:**

프로젝트에 자동화된 테스트 프레임워크는 없으며, 문서 품질 검증은 아래 방식으로 수행:

| Test Type | Method | Notes |
|-----------|--------|-------|
| Markdown 렌더링 | GitHub preview, VS Code preview | Mermaid diagram 호환성 확인 |
| Cross-reference 검증 | 수동 경로 대조 | Template → Command → README 경로 일치 여부 |
| Mermaid Diagram Safety | `---title---` syntax 호환성 | 일부 플랫폼에서 미렌더링 가능 |
| Link 검증 | Dead link 검사 | examples/ 참조, LICENSE 참조 |
| i18n 일관성 | 한영 혼용 패턴 확인 | Usage section 한국어 예시 |

**기존 검증 패턴 (docs/verify/main/):**
- `2026-02-09-claude-plugin-packaging-verify.md`: 빌드/테스트 없이 파일 존재 확인으로 검증
- `2026-02-10-task-list-id-auto-assign-verify.md`: Python syntax + JSON validity + 수동 테스트

## Relevant Files

### Core Files (Must Modify)

| File | Purpose | Key Changes Needed |
|------|---------|-------------------|
| `README.md` | 메인 문서 | Auto-assign 반영, Usage 업데이트, Hook 문서화, 한영 정리 |
| `examples/examples.md` | 워크플로우 예시 | 수동 export 제거, auto-assign 반영 |
| `templates/rpi-main-template.md` | 세션 추적 | Quick Resume export 안내 검토 |

### Reference Files (Read Only)

| File | Why Relevant |
|------|--------------|
| `commands/plan.md` | Auto-assign 구현 확인 (lines 129-166) |
| `hooks/session-info.py` | Hook 동작 확인, RPI format guard |
| `hooks/hooks.json` | Hook 등록 방식 확인 |
| `templates/plan-template.md` | Auto-assign 섹션 (lines 210-218) |
| `.claude-plugin/plugin.json` | Plugin 설치 명령어 검증 |
| `.claude-plugin/marketplace.json` | Marketplace 메타데이터 검증 |
| `docs/rpi/main/rpi-main.md` | 기존 rpi-main 패턴 참고 |

## Existing Patterns

### Architecture Pattern
- YAML frontmatter → Sections → Exit Conditions → Red Flags (command files)
- Metadata header → Content → Notes (template files)
- Mermaid diagrams for workflows (README, command files)

### Naming Conventions
- Files: `YYYY-MM-DD-[feature]-{research|plan|verify}.md`
- Branches: `feature/name` or `fix/name` → docs dir uses sanitized name
- Commands: `/rpi:[phase]` namespace

### Documentation Pattern
- Korean comments in docs/ (project team language)
- English for command files, templates, README
- Mixed in usage examples (needs standardization)

## Dependencies

### Internal Dependencies
- `README.md` ← `commands/*.md` (기능 설명 일치 필요)
- `README.md` ← `templates/*.md` (경로, 구조 일치 필요)
- `README.md` ← `hooks/session-info.py` (Hook 기능 문서화 필요)
- `examples/examples.md` ← `commands/*.md` (워크플로우 일치 필요)

### External Dependencies
- Claude Code CLI (버전 미명시)
- Python 3.7+ (hooks/session-info.py)
- Git (버전 관리)
- jq (optional, install.sh hook 등록용)

## Impact Analysis

### Files to Create

1. `CHANGELOG.md` - 버전 히스토리 (v1.0.0 릴리스 기록)
2. `.github/ISSUE_TEMPLATE/bug_report.md` - 이슈 템플릿
3. `.github/ISSUE_TEMPLATE/feature_request.md` - 기능 요청 템플릿
4. `.github/PULL_REQUEST_TEMPLATE.md` - PR 템플릿

### Files to Modify

1. `README.md` - **Major update** (auto-assign, hook docs, usage, i18n, TOC, badges)
2. `examples/examples.md` - **Moderate update** (auto-assign 반영, export 제거)
3. `templates/rpi-main-template.md` - **Minor update** (Quick Resume export 안내)

### Potential Side Effects

- [ ] README 구조 변경 시 기존 북마크/링크 영향
- [ ] 한국어 제거 시 한국 사용자 경험 변화
- [ ] CHANGELOG 추가 시 릴리스 프로세스 정립 필요

## Constraints Discovered

1. **Language Policy 미정립**: 한영 혼용 기준이 없어 일관성 문제 발생
2. **버전 관리 미흡**: CHANGELOG 없이 Git 히스토리에만 의존
3. **자동 테스트 부재**: 문서 품질 검증이 수동으로만 가능
4. **Plugin 설치 명령어 검증 불가**: 실제 Claude Code marketplace가 어떤 syntax를 요구하는지 확인 필요

## Open Questions

- [x] Task List ID Auto-Assign이 README에 반영되었나? → **No, 미반영**
- [x] Hook 시스템이 문서화되어 있나? → **No, README에 없음**
- [x] 한국어 예시를 어떻게 처리할 것인가? → **영어 기본 + 한국어 주석 형태 제안**
- [ ] Plugin install 명령어 정확한 syntax는? → marketplace 동작 확인 필요
- [ ] README TOC 자동 생성 도구 사용 여부? → 수동 작성 vs doctoc 등
- [ ] GitHub Issue/PR 템플릿 도입 범위? → 사용자 판단 필요

## Notes

- 4개 에이전트 모두 **Task List ID Auto-Assign 미반영**을 최우선 이슈로 도출
- README의 기본 구조와 Key Concepts는 높은 품질. 증분 업데이트로 충분
- Mermaid diagram `---title---` syntax는 일부 렌더러에서 비호환 → 검토 필요
- install.sh의 hooks.json 미복사 이슈: Plugin 설치 방식 권장이므로 우선순위 낮음
- 전체 개선 항목 22개, P0 2개 / P1 5개 / P2 7개 / P3-P4 8개
