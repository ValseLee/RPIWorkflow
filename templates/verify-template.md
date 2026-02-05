# Verification Report: [Feature Name]

> **Date**: YYYY-MM-DD
> **Status**: ✅ PASSED / ❌ FAILED
> **Branch**: [branch-name]
> **Plan**: `docs/plans/[branch]/...-plan.md`
> **Research**: `docs/research/[branch]/...-research.md`

## Summary

<!-- One sentence: All verifications passed / Verification failed with N issues -->

## Build Verification

- **Status**: ✅ PASSED / ❌ FAILED
- **Command**: `[build command used]`
- **Duration**: X seconds

<!-- If failed, include error output: -->
```
[build error output if any]
```

## Test Verification

- **Status**: ✅ PASSED / ❌ FAILED
- **Tests Run**: N
- **Tests Passed**: N
- **Tests Failed**: N
- **Coverage**: X% (if available)

### Failed Tests

<!-- List each failed test if any: -->
| Test | Error |
|------|-------|
| `TestClass.testMethod` | [error message] |

## Plan Implementation Check

| Step | File | Action | Status | Notes |
|------|------|--------|--------|-------|
| 1 | `path/to/file.swift` | Create | ✅ / ❌ | [details] |
| 2 | `path/to/file.swift` | Modify | ✅ / ❌ | [details] |
| ... | ... | ... | ... | ... |

### Missing Implementations

<!-- List any steps not implemented: -->
- Step N: [what's missing]

### Extra Changes

<!-- List any changes not in plan: -->
- [file]: [unexpected change]

## Issues Found

<!-- For each issue: -->

### Issue 1: [Issue Title]

- **Type**: Build Error / Test Failure / Missing Implementation / Unexpected Change
- **Severity**: Critical / Major / Minor
- **Location**: `path/to/file.swift:line` or Step N
- **Description**: [what's wrong]
- **Suggested Fix**: [how to fix]

---

### Issue 2: [Issue Title]

- **Type**: ...
- **Severity**: ...
- **Location**: ...
- **Description**: ...
- **Suggested Fix**: ...

---

## Recommended Fix Tasks

<!-- If verification failed, list recommended tasks: -->

1. **Fix: [Issue 1 Title]**
   - File: `path/to/file.swift`
   - Action: [what to do]
   - Priority: High / Medium / Low

2. **Fix: [Issue 2 Title]**
   - File: `path/to/file.swift`
   - Action: [what to do]
   - Priority: High / Medium / Low

## Conclusion

<!-- Summary and next steps -->

### If PASSED:
- [ ] Ready for code review
- [ ] Ready for PR creation
- [ ] Ready for merge to main

### If FAILED:
- [ ] Fix tasks created: Yes / No
- [ ] Next action: /rpi:implement / Manual fix / Abort
