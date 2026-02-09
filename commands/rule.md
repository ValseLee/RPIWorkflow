---
description: RPI Rule management - Add, list, or remove project-specific rules for Research agents. Rules guide the 4 Explore Agents during /rpi:research.
allowed-tools: Read, Write, Glob, AskUserQuestion
---

# RPI Rule Management

## Overview

Rules provide project-specific context to the 4 Explore Agents during Research phase. Each rule type corresponds to one agent.

## Rule Types

| Type | Agent | Purpose |
|------|-------|---------|
| `architecture` | Architecture Agent | Layer structure, directory conventions, module patterns |
| `patterns` | Similar Feature Agent | Code style, reference implementations, naming conventions |
| `dependencies` | Dependency Agent | DI patterns, module boundaries, forbidden dependencies |
| `testing` | Test Structure Agent | Test framework, mocking patterns, coverage requirements |

## Commands

### Add Rule

```
/rpi:rule add [type]
```

Creates a rule file for the specified type. Opens interactive editor to define rules.

**Example:**
```
/rpi:rule add architecture
```

### List Rules

```
/rpi:rule list
```

Shows all rules defined for the current project.

### Remove Rule

```
/rpi:rule remove [type]
```

Removes a rule file for the specified type.

## Workflow

### Adding a Rule

1. User runs `/rpi:rule add [type]`
2. Detect project root (git root or current directory)
3. Check if rule already exists at `<project>/.claude/rules/[type].md`
4. If exists, ask: Update existing or create new?
5. Load template from `templates/rule-template.md`
6. Ask user for rule content via AskUserQuestion or direct input
7. Create `<project>/.claude/rules/` directory if needed
8. Write rule file

### Listing Rules

1. User runs `/rpi:rule list`
2. Glob for `<project>/.claude/rules/*.md`
3. Display found rules with summary

### Removing a Rule

1. User runs `/rpi:rule remove [type]`
2. Check if rule exists at `<project>/.claude/rules/[type].md`
3. Confirm deletion
4. Delete file

## Project Root Detection

Detect project root from (in order):
1. Git repository root (`git rev-parse --show-toplevel`)
2. Current working directory
3. Ask user if unable to detect

## Rule File Location

```
<project>/.claude/rules/
├── architecture.md
├── patterns.md
├── dependencies.md
└── testing.md
```

**Benefits of project-local rules:**
- Version controlled with git
- Shared with team members
- Portable with the project

## Integration with Research Phase

When `/rpi:research` runs:

1. Detect project root
2. Check for rules in `<project>/.claude/rules/[type].md`
3. If rule exists, include in agent prompt:

```
[Agent Prompt] + "\n\nProject Rules:\n" + [Rule Content]
```

## Rule Template Structure

Each rule file should contain:
- **Context**: What this project does
- **Conventions**: Must-follow patterns
- **Avoid**: Anti-patterns or forbidden approaches
- **References**: Key files to always check

## Example Usage

### Adding Architecture Rule

**User**: `/rpi:rule add architecture`

**Claude**: "Creating architecture rule for this project.

What architecture patterns does this project follow?
- Layer structure (e.g., Clean Architecture, MVVM)
- Directory conventions
- Module organization"

**User**: "Clean Architecture with Domain/Data/Presentation layers. Domain has no external dependencies."

**Claude**: "Rule saved to `.claude/rules/architecture.md`

This rule will be used by the Architecture Agent during `/rpi:research`."

### Listing Rules

**User**: `/rpi:rule list`

**Claude**:
```
Project rules at .claude/rules/:

✓ architecture.md - Clean Architecture, Domain/Data/Presentation
✓ testing.md - XCTest with Swift Testing, 80% coverage target
✗ patterns.md - Not defined
✗ dependencies.md - Not defined

Use `/rpi:rule add [type]` to add missing rules.
```

## Exit Message

After any rule operation:

```
Rule [action] complete.

[type]: [summary or "removed"]

Rules are automatically loaded during /rpi:research for this project.
```
