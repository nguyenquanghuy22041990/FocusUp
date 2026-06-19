# 07 — Testing

## Strategy

**Test the logic layer; exclude SwiftUI views from CI gate.**

| Layer | Coverage approach |
|-------|-------------------|
| Domain (calculators, validation) | Direct unit tests |
| ViewModels / Managers | Unit tests with mocks |
| Repositories | In-memory SwiftData tests |
| Coordinators / restoration | Integration-style tests |
| SwiftUI Views | Previews only; not gated in CI |
| UI (XCUITest) | Scaffold only — not in CI |

Philosophy aligns with `scripts/coverage_policy.json`: gate **logic coverage ≥ 80%**.

---

## Framework

**Swift Testing** (`import Testing`):

```swift
@Test(.tags(.focus, .production))
func tickAutoCompletesAtDurationBoundary() async { ... }
```

**Tags** (`FocusUpTests/Helpers/TestTags.swift`): `.production`, `.focus`, `.tasks`, `.dashboard`, etc.

**Legacy:** `FocusUpUITests` uses XCTest template — not run in CI (`-only-testing:FocusUpTests`).

---

## Test Organization

```
FocusUpTests/
├── AppLifecycle/
├── Audio/
├── Core/
├── Cuckoo/
├── Dashboard/
├── DesignSystem/
├── Focus/
├── Foundation/
├── LiveActivities/
├── Navigation/
├── Notifications/
├── Persistence/
├── Production/          # Smoke tests
├── Rest/
├── Statistics/
├── Tasks/
├── Timer/
└── Helpers/             # TestTags, fixtures
```

~72 files, ~236 test cases. Mirrors feature/domain structure.

---

## Mocking Approach

| Type | Implementation |
|------|----------------|
| Repositories | `MockTaskRepository`, `Preview*Repository`, in-memory `*RepositoryImpl` |
| Clock | `TestClock` + **Cuckoo** generated mocks (`ClockCuckooTests`) |
| Notifications | `NoOpNotificationService` (in app target) |
| Audio | `NoOpSessionAmbientSoundPlayer`, `MockSessionAmbientSoundPlayer` |
| Live Activities | `NoOpLiveActivityManager`, `RecordingLiveActivityManager` |
| Coordinator | `MockAppCoordinator` |

**Cuckoo:** `Cuckoofile.toml` generates mocks for `Clock` only. `@MainActor` protocols mocked manually (Cuckoo issue #513).

**Committed generated code:** `FocusUpTests/Generated/GeneratedMocks.swift` — CI does not regenerate.

**AppContainer.testing caveat:** Uses `Repositories.preview` (in-memory stubs), not full in-memory SwiftData — some integration tests build fresh containers via `PersistenceController(inMemory: true)`.

---

## Notable Test Suites

| Suite | What it proves |
|-------|----------------|
| `FocusSessionLifecycleStressTests` | Pause/resume, auto-complete at boundary |
| `RestorationIntegrationTests` | Cold restore + timer reconciliation |
| `NotificationSchedulerTests` | Quiet hours, reschedule logic |
| `FocusAnalyticsCalculatorTests` | Streaks, trends, distribution |
| `ProductionSmokeTests` | Container initializes, orchestrator works |
| `AppForegroundRefreshTests` | Stale route cleanup |

---

## Code Coverage

| Metric | ~Value | CI gate |
|--------|--------|---------|
| Logic coverage | 83% | ≥ 80% |
| Total app target | 38% | None (0%) |

**Script:** `scripts/logic_coverage.py` parses `xccov` JSON from `TestResults.xcresult`.

**Excluded from logic:** `*View.swift`, DesignSystem, Cards, Previews, RestorationModifiers, etc.

---

## CI Integration

```bash
xcodebuild test -only-testing:FocusUpTests -enableCodeCoverage YES
python3 scripts/logic_coverage.py TestResults.xcresult scripts/coverage_policy.json
```

---

## Example Interview Questions

**Q: Why Swift Testing over XCTest?**  
A: Modern macros (`@Test`, `#expect`), tags, parallel by default, cleaner async tests. XCTest reserved for UI test target scaffold.

**Q: How do you test navigation?**  
A: `AppCoordinatorTabNavigationTests`, `NavigationRestorationTests` — assert `path` and `selectedTab` without UI.

**Q: How test timers without waiting?**  
A: Inject `TestClock`; advance `now`; call `TimerEngine.tick(at:)` or manager methods synchronously on MainActor.

**Q: Why exclude views from coverage?**  
A: Low signal/cost ratio; ViewModels hold decisions. Industry-acceptable for SwiftUI MVVM if logic is tested.

**Q: What's missing?**  
A: Real UI tests, `NotificationPermissionViewModel` was added recently, `DashboardViewModelTests` expanded — still no snapshot tests.

---

## Running Locally

```bash
xcodebuild test -scheme FocusUp -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:FocusUpTests
python3 scripts/logic_coverage.py TestResults.xcresult scripts/coverage_policy.json
```

Regenerate Cuckoo: `scripts/generate_cuckoo_mocks.sh`
