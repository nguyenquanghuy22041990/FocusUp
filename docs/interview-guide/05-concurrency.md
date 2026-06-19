# 05 — Concurrency

## Overview

FocusUp uses **Swift Concurrency** (`async`/`await`, `@MainActor`, structured `Task`) throughout session lifecycle, repositories, and restoration. Project setting: `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` on app target.

---

## async/await Usage

| Area | Pattern |
|------|---------|
| Repositories | `func fetchAll() async throws -> [Task]` |
| Session managers | `startSession()`, `pauseSession()`, `completeSession()` async |
| ViewModels | `load()`, `refresh()` async |
| Notifications | `schedule()`, `rescheduleAll()` async |
| Cold restore | `AppRestorationCoordinator.performColdRestore` async pipeline |

**Parallel fetch (dashboard):**

```swift
async let analytics = statisticsRepository.fetchAnalytics()
async let tasks = taskRepository.fetchAll()
let statistics = try await analytics
let allTasks = try await tasks
```

---

## @MainActor

**Isolated types:** `AppContainer`, `FocusSessionManager`, `AppCoordinator`, most ViewModels, `NotificationServiceImpl`.

**Why:** SwiftUI, `TimerEngine` UI bindings, `UNUserNotificationCenter` callbacks expect main thread.

**CI lesson:** `AppForegroundRefresh.dismissLiveActivitiesWhenNoActiveSession` must be `@MainActor` — reading `activeSession` from nonisolated async function failed on stricter CI compiler.

**Pattern:** Domain structs are `Sendable`; managers/repos on MainActor; `Clock` is `Sendable` for testing.

---

## Task Lifecycle

| Location | Pattern |
|----------|---------|
| `AppRootView` | `.task { await performColdStart() }` — cancelled if view dismantled |
| Timer views | `runTimerLoop()` async loop with `Task.sleep(for: .seconds(1))` |
| Button handlers | `_Concurrency.Task { await viewModel.pause() }` |
| `TaskDetailViewModel.load` | Checks `Task.isCancelled` before updating state |

**Timer loop (FocusTimerView):**

```swift
private func runTimerLoop() async {
  while !Task.isCancelled, viewModel.isRunning {
  await viewModel.advanceTimerTick()
  try? await Task.sleep(for: .seconds(1))
  }
}
```

Loop starts in `.task` alongside `loadAssociatedTask()`; stops when scene inactive or session ends.

---

## Cancellation

**Handled in:**
- `TaskDetailViewModel.load()` — early return if cancelled; avoids setting state after cancel
- Timer loops — `Task.isCancelled` in while condition
- SwiftUI `.task` — auto-cancels on disappear

**Not everywhere:** Some `try? await` swallows errors (restoration paths) — intentional resilience vs. strict failure.

---

## Structured Concurrency

- `async let` for parallel repository reads in orchestrator
- No unbounded `Task.detached` in production paths
- Child tasks inherit actor context when created on `@MainActor`

---

## Thread Safety

| Mechanism | Protects |
|-----------|----------|
| `@MainActor` | Session managers, coordinators, UI state |
| `Sendable` domain types | `Task`, `FocusSession`, enums |
| Value-type snapshots | `TimerSnapshot` passed across restore |
| Single `activeSession` per manager | No concurrent session mutation |

**TimerEngine** is `@Observable` on MainActor — `tick(at:)` called from main actor timer loop only.

---

## Race Conditions Avoided

| Scenario | Solution |
|----------|----------|
| Double active session | `sessionAlreadyActive` throw on start |
| Stale navigation after force-quit | `clearStaleFocusSessionRoutes` on foreground |
| Split-brain timer vs. DB | SwiftData authoritative; scene snapshot only if same session ID + elapsed ≥ DB |
| Auto-complete without persist | `tick()` async calls `completeSession()` when engine completes |
| Cold restore vs. scene storage | `AppRestorationCoordinator` ordered pipeline |
| Duplicate Live Activities | `AppForegroundRefresh` ends activities when no session |

**Known gap:** Rapid pause/resume stress-tested (`FocusSessionLifecycleStressTests`) but not distributed/multi-device sync (N/A — offline app).

---

## Interview Talking Points

1. **Why `_Concurrency.Task` in views?** Button actions are synchronous; wrapping async manager calls avoids blocking main thread.
2. **MainActor default isolation trade-off?** Safer UI code; must mark nonisolated helpers explicitly; CI stricter than local without pin.
3. **How test async code?** Swift Testing `async` tests; `TestClock` injects fixed time; `@MainActor` test structs.

---

## Key Files

- `Features/Focus/Managers/FocusSessionManager.swift` — async lifecycle
- `Core/Timer/TimerEngine.swift` — synchronous state machine on MainActor
- `Core/AppLifecycle/AppRestorationCoordinator.swift` — async restore orchestration
- `Core/AppLifecycle/AppForegroundRefresh.swift` — `@MainActor` foreground sync
