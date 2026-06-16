# FocusUp MVP-1 Production Readiness

**iOS architecture & interview docs:** [ios/README.md](./ios/README.md)

## Status: Production-ready for MVP-1

Last hardening pass: architecture validation, lifecycle refresh, navigation safety, error surfaces, and expanded deterministic tests.

## Validated systems

| System | Status | Notes |
|--------|--------|-------|
| Tasks | ✅ | Full CRUD, milestones, restoration |
| Focus / Rest timers | ✅ | TimerEngine ownership, SceneStorage restoration |
| Dashboard | ✅ | Orchestration hub, live session card |
| Statistics | ✅ | Shared analytics calculator |
| Notifications | ✅ | Permission, quiet hours, scheduler, settings UI |
| Live Activities | ✅ | Focus/rest sync |
| Accessibility | ✅ | Dynamic Type, VoiceOver, reduced motion |
| Responsive layouts | ✅ | iPhone / iPad / adaptive grids |

## Intentional deferred UI (post-MVP)

- Focus session history detail
- Statistics drill-down routes (root screen is complete)
- Tasks list filter routes that remain navigable stubs

## Hardening applied

1. **Safe tab navigation** — `AppCoordinator.openFocusTab` / `openRestTab` only push active routes when sessions exist.
2. **Stale route cleanup** — Foreground refresh and session end clear orphaned `.activeSession` / `.restSession` paths.
3. **Lifecycle** — `AppForegroundRefresh` on scene `.active` reschedules notifications and reconciles navigation.
4. **Dashboard errors** — Failed load shows retry card instead of empty content.
5. **Settings** — Production home, About, Appearance (no “Coming soon” root).
6. **Dashboard drill-ins** — Weekly/goals routes redirect to Statistics / Tasks tabs.

## Test tags

- `.production` — smoke, lifecycle, navigation safety, P0 integration tests
- Run all P0 tests:
  ```bash
  xcodebuild test -destination 'platform=iOS Simulator,name=iPhone 17' \
    -only-testing:FocusUpTests/ProductionSmokeTests \
    -only-testing:FocusUpTests/LiveActivityCoordinatorTests \
    -only-testing:FocusUpTests/RestorationIntegrationTests \
    -only-testing:FocusUpTests/FocusSessionLifecycleStressTests \
    -only-testing:FocusUpTests/SessionCoordinationTests \
    -only-testing:FocusUpTests/DashboardRefreshIntegrationTests \
    -only-testing:FocusUpTests/NotificationSchedulerIntegrationTests \
    -only-testing:FocusUpTests/StatisticsAccessibilityTests
  ```

## Release checklist

- [ ] Device test: focus → background → foreground → dashboard session card
- [ ] Device test: complete session → force quit → relaunch (no ghost session)
- [ ] iPad split-screen: dashboard + active focus
- [ ] VoiceOver pass on dashboard active session card
- [ ] Reduce Motion enabled: no breathing / numeric transitions
- [ ] Notification permission denied: settings remain usable

## Remaining optional improvements

- Focus history screen
- Cloud sync / widgets / Siri
- macOS / watchOS targets
