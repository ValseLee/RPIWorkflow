# Rule: Testing - [Project Name]

> **Type**: testing
> **Project**: [Project Name]
> **Created**: YYYY-MM-DD

## Context

Testing conventions and requirements.

## Conventions

### Test Framework

- **Unit Tests**: Swift Testing (`@Test`, `#expect`)
- **UI Tests**: XCUITest
- **Coverage Target**: 80% for Domain layer, 60% overall

### Test File Organization

```
Tests/
├── UnitTests/
│   ├── Domain/
│   │   └── UseCases/
│   │       └── FetchUserUseCaseTests.swift
│   └── Data/
│       └── Repositories/
│           └── UserRepositoryTests.swift
├── IntegrationTests/
│   └── API/
└── UITests/
    └── Journeys/
        └── LoginJourneyTests.swift
```

### Test Naming

```swift
// Pattern: test_[method]_[condition]_[expectedResult]
@Test func fetchUser_withValidId_returnsUser() { }
@Test func fetchUser_withInvalidId_throwsNotFoundError() { }
```

### Mocking Pattern

```swift
// Protocol-based mocks
final class MockUserRepository: UserRepositoryProtocol {
    var fetchUserResult: Result<User, Error> = .success(.mock)
    var fetchUserCallCount = 0

    func fetchUser(id: String) async throws -> User {
        fetchUserCallCount += 1
        return try fetchUserResult.get()
    }
}
```

### Test Data

```swift
// Use extensions for test fixtures
extension User {
    static var mock: User {
        User(id: "test-id", name: "Test User")
    }

    static func mock(id: String = "test-id", name: String = "Test") -> User {
        User(id: id, name: name)
    }
}
```

## Avoid

- ❌ Testing implementation details (test behavior, not structure)
- ❌ Flaky tests (no real network, no real delays)
- ❌ Test interdependence (each test must be isolated)
- ❌ Testing third-party code

## Key References

| File | Purpose |
|------|---------|
| `Tests/UnitTests/Domain/` | Domain test examples |
| `Tests/Mocks/` | Shared mock implementations |
| `Tests/Fixtures/` | Test data fixtures |
