# Folder Structure

# 1. Overview

The project uses a feature-first folder structure optimized for:

- SwiftUI
- MVVM-C
- Clean Architecture
- scalability
- maintainability
- discoverability

The structure intentionally avoids:
- overly deep nesting
- type-first organization
- unnecessary module fragmentation

Goals:
- keep related code close together
- improve navigation in large projects
- simplify onboarding
- improve Cursor AI consistency

---

# 2. Root Structure

```text
FocusUp/
├── App/
├── Features/
├── Core/
├── Domain/
├── Data/
├── Resources/
├── Tests/
└── Docs/
```

---

# 3. App Layer

Contains:
- app entry point
- global navigation
- app lifecycle
- app-wide dependency setup

```text
App/
├── AppEntry/
├── Navigation/
├── DependencyInjection/
└── Environment/
```

---

# 3.1 AppEntry

Contains:
- @main App
- root scene configuration
- app startup logic

Example:

```text
AppEntry/
├── FocusUpApp.swift
├── RootView.swift
└── AppCoordinator.swift
```

---

# 3.2 Navigation

Contains:
- root navigation
- shared navigation destinations
- app routing helpers

Example:

```text
Navigation/
├── AppRouter.swift
├── NavigationDestination.swift
└── TabCoordinator.swift
```

---

# 3.3 DependencyInjection

Contains:
- lightweight dependency container
- repository registration
- service registration

Example:

```text
DependencyInjection/
├── AppContainer.swift
└── DependencyFactory.swift
```

---

# 4. Features Layer

The Features folder is the heart of the application.

Each feature owns:
- Views
- ViewModels
- Coordinators
- Components
- UseCases
- Feature-specific Models

---

# 4.1 Feature Structure

```text
Features/
├── Home/
├── Tasks/
├── Focus/
├── Rest/
├── Statistics/
└── Settings/
```

---

# 4.2 Standard Feature Template

Each feature follows a consistent structure.

```text
FeatureName/
├── Views/
├── ViewModels/
├── Coordinator/
├── Components/
├── UseCases/
├── Models/
└── Extensions/
```

---

# 4.3 Example: Tasks Feature

```text
Tasks/
├── Views/
│   ├── TaskListView.swift
│   ├── TaskDetailView.swift
│   ├── CreateTaskView.swift
│   └── EditTaskView.swift
│
├── ViewModels/
│   ├── TaskListViewModel.swift
│   ├── TaskDetailViewModel.swift
│   └── CreateTaskViewModel.swift
│
├── Coordinator/
│   └── TasksCoordinator.swift
│
├── Components/
│   ├── TaskCardView.swift
│   ├── MilestoneView.swift
│   └── ProgressRingView.swift
│
├── UseCases/
│   └── TaskUseCase.swift
│
├── Models/
│   ├── TaskFilter.swift
│   └── TaskUIModel.swift
│
└── Extensions/
    └── Task+Preview.swift
```

---

# 5. Core Layer

Contains reusable application-wide utilities and shared UI.

```text
Core/
├── DesignSystem/
├── Components/
├── Extensions/
├── Utilities/
├── Constants/
├── Helpers/
├── Protocols/
└── Services/
```

---

# 5.1 DesignSystem

Contains:
- colors
- typography
- spacing
- reusable modifiers
- animation styles

Example:

```text
DesignSystem/
├── Colors/
├── Typography/
├── Spacing/
├── Animations/
├── Buttons/
└── Modifiers/
```

---

# 5.2 Components

Reusable shared UI components.

Only truly reusable components belong here.

Example:

```text
Components/
├── AppButton.swift
├── LoadingView.swift
├── EmptyStateView.swift
├── CountdownCircleView.swift
└── AppCardView.swift
```

Avoid moving feature-specific views into Core too early.

---

# 5.3 Extensions

Contains:
- Swift extensions
- Foundation extensions
- SwiftUI extensions

Example:

```text
Extensions/
├── Date+Extensions.swift
├── Color+Extensions.swift
├── View+Extensions.swift
└── String+Extensions.swift
```

---

# 5.4 Utilities

Contains:
- helper utilities
- lightweight shared logic

Example:

```text
Utilities/
├── DateFormatterHelper.swift
├── HapticManager.swift
└── TimeFormatter.swift
```

---

# 5.5 Constants

Contains:
- app constants
- spacing values
- animation durations
- notification identifiers

Example:

```text
Constants/
├── AppSpacing.swift
├── AnimationConstants.swift
└── NotificationConstants.swift
```

---

# 6. Domain Layer

Contains framework-independent business logic.

```text
Domain/
├── Models/
├── UseCases/
├── Repositories/
└── Services/
```

---

# 6.1 Models

Pure domain entities.

These should:
- remain framework-independent
- avoid SwiftUI imports
- avoid SwiftData annotations

Example:

```text
Models/
├── Task.swift
├── Milestone.swift
├── FocusSession.swift
└── UserPreferences.swift
```

---

# 6.2 UseCases

Contains business workflows.

Example:

```text
UseCases/
├── TaskUseCase.swift
├── FocusSessionUseCase.swift
└── StatisticsUseCase.swift
```

Avoid:
- one use case per CRUD operation

Prefer grouped feature logic.

---

# 6.3 Repositories

Repository contracts/protocols.

Example:

```text
Repositories/
├── TaskRepository.swift
├── FocusSessionRepository.swift
└── PreferencesRepository.swift
```

---

# 6.4 Services

Pure business services.

Example:

```text
Services/
├── MotivationMessageGenerator.swift
├── ProgressCalculator.swift
└── WorkloadEstimator.swift
```

---

# 7. Data Layer

Contains implementation details.

```text
Data/
├── Persistence/
├── Repositories/
├── Services/
├── DTOs/
└── Mappers/
```

---

# 7.1 Persistence

SwiftData entities and persistence logic.

Example:

```text
Persistence/
├── Entities/
├── Database/
└── Migrations/
```

---

# 7.2 Entities

SwiftData models.

Example:

```text
Entities/
├── TaskEntity.swift
├── MilestoneEntity.swift
└── FocusSessionEntity.swift
```

---

# 7.3 Repositories

Repository implementations.

Example:

```text
Repositories/
├── TaskRepositoryImpl.swift
├── FocusSessionRepositoryImpl.swift
└── PreferencesRepositoryImpl.swift
```

---

# 7.4 Services

Framework/system integrations.

Example:

```text
Services/
├── NotificationService.swift
├── LiveActivityService.swift
└── BackgroundTaskService.swift
```

---

# 7.5 DTOs

Only use DTOs when necessary.

Avoid excessive DTO abstraction in MVP.

Example:

```text
DTOs/
└── NotificationPayload.swift
```

---

# 7.6 Mappers

Mapping between:
- SwiftData entities
- domain models

Example:

```text
Mappers/
├── TaskMapper.swift
└── SessionMapper.swift
```

---

# 8. Resources Layer

Contains application resources.

```text
Resources/
├── Assets.xcassets
├── Fonts/
├── Localization/
└── PreviewContent/
```

---

# 8.1 Localization

Prepared for future localization support.

Example:

```text
Localization/
├── en.lproj/
└── vi.lproj/
```

---

# 9. Tests Layer

```text
Tests/
├── UnitTests/
├── UITests/
└── PreviewMocks/
```

---

# 9.1 UnitTests

Focus on:
- use cases
- repositories
- ViewModels
- timer logic

Example:

```text
UnitTests/
├── Domain/
├── Data/
└── Features/
```

---

# 9.2 UITests

Critical flow testing.

Example:

```text
UITests/
├── FocusFlowTests.swift
├── TaskCreationTests.swift
└── RestorationTests.swift
```

---

# 9.3 PreviewMocks

Reusable SwiftUI preview data.

Example:

```text
PreviewMocks/
├── MockTasks.swift
└── MockSessions.swift
```

---

# 10. Docs Layer

Contains technical documentation.

```text
Docs/
├── architecture.md
├── product_requirements.md
├── coding_guidelines.md
├── state_management.md
├── design_system.md
├── persistence.md
├── feature_breakdown.md
├── roadmap.md
└── cursor_rules.md
```

---

# 11. Naming Conventions

## Files

Use:
- PascalCase
- descriptive names

Examples:

```text
TaskListView.swift
FocusSessionViewModel.swift
ProgressRingView.swift
```

Avoid:
- abbreviations
- generic names like Manager.swift

---

# 12. File Organization Principles

## Principles

- keep related files together
- prefer shallow hierarchy
- organize by feature first
- avoid giant shared folders
- avoid premature modularization

---

# 13. Scalability Strategy

The structure should evolve gradually.

Only extract modules when:
- compile time becomes problematic
- feature boundaries become large
- independent deployment becomes necessary

Do NOT modularize prematurely.

---

# 14. Anti-Patterns To Avoid

Avoid:
- type-first organization
- giant Helpers folder
- feature leakage
- over-nested directories
- shared folder abuse
- massive Core folder
- protocol explosion

---

# 15. Engineering Philosophy

The folder structure should feel:
- predictable
- scalable
- modern
- lightweight
- easy to navigate

The structure prioritizes:
- clarity
- maintainability
- feature ownership
- SwiftUI-first development

```