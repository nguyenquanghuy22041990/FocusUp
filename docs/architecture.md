# Architecture Document

# 1. Overview

FocusUp uses a pragmatic Clean Architecture approach optimized for:

- SwiftUI
- maintainability
- testability
- readability
- offline-first behavior
- modern iOS development

The architecture intentionally balances:
- scalability
- simplicity
- engineering quality

The goal is to avoid both:
- tightly coupled code
- unnecessary enterprise overengineering

This project prioritizes:
- clean feature boundaries
- predictable state management
- polished user experience
- modern SwiftUI practices

---

# 2. Core Technologies

| Area | Technology |
|---|---|
| UI Framework | SwiftUI |
| Architecture | MVVM-C + Pragmatic Clean Architecture |
| Persistence | SwiftData |
| State Management | Observation Framework |
| Navigation | NavigationStack |
| Testing | Swift Testing |
| Async | async/await |
| Timers | TimelineView |
| Live Activities | ActivityKit |
| Notifications | UserNotifications |
| Restoration | SceneStorage |

Minimum platform:
- iOS 17.5+

---

# 3. Architecture Style

The application follows:

- MVVM-C
- Clean Architecture principles
- feature-first organization
- unidirectional data flow

The architecture is intentionally lightweight.

Avoid:
- unnecessary abstractions
- excessive protocols
- deeply nested dependency chains
- enterprise-style boilerplate

---

# 4. High-Level Architecture

```text
┌────────────────────┐
│    SwiftUI Views   │
└─────────┬──────────┘
          │
          ▼
┌────────────────────┐
│     ViewModels     │
│   Presentation     │
└─────────┬──────────┘
          │
          ▼
┌────────────────────┐
│      UseCases      │
│       Domain       │
└─────────┬──────────┘
          │
          ▼
┌────────────────────┐
│    Repositories    │
│        Data        │
└─────────┬──────────┘
          │
          ▼
┌────────────────────┐
│ SwiftData / System │
│     Frameworks     │
└────────────────────┘
```

---

# 5. Layer Responsibilities

---

# 5.1 Presentation Layer

## Components

- SwiftUI Views
- ViewModels
- Coordinators
- UI State
- animations

## Responsibilities

- render UI
- handle user interaction
- manage screen state
- coordinate navigation
- transform domain models into UI-ready data

## Rules

Views:
- remain declarative
- avoid business logic
- avoid persistence access

ViewModels:
- own screen state
- trigger use cases
- expose observable state
- remain lightweight

Coordinators:
- manage navigation flows
- manage modal presentation
- support future deep links

Coordinators should NOT:
- contain business logic
- own persistence
- manage timer logic

---

# 5.2 Domain Layer

## Components

- domain entities
- use cases
- business rules
- repository contracts

## Responsibilities

- application business logic
- feature workflows
- validation
- calculations

Examples:
- task progress calculation
- workload estimation
- session completion logic
- motivational message generation

## Rules

Domain layer:
- should not depend on SwiftUI
- should not depend on SwiftData
- should remain framework-independent

---

# 5.3 Data Layer

## Components

- repository implementations
- SwiftData services
- notification services
- persistence mapping

## Responsibilities

- local persistence
- framework integration
- data storage
- data retrieval

## Rules

Repositories:
- abstract persistence details
- expose clean interfaces
- isolate SwiftData from domain logic

---

# 6. Feature-First Organization

The project uses feature-first structure instead of type-first structure.

## Example

```text id="gk28me"
Features/
    Home/
    Tasks/
    Focus/
    Rest/
    Statistics/
    Settings/
```

Each feature owns:
- views
- view models
- coordinator
- components
- use cases
- feature-specific models

This improves:
- scalability
- discoverability
- maintainability

---

# 7. Folder Structure

```text id="n0um7w"
App/
    AppEntry/
    Navigation/

Features/
    Home/
    Tasks/
    Focus/
    Rest/
    Statistics/
    Settings/

Core/
    DesignSystem/
    Components/
    Extensions/
    Utilities/
    Constants/

Domain/
    Models/
    UseCases/
    Repositories/

Data/
    Persistence/
    Repositories/
    Services/

Resources/
    Assets/
    Localization/

Tests/
    UnitTests/
    UITests/

Docs/
```

---

# 8. State Management

The application uses modern SwiftUI state management with the Observation framework.

---

# 8.1 State Ownership Rules

| State Type | Recommended Wrapper |
|---|---|
| Local transient state | @State |
| Child mutation | @Binding |
| Shared observable state | @Observable |
| App-wide dependency | @Environment |
| Temporary restoration state | @SceneStorage |

---

# 8.2 State Management Principles

- single source of truth
- minimal duplicated state
- derived state when possible
- clear ownership boundaries

Avoid:
- duplicated observable state
- business logic inside Views
- global mutable state

---

# 8.3 Observable ViewModels

ViewModels use:
- @Observable

instead of:
- ObservableObject
- @Published

unless compatibility requires otherwise.

Example:

```swift id="4fxhkv"
@Observable
final class TaskListViewModel {
    var tasks: [Task] = []
    var selectedFilter: TaskFilter = .active
    var isLoading = false
}
```

---

# 9. Navigation Architecture

The application uses:
- NavigationStack
- strongly typed destinations
- lightweight coordinators

---

# 9.1 Navigation Principles

- avoid deeply nested navigation
- avoid navigation logic inside reusable views
- support state restoration
- keep navigation predictable

---

# 10. SceneStorage Strategy

SceneStorage is used for temporary UI restoration only.

## Supported Restoration State

- selected tab
- active navigation path
- timer progress
- current session screen
- temporary form drafts
- selected filters

---

# 10.1 SceneStorage Rules

SceneStorage should NOT store:
- permanent business data
- task persistence
- session history
- statistics

Permanent data belongs in SwiftData.

---

# 11. Persistence Architecture

The application uses:
- SwiftData

Persistence remains fully local during MVP1.

---

# 11.1 Domain Model vs Persistence Model

The architecture separates:
- domain entities
- persistence entities

## Example

### Domain Model

```swift id="8tylv8"
struct Task {
    let id: UUID
    let title: String
}
```

### SwiftData Entity

```swift id="cd6ekf"
@Model
final class TaskEntity
```

Repositories map between these layers.

---

# 11.2 Persistence Rules

- Views never access SwiftData directly
- ViewModels do not own persistence logic
- repositories isolate storage implementation
- persistence should remain replaceable

---

# 12. Use Case Strategy

The architecture uses pragmatic use cases.

Avoid:
- use-case-per-CRUD-operation
- meaningless abstraction layers

---

# 12.1 Preferred Style

## Avoid

```text id="pzq5md"
CreateTaskUseCase
DeleteTaskUseCase
UpdateTaskUseCase
```

## Prefer

```text id="0g2m5x"
TaskUseCase
    - createTask()
    - updateTask()
    - calculateProgress()
    - completeMilestone()
```

This keeps the architecture simpler and easier to maintain.

---

# 13. Dependency Injection

The application uses lightweight dependency injection.

Preferred methods:
- initializer injection
- environment injection
- lightweight factory pattern

Avoid:
- heavy DI frameworks
- service locators
- singleton-heavy architecture

---

# 14. Concurrency Strategy

The application uses:
- async/await
- structured concurrency

---

# 14.1 Concurrency Rules

- UI updates occur on MainActor
- prefer cancellation-aware tasks
- avoid callback-based async code
- avoid detached tasks unless necessary

---

# 15. Timer Architecture

Focus and rest timers are core application features.

Timer responsibilities include:
- countdown management
- background continuation
- restoration after relaunch
- Live Activities integration

---

# 15.1 Timer Implementation

Recommended tools:
- TimelineView
- ActivityKit
- BackgroundTasks

Timer logic should remain outside SwiftUI views.

Avoid:
- timer logic inside Views
- duplicated timer state

---

# 16. Design System Architecture

Reusable UI components belong in:
- Core/DesignSystem
- Core/Components

Examples:
- buttons
- cards
- progress rings
- typography
- spacing
- animations

---

# 17. Error Handling Strategy

The application uses lightweight user-friendly error handling.

ViewModels:
- transform domain errors into UI state
- avoid exposing raw framework errors

---

# 18. Testing Strategy

The application uses:
- Swift Testing

---

# 18.1 Unit Testing Priorities

Primary testing targets:
- use cases
- repositories
- timer logic
- ViewModels

---

# 18.2 UI Testing Priorities

Critical flows:
- onboarding
- task creation
- focus session
- restoration behavior

---

# 19. Scalability Strategy

The architecture intentionally starts lightweight.

Future scalability paths:
- widgets
- cloud sync
- watchOS
- AI-generated encouragement
- Siri integration

The architecture should evolve only when complexity genuinely requires it.

---

# 20. Anti-Patterns To Avoid

Avoid:
- massive ViewModels
- business logic inside Views
- excessive protocols
- generic abstraction overuse
- singleton abuse
- UIKit-style coordinator complexity
- premature modularization
- architecture for architecture’s sake

---

# 21. Engineering Philosophy

This project prioritizes:

- clarity over cleverness
- maintainability over abstraction
- UX polish over feature quantity
- intentional simplicity
- modern Apple platform practices

The final codebase should feel:
- modern
- scalable
- calm
- polished
- production-quality

```

# 22. iPad Navigation Strategy

The application supports adaptive navigation patterns.

Preferred navigation:
- NavigationStack on iPhone
- NavigationSplitView on iPad when appropriate

Layouts should adapt using:
- AnyLayout
- ViewThatFits
- size class awareness

Avoid:
- hardcoded device checks
- separate duplicated iPad screens

```