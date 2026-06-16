# Cursor Rules

# 1. Overview

This document defines mandatory coding and architectural rules for AI-generated code inside the FocusUp project.

Goals:
- maintain architectural consistency
- reduce technical debt
- improve maintainability
- ensure modern SwiftUI practices
- avoid overengineering
- generate production-quality code

All generated code should follow:
- SwiftUI-first development
- MVVM-C
- pragmatic Clean Architecture
- feature-first organization
- modern Apple platform APIs

---

# 2. Core Philosophy

Always prioritize:
- readability
- maintainability
- simplicity
- explicitness
- modern SwiftUI practices

Avoid:
- unnecessary abstractions
- enterprise-style boilerplate
- overengineered patterns
- UIKit-style imperative architecture

---

# 3. Technology Stack Rules

Always use:

| Area | Technology |
|---|---|
| UI | SwiftUI |
| Persistence | SwiftData |
| State | Observation framework |
| Navigation | NavigationStack |
| Async | async/await |
| Testing | Swift Testing |
| Architecture | MVVM-C |

Minimum target:
- iOS 17.5+

---

# 4. SwiftUI Rules

---

# 4.1 SwiftUI-First

Always prefer:
- native SwiftUI APIs
- declarative UI
- modern SwiftUI modifiers

Avoid:
- UIKit wrappers unless absolutely necessary
- UIViewRepresentable without clear justification

---

# 4.2 View Responsibilities

Views should:
- remain declarative
- render UI only
- avoid business logic
- avoid persistence logic

Views should NOT:
- directly access repositories
- perform heavy calculations
- manage timer internals

---

# 4.3 Component Extraction

Extract reusable UI components when:
- repeated more than twice
- visually reusable
- improves readability

Avoid:
- overcomponentization
- tiny meaningless wrappers

---

# 4.4 View File Size

Preferred maximum:
- 300 lines per View

If larger:
- extract components
- extract modifiers
- simplify responsibilities

---

# 5. State Management Rules

---

# 5.1 Observation Framework

Always prefer:
- @Observable

Avoid:
- ObservableObject
- @Published

unless compatibility requires them.

---

# 5.2 Wrapper Usage

Use:

| Scenario | Wrapper |
|---|---|
| Local state | @State |
| Child mutation | @Binding |
| Shared screen state | @Observable |
| App dependency | @Environment |
| Restoration state | @SceneStorage |

Avoid:
- duplicated state
- giant global app state

---

# 5.3 SceneStorage Rules

Use SceneStorage for:
- navigation restoration
- selected tab
- temporary drafts
- active timer state

Do NOT use SceneStorage for:
- permanent business persistence

---

# 6. Architecture Rules

---

# 6.1 MVVM-C

Always follow:
- View
- ViewModel
- Coordinator

Responsibilities:
- View → rendering
- ViewModel → screen state
- Coordinator → navigation

---

# 6.2 Clean Architecture

Follow:
- Presentation layer
- Domain layer
- Data layer

Keep boundaries clean.

Avoid:
- leaking persistence into presentation
- business logic inside Views

---

# 6.3 Repository Pattern

Repositories should:
- isolate SwiftData
- expose domain models
- remain async-friendly

Views should never access repositories directly.

---

# 6.4 Use Case Rules

UseCases should:
- encapsulate meaningful business workflows
- remain feature-oriented

Avoid:
- one use case per CRUD operation
- meaningless abstractions

---

# 7. Folder Structure Rules

Always follow the documented folder structure.

New files must be placed in:
- correct feature folder
- correct architectural layer

Avoid:
- dumping unrelated files into Core
- giant Helpers folders

---

# 8. File Naming Rules

Use:
- PascalCase
- descriptive names

Examples:

```text id="v3z8n3"
TaskListView.swift
FocusSessionViewModel.swift
ProgressRingView.swift
```

Avoid:
- abbreviations
- vague names

Examples to avoid:

```text id="7h8hwy"
Utils.swift
Helper.swift
Manager.swift
```

---

# 9. Concurrency Rules

Always use:
- async/await
- structured concurrency

Avoid:
- callback-based APIs
- detached tasks unless necessary

UI updates must occur on:
- MainActor

---

# 10. SwiftData Rules

SwiftData entities must:
- remain inside Data/Persistence

Domain models must:
- remain framework-independent

Always map:
- entities ↔ domain models

Avoid:
- exposing SwiftData entities to Views

---

# 11. Navigation Rules

Use:
- NavigationStack
- typed navigation

Avoid:
- hidden navigation side effects
- navigation logic inside reusable components

---

# 12. Timer Rules

Timer logic must:
- live outside SwiftUI Views
- support restoration
- support background continuation

Prefer:
- TimelineView
- ActivityKit

Avoid:
- timer state duplication
- Timer logic directly inside body

---

# 13. UI & Design Rules

Follow:
- design_system.md
- screenshot references
- calm visual style

Preserve:
- spacing consistency
- typography hierarchy
- dark mode quality

Avoid:
- cluttered layouts
- aggressive gradients
- inconsistent styling

---

# 14. Universal Layout Rules

All generated UI must support:
- iPhone
- iPad
- portrait
- landscape
- split view multitasking

Prefer:
- AnyLayout
- adaptive Grid layouts
- NavigationSplitView when appropriate
- responsive spacing

Avoid:
- hardcoded widths/heights
- iPhone-only assumptions
- full-width stretched content on iPad

---

# 15. Animation Rules

Prefer:
- subtle animations
- spring animations
- smooth transitions

Use:
- PhaseAnimator
- SymbolEffect

Avoid:
- flashy animations
- excessive motion

---

# 16. Accessibility Rules

All generated UI should support:
- Dynamic Type
- VoiceOver
- sufficient contrast
- minimum 44pt touch targets

Accessibility is NOT optional.

---

# 17. Testing Rules

Use:
- Swift Testing

Priority testing targets:
- ViewModels
- repositories
- use cases
- timer logic

Avoid:
- unnecessary mocking complexity

---

# 18. Preview Rules

Reusable Views should include:
- #Preview support

Use:
- lightweight mock data
- preview helpers

Example:

```swift id="6r6th1"
#Preview {
    TaskCardView(task: .mock)
}
```

---

# 19. Performance Rules

Avoid:
- unnecessary AnyView
- deeply nested stacks
- giant observable state trees
- heavy work inside body

Prefer:
- extracted subviews
- computed properties
- lightweight rendering

---

# 20. Error Handling Rules

Errors should:
- remain user-friendly
- avoid exposing raw system details

Transform:
- technical errors → presentation-friendly state

inside:
- ViewModels
- UseCases

---

# 21. Logging Rules

Prefer:
- lightweight debug logs
- structured logging

Avoid:
- excessive print statements
- noisy debugging output

---

# 22. Documentation Rules

When generating new architecture or feature code:
- follow existing docs
- keep consistency with current structure
- avoid inventing new patterns without justification

Important reference documents:
- architecture.md
- coding_guidelines.md
- state_management.md
- design_system.md
- persistence.md

---

# 23. Code Generation Style

Generated code should feel:
- intentional
- production-quality
- modern
- readable
- scalable

Avoid:
- tutorial-style code
- beginner patterns
- unnecessary comments everywhere

Comments should explain:
- intent
- architectural reasoning
- non-obvious behavior

NOT:
- obvious syntax

---

# 24. Anti-Patterns To Avoid

Avoid:
- massive Views
- massive ViewModels
- singleton abuse
- protocol explosion
- generic overengineering
- business logic inside Views
- persistence logic inside UI
- UIKit-style imperative flows
- giant utility classes
- premature modularization

---

# 25. Preferred Engineering Style

Prefer:
- composition
- feature ownership
- lightweight abstractions
- predictable state
- SwiftUI-native solutions

The codebase should feel:
- modern
- clean
- calm
- maintainable
- Apple-platform-native

---

# 26. Final Rule

When uncertain:
- prefer simpler architecture
- prefer readability
- prefer maintainability
- follow existing project patterns

Do NOT introduce:
- new architecture styles
- heavy frameworks
- complex abstractions

unless clearly justified by real complexity.

```