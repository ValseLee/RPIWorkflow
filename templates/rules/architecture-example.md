# Rule: Architecture - [Project Name]

> **Type**: architecture
> **Project**: [Project Name]
> **Created**: YYYY-MM-DD

## Context

This project follows Clean Architecture with strict layer separation.

## Conventions

### Layer Structure

```
src/
├── Domain/          # Business logic, entities, use cases (no external deps)
├── Data/            # Repositories, data sources, mappers
├── Presentation/    # ViewModels, Views, Controllers
└── Infrastructure/  # DI, configuration, external services
```

### Dependency Direction

```
Presentation → Domain ← Data
                ↑
          Infrastructure
```

- Domain layer has NO external dependencies
- Data layer implements Domain interfaces
- Presentation depends only on Domain

### Module Organization

- One feature = one module
- Each module has its own Domain/Data/Presentation subdirectories
- Shared code goes in `Core/` module

## Avoid

- ❌ Importing Data layer in Domain
- ❌ Direct database access from Presentation
- ❌ Business logic in ViewModels
- ❌ Circular dependencies between modules

## Key References

| File | Purpose |
|------|---------|
| `src/Domain/Entities/` | Entity patterns |
| `src/Data/Repositories/` | Repository implementation patterns |
| `src/Core/DI/` | Dependency injection setup |
