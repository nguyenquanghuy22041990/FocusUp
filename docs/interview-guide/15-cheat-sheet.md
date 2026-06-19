# 15 — One-Page Cheat Sheet

## Elevator Pitch (30 sec)

> FocusUp is an offline-first iOS focus app: tasks, Pomodoro-style timers, rest breaks, dashboard, and local notifications. Built with SwiftUI, MVVM-C, SwiftData, and Observation. Timers use wall-clock math for accurate restoration after force-quit. CI runs unit tests on macOS with an 80% logic-coverage gate.

---

## Architecture (memorize)

```
View → ViewModel → Manager/Orchestrator → Repository (protocol) → SwiftData
Navigation: AppCoordinator + TabCoordinator<Route>
DI: AppContainer via Environment
```

---

## Tech Stack

| Item | Value |
|------|-------|
| iOS | 17.5+ |
| UI | SwiftUI + `@Observable` |
| DB | SwiftData (5 entities) |
| Tests | Swift Testing (~236 tests) |
| CI | GitHub Actions, macos-26, Xcode 26.5 |
| Coverage | Logic ≥ 80% (~83% actual) |
| SPM (app) | None (Cuckoo tests only) |

---

## 5 Tabs

Dashboard · Tasks · Focus · Statistics · Settings  
(Rest = `FocusRoute.restSession`, not a tab)

---

## Session Lifecycle (Focus)

`start` → `TimerEngine.running` → `tick` → (complete) → persist → clear → stop audio → end Live Activity → notify

**Managers:** `FocusSessionManager`, `RestSessionManager`  
**Timer:** `TimerEngine` + injectable `Clock`

---

## Restoration Order

1. SwiftData `restoreOnLaunch`  
2. SceneStorage snapshot (if valid)  
3. Navigation reconcile  
4. Reschedule notifications  
5. `AppForegroundRefresh`

---

## Key Files (rapid fire)

| File | One line |
|------|----------|
| `AppContainer.swift` | DI root |
| `AppRootView.swift` | Cold start + scene phase |
| `AppCoordinator.swift` | Tabs + navigation |
| `FocusSessionManager.swift` | Focus lifecycle |
| `TimerEngine.swift` | Timer state machine |
| `AppRestorationCoordinator.swift` | Restore pipeline |
| `NotificationScheduler.swift` | Local notifications |
| `FocusAnalyticsCalculator.swift` | Pure stats math |
| `logic_coverage.py` | CI coverage gate |

---

## Design Patterns (name + file)

- **Repository** — `TaskRepository` / `TaskRepositoryImpl`
- **Coordinator** — `AppCoordinator`
- **Strategy** — `Clock`, `SessionAmbientSoundPlaying`
- **Facade** — `DashboardOrchestrator`
- **Null Object** — `NoOpNotificationService`

---

## CI Triggers

- PR → `develop` / `main` ✅  
- Push → `develop` / `main` ✅  
- Feature branch push (no PR) ❌  

One job: build + test + 80% logic coverage.

---

## Known Weaknesses (say proactively)

1. `fatalError` if SwiftData fails to init  
2. No TestFlight / CD pipeline  
3. UI tests are stubs  
4. `AppContainer.testing` uses preview repos  
5. Some placeholder screens  

---

## Common Questions — Short Answers

**Why coordinators?** Navigation out of ViewModels; testable paths.

**Why wall-clock timer?** Correct elapsed after background; restoration.

**Why exclude views from coverage?** Test ViewModels/domain; SwiftUI low ROI.

**Why no backend?** MVP scope; privacy; simplicity.

**Biggest bug you fixed?** Timer auto-complete didn't persist — split-brain session state.

**MainActor?** UI + managers isolated; `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`.

---

## Numbers

- ~266 app Swift files  
- ~72 test files  
- 5 repository pairs  
- 5 SwiftData entities  
- 80% logic gate / ~83% actual  

---

## Docs Map

| File | Topic |
|------|-------|
| `01-project-overview.md` | Big picture |
| `02-architecture.md` | Deep architecture |
| `03-features.md` | Per-feature walkthrough |
| `10-design-patterns.md` | Pattern summary |
| `design-patterns/` | One deep dive per pattern |
| `16-app-restoration-coordinator.md` | Cold restore line-by-line |
| `13-interview-questions.md` | 100+ Q&A |
| `14-project-review.md` | Weaknesses |

---

## Pre-Interview Checklist

- [ ] Run tests locally once  
- [ ] Trace one user flow: start focus → background → foreground  
- [ ] Explain cold restore in 60 seconds  
- [ ] Open `AppContainer.swift` and explain wiring  
- [ ] Name one weakness + how you'd fix it  
