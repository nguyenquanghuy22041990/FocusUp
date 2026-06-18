# State Management

# 1. Overview

This document defines the state management strategy for FocusUp.

Goals:
- predictable UI behavior
- minimal duplicated state
- clear ownership boundaries
- reliable restoration
- smooth SwiftUI rendering
- maintainable feature architecture

The project uses:
- SwiftUI
- Observation framework
- SceneStorage
- unidirectional data flow

The architecture prioritizes:
- simplicity
- explicit ownership
- lightweight state propagation

---

# 2. Core Principles

## State Management Philosophy

The application follows these principles:

- single source of truth
- localize state whenever possible
- derive state instead of duplicating it
- avoid unnecessary shared mutable state
- keep UI reactive and predictable

---

# 3. State Ownership Hierarchy

State should live at the highest appropriate level, but no higher.

Preferred ownership order:

| Scope | Owner |
|---|---|
| Local UI state | View |
| Screen state | ViewModel |
| Feature state | Feature Coordinator |
| App-wide dependencies | Environment |
| Persistent data | SwiftData |

---

# 4. State Types

---

# 4.1 Local Transient State

Use:
- @State

For:
- toggles
- temporary UI interaction
- animations
- local sheet visibility
- focus state

Example:

```swift id="n6ksjq"
@State private var isShowingSheet = false
```

Avoid storing:
- business data
- shared feature state

inside @State.

---

# 4.2 Child View Mutation

Use:
- @Binding

For:
- controlled child mutations
- form field propagation
- lightweight state sharing

Example:

```swift id="v9z4f0"
@Binding var title: String
```

Avoid:
- deep binding chains
- binding-heavy architecture

---

# 4.3 Shared Observable State

Use:
- @Observable

For:
- screen state
- feature state
- ViewModels

Example:

```swift id="l2h0uv"
@Observable
final class TaskListViewModel {
    var tasks: [Task] = []
    var isLoading = false
}
```

Prefer:
- Observation framework

Avoid:
- ObservableObject
- @Published

unless compatibility requires otherwise.

---

# 4.4 Environment State

Use:
- @Environment

For:
- app-wide services
- theme access
- shared dependencies

Examples:
- router
- app settings
- dependency container

Avoid:
- large mutable app-wide state stores

---

# 4.5 Scene Restoration State

Use:
- @SceneStorage

For:
- temporary restoration
- navigation restoration
- lightweight UI persistence

Examples:
- selected tab
- current navigation path
- draft form input
- timer screen state
- selected filters

---

# 4.6 Persistent Business State

Use:
- SwiftData

For:
- tasks
- milestones
- sessions
- preferences
- statistics

Persistent state should NOT rely on:
- @State
- SceneStorage

---

# 5. Recommended Wrapper Usage

| Scenario | Recommended Wrapper |
|---|---|
| Temporary button state | @State |
| Form field binding | @Binding |
| Screen ViewModel | @Observable |
| App-level dependency | @Environment |
| Navigation restoration | @SceneStorage |
| Persistent data | SwiftData |

---

# 6. ViewModel State Strategy

---

# 6.1 Responsibilities

ViewModels own:
- screen state
- loading state
- UI transformations
- async coordination
- use case interaction

ViewModels should NOT:
- own persistence implementation
- contain framework-heavy logic
- manipulate navigation directly

---

# 6.2 Example ViewModel

```swift id="p6z0eq"
@MainActor
@Observable
final class FocusSessionViewModel {

    var remainingTime: TimeInterval = 0
    var isRunning = false
    var selectedTask: Task?

    private let sessionUseCase: FocusSessionUseCase

    init(sessionUseCase: FocusSessionUseCase) {
        self.sessionUseCase = sessionUseCase
    }
}
```

---

# 6.3 Derived State

Prefer computed properties over duplicated state.

## Prefer

```swift id="gllr5g"
var progressPercentage: Double {
    completedMilestones / totalMilestones
}
```

## Avoid

```swift id="92r04t"
var completedMilestones: Int
var progressPercentage: Double
```

when one can derive the other.

---

# 7. SceneStorage Strategy

SceneStorage is a key part of the architecture.

The app should restore interrupted user flows smoothly.

---

# 7.1 SceneStorage Responsibilities

Use SceneStorage for:
- selected tab
- active timer state
- current navigation path
- active screen
- temporary draft input
- selected task filter

---

# 7.2 Example

```swift id="qv7b0h"
@SceneStorage("selectedTab")
private var selectedTab = 0
```

---

# 7.3 SceneStorage Rules

SceneStorage should:
- remain lightweight
- store small serializable values
- support temporary restoration only

Avoid storing:
- large models
- business entities
- session history
- persistent application data

---

# 8. Navigation State

Navigation should remain:
- predictable
- centralized
- restorable

Use:
- NavigationStack
- typed destinations

Avoid:
- hidden navigation side effects
- duplicated navigation sources

---

# 8.1 Navigation Restoration

Navigation state may be restored using:
- SceneStorage
- lightweight navigation paths

---

# 9. Timer State Management

Focus and rest timers are state-heavy features.

Timer state should remain:
- centralized
- interruption-safe
- background-safe

---

# 9.1 Timer State Ownership

Timer logic belongs in:
- dedicated ViewModel
- timer service
- use case layer

NOT inside:
- SwiftUI Views

---

# 9.2 Timer Restoration

Timer state should survive:
- app backgrounding
- interruptions
- temporary app termination

Use:
- SceneStorage
- persistence snapshot if needed

---

# 9.3 Recommended Timer Data

Persist:
- start time
- duration
- remaining time
- session type
- related task ID

Avoid:
- relying only on active Timer instances

---

# 10. Async State Management

---

# 10.1 Loading State

Use explicit loading state.

Example:

```swift id="9xeh7x"
var isLoading = false
```

Avoid:
- implicit loading assumptions

---

# 10.2 Error State

Expose presentation-friendly errors.

Example:

```swift id="ztkgxk"
var errorMessage: String?
```

Avoid:
- exposing raw framework errors directly to UI

---

# 10.3 Task Cancellation

Async tasks should support cancellation whenever appropriate.

Example:
- leaving screen
- canceling timer
- restarting session

---

# 11. Persistence Synchronization

SwiftData is the source of truth for business persistence.

Flow:

```text
SwiftData
    ↓
Repository
    ↓
UseCase
    ↓
ViewModel
    ↓
SwiftUI View
```

Avoid:
- bypassing repository layer
- direct View access to SwiftData

---

# 12. Environment Strategy

Environment should remain lightweight.

Recommended environment objects:
- app router
- theme manager
- dependency container

Avoid:
- placing all app state in environment

---

# 13. UI State Guidelines

---

# 13.1 Keep UI State Local

Prefer local state whenever possible.

Example:
- sheet visibility
- animation trigger
- temporary text field focus

Avoid promoting temporary UI state unnecessarily.

---

# 13.2 Avoid State Duplication

Avoid patterns like:

```swift id="h2q3gh"
var tasks: [Task]
var filteredTasks: [Task]
```

Prefer computed state:

```swift id="9j4w4o"
var filteredTasks: [Task] {
    tasks.filter { ... }
}
```

---

# 14. Performance Guidelines

Avoid:
- giant observable objects
- excessive re-rendering
- unnecessary state propagation
- deeply shared mutable state

Prefer:
- feature-local observable state
- lightweight computed properties
- extracted subviews

---

# 15. Testing Strategy

State logic should remain testable.

Priority testing targets:
- ViewModels
- timer restoration
- task progress logic
- state transitions

Avoid:
- hidden state mutations
- implicit side effects

---

# 16. Anti-Patterns To Avoid

Avoid:
- massive global app state
- singleton-driven state
- duplicated observable state
- business logic inside Views
- state mutation from multiple sources
- persistence logic inside UI
- binding chains across many layers

---

# 17. Engineering Philosophy

State management should feel:
- predictable
- lightweight
- scalable
- interruption-safe
- SwiftUI-native

The architecture prioritizes:
- clear ownership
- modern Observation APIs
- restoration reliability
- maintainable feature boundaries

```