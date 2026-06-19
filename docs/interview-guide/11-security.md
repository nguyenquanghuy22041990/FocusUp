# 11 — Security & Reliability

## Data Protection

| Data | Storage | Sensitivity |
|------|---------|-------------|
| Tasks, sessions, preferences | SwiftData (app sandbox) | Local user data |
| Restoration backups | UserDefaults / SceneStorage | Navigation + timer state |
| Ambient sounds | App bundle | Public assets |

**No cloud sync, no accounts** — attack surface is device-local.

**iOS sandbox:** Standard app container; data encrypted at rest by iOS file protection (system default).

**Not implemented:** Keychain for secrets (none needed), app passcode, data export encryption.

---

## Secrets Management

- **No API keys** in repo (offline app)
- **No GitHub secrets** in CI (verify-only workflow)
- `.gitignore` excludes `xcuserdata`, build artifacts

**If adding sync later:** Keychain + server tokens; never commit secrets; use Xcode build settings / CI secrets.

---

## Input Validation

| Input | Validation |
|-------|------------|
| Task create/edit | `TaskValidation`, `CreateTaskFormValidation` |
| Milestone titles | Trim whitespace; reject empty |
| Deadlines | Must be today or later |
| Focus duration | Clamped non-negative in `FocusDuration` |
| Session start | `sessionAlreadyActive` guard |

**UI:** SwiftUI forms; errors shown inline in ViewModels.

---

## Notifications

- User permission required (`NotificationPermissionViewModel`)
- Respects denied state — `needsSettingsRecovery` → settings prompt
- Quiet hours defer scheduling — no notification spam at night

---

## Error Handling & Resilience

| Area | Strategy |
|------|----------|
| Repository failures | Propagate `throws` → ViewModel error state |
| Persistence init failure | `fatalError` on `.shared` — **brittle** |
| Restoration | `try?` in places — prefer partial restore over crash |
| Timer snapshot expiry | 24h TTL — ignore stale snapshots |
| Foreground refresh | Clear stale routes, dismiss orphan Live Activities |
| Session auto-complete | Persist on tick completion — prevents ghost sessions |

**Reliability highlight:** Layered restoration (SwiftData + SceneStorage + UserDefaults) for force-quit survival.

---

## Privacy

- No analytics SDKs
- No third-party tracking
- Local notifications only — no push token

**App Store privacy nutrition:** No data collected off-device.

---

## Threat Model (MVP)

| Threat | Mitigation |
|--------|------------|
| Malicious input in task fields | Validation + local-only |
| Tampered local DB | N/A — single-user trust model |
| MITM | No network |
| Jailbreak data extraction | Standard iOS limits; no extra hardening |

---

## Interview Answer

> "Security posture matches an offline productivity app: sandboxed SwiftData, no network attack surface, notification permission gating, input validation on tasks. Reliability investment went into restoration and session lifecycle correctness. Weak spot: `fatalError` if persistence fails to initialize — I'd replace with recoverable error UI for production."

---

## Key Files

- `Domain/Tasks/TaskValidation.swift`
- `Features/Notifications/Permission/NotificationPermissionViewModel.swift`
- `Core/AppLifecycle/AppRestorationCoordinator.swift`
- `Data/Persistence/PersistenceController.swift` (fatalError weakness)
