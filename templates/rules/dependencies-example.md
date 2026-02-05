# Rule: Dependencies - [Project Name]

> **Type**: dependencies
> **Project**: [Project Name]
> **Created**: YYYY-MM-DD

## Context

Dependency injection and module boundary rules.

## Conventions

### DI Container Setup

```swift
// Use protocol-based DI
protocol ServiceContainerProtocol {
    var userRepository: UserRepositoryProtocol { get }
    var authService: AuthServiceProtocol { get }
}

// Register in composition root
final class ServiceContainer: ServiceContainerProtocol {
    lazy var userRepository: UserRepositoryProtocol = UserRepository(...)
}
```

### Module Boundaries

```
Feature modules can import:
✓ Core module
✓ Domain protocols from other features
✗ Concrete implementations from other features
✗ Data layer from other features
```

### Dependency Graph

```
App
├── FeatureA (imports: Core)
├── FeatureB (imports: Core, FeatureA.Domain)
├── Core (imports: nothing project-internal)
└── Infrastructure (imports: all for DI wiring)
```

## Avoid

- ❌ Singletons (use DI instead)
- ❌ Static dependencies (inject protocols)
- ❌ Importing concrete types across module boundaries
- ❌ Circular module dependencies

## Key References

| File | Purpose |
|------|---------|
| `src/Infrastructure/DI/` | DI container implementation |
| `Package.swift` or `project.yml` | Module dependency declarations |
