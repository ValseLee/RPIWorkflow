# Contributing to RPI Workflow

Thank you for your interest in contributing to RPI Workflow! This document provides guidelines for contributing.

## How to Contribute

### Reporting Bugs

1. **Check existing issues** - Search [GitHub Issues](https://github.com/ValseLee/RPIWorkflow/issues) to avoid duplicates
2. **Create a new issue** with:
   - Clear, descriptive title
   - Steps to reproduce
   - Expected vs actual behavior
   - Claude Code version
   - OS and environment details

### Suggesting Features

1. **Open a feature request issue** with:
   - Problem you're trying to solve
   - Proposed solution
   - Alternative approaches considered
   - Use case examples

### Pull Requests

1. **Fork** the repository
2. **Create a branch** from `main`:
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. **Make your changes** following the code style below
4. **Test your changes** by installing locally:
   ```bash
   ./install.sh
   ```
5. **Commit** with clear messages:
   ```bash
   git commit -m "feat: add new feature description"
   ```
6. **Push** and create a Pull Request

## Code Style

### Command Files (`commands/*.md`)

Follow this structure:
```markdown
---
description: Brief description for Claude Code
allowed-tools: Tool1, Tool2, Tool3
---

# Phase Name

## Overview
[What this phase does]

## Prerequisites
[What must be done before]

## Workflow
[Mermaid diagram + explanation]

## Output Files
[What gets created]

## Exit Conditions
[Checklist before completing]

## Red Flags - STOP
[What to avoid]
```

### Template Files (`templates/*.md`)

- Use clear section headers
- Include placeholder markers: `[feature-name]`, `[branch-name]`, `YYYY-MM-DD`
- Add examples where helpful

### Documentation

- Keep README.md concise
- Add detailed examples to `examples/` directory
- Update relevant docs when changing functionality

## Commit Message Format

Use [Conventional Commits](https://www.conventionalcommits.org/):

| Type | Description |
|------|-------------|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation only |
| `refactor` | Code change that neither fixes a bug nor adds a feature |
| `chore` | Maintenance tasks |

Examples:
```
feat: add Python project support to verify phase
fix: correct task dependency detection in plan phase
docs: add session recovery example
```

## Testing Changes

### Manual Testing Checklist

Before submitting a PR:

- [ ] Run `/rpi:research` on a test project
- [ ] Run `/rpi:plan` with the research output
- [ ] Run `/rpi:implement` and verify task tracking
- [ ] Test `/rpi:rule add` and `/rpi:rule list`
- [ ] Verify session resume after `/clear`

### Test Projects

Test with different project types:
- Node.js (`package.json`)
- Python (`pyproject.toml`)
- Swift (`Package.swift`)
- Rust (`Cargo.toml`)

## Development Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/ValseLee/RPIWorkflow.git
   cd RPIWorkflow
   ```

2. Create a test branch:
   ```bash
   git checkout -b test/my-changes
   ```

3. Install locally for testing:
   ```bash
   ./install.sh
   ```

4. Make changes and test in Claude Code

5. Uninstall test version:
   ```bash
   ./uninstall.sh
   ```

## Questions?

- Open a [Discussion](https://github.com/ValseLee/RPIWorkflow/discussions) for questions
- Check existing issues for similar problems

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
