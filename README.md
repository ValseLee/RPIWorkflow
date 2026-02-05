# RPI Workflow

**Research → Plan → Implement**: A structured workflow for Claude Code that manages context efficiently across complex coding tasks.

## Why RPI?

When working with AI coding assistants on large tasks, you often hit context limits mid-implementation. RPI solves this by:

- **Separating concerns**: Each phase has a clear goal and output
- **Preserving context**: Documents carry knowledge between sessions
- **Enabling parallelism**: Research uses 4 parallel Explore agents; Implementation uses parallel Sub-Agents
- **Tracking progress**: Claude Tasks persist across `/clear` commands

## Workflow Overview

```
┌─────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  Rule   │────▶│  Research   │────▶│    Plan     │────▶│  Implement  │────▶│   Verify    │
│(optional)│     │             │     │             │     │             │     │             │
│ Project │     │ 4 Explore   │     │ Batch +     │     │ Sub-Agents  │     │ Build/Test  │
│ Context │     │ Agents      │     │ Task Design │     │ + Tracking  │     │ + Plan Check│
└─────────┘     └─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘
      │               │                   │                   │                   │
      ▼               ▼                   ▼                   ▼                   ▼
 rules/*.md      research.md          plan.md            TaskList           verify.md
                 rpi-main.md        (Tasks created)      (Progress)          (Report)
```

### Setup: Rule (`/rpi:rule`) - Optional

Define project-specific rules to guide Research agents:
- **architecture**: Layer structure, module patterns
- **patterns**: Code style, naming conventions
- **dependencies**: DI patterns, module boundaries
- **testing**: Test framework, mocking patterns

**Output**: `~/.claude/rpi/rules/[type]/[project].md`

### Phase 1: Research (`/rpi:research`)

Launches 4 Explore agents **in parallel** to investigate:
- **Architecture**: Project structure, layer patterns
- **Similar Features**: Reference implementations to follow
- **Dependencies**: Impact scope and affected files
- **Test Structure**: Testing conventions and patterns

**Output**: `research.md` + `rpi-main.md`

### Phase 2: Plan (`/rpi:plan`)

Creates implementation plan with:
- Batched steps grouped by complexity
- Claude Tasks for progress tracking
- Parallel vs sequential task dependencies

**Output**: `plan.md` + Claude Tasks registered

### Phase 3: Implement (`/rpi:implement`)

Executes tasks via Sub-Agents:
- Parallel execution for independent tasks
- Context checkpoints at batch boundaries
- Seamless session resume via TaskList

**Output**: Working code with tracked progress

### Phase 4: Verify (`/rpi:verify`)

Validates implementation completeness:
- **Build verification**: Auto-detects project type (Swift, Node, Rust, Go, etc.)
- **Test verification**: Runs project test suite
- **Plan check**: Compares implementation against plan.md

**Output**: `verify.md` (report) - Creates fix tasks if issues found

## Installation

### Quick Install

```bash
# Clone the repository
git clone https://github.com/ValseLee/RPIWorkflow.git
cd RPIWorkflow

# Run install script
./install.sh
```

### Manual Install

1. Copy commands to Claude Code commands directory:
```bash
mkdir -p ~/.claude/commands/rpi
cp commands/*.md ~/.claude/commands/rpi/
```

2. Copy templates:
```bash
mkdir -p ~/.claude/rpi
cp templates/*.md ~/.claude/rpi/
```

3. Restart Claude Code or start a new session.

## Usage

### Starting a New Feature

```bash
# 0. (Optional) Setup project rules first time
/rpi:rule add architecture
/rpi:rule add testing

# 1. Research phase
/rpi:research
# "RPI로 [기능명] 구현하자" or "Start RPI research for [feature]"

# 2. After research completes
/clear

# 3. Plan phase
/rpi:plan
# "@docs/research/[branch]/...-research.md 참고해서 plan 작성해줘"

# 4. After plan approval
export CLAUDE_CODE_TASK_LIST_ID="[id from TaskList]"
/clear

# 5. Implement phase
/rpi:implement
# "TaskList 확인하고 구현 시작"

# 6. After all tasks complete
/rpi:verify
# Validates build, tests, and plan implementation
```

### Resuming Work

```bash
# After /clear or new session
/rpi:implement
# "@docs/rpi/[branch]/rpi-main.md 참고해서 RPI 이어서 진행해줘"
```

### Context Management

When context usage exceeds 40% (check Status Line):
1. Complete current batch
2. Run `/clear`
3. Resume with `/rpi:implement`
4. TaskList automatically shows progress

## Project Structure

```
~/.claude/
├── commands/rpi/          # Slash commands
│   ├── research.md        # /rpi:research
│   ├── plan.md            # /rpi:plan
│   ├── implement.md       # /rpi:implement
│   ├── verify.md          # /rpi:verify
│   └── rule.md            # /rpi:rule
└── rpi/                   # Templates & Rules
    ├── rpi-main-template.md
    ├── research-template.md
    ├── plan-template.md
    ├── verify-template.md
    ├── rule-template.md
    └── rules/             # Project-specific rules
        ├── architecture/
        ├── patterns/
        ├── dependencies/
        └── testing/

your-project/
└── docs/
    ├── research/[branch]/  # Research outputs
    ├── plans/[branch]/     # Plan documents
    ├── verify/[branch]/    # Verification reports
    └── rpi/[branch]/       # RPI status tracking
```

## Key Concepts

### Project Rules

Rules provide project-specific context to Research agents. Each rule type guides a specific Explore Agent:

| Rule Type | Agent | Example Content |
|-----------|-------|-----------------|
| `architecture` | Architecture | Layer structure, module patterns |
| `patterns` | Similar Feature | Code style, naming conventions |
| `dependencies` | Dependency | DI patterns, module boundaries |
| `testing` | Test Structure | Test framework, mocking patterns |

**Managing rules:**
```bash
# Add a rule
/rpi:rule add architecture

# List rules for current project
/rpi:rule list

# Remove a rule
/rpi:rule remove testing
```

Rules are stored in `~/.claude/rpi/rules/[type]/[project-name].md` and automatically loaded during `/rpi:research`.

### Batching

Tasks are grouped by complexity:
| Complexity | Batch Size | Example |
|------------|------------|---------|
| High (new architecture) | 2-3 tasks | Entity + Repository + UseCase |
| Medium (modify existing) | 4-5 tasks | Mapper + DI + ViewModel |
| Low (simple changes) | 5-7 tasks | imports, type fixes |

### Parallel Execution

Tasks without dependencies run in parallel:
```
Batch 1:
- Task 1: "Create UserEntity" ← parallel
- Task 2: "Create BookEntity" ← parallel
- Task 3: "Create UserRepository" ← blockedBy: [1]
```

### Task Persistence

```bash
# Set before /clear to preserve tasks
export CLAUDE_CODE_TASK_LIST_ID="[id]"
```

## Examples

See [examples/](./examples/) for detailed conversation examples:
- Bug fix workflow
- New feature implementation
- Refactoring existing code
- Session recovery

## Requirements

- [Claude Code](https://claude.ai/code) CLI
- Git (for version control)

## Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](./CONTRIBUTING.md) for guidelines.

## License

MIT License - see [LICENSE](./LICENSE) for details.
