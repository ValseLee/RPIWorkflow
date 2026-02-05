# Rule: Patterns - [Project Name]

> **Type**: patterns
> **Project**: [Project Name]
> **Created**: YYYY-MM-DD

## Context

Code style and implementation patterns used throughout the project.

## Conventions

### Naming Conventions

```
Files:      [Feature]ViewController.swift, [Feature]ViewModel.swift
Classes:    PascalCase (UserRepository, BookService)
Methods:    camelCase (fetchUser, updateBook)
Properties: camelCase (userName, isLoading)
Constants:  SCREAMING_SNAKE_CASE or static let
```

### Error Handling Pattern

```swift
// Use Result type for operations that can fail
func fetchUser(id: String) async -> Result<User, UserError>

// Custom error enums per domain
enum UserError: Error {
    case notFound
    case networkError(underlying: Error)
    case invalidData
}
```

### ViewModel Pattern

```swift
@Observable
final class FeatureViewModel {
    // State
    private(set) var items: [Item] = []
    private(set) var isLoading = false
    private(set) var error: Error?

    // Dependencies
    private let useCase: FeatureUseCaseProtocol

    // Actions
    func load() async { }
    func refresh() async { }
}
```

## Avoid

- ❌ Force unwrapping (`!`) except in tests or IBOutlets
- ❌ Stringly-typed APIs (use enums)
- ❌ Massive view controllers (split into child VCs or use MVVM)
- ❌ Callback hell (use async/await)

## Key References

| File | Purpose |
|------|---------|
| `src/Features/User/` | Reference feature implementation |
| `docs/STYLE_GUIDE.md` | Full style guide |
