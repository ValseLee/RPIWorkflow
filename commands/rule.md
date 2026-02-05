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
2. Check if rule already exists at `~/.claude/rpi/rules/[type]/[project-name].md`
3. If exists, ask: Update existing or create new?
4. Load template from `~/.claude/rpi/rule-template.md`
5. Ask user for rule content via AskUserQuestion or direct input
6. Write rule file

### Listing Rules

1. User runs `/rpi:rule list`
2. Glob for `~/.claude/rpi/rules/*/[project-name].md`
3. Display found rules with summary

### Removing a Rule

1. User runs `/rpi:rule remove [type]`
2. Check if rule exists
3. Confirm deletion
4. Delete file

## Project Name Detection

Detect project name from (in order):
1. Git repository name (`git rev-parse --show-toplevel | xargs basename`)
2. Current directory name
3. Ask user if unable to detect

## Rule File Location

```
~/.claude/rpi/rules/
├── architecture/
│   └── [project-name].md
├── patterns/
│   └── [project-name].md
├── dependencies/
│   └── [project-name].md
└── testing/
    └── [project-name].md
```

## Integration with Research Phase

When `/rpi:research` runs:

1. Detect project name
2. Check for rules in `~/.claude/rpi/rules/[type]/[project-name].md`
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

**Claude**: "Creating architecture rule for project 'MyApp'.

What architecture patterns does this project follow?
- Layer structure (e.g., Clean Architecture, MVVM)
- Directory conventions
- Module organization"

**User**: "Clean Architecture with Domain/Data/Presentation layers. Domain has no external dependencies."

**Claude**: "Rule saved to `~/.claude/rpi/rules/architecture/MyApp.md`

This rule will be used by the Architecture Agent during `/rpi:research`."

### Listing Rules

**User**: `/rpi:rule list`

**Claude**:
```
Rules for 'MyApp':

✓ architecture - Clean Architecture, Domain/Data/Presentation
✓ testing - XCTest with Swift Testing, 80% coverage target
✗ patterns - Not defined
✗ dependencies - Not defined

Use `/rpi:rule add [type]` to add missing rules.
```

## Exit Message

After any rule operation:

```
Rule [action] complete.

[type]: [summary or "removed"]

Rules are automatically loaded during /rpi:research for this project.
```
