# 06 — Persistence

## Technology

**SwiftData** (not Core Data). Single `ModelContainer` owned by `PersistenceController`.

| File | Role |
|------|------|
| `Data/Persistence/PersistenceController.swift` | Container + `mainContext` |
| `Data/Persistence/PersistenceSchema.swift` | Schema registration |
| `Data/Persistence/Entities/*.swift` | `@Model` entities |
| `Data/Mappers/*.swift` | Entity ↔ domain mapping |
| `Data/Repositories/*Impl.swift` | CRUD via protocols |

Wired in `App/App.swift`: `.modelContainer(container.persistence.container)`.

---

## Data Models

### SwiftData Entities

| Entity | Domain type | Notes |
|--------|-------------|-------|
| `TaskEntity` | `Task` | Cascade to milestones |
| `TaskMilestoneEntity` | `TaskMilestone` | Child of task |
| `FocusSessionEntity` | `FocusSession` | Active + completed sessions |
| `RestSessionEntity` | `RestSession` | Rest sessions |
| `UserPreferencesEntity` | `UserPreferences` | Notifications, haptics, motion |

### Domain Layer

Pure `struct`/`enum` in `Domain/` — `Codable`, `Sendable`, `Equatable` where needed. **No SwiftData imports in Domain.**

---

## SwiftData schema diagram

Registered in [`PersistenceSchema.swift`](../../FocusUp/Data/Persistence/PersistenceSchema.swift) — **5 `@Model` types**, one `ModelContainer`, default on-disk store (or in-memory for tests/previews).

### Entity-relationship (high level)

```mermaid
erDiagram
    TaskEntity ||--o{ TaskMilestoneEntity : "milestones cascade delete"

    TaskEntity {
        UUID id PK "unique"
        string title
        string notes
        string purpose
        string hobbies
        date deadline "optional"
        string priorityRawValue
        string statusRawValue
        bool isCompleted
        date createdAt
        date updatedAt
    }

    TaskMilestoneEntity {
        UUID id PK "unique"
        string title
        bool isCompleted
        date createdAt
        date updatedAt
        TaskEntity task FK "inverse relationship"
    }

    FocusSessionEntity {
        UUID id PK "unique"
        string title
        int plannedDurationSeconds
        int elapsedSeconds
        string statusRawValue
        date segmentStartedAt "optional"
        date sessionStartedAt "optional"
        date completedAt "optional"
        UUID associatedTaskID "optional logical FK to Task"
        date createdAt
        date updatedAt
    }

    RestSessionEntity {
        UUID id PK "unique"
        string title
        int plannedDurationSeconds
        int elapsedSeconds
        string statusRawValue
        date segmentStartedAt "optional"
        date sessionStartedAt "optional"
        date completedAt "optional"
        date createdAt
        date updatedAt
    }

    UserPreferencesEntity {
        UUID id PK "unique singletonID"
        bool prefersReducedMotion
        bool hapticsEnabled
        bool focusRemindersEnabled
        bool quietHoursEnabled
        int quietHoursStartHour
        int quietHoursEndHour
        date createdAt
        date updatedAt
    }
```

`FocusSessionEntity`, `RestSessionEntity`, and `UserPreferencesEntity` have **no SwiftData relationships** to each other. Focus→Task is a **UUID reference** only (`associatedTaskID`).

### Visual map (how tables relate)

```mermaid
flowchart TB
    subgraph swiftdata ["SwiftData ModelContainer"]
        TE[TaskEntity]
        TME[TaskMilestoneEntity]
        FSE[FocusSessionEntity]
        RSE[RestSessionEntity]
        UPE[UserPreferencesEntity]
    end

    TE -->|"Relationship cascade"| TME
    FSE -.->|"associatedTaskID UUID"| TE

    subgraph not_in_db ["Not stored as entities"]
        STATS[StatisticsSummary]
        STATS2["Computed by FocusAnalyticsCalculator"]
    end

    FSE --> STATS2
    TE --> STATS2

    subgraph other_stores ["Other persistence"]
        SS["SceneStorage timer snapshots"]
        UD["UserDefaults AppRestorationStore"]
    end
```

### Relationship rules

| From | To | Type | Notes |
|------|-----|------|-------|
| `TaskEntity` | `TaskMilestoneEntity` | **SwiftData `@Relationship`** | `deleteRule: .cascade` — deleting task deletes milestones |
| `FocusSessionEntity` | `TaskEntity` | **Logical only** | `associatedTaskID: UUID?` — no `@Relationship`; app resolves via `TaskRepository.fetch(id:)` |
| `RestSessionEntity` | — | **Standalone** | No task link |
| `UserPreferencesEntity` | — | **Singleton** | Fixed `UserPreferences.singletonID` — one preferences row |

### What is *not* in SwiftData

| Data | Where it lives |
|------|----------------|
| Statistics / charts | Computed at read time from `FocusSessionEntity` + `TaskEntity` |
| Active timer tick state | `TimerEngine` in memory + SceneStorage snapshot |
| Navigation state | SceneStorage + `AppRestorationStore` |
| Form drafts | SceneStorage / `FormDraftManager` |

### Domain mapping layer

Entities are **never** used in Features or ViewModels. Repositories map both ways:

```mermaid
flowchart LR
    SDE[SwiftData Entity] <-->|Mappers| DOM[Domain struct]
    DOM --> VM[ViewModel or Manager]
    SDE --> CTX[ModelContext]
```

Entity files: `FocusUp/Data/Persistence/Entities/`  
Mapper files: `FocusUp/Data/Mappers/`

---

## CRUD Flow

```mermaid
sequenceDiagram
    participant VM as ViewModel or Manager
    participant R as TaskRepositoryImpl
    participant M as TaskMapper
    participant C as ModelContext

    VM->>R: update(task)
    R->>M: toEntity(domain)
    M->>C: fetch or insert entity
    C->>C: save()
    R-->>VM: success
```

**Active session pattern:** `FocusRepository.fetchActive()` on launch; managers call `save()` on every pause/tick boundary.

**Statistics:** `StatisticsRepositoryImpl` reads focus sessions, runs `FocusAnalyticsCalculator`, caches summary until `invalidateCache()`.

---

## Migrations

**No explicit migration versioning** in MVP — schema is young. SwiftData lightweight migration assumed for additive changes.

**Risk for interview:** Production schema changes need `VersionedSchema` or migration plan before shipping breaking changes.

---

## Additional Persistence

| Store | Data | File |
|-------|------|------|
| SceneStorage | Timer snapshots, nav state | Restoration modifiers |
| UserDefaults | Backup restoration payloads | `AppRestorationStore` |
| In-memory drafts | Create/edit task forms | `FormDraftManager`, `EditDraftStore` |

---

## Error Handling

| Layer | Behavior |
|-------|----------|
| `PersistenceController.init` | `throws PersistenceError` |
| `PersistenceController.shared` | `fatalError` on failure — **weakness** |
| Repository methods | `async throws` to callers |
| ViewModels | Map to `.error(String)` or `lastError` |

---

## Why SwiftData + Repository?

| Benefit | Explanation |
|---------|-------------|
| Testability | Protocol repos + in-memory container in tests |
| Clean boundaries | Domain free of framework |
| Preview support | `PreviewTaskRepository` etc. |
| Future sync | Could swap Data layer without touching Domain |

**Alternative considered:** Core Data — more mature migrations, more boilerplate. SwiftData chosen for modern Swift API.

---

## Instances

| Instance | Use |
|----------|-----|
| `PersistenceController.shared` | Production |
| `.preview` | SwiftUI previews (in-memory + sample data) |
| `.testing` | Tests |
| `PersistenceController(inMemory: true)` | Unit tests |

---

## Key Files

- `Domain/Tasks/TaskRepository.swift` — protocol
- `Data/Repositories/TaskRepositoryImpl.swift` — implementation
- `Data/Mappers/TaskMapper.swift` — mapping
- `Data/Repositories/FocusRepositoryImpl.swift` — `fetchActive()` for restoration
