# Coding Guidelines

# 1. Overview

This document defines coding standards and engineering principles for the FocusUp project.

Goals:
- maintain consistency
- improve readability
- reduce bugs
- simplify collaboration
- improve AI-generated code quality
- support long-term maintainability

The project prioritizes:
- clarity
- simplicity
- modern Swift practices
- SwiftUI-first development

---

# 2. Core Principles

## Prioritize

- readability over cleverness
- simplicity over abstraction
- composition over inheritance
- explicitness over magic
- maintainability over premature optimization

---

# 3. Swift Version & Platform

## Requirements

- Swift 6+
- iOS 17.5+
- SwiftUI-first architecture

Use modern Apple APIs whenever appropriate.

Avoid legacy UIKit patterns unless absolutely necessary.

---

# 4. SwiftUI Guidelines

---

# 4.1 View Responsibilities

SwiftUI Views should:
- remain declarative
- focus on rendering
- remain lightweight
- avoid business logic

Views should NOT:
- access persistence directly
- perform complex calculations
- contain networking logic
- contain timer logic

---

# 4.2 View Composition

Prefer:
- small reusable views
- extracted components
- shallow hierarchies

Avoid:
- giant 500+ line views
- deeply nested stacks
- duplicated UI blocks

---

# 4.3 View Structure

Preferred ordering:

```swift id="sdg9ri"
struct TaskListView: View {

    // MARK: - Properties

    // MARK: - Body

    // MARK: - Components

    // MARK: - Actions

    // MARK: - Helpers
}
```

---

# 4.4 State Ownership

Use the smallest appropriate state scope.

| State Type | Preferred Wrapper |
|---|---|
| Local transient state | @State |
| Child mutation | @Binding |
| Shared observable state | @Observable |
| App-wide dependency | @Environment |
| Temporary restoration | @SceneStorage |

Avoid:
- duplicated state
- unnecessary bindings
- global mutable state

---

# 4.5 Navigation

Use:
- NavigationStack
- strongly typed destinations

Avoid:
- deeply nested navigation
- hidden navigation side effects

---

# 4.6 Animations

Animations should:
- feel smooth
- feel subtle
- improve UX clarity

Prefer:
- spring animations
- PhaseAnimator
- SymbolEffect

Avoid:
- excessive animation
- distracting transitions

---

# 5. ViewModel Guidelines

---

# 5.1 Responsibilities

ViewModels should:
- manage UI state
- coordinate use cases
- expose observable data
- transform domain models into UI-ready models

ViewModels should NOT:
- own persistence implementation
- directly manipulate SwiftData
- contain heavy business logic

---

# 5.2 Observation

Prefer:
- @Observable

Avoid:
- ObservableObject
- @Published

unless compatibility requires otherwise.

---

# 5.3 ViewModel Size

Recommended:
- under 300 lines

If larger:
- extract helpers
- extract services
- split responsibilities

Avoid:
- massive ViewModels

---

# 5.4 Async Logic

Prefer:
- async/await
- structured concurrency

Avoid:
- callback-based APIs
- deeply nested async chains

---

# 6. Domain Layer Guidelines

---

# 6.1 Domain Models

Domain models should:
- remain framework-independent
- avoid SwiftUI imports
- avoid persistence annotations

Prefer:

```swift id="jlwm8m"
struct Task
```

Avoid:
- coupling domain models to SwiftData

---

# 6.2 Use Cases

UseCases should:
- encapsulate business workflows
- remain lightweight
- stay feature-oriented

Avoid:
- use-case-per-CRUD-operation
- meaningless abstraction layers

---

# 6.3 Business Logic Placement

Business logic belongs in:
- UseCases
- domain services

NOT:
- SwiftUI Views
- reusable components

---

# 7. Persistence Guidelines

---

# 7.1 SwiftData Usage

SwiftData models should remain inside:
- Data/Persistence

Avoid:
- leaking SwiftData entities into Views

---

# 7.2 Repository Pattern

Repositories should:
- isolate persistence
- expose clean interfaces
- map entities to domain models

Views should never access repositories directly.

---

# 8. Dependency Injection

Preferred:
- initializer injection
- lightweight factories
- environment injection

Avoid:
- singleton-heavy architecture
- service locator patterns
- heavy DI frameworks

---

# 9. File Organization

---

# 9.1 One Responsibility Per File

Each file should ideally contain:
- one main type
- one clear responsibility

Avoid:
- multi-purpose files
- unrelated extensions grouped together

---

# 9.2 File Size Limits

Recommended limits:

| File Type | Recommended Max |
|---|---|
| View | 300 lines |
| ViewModel | 300 lines |
| UseCase | 250 lines |
| Service | 300 lines |

If exceeded:
- refactor
- extract components
- split responsibilities

---

# 9.3 Extensions

Group extensions logically.

Example:

```swift id="0l1s4j"
extension Date
extension Color
extension View
```

Avoid giant extension files.

---

# 10. Naming Conventions

---

# 10.1 General Naming

Use:
- clear descriptive names
- full words
- intention-revealing naming

Avoid:
- abbreviations
- vague naming

---

# 10.2 Type Naming

Examples:

```swift id="2fx9ps"
TaskListView
FocusSessionViewModel
ProgressCalculator
TaskRepository
```

Avoid:

```swift id="v4w55z"
TaskMgr
DataHandler
Utils
Helper
```

---

# 10.3 Boolean Naming

Prefer:

```swift id="x0lhmv"
isLoading
hasCompleted
canStartSession
```

Avoid:

```swift id="k6mh2l"
loading
done
available
```

---

# 11. Concurrency Guidelines

---

# 11.1 MainActor

UI updates must occur on:
- MainActor

Example:

```swift id="1mjlwm"
@MainActor
final class TaskListViewModel
```

---

# 11.2 Task Management

Prefer:
- cancellation-aware tasks
- structured concurrency

Avoid:
- detached tasks unless necessary

---

# 11.3 Async Safety

Avoid:
- race conditions
- duplicated async requests
- uncontrolled task spawning

---

# 12. Error Handling

---

# 12.1 Error Philosophy

Errors should:
- remain user-friendly
- provide actionable context
- avoid exposing framework internals

---

# 12.2 Error Placement

Transform technical errors into:
- presentation-friendly state

inside:
- ViewModels
- UseCases

---

# 13. Testing Guidelines

---

# 13.1 Testing Priorities

Highest priority:
- business logic
- timer logic
- ViewModels
- repositories

Lower priority:
- simple UI rendering

---

# 13.2 Testing Style

Use:
- Swift Testing
- descriptive test naming

Example:

```swift id="4rk8r5"
@Test("Completing milestone updates task progress")
```

---

# 13.3 Mocking

Prefer:
- lightweight mocks
- protocol-based testing seams

Avoid:
- excessive mocking frameworks

---

# 14. Preview Guidelines

Every reusable SwiftUI component should include:
- Preview support

Prefer:
- lightweight preview data
- preview-specific mocks

Example:

```swift id="r3l7zh"
#Preview {
    TaskCardView(task: .mock)
}
```

---

# 15. Design System Rules

Shared UI patterns belong in:
- Core/DesignSystem
- Core/Components

Avoid:
- duplicated button styles
- duplicated spacing logic
- inconsistent typography

---

# 16. Performance Guidelines

Avoid:
- unnecessary AnyView
- expensive recomputation
- large observable state trees
- heavy work inside body

Prefer:
- computed helpers
- extracted components
- lightweight state updates

---

# 17. Accessibility Guidelines

Support:
- Dynamic Type
- VoiceOver
- sufficient contrast
- reduced motion

Accessibility should be considered during implementation, not after.

---

# 18. Logging Guidelines

Prefer:
- lightweight debug logging
- structured logs

Avoid:
- noisy console spam
- debug prints committed to production code

---

# 19. Anti-Patterns To Avoid

Avoid:
- massive Views
- massive ViewModels
- singleton abuse
- premature abstraction
- protocol explosion
- UIKit-style imperative code
- deeply nested callbacks
- duplicated app state
- feature leakage across modules

---

# 20. AI-Generated Code Rules

When generating code with AI tools:

- prefer modern SwiftUI APIs
- prefer Observation framework
- keep architecture lightweight
- follow folder structure strictly
- avoid inventing unnecessary abstractions
- generate preview support
- generate testable code
- maintain feature boundaries

AI-generated code should feel:
- intentional
- maintainable
- production-quality

---

# 21. Engineering Philosophy

This codebase should feel:
- modern
- calm
- scalable
- polished
- readable

The project values:
- engineering craftsmanship
- user experience quality
- long-term maintainability
- pragmatic architecture decisions

```

# 22. Responsive Layout Rules

Always support:
- compact width
- regular width
- split screen multitasking
- landscape orientation

Prefer:
- adaptive stacks
- AnyLayout
- Grid
- ViewThatFits

Avoid:
- hardcoded frame widths
- device-specific branching
- duplicated iPhone/iPad views

```