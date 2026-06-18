# Persistence Architecture

# 1. Overview

This document defines the persistence strategy for FocusUp.

Goals:
- offline-first behavior
- lightweight architecture
- reliable state restoration
- maintainable persistence boundaries
- SwiftUI-friendly integration
- testable data layer

The application uses:
- SwiftData
- Repository pattern
- domain-to-entity mapping

The persistence layer should remain:
- simple
- scalable
- replaceable
- isolated from UI

---

# 2. Persistence Philosophy

The application follows these principles:

- persistence is an implementation detail
- Views should never access persistence directly
- business logic should remain persistence-independent
- SwiftData should remain isolated inside the Data layer
- repositories are the persistence boundary

Avoid:
- leaking SwiftData entities into Views
- tightly coupling domain logic to persistence frameworks
- persistence logic inside ViewModels

---

# 3. Persistence Stack

| Area | Technology |
|---|---|
| Persistence Framework | SwiftData |
| Local Storage | SQLite (managed by SwiftData) |
| Restoration | SceneStorage |
| Architecture | Repository Pattern |

Minimum platform:
- iOS 17.5+

---

# 4. Persistence Layers

```text
SwiftUI View
    ↓
ViewModel
    ↓
UseCase
    ↓
Repository
    ↓
SwiftData
```

---

# 5. Persistence Responsibilities

---

# 5.1 SwiftData Responsibilities

SwiftData handles:
- local database storage
- entity relationships
- object persistence
- query execution

SwiftData should NOT:
- contain business logic
- control UI behavior
- contain presentation logic

---

# 5.2 Repository Responsibilities

Repositories:
- abstract persistence implementation
- map entities to domain models
- expose clean async APIs
- isolate storage framework details

Repositories should be the ONLY layer interacting directly with SwiftData.

---

# 5.3 ViewModel Responsibilities

ViewModels:
- request data from use cases
- expose UI state
- avoid direct persistence access

Avoid:
- ModelContext inside ViewModels
- direct fetch descriptors in Views

---

# 6. Folder Structure

```text id="j0uvg4"
Data/
├── Persistence/
│   ├── Entities/
│   ├── Database/
│   └── Migrations/
│
├── Repositories/
│
├── Mappers/
│
└── Services/
```

---

# 7. Domain Model Separation

The architecture separates:
- domain models
- persistence entities

This improves:
- testability
- maintainability
- framework independence

---

# 7.1 Domain Models

Located in:

```text id="8v2v5x"
Domain/Models/
```

Example:

```swift id="1d4uk5"
struct Task {
    let id: UUID
    let title: String
    let deadline: Date?
}
```

Domain models should:
- remain framework-independent
- avoid SwiftData annotations
- avoid persistence imports

---

# 7.2 Persistence Entities

Located in:

```text id="3zvl2s"
Data/Persistence/Entities/
```

Example:

```swift id="xj09lf"
@Model
final class TaskEntity {

    @Attribute(.unique)
    var id: UUID

    var title: String
    var deadline: Date?
}
```

Persistence entities should:
- remain storage-focused
- avoid business logic
- avoid UI logic

---

# 8. Mapping Strategy

Repositories map between:
- domain models
- persistence entities

---

# 8.1 Mapper Responsibilities

Mappers should:
- remain lightweight
- perform pure transformations

Example:

```swift id="2wqmgj"
struct TaskMapper {

    static func toDomain(_ entity: TaskEntity) -> Task

    static func toEntity(_ model: Task) -> TaskEntity
}
```

Avoid:
- business calculations inside mappers

---

# 9. Persisted Models

---

# 9.1 TaskEntity

Represents:
- user-created tasks

Fields:
- id
- title
- description
- deadline
- createdAt
- updatedAt
- isArchived
- purpose
- hobbies
- dailyTargetDuration

Relationships:
- milestones
- focus sessions

---

# 9.2 MilestoneEntity

Represents:
- task checkpoints

Fields:
- id
- title
- isCompleted
- orderIndex

Relationship:
- parent task

---

# 9.3 FocusSessionEntity

Represents:
- completed focus sessions

Fields:
- id
- startedAt
- completedAt
- duration
- sessionType
- relatedTaskID

---

# 9.4 UserPreferencesEntity

Represents:
- user settings

Fields:
- selectedTheme
- preferredFocusDuration
- onboardingCompleted
- notificationSettings

---

# 10. Repository Design

Repositories expose async APIs.

Example:

```swift id="g6lbv5"
protocol TaskRepository {

    func fetchTasks() async throws -> [Task]

    func saveTask(_ task: Task) async throws

    func deleteTask(id: UUID) async throws
}
```

---

# 10.1 Repository Rules

Repositories should:
- remain feature-oriented
- avoid generic repository overengineering
- expose clean domain-focused APIs

Avoid:
- giant generic repositories
- persistence-heavy APIs leaking outward

---

# 11. ModelContext Management

ModelContext should remain isolated.

Preferred ownership:
- repository layer
- persistence services

Avoid:
- passing ModelContext deeply through Views

---

# 12. Query Strategy

Prefer:
- lightweight focused queries
- async repository APIs
- feature-specific fetches

Avoid:
- fetching excessive data
- overusing live query updates unnecessarily

---

# 13. Relationship Strategy

Use SwiftData relationships carefully.

Example relationships:
- Task ↔ Milestones
- Task ↔ FocusSessions

Avoid:
- deeply nested relationship graphs
- circular ownership complexity

---

# 14. Offline-First Strategy

The application is fully offline-first during MVP1.

Requirements:
- all core features function offline
- no authentication required
- no remote dependency required

Persistent data includes:
- tasks
- milestones
- sessions
- statistics
- user preferences

---

# 15. SceneStorage vs Persistence

Use:
- SceneStorage for temporary UI restoration
- SwiftData for permanent business persistence

---

# 15.1 SceneStorage Examples

Good candidates:
- selected tab
- current screen
- draft text
- active timer state

---

# 15.2 SwiftData Examples

Good candidates:
- task history
- completed sessions
- milestones
- preferences

---

# 16. Migration Strategy

The architecture should support future migrations.

Store:
- stable identifiers
- version-safe models

Prepare folder:

```text id="l8wmtm"
Persistence/Migrations/
```

Even if MVP1 migrations are minimal.

---

# 17. Concurrency Strategy

Persistence operations should support:
- async/await
- MainActor safety
- cancellation awareness

Avoid:
- blocking main thread
- large synchronous persistence operations

---

# 18. Performance Guidelines

Prefer:
- small focused fetches
- lazy loading where appropriate
- lightweight mapping

Avoid:
- loading entire databases unnecessarily
- large observable persistence trees

---

# 19. Error Handling

Persistence errors should:
- remain internal when possible
- transform into user-friendly messages

Avoid:
- exposing raw database errors to UI

---

# 20. Testing Strategy

Persistence should remain testable.

Priority testing areas:
- repository behavior
- mapping correctness
- task persistence
- timer session persistence
- restoration behavior

---

# 21. Future Scalability

The architecture should support future:
- iCloud sync
- CloudKit
- widgets
- Apple Watch integration
- AI-generated insights

without major persistence redesign.

---

# 22. Anti-Patterns To Avoid

Avoid:
- direct SwiftData access in Views
- persistence logic inside ViewModels
- business logic inside entities
- giant generic repositories
- leaking persistence models into domain layer
- singleton database managers
- tightly coupled persistence flows

---

# 23. Engineering Philosophy

The persistence layer should feel:
- lightweight
- isolated
- predictable
- scalable
- SwiftUI-friendly

The architecture prioritizes:
- clean boundaries
- offline reliability
- maintainability
- pragmatic simplicity

```