# 09 — Performance

## Design Choices That Help Performance

### Timestamp-based timer (`TimerEngine`)

- No `Timer.publish` firing 60×/second
- Elapsed = `accumulated + (now - segmentStartedAt)` — cheap on tick
- Background time accounted without running loop

### Tick loop gating

- `runTimerLoop()` only when `scenePhase == .active`
- 1-second sleep between ticks — minimal wakeups

### Statistics cache

- `StatisticsRepositoryImpl` caches analytics until `invalidateCache()`
- Dashboard refresh can skip invalidation for lightweight session continuity updates

### Lazy ViewModel creation

- `FocusView` creates timer VMs only when navigating to routes — avoids eager setup

### Parallel async fetch

- `DashboardOrchestrator` uses `async let` for analytics + tasks

---

## Lazy Loading

| Area | Pattern |
|------|---------|
| Navigation destinations | Views built in `navigationDestination` — lazy |
| Notification settings VM | Lazy init in `SettingsView.task` |
| Statistics charts | Rendered when tab appears |
| SwiftData fetches | On-demand per screen `load()` |

No explicit pagination for tasks (MVP dataset assumed small).

---

## Memory Management

| Concern | Approach |
|---------|----------|
| `AVAudioPlayer` | Single player in `SessionAmbientSoundPlayer`; stopped on session end |
| Live Activities | Ended on complete/cancel/foreground cleanup |
| ViewModels in `FocusView` | Optional refs; can nil on pop |
| SwiftData context | Shared `mainContext`; no duplicate containers |
| Observation | Fine-grained vs. broad `objectWillChange` |

**No known retain cycles** from Combine (minimal Combine usage).

---

## Rendering

- **Reduce Motion:** animations disabled via `focusMotionReduced` environment
- **Charts:** Swift Charts with calm styling — reasonable for weekly data points
- **Tab bar hidden** during active timer — less layout work on timer screen
- **Design tokens** — consistent spacing avoids expensive layout thrash

---

## Expensive Operations Avoided

| Avoided | Instead |
|---------|---------|
| Polling server | Offline-only |
| Re-fetch all data every second | Timer local; dashboard refresh on events |
| Regenerating statistics every tick | Cache + invalidate on explicit refresh |
| Loading all audio files | Random single file from catalog |
| UI tests in CI | Unit tests only |

---

## Profiling Opportunities

| Area | Tool | What to look for |
|------|------|------------------|
| Timer screen | Instruments Time Profiler | Tick loop, SwiftUI body recomputation |
| Launch | Instruments App Launch | Cold restore pipeline duration |
| SwiftData | Core Data template / SwiftData debugging | Fetch frequency on dashboard |
| Memory | Leaks instrument | AVAudioPlayer, Live Activity retention |
| Energy | Energy Log | Background audio if session left running |

---

## Interview Answer

> "Performance wasn't micro-optimized with Instruments for MVP, but architecture avoids common pitfalls: wall-clock timers instead of high-frequency publishers, scene-gated tick loops, cached statistics, and ending Live Activities/ audio on session completion. Biggest future wins would be profiling SwiftUI body invalidation on timer screens and task list scaling if datasets grow."
