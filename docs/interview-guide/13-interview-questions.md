# 13 — Interview Questions (100+)

Senior-level answers tied to FocusUp. Reference files when discussing in person.

---

## Swift (1–12)

**Q1: Why are domain models `struct` instead of `class`?**  
**A:** Value semantics, `Sendable` safety, predictable copies. `Task`, `FocusSession` in `Domain/` have no shared mutable identity across layers.

**Q2: What is `Sendable` used for here?**  
**A:** Domain enums/structs cross concurrency boundaries safely. Managers stay `@MainActor`; domain types pass data without data races.

**Q3: Explain `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` impact.**  
**A:** Unannotated types default to MainActor. Caught `AppForegroundRefresh` accessing session managers from nonisolated async — fixed with `@MainActor`.

**Q4: Why `_Concurrency.Task` in views?**  
**A:** Button actions are sync; wrapping `await manager.pause()` creates async context without blocking UI.

**Q5: Value vs reference types for ViewModels?**  
**A:** ViewModels are `@Observable` **classes** — shared identity across view hierarchy. Domain stays struct.

**Q6: How do you avoid retain cycles?**  
**A:** Minimal closures capturing `self` in managers; no Combine chains. `onCompleted` on permission VM is optional callback — caller owns lifecycle.

**Q7: What protocols use `any` in the codebase?**  
**A:** `any TaskRepository`, `any Clock` — existentials for DI. Trade-off: slight runtime cost vs. flexibility.

**Q8: Why `Codable` on routes and restoration state?**  
**A:** `PersistedNavigationState`, timer snapshots encode to SceneStorage/UserDefaults.

**Q9: Explain `guard` heavy style in managers.**  
**A:** `FocusSessionManager.pauseSession()` guards `activeSession` — fail fast with typed errors (`FocusSessionManagerError`).

**Q10: When use `enum` with associated values?**  
**A:** `TasksRoute.detail(UUID)`, `DashboardLoadingState.failed(String)` — type-safe state.

**Q11: Why separate `FocusSession+Timing` extension?**  
**A:** Keeps core model small; timing math grouped for tests and restoration.

**Q12: What Swift 6 concurrency features matter here?**  
**A:** Strict isolation checking in CI; `@MainActor` discipline; `async let` in orchestrator.

---

## SwiftUI (13–24)

**Q13: Why `@Observable` over `ObservableObject`?**  
**A:** Less boilerplate; SwiftUI 5 integration; no `@Published`. Used on all major ViewModels.

**Q14: When use `@Bindable`?**  
**A:** When child needs bindings to `@Observable` — `FocusTimerView(@Bindable var viewModel:)`.

**Q15: Why `@State` for optional ViewModels in `FocusView`?**  
**A:** Lazy creation per route; VMs created when navigating to active/rest screens.

**Q16: Explain `NavigationStack(path:)` binding.**  
**A:** `TabCoordinator.path` drives stack; programmatic push `.activeSession` on restore.

**Q17: How inject dependencies in SwiftUI?**  
**A:** Custom `EnvironmentKey` — `\.appContainer` set in `App.swift`.

**Q18: What is `@SceneStorage` used for?**  
**A:** Timer snapshot `Data` in `AppRootView` — survives short process death within scene.

**Q19: How handle Dynamic Type?**  
**A:** `@Environment(\.dynamicTypeSize)` on timer displays; design system fonts scale.

**Q20: Why hide tab bar during active timer?**  
**A:** `ActiveTimerTabBarVisibility` — immersive focus UX; prevents accidental tab switch.

**Q21: How do previews get dependencies?**  
**A:** `.appContainer(.preview)` — in-memory persistence, no-op services.

**Q22: `@ViewBuilder` purpose in timer views?**  
**A:** Compose conditional sections (setup vs active) as single `body` without `AnyView`.

**Q23: How respect Reduce Motion?**  
**A:** `focusMotionReduced` environment from user prefs + system setting; disables breathing animations.

**Q24: Why not use `@FetchRequest` / `@Query` in views?**  
**A:** Repository pattern keeps domain testable; views don't talk to SwiftData directly.

---

## Architecture (25–36)

**Q25: Describe MVVM-C in one sentence.**  
**A:** Views bind to ViewModels for state; Coordinators own navigation; Models live in Domain.

**Q26: Where is business logic?**  
**A:** Domain calculators, validation, session managers, orchestrators — not in Views.

**Q27: Why session managers separate from ViewModels?**  
**A:** Shared between `FocusTimerViewModel` and `DashboardOrchestrator`; single source of truth for `activeSession`.

**Q28: What is `DashboardOrchestrator`?**  
**A:** Facade coordinating repo reads + session state into `DashboardSnapshot` via `DashboardStateAggregator`.

**Q29: Why empty `Domain/Usecases/`?**  
**A:** Use cases folded into managers/orchestrators for MVP — pragmatic, not ceremonial Clean Architecture.

**Q30: How do features stay decoupled?**  
**A:** Shared Domain/Core only; `TaskUpdateNotifier` for cross-feature events; no Feature→Feature imports.

**Q31: Why feature-first folders?**  
**A:** `docs/folder_structure.md` — colocate UI, VM, feature logic; faster navigation than layer-first.

**Q32: Presentation layer empty?**  
**A:** `Presentation/` placeholder unused — coordinators replaced planned router layer.

**Q33: How would you modularize with SPM?**  
**A:** `FocusUpDomain`, `FocusUpData`, `FocusUpFeaturesTasks` — extract when team/size grows.

**Q34: Offline-first implications?**  
**A:** No network repos; all sync is local; notifications scheduled locally.

**Q35: What's the dependency rule?**  
**A:** Features → Domain/Core/Data; Domain imports nothing UI-related.

**Q36: How does rest relate to focus architecturally?**  
**A:** Separate managers/repos; shared Focus tab navigation; parallel code paths.

---

## State Management (37–46)

**Q37: Single source of truth for active focus session?**  
**A:** `FocusSessionManager.activeSession` + SwiftData persistence.

**Q38: How does dashboard know session changed?**  
**A:** `onChange` of session id/status; `onSessionContinuityChanged()` on ViewModel.

**Q39: Loading states pattern?**  
**A:** `DashboardLoadingState` enum: idle/loading/loaded/failed(String).

**Q40: Form draft state?**  
**A:** `CreateTaskDraft` + `FormDraftManager` + SceneStorage restoration modifier.

**Q41: Navigation state ownership?**  
**A:** `AppCoordinator` + per-tab `TabCoordinator.path`.

**Q42: User preferences flow?**  
**A:** `UserPreferencesRepository` → SwiftData; read on launch for haptics/motion.

**Q43: Timer UI state vs engine state?**  
**A:** `TimerEngine` owns truth; ViewModel exposes formatted remaining/progress.

**Q44: Error state in task detail?**  
**A:** `TaskDetailViewState.error(String)` — explicit UI state.

**Q45: Why `TaskUpdateNotifier` instead of shared VM?**  
**A:** Decouples task mutations from notification scheduler in `AppRootView`.

**Q46: Cold restore flag purpose?**  
**A:** `hasCompletedColdRestore` — blocks foreground refresh until restore finishes.

---

## Concurrency (47–58)

**Q47: Why `@MainActor` on `AppContainer`?**  
**A:** All wired services touch UI or main-thread APIs.

**Q48: How test async managers?**  
**A:** `@MainActor` test structs; `await manager.startSession()` in Swift Testing.

**Q49: Timer loop cancellation?**  
**A:** `while !Task.isCancelled` in `runTimerLoop()`; `.task` cancels on disappear.

**Q50: `async let` usage?**  
**A:** `DashboardOrchestrator.refresh()` parallelizes analytics + tasks fetch.

**Q51: Race when starting two sessions?**  
**A:** `sessionAlreadyActive` error — manager rejects double start.

**Q52: Is `TimerEngine` thread-safe?**  
**A:** MainActor-isolated; only called from main actor loop.

**Q53: Why inject `Clock`?**  
**A:** `TestClock` advances time deterministically in tests.

**Q54: Scene phase and concurrency?**  
**A:** Foreground `Task { await AppForegroundRefresh.perform }` — async work off button handlers.

**Q55: Cancellation in `TaskDetailViewModel.load`?**  
**A:** Checks `Task.isCancelled` before setting state — avoids stale UI.

**Q56: Structured vs unstructured tasks?**  
**A:** Prefer structured `.task` and scoped `Task {}`; no detached tasks in production.

**Q57: CI concurrency lesson?**  
**A:** Nonisolated async + MainActor properties = compile error on strict CI — pin Xcode.

**Q58: Sendable closures in modifiers?**  
**A:** Restoration modifiers run on MainActor; snapshots are `Codable` value data.

---

## Testing (59–70)

**Q59: Why Swift Testing?**  
**A:** `@Test`, tags, clean async; 236 cases organized by feature.

**Q60: What's `.production` tag?**  
**A:** Smoke tests for critical paths — `ProductionSmokeTests`.

**Q61: How mock repositories?**  
**A:** `MockTaskRepository` with in-memory array; inject into ViewModels.

**Q62: Why Cuckoo only for `Clock`?**  
**A:** `@MainActor` protocols crash Cuckoo generator — hand-written mocks otherwise.

**Q63: Why commit `GeneratedMocks.swift`?**  
**A:** CI doesn't run generator; deterministic builds.

**Q64: Integration test example?**  
**A:** `RestorationIntegrationTests` — full restore pipeline with in-memory DB.

**Q65: Stress test example?**  
**A:** `FocusSessionLifecycleStressTests` — rapid pause/resume, boundary auto-complete.

**Q66: Why no UI tests in CI?**  
**A:** Template XCUITest; slow; unit tests give better ROI for MVP.

**Q67: Logic vs total coverage?**  
**A:** 83% logic / 38% total — policy excludes views by design.

**Q68: How test navigation without UI?**  
**A:** Assert `coordinator.tabCoordinators.focus.path` after coordinator calls.

**Q69: `AppContainer.testing` limitation?**  
**A:** Uses preview repos — I'd switch to in-memory `Repositories.live` for fidelity.

**Q70: Test organization principle?**  
**A:** Mirror `Features/` and `Domain/` in `FocusUpTests/`.

---

## CI/CD (71–80)

**Q71: When does CI run?**  
**A:** PRs to develop/main; pushes to develop/main — not feature-only pushes.

**Q72: Why one job?**  
**A:** MVP simplicity; single macOS pipeline is standard for small iOS apps.

**Q73: Why pin Xcode 26.5?**  
**A:** Reproducibility; fixed MainActor strictness mismatch.

**Q74: What fails CI?**  
**A:** Compile error, test failure, logic coverage &lt; 80%, simulator not found.

**Q75: Why dynamic simulator selection?**  
**A:** Runner images change device names; Python picks first available iPhone.

**Q76: Artifacts uploaded?**  
**A:** `TestResults.xcresult` always — debug failures in Xcode.

**Q77: Concurrency group purpose?**  
**A:** Cancel superseded runs on same ref — save macOS minutes.

**Q78: Missing from CI?**  
**A:** SwiftLint, TestFlight, SPM cache, path filters.

**Q79: Android CI difference?**  
**A:** Ubuntu, ktlint+detekt+test, path-filtered — separate project.

**Q80: How coverage reported in GitHub UI?**  
**A:** `logic_coverage.py` writes Step Summary markdown table.

---

## Persistence (81–92)

**Q81: Why SwiftData over Core Data?**  
**A:** Modern Swift API, less boilerplate; fits MVP. Trade-off: migrations less mature.

**Q82: How map entity to domain?**  
**A:** `TaskMapper.toDomain` / `toEntity` in `Data/Mappers/`.

**Q83: Active session query?**  
**A:** `FocusRepository.fetchActive()` on cold launch.

**Q84: Statistics storage?**  
**A:** Computed — no Statistics entity; `StatisticsRepositoryImpl` aggregates sessions.

**Q85: Milestone relationship?**  
**A:** `TaskEntity` cascade to `TaskMilestoneEntity`.

**Q86: In-memory testing?**  
**A:** `PersistenceController(inMemory: true)` in tests.

**Q87: `fatalError` concern?**  
**A:** `PersistenceController.shared` crashes on init failure — should show recovery UI.

**Q88: Migrations strategy?**  
**A:** None explicit yet — additive schema changes only for MVP.

**Q89: SceneStorage vs SwiftData?**  
**A:** SwiftData authoritative for sessions; SceneStorage for fast timer UI restore.

**Q90: UserDefaults backup role?**  
**A:** `AppRestorationStore` — survives scene loss; secondary to DB.

**Q91: CRUD from create task flow?**  
**A:** `CreateTaskViewModel` validates → `repository.create` → notifier.

**Q92: Preferences persistence?**  
**A:** `UserPreferencesRepositoryImpl` → `UserPreferencesEntity`.

---

## Performance, DI, Accessibility (93–108)

**Q93: Performance optimization for timers?**  
**A:** Wall-clock math; 1s tick; loop only when scene active.

**Q94: Statistics performance?**  
**A:** In-memory cache until `invalidateCache()`.

**Q95: Memory with audio?**  
**A:** Single `AVAudioPlayer`; stopped on `stop()`.

**Q96: Why manual DI?**  
**A:** Explicit graph in `AppContainer`; no magic for interview clarity.

**Q97: Environment vs constructor injection?**  
**A:** Container via environment; ViewModels get specific deps in `init` for testability.

**Q98: VoiceOver on timer?**  
**A:** `FocusSession+Accessibility` labels; remaining time announced.

**Q99: Dynamic Type on dashboard?**  
**A:** Design system typography scales; tests in `DesignSystemAccessibilityTests`.

**Q100: Touch targets?**  
**A:** 44pt minimum per design system docs.

**Q101: Reduce Motion?**  
**A:** User pref + system; disables calm breathing on rest screen.

**Q102: iPad layout?**  
**A:** `AdaptiveRootNavigationView` sidebar on regular size class.

**Q103: Lazy loading tasks?**  
**A:** `fetchAll` on appear — OK for MVP; paginate later.

**Q104: Profiling target?**  
**A:** Timer view body recomputation; cold launch restore duration.

**Q105: Factory methods on container?**  
**A:** `.live`, `.preview`, `.testing` — different graphs for prod/previews/tests.

**Q106: Protocol-oriented DI benefit?**  
**A:** Swap `NoOpNotificationService` in tests without changing scheduler code.

**Q107: Chart accessibility?**  
**A:** `StatisticsFormatting` provides spoken summaries.

**Q108: Haptic feedback DI?**  
**A:** `HapticFeedbackCoordinator` via environment; disabled from preferences.

---

## Navigation, Errors, Features (109–120)

**Q109: Typed routes benefit?**  
**A:** Compile-time safety; `navigationDestination(for: FocusRoute.self)`.

**Q110: Cross-tab navigation example?**  
**A:** Dashboard priority tap → `selectTab(.tasks)` + `push(.detail(id))`.

**Q111: Stale route cleanup?**  
**A:** `clearStaleFocusSessionRoutes` when no active session on foreground.

**Q112: Back lock during timer?**  
**A:** `navigationBackLocked` — prevents accidental exit mid-session.

**Q113: Deep links?**  
**A:** `AppDeepLink` parsed into coordinator actions.

**Q114: Error handling in dashboard load?**  
**A:** `loadingState = .failed(message)` — user sees error view.

**Q115: Silent errors in restore?**  
**A:** Some `try?` — prefer partial restore over crash; trade-off for UX.

**Q116: Quiet hours edge case?**  
**A:** Midnight-spanning quiet period — special deadline reminder fallback.

**Q117: Auto-complete bug fix?**  
**A:** `tick()` now `async` calls `completeSession()` — persist + clear session.

**Q118: Priority engine limits?**  
**A:** Max 5 tasks; scoring weights in `DashboardPriorityEngine`.

**Q119: Task filter logic?**  
**A:** Today = todo|inProgress; Upcoming = todo; Completed = completed.

**Q120: Live Activity lifecycle?**  
**A:** Start on session start; sync on pause; end on complete; dismissed if no session on foreground.

---

## Bonus: Rapid-Fire (121–108 condensed extras)

**Q121: Notification types?** Session complete, deadline, focus reminder, motivation.  
**Q122: Rest notifications?** None on rest complete — intentional calm.  
**Q123: Cuckoo version?** 2.3.0 test-only.  
**Q124: Deployment target?** iOS 17.5.  
**Q125: God object risk?** `AppContainer` — mitigated by protocol repos.  
**Q126: Placeholder features?** Focus history, statistics drill-down.  
**Q127: Widget extension?** `FocusTimerWidget` excluded from coverage.  
**Q128: Bundle sounds?** `Sounds/focus_sounds`, `rest_sounds`.  
**Q129: Haptics?** `HapticFeedbackCoordinator` on key actions.  
**Q130: Production readiness doc?** `docs/PRODUCTION_READINESS.md` — MVP-1 validated.

---

## How to Use This Doc

1. Pick 10 random questions — answer aloud in 60 seconds each  
2. For architecture questions, sketch the MVVM-C diagram from memory  
3. For weakness questions, pair with `14-project-review.md`  
4. Always tie answers to a **file name** — interviewers trust specifics
