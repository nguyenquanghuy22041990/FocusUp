# 12 — Technical Decisions

| # | Decision | Why | Alternatives | Trade-off |
|---|----------|-----|--------------|-----------|
| 1 | SwiftUI + iOS 17.5+ | Modern APIs, Observation, Charts | UIKit | Harder to test views; team must know SwiftUI |
| 2 | MVVM-C | Clear nav + testable VMs | VIPER, TCA | More types than tiny apps need |
| 3 | SwiftData | Less boilerplate than Core Data | Core Data, Realm | Immature migrations |
| 4 | Manual `AppContainer` DI | Explicit, interview-clear | Factory, Swinject | Container grows |
| 5 | `@Observable` over `ObservableObject` | Less boilerplate | Combine publishers | Newer API |
| 6 | Session managers | Shared lifecycle for dashboard + timer | Fat ViewModels | Extra layer |
| 6b | `SessionLifecycleRunner` | DRY focus/rest pause/resume/restore | Duplicate manager bodies | Generic + side-effect hooks |
| 7 | Wall-clock `TimerEngine` | Accurate restore | `Timer.publish` | Must inject `Clock` for tests |
| 8 | Rest under Focus tab | Single timer tab UX | Separate Rest tab | Couples features |
| 9 | Local notifications only | No backend MVP | APNs push | No cross-device |
| 10 | Logic coverage gate 80% | Meaningful CI signal | 80% total coverage | Excludes views by policy |
| 11 | Swift Testing | Modern test macros | XCTest only | UI test target still XCTest |
| 12 | Cuckoo for `Clock` only | Generated mocks | All hand-written | MainActor protocols manual |
| 13 | Committed generated mocks | Deterministic CI | Generate in CI | Drift if forget regen |
| 14 | SceneStorage + UserDefaults backup | Survive force-quit | SwiftData only | Complexity; reconciliation needed |
| 15 | SwiftData authoritative for sessions | DB outlives scene | SceneStorage only | Must reconcile on restore |
| 16 | PR-only feature CI | Avoid duplicate macOS runs | Push on `feature/**` | No CI until PR opened |
| 17 | Pin Xcode 26.5 in CI | Reproducible builds | Default runner Xcode | Manual bump |
| 18 | No SwiftLint in CI yet | MVP speed | Required lint gate | Style drift risk |
| 19 | Preview repos in app target | SwiftUI previews work | Test-only mocks | Blurs test/app boundary |
| 20 | `fatalError` on persistence failure | Fail fast at launch | Recoverable error UI | Bad UX if corrupt DB |

---

## Deep Dives

### Timestamp timer vs. Combine timer

**Chosen:** `TimerEngine` computes elapsed from dates.  
**Why:** After background, elapsed is correct without counting ticks.  
**Alternative:** Combine `Timer.publish(every: 1)` — drifts, misses background time.  
**When alternative OK:** Live UI countdown display only (still use wall-clock for truth).

### Repository vs. direct SwiftData in ViewModels

**Chosen:** Protocol repositories.  
**Why:** Domain tests, preview data, future sync layer.  
**Alternative:** `@Query` in views — faster prototype, untestable logic.

### Dashboard orchestrator outside AppContainer

**Chosen:** Created where needed (dashboard).  
**Why:** Avoid container bloat.  
**Weakness:** Not singleton — document if asked; could move to container for consistency.

### Coverage exclusions

**Chosen:** Exclude `*View.swift`, design system, cards.  
**Why:** 38% total vs 83% logic — gate measures testable code.  
**Risk:** Over-exclusion inflates metric — policy is version-controlled JSON.

---

## When You'd Choose Differently

| Situation | Different choice |
|-----------|------------------|
| Team > 10 iOS engineers | Modular SPM packages per feature |
| Cloud sync required | Core Data + CloudKit or custom sync layer |
| Heavy UI regression needs | XCUITest or snapshot tests in CI |
| Rapid prototype | SwiftData `@Query` in views, skip coordinators |
| Enterprise compliance | Keychain, certificate pinning, audit logs |

---

## Files That Embody Decisions

- `Core/Timer/TimerEngine.swift` — wall-clock decision
- `Core/DependencyInjection/AppContainer.swift` — DI graph
- `Core/AppLifecycle/AppRestorationCoordinator.swift` — restoration strategy
- `scripts/coverage_policy.json` — coverage philosophy
- `.github/workflows/ios-ci.yml` — CI trigger philosophy
