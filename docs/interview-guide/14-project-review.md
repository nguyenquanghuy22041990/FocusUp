# 14 — Project Review (Honest Weaknesses)

Use this doc to show **self-awareness** in interviews — strengths land better when you acknowledge trade-offs.

---

## Implementation Weak Points

| Issue | Location | Impact |
|-------|----------|--------|
| `fatalError` on persistence init | `PersistenceController.makeShared` | App crash if DB corrupt — no recovery UI |
| `AppContainer.testing` uses preview repos | `AppContainer.swift` | Tests don't always hit real SwiftData impl |
| Stub ViewModels | `FocusViewModel`, `SettingsViewModel` | Dead code / incomplete features |
| Placeholder screens | `FocusRoute.history`, statistics detail routes | Incomplete MVP surface |
| `cancelTaskReminders` not wired on delete | Notifications | Orphan reminder identifiers possible |
| `DashboardOrchestrator` not in container | Created ad hoc | Inconsistent DI story |

---

## Code Smells

- **`try?` in restoration** — swallows errors silently; hard to debug edge cases
- **Testing code in app target** (`Testing/` folder) — convenient for previews, blurs boundaries
- **Some ViewModels created in Views** (`FocusView` optional state) — lifecycle complexity
- **Duplicate restoration paths** — SceneStorage + UserDefaults + SwiftData requires mental overhead
- **Empty folders** (`Presentation/`, `Domain/Usecases/`) — scaffolding never filled

---

## Missing Tests

| Gap | Priority |
|-----|----------|
| UI / XCUITest flows | High for release confidence |
| `NotificationServiceImpl` (UNUserNotificationCenter) | Medium — needs wrapper protocol |
| `SessionAmbientSoundPlayer` (AVFoundation) | Low — hard to test; excluded or wrapper |
| Snapshot / visual regression | Low for MVP |
| `AppContainer.testing` with real in-memory repos | Medium — integration fidelity |

---

## Scalability Concerns

| Area | Limit | Future fix |
|------|-------|------------|
| Task list | `fetchAll()` — no pagination | Paged queries, sections |
| Statistics | Recalculates from all sessions | Incremental aggregates |
| `AppContainer` | God-object tendency | Feature modules / SPM |
| Single `mainContext` | Write contention if background writes added | Actor-isolated contexts |
| No sync | Single device only | CloudKit / custom backend |

---

## Potential Bugs / Edge Cases

| Risk | Mitigation status |
|------|-------------------|
| Timer auto-complete | **Fixed** — `tick()` persists via `completeSession()` |
| Duplicate focus/rest manager lifecycle | **Fixed** — `SessionLifecycleRunner` + thin managers |
| Ghost navigation routes | Handled — `AppForegroundRefresh`, coordinator reconcile |
| Stale task link on focus start | `reconcileTaskSelection` clears completed tasks |
| Race: push + PR duplicate CI | **Fixed** — removed `feature/**` push trigger |
| MainActor isolation CI failures | **Fixed** — `@MainActor` on `AppForegroundRefresh` |
| 24h snapshot expiry mid-session | Rare; user would lose scene restore but DB keeps session |

---

## Refactoring Opportunities

1. Replace `fatalError` with launch error screen + reset data option
2. Move `DashboardOrchestrator` factory into `AppContainer`
3. Fix `AppContainer.testing` to use `Repositories.live(using: inMemoryPersistence)`
4. Remove or implement stub ViewModels
5. Wire `cancelTaskReminders` on task delete
6. Extract `NotificationCenter` → async stream or delegate for testability
7. SPM module per feature (long-term)

---

## Making It More Impressive for Interviews

| Addition | Interview signal |
|----------|------------------|
| TestFlight CD workflow | End-to-end delivery ownership |
| 2–3 real XCUITest flows | Quality beyond unit tests |
| SwiftLint + strict concurrency in CI | Production discipline |
| Short architecture ADR folder | Documented decision trail |
| Performance Instruments screenshot | Data-driven optimization |
| Accessibility audit checklist completed | Inclusive design |
| Fix persistence `fatalError` | Reliability maturity |

---

## What to Say When Asked "Biggest Weakness?"

> "The architecture is solid for MVP, but deployment and UI-test automation aren't there yet. The biggest technical debt I'd fix first is persistence failure handling — `fatalError` on container creation — and making `AppContainer.testing` use real in-memory repositories so integration tests match production wiring."

---

## Strengths to Balance the Critique

- Layered session restoration is thoughtfully designed
- Timer correctness and auto-complete bug were addressed with tests
- 80% logic coverage gate with honest exclusions
- CI pinned to Xcode 26.5, single run per PR
- Clear domain/repository separation
- Accessibility and Reduce Motion considered in design system
