# Research: README-Workflow Alignment

> **Date**: 2026-02-09
> **Status**: Complete
> **Project**: RPIWorkflow

## Executive Summary

README.md contains several discrepancies with the actual workflow implementation. The template path migration (commit c499ea3) updated all command files to use `templates/` paths, but the README and install.sh still reference old `~/.claude/rpi/` paths. Additionally, the project structure diagram is incomplete and the verify command doesn't reference its template.

## Parallel Exploration Results

### 1. Architecture Analysis

**Project Structure:**
```
RPIWorkflow/
├── .claude/                    # Project-local Claude settings (NOT documented in README)
│   └── settings.local.json
├── .claude-plugin/             # Plugin manifest
│   ├── plugin.json
│   └── marketplace.json
├── commands/                   # 5 slash commands
│   ├── research.md
│   ├── plan.md
│   ├── implement.md
│   ├── verify.md
│   └── rule.md
├── hooks/                      # Session management hooks
│   ├── hooks.json
│   └── session-info.py
├── templates/                  # Document templates
│   ├── rpi-main-template.md
│   ├── research-template.md
│   ├── plan-template.md
│   ├── verify-template.md
│   └── rule-template.md
├── docs/                       # Generated RPI workflow documents
│   ├── research/main/
│   ├── plans/main/
│   ├── verify/main/
│   └── rpi/main/
├── examples/
│   └── examples.md
├── install.sh                  # Legacy manual installer
├── uninstall.sh                # Legacy uninstaller (NOT in README)
├── README.md
├── CONTRIBUTING.md
├── LICENSE
└── .gitignore
```

**Key Patterns:**
- Plugin system: `.claude-plugin/plugin.json` + `marketplace.json`
- Hook system: `hooks/hooks.json` registers `session-info.py` on every `UserPromptSubmit`
- Template system: All in `templates/` directory, referenced by commands
- Output documents: All in `docs/[type]/[branch]/` structure

### 2. Similar Feature Analysis

**Command File Template Path References:**

| Command | Template Referenced | Path Used |
|---------|-------------------|-----------|
| research.md | `templates/research-template.md` | NEW (`templates/`) |
| research.md | `templates/rpi-main-template.md` | NEW (`templates/`) |
| plan.md | `templates/plan-template.md` | NEW (`templates/`) |
| implement.md | (none) | N/A |
| verify.md | (none - but template EXISTS) | **MISSING** |
| rule.md | `templates/rule-template.md` | NEW (`templates/`) |

All command files have been migrated to `templates/` paths. No command references `~/.claude/rpi/`.

### 3. Dependency Analysis

**README Sections That Reference Actual Files:**

| README Section | Lines | References | Status |
|----------------|-------|------------|--------|
| Plugin Install | 106-110 | `.claude-plugin/` manifests | Needs verification of exact command syntax |
| Manual Install | 127-150 | `~/.claude/rpi/`, `~/.claude/commands/rpi/` | Legacy - path mismatch with commands |
| Plugin Structure | 207-227 | Full project tree | Missing `.claude/`, `uninstall.sh` |
| Manual Structure | 241-257 | `~/.claude/` tree | Missing hooks directory |
| Agent Teams | 261-316 | `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` | Implemented in research.md |
| Task Persistence | 371-375 | `CLAUDE_CODE_TASK_LIST_ID` | Accurate |

**Impact Scope:**

| File | Change Type | Risk |
|------|-------------|------|
| `README.md` | Modify | Low - documentation only |

### 4. Test Structure Analysis

N/A - This project is a workflow plugin, not application code. No test suite exists. Testing is manual (run the workflow commands and verify output).

## Relevant Files

### Core Files (Must Modify)

| File | Purpose | Key Issues |
|------|---------|------------|
| `README.md` | Main documentation | Multiple discrepancies with actual implementation |

### Reference Files (Read Only)

| File | Why Relevant |
|------|--------------|
| `commands/research.md` | Actual research command implementation |
| `commands/plan.md` | Actual plan command implementation |
| `commands/implement.md` | Actual implement command implementation |
| `commands/verify.md` | Actual verify command, missing template ref |
| `commands/rule.md` | Actual rule command implementation |
| `templates/verify-template.md` | Exists but not referenced by verify command |
| `install.sh` | Legacy installer, still uses old paths |
| `hooks/hooks.json` | Hook registration format |
| `.claude-plugin/plugin.json` | Plugin manifest |
| `.claude-plugin/marketplace.json` | Marketplace config |

## Discrepancies Found

### HIGH PRIORITY

#### 1. Plugin Install Command Inconsistency
- **README (L106-110)**: `/plugin marketplace add ValseLee/RPIWorkflow` then `/plugin install rpi@rpi-workflow`
- **install.sh (L23)**: `claude plugin install github:ValseLee/RPIWorkflow`
- **Status**: Need to verify which is the correct command syntax for Claude Code's plugin system. These are likely speculative since Claude Code plugin marketplace is not yet publicly available.

#### 2. Manual Install Template Path vs Commands
- **README (L145-148)**: `cp templates/*.md ~/.claude/rpi/` (copies to `~/.claude/rpi/`)
- **install.sh (L18)**: Also uses `~/.claude/rpi/`
- **Commands**: All reference `templates/` directly (plugin-relative)
- **Issue**: After manual install, commands would look for `templates/` but files are at `~/.claude/rpi/`. The manual install path is correct for the `~/.claude/rpi/` approach, but the commands no longer reference that path.
- **Resolution needed**: Either (a) revert commands to support both paths, or (b) update install.sh/README to match new template resolution, or (c) document that manual install is deprecated in favor of plugin install.

#### 3. Project Structure Diagram Incomplete
**README Plugin Structure (L207-227) is missing:**
- `.claude/` directory (exists at repo root with `settings.local.json`)
- `uninstall.sh` (exists in root)
- `templates/rules/` subdirectory with example files (if it exists)

**README Manual Install Structure (L241-257) is missing:**
- `~/.claude/hooks/rpi/` directory that `install.sh` creates

### MEDIUM PRIORITY

#### 4. Verify Command Missing Template Reference
- `templates/verify-template.md` EXISTS in the repo
- `commands/verify.md` does NOT reference it
- All other commands (research, plan, rule) reference their templates
- Inconsistency in the template referencing pattern

#### 5. Examples Directory Description
- **README (L379)**: "See examples/ for detailed conversation examples" with 4 bullet points implying multiple files
- **Actual**: Single file `examples/examples.md`
- Minor: Content may be in one file, but presentation suggests multiple

### LOW PRIORITY

#### 6. README "Output" Lines Are Simplified
- **README (L72)**: `Output: research.md + rpi-main.md`
- **Actual**: `docs/research/[branch]/YYYY-MM-DD-[feature]-research.md`
- These are intentionally simplified in README for readability, full paths are in the commands

## Existing Patterns

### Template Resolution Pattern
Commands use relative path `templates/[name]-template.md` which resolves to:
- **Plugin install**: `${CLAUDE_PLUGIN_ROOT}/templates/[name]-template.md`
- **Manual install**: Would need `~/.claude/rpi/[name]-template.md` (but commands no longer reference this)

### Document Output Pattern
All output documents follow: `docs/[type]/[branch-name]/YYYY-MM-DD-[feature]-[type].md`
- Research: `docs/research/[branch]/`
- Plans: `docs/plans/[branch]/`
- Verify: `docs/verify/[branch]/`
- RPI Main: `docs/rpi/[branch]/rpi-main.md`

## Dependencies

### Internal Dependencies
- All commands depend on `templates/` directory
- `plan.md` depends on `research.md` output
- `implement.md` depends on `plan.md` output + TaskList
- `verify.md` depends on `implement.md` completion
- `hooks/session-info.py` depends on Claude Code task storage at `~/.claude/tasks/`

### External Dependencies
- Claude Code CLI (required)
- Git (for branch detection)
- Python 3 (for session-info hook)
- jq (for install.sh settings manipulation)

## Impact Analysis

### Files to Modify

1. `README.md` - Fix all discrepancies listed above

### Potential Side Effects

- [ ] Changing manual install docs may affect users who already installed manually
- [ ] Plugin install commands are speculative - need to confirm syntax when plugin marketplace launches

## Constraints Discovered

1. **Plugin Marketplace Not Yet Public**: The plugin install commands in README may be speculative. The exact syntax needs verification when Claude Code's plugin marketplace is available.
2. **Manual Install Path Conflict**: After the template path migration (c499ea3), manual install and plugin install have divergent path resolution strategies. This needs a clear decision.
3. **Backward Compatibility**: Users who installed manually have templates at `~/.claude/rpi/` but commands now look at `templates/`.

## Open Questions

- [ ] Is the Claude Code plugin marketplace (`/plugin marketplace add`) actually available? What is the correct command syntax?
- [ ] Should manual install be marked as deprecated or maintained alongside plugin install?
- [ ] Should `commands/verify.md` reference `templates/verify-template.md` for consistency?
- [ ] Should `install.sh` be updated to match the new `templates/` path convention, or should it remain as a legacy installer?

## Notes

- The template path migration (c499ea3) was a significant change that affected command-template relationships
- The hook system (`hooks/hooks.json` + `session-info.py`) is well-implemented and accurately described in README
- Agent Teams mode is fully documented in `commands/research.md` and accurately described in README
- The core workflow (Research -> Plan -> Implement -> Verify) is consistent between README and commands
