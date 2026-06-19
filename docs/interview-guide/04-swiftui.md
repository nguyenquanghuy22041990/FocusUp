# 04 — SwiftUI Knowledge Used

FocusUp targets **iOS 17.5+** and uses the **Observation** framework (`@Observable`), not legacy `ObservableObject` for new code.

---

## Property Wrappers & Observation

| API | What it is | Used for | Example files |
|-----|------------|----------|---------------|
| `@Observable` | Macro; automatic observation | ViewModels, managers, coordinators | `FocusTimerViewModel`, `AppCoordinator` |
| `@Bindable` | Two-way binding to `@Observable` | Child views editing VM/coordinator | `FocusTimerView`, `FocusView` |
| `@Environment` | Read environment values | DI, size class, scene phase | `AppRootView`, timer views |
| `@State` | View-local value | Lazy VM creation, UI toggles | `FocusView` (`startViewModel?`), `AppRootView` |
| `@SceneStorage` | Per-scene persisted state | Timer snapshots | `AppRootView` |
| `@Bindable var coordinator` | Bindable coordinator in navigation | `FocusView` navigation stack |

**Not used in app code:** `@StateObject`, `@ObservedObject`, `@EnvironmentObject` — deliberate migration to Observation.

**Interview Q:** Why `@Bindable` instead of `@ObservedObject`?  
**A:** With `@Observable`, `@Bindable` enables `$` bindings and observation without `ObservableObject` + `@Published` overhead.

---

## Navigation

| Technique | Where |
|-----------|-------|
| `NavigationStack(path:)` | Feature roots (`FocusView`, `TasksView`) |
| Typed `Route` enums | `FocusRoute`, `TasksRoute`, etc. |
| `navigationDestination(for:)` | Route → view mapping |
| Programmatic push | `tabCoordinator.push(.activeSession)` |
| Cross-tab | `AppCoordinator.selectTab` + push |

**Rest on Focus tab:** Rest is `FocusRoute.restSession`, not a separate tab — simplifies tab bar but couples features.

---

## View Composition

- **Feature shells** (`FeatureNavigationShell`, `TabFeatureRoot`) wrap consistent chrome
- **Design system components** (`AppCard`, `PrimaryButton`, `ProgressRing`) in `DesignSystem/`
- **`@ViewBuilder`** for conditional sections — `FocusTimerView`, `RestTimerView`, `ResponsiveContainer`

```swift
@ViewBuilder
private var controlsSection: some View { ... }
```

---

## Custom ViewModifiers

| Modifier | Purpose | File |
|----------|---------|------|
| `.navigationRestoration(coordinator:)` | Persist/restore nav stack | `NavigationRestorationModifier` |
| `.focusTimerRestoration(manager:)` | Persist timer on background | `FocusTimerRestorationModifier` |
| `.activeTimerTabBarVisibility` | Hide tab bar during session | `ActiveTimerTabBarVisibility` |
| `.navigationBackLocked` | Block back during active timer | `NavigationBackLockModifier` |
| `.focusMotionContext` | Reduce motion env injection | `FocusMotionAccessibility` |
| `.calmBreathing` | Rest animations | `CalmBreathingModifier` |
| `.readableContentWidth` | iPad content width | `ReadableContentWidth` |
| `.dismissKeyboardOnTap` | Form UX | `KeyboardDismissal` |

**Pattern:** Modifier wraps cross-cutting behavior that would clutter `body`.

---

## Lifecycle

| Hook | Use |
|------|-----|
| `.task { }` | Cold start restore, async load | `AppRootView`, `DashboardView` |
| `.onChange(of: scenePhase)` | Foreground refresh, timer loop gating | `AppRootView`, timer views |
| `.onAppear` | One-shot UI setup | Various |
| `.onReceive` | `TaskUpdateNotifier` → reschedule notifications | `AppRootView` |

**Scene phases:** Timer tick loops only run when `scenePhase == .active` — saves battery; restoration handles background elapsed time.

---

## Animations

- `FocusTransitionModifiers` — focus UI transitions
- `CalmBreathingModifier` / `CalmStateTransitionModifier` — rest screen
- Respects `@Environment(\.focusMotionReduced)` derived from user preferences + system Reduce Motion

---

## Responsive Layout

| API | Use |
|-----|-----|
| `@Environment(\.horizontalSizeClass)` | Phone vs. tablet layout |
| `@Environment(\.dynamicTypeSize)` | Scale timer display |
| `AdaptiveRootNavigationView` | Sidebar on regular width |
| `ResponsiveContainer` | Max width constraints |
| `ReadableContentWidth.maxContentWidth` (680pt) | iPad readability |

See `docs/responsive_layout_guidelines.md`.

---

## Accessibility

- `accessibilityLabel` on routes (`TasksRoute.accessibilityLabel`)
- `FocusSession+Accessibility`, `RestSession+Accessibility` extensions
- Chart accessibility summaries in `StatisticsFormatting`
- Design system tests: `DesignSystemAccessibilityTests`, `StatisticsAccessibilityTests`
- Min touch targets via design tokens (44pt)

---

## Scene Restoration

**Three layers:**

1. **SwiftData** — active sessions (source of truth)
2. **SceneStorage** — timer snapshots, navigation state (fast reconnect)
3. **UserDefaults** (`AppRestorationStore`) — backup if scene storage lost

Modifiers persist on `background`/`inactive` and session identity changes.

---

## Advanced Techniques

| Technique | Where |
|-----------|-------|
| Custom `EnvironmentKey` for DI | `\.appContainer`, `\.hapticFeedback` |
| Lazy ViewModel creation | `FocusView` holds optional VMs until route needs them |
| `#Preview` with `.appContainer(.preview)` | Throughout feature folders |
| `_Concurrency.Task` in views | Bridge sync actions to async managers |

---

## Interview Questions (SwiftUI)

1. **Why Observation over Combine for ViewModels?** Less boilerplate; SwiftUI integrates natively; session state doesn't need reactive streams.
2. **Where is navigation state stored?** `TabCoordinator.path` on `AppCoordinator`, restored via SceneStorage.
3. **How do you test SwiftUI views?** Mostly don't in CI — test ViewModels/managers; logic coverage excludes `*View.swift`.
4. **How handle Dynamic Type on timer?** `dynamicTypeSize` env + scaled fonts in `DesignSystem`.
