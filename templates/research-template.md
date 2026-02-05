# Research: [Feature Name]

> **Date**: YYYY-MM-DD
> **Status**: Draft | Complete
> **Project**: [Project Name]

## Executive Summary

<!-- 2-3 sentences summarizing what was discovered -->

## Parallel Exploration Results

### 1. Architecture Analysis

<!-- Output from Explore Agent: Architecture -->

**Project Structure:**
- Core/Domain Layer: `path/`
- Data/Infrastructure Layer: `path/`
- Presentation/API Layer: `path/`

**Key Patterns:**
```
// Example pattern code
```

### 2. Similar Feature Analysis

<!-- Output from Explore Agent: Similar Feature -->

| Similar Feature | Files | Pattern Notes |
|-----------------|-------|---------------|
| [Feature Name] | `path/to/files` | How it's implemented |

### 3. Dependency Analysis

<!-- Output from Explore Agent: Dependency -->

**Direct Dependencies:**
- `ModuleA` → imports X, Y
- `ServiceB` → uses Repository

**Impact Scope:**
| File | Change Type | Risk |
|------|-------------|------|
| `path/to/file` | Modify | Low/Med/High |

### 4. Test Structure Analysis

<!-- Output from Explore Agent: Test Structure -->

**Test Location:** `path/to/tests/`

**Test Patterns:**
```
// Example test code showing framework patterns
describe('Feature', () => {
    it('should behave correctly', () => { });
});
```

**Naming Convention:** `test_[action]_[condition]_[result]`

## Relevant Files

### Core Files (Must Modify)

| File | Purpose | Key Patterns |
|------|---------|--------------|
| `path/to/file` | Description | Pattern notes |

### Reference Files (Read Only)

| File | Why Relevant |
|------|--------------|
| `path/to/file` | Contains pattern to follow |

## Existing Patterns

### Architecture Pattern

<!-- How similar features are structured in this codebase -->

```
// Example code showing the pattern
```

### Naming Conventions

- Files: `[Feature]Controller`, `[Feature]Service`
- Types: PascalCase
- Properties: camelCase

### Dependency Injection Pattern

<!-- How dependencies are injected in this project -->

## Dependencies

### Internal Dependencies

- `ModuleA` → Used for X
- `ModuleB` → Used for Y

### External Dependencies

- `LibraryX` (version) → Purpose

## Impact Analysis

### Files to Create

1. `path/to/NewFile` - Purpose

### Files to Modify

1. `path/to/Existing` - What changes needed

### Potential Side Effects

- [ ] May affect feature X
- [ ] Needs migration for Y

## Constraints Discovered

<!-- Technical limitations, business rules, or patterns that must be followed -->

1. **Constraint Name**: Description and why it matters

## Open Questions

<!-- Questions that need answers before planning -->

- [ ] Question 1?
- [ ] Question 2?

## Notes

<!-- Any additional observations -->
