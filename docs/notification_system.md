# Notification System

# 1. Overview

This document defines the notification architecture and notification philosophy for FocusUp.

Goals:
- encourage consistency
- reduce productivity anxiety
- create emotionally supportive reminders
- maintain calm UX
- avoid guilt-driven messaging
- support offline-first behavior

The notification system uses:
- local notifications only
- lightweight personalization
- user-controlled scheduling

The notification experience should feel:
- gentle
- motivating
- emotionally supportive
- non-intrusive

---

# 2. Notification Philosophy

FocusUp notifications should:
- encourage gradual progress
- support emotional motivation
- celebrate small wins
- reduce pressure

The app should NOT:
- shame users
- pressure users aggressively
- create anxiety
- overwhelm users with reminders

---

# 3. Notification Types

---

# 3.1 Focus Reminder Notifications

Purpose:
- encourage starting focus sessions

Examples:
- morning focus reminders
- scheduled work reminders
- inactive session reminders

---

# 3.2 Focus Completion Notifications

Purpose:
- celebrate completed focus sessions

Examples:
- session completed
- milestone reached
- streak achieved

---

# 3.3 Daily Encouragement Notifications

Purpose:
- reinforce long-term motivation

Examples:
- goal encouragement
- hobby-related motivation
- gentle consistency reminders

---

# 3.4 Rest Session Notifications

Purpose:
- encourage healthy breaks

Examples:
- focus completed → recommend rest
- rest session completed

---

# 4. Notification Architecture

```text
User Preferences
        ↓
Notification Scheduler
        ↓
Message Generator
        ↓
UNUserNotificationCenter
```

---

# 5. Core Components

```text id="m7s2hb"
Data/
└── Services/
    ├── NotificationService.swift
    ├── NotificationScheduler.swift
    ├── NotificationPermissionManager.swift
    └── MotivationMessageGenerator.swift
```

---

# 6. Notification Services

---

# 6.1 NotificationService

Responsibilities:
- create notifications
- schedule notifications
- remove notifications
- manage identifiers

Should NOT:
- generate business logic
- own motivational logic

---

# 6.2 NotificationScheduler

Responsibilities:
- determine scheduling timing
- apply quiet hours
- manage recurring reminders
- avoid notification spam

---

# 6.3 MotivationMessageGenerator

Responsibilities:
- generate supportive messages
- personalize notifications
- combine:
  - hobbies
  - goals
  - progress
  - streaks

Should remain:
- lightweight
- deterministic
- offline-first

---

# 6.4 NotificationPermissionManager

Responsibilities:
- request notification permissions
- track permission state
- expose permission status

---

# 7. Notification Framework

Use:
- UserNotifications framework

The application uses:
- local notifications only in MVP1

Avoid:
- remote push notifications
- server dependencies
- analytics-driven notifications

---

# 8. Notification Categories

Recommended categories:

| Category | Purpose |
|---|---|
| focus_reminder | Encourage focus |
| focus_completed | Celebrate completion |
| rest_reminder | Encourage rest |
| encouragement | Daily motivation |
| streak_update | Celebrate consistency |

---

# 9. Notification Scheduling Strategy

Notifications should remain:
- predictable
- minimal
- user-friendly

Avoid:
- excessive frequency
- random interruptions
- spam behavior

---

# 9.1 Scheduling Rules

Prefer:
- 1–3 notifications daily maximum
- user-selected timing
- contextual reminders

Avoid:
- notification overload
- repeated failed reminders

---

# 9.2 Quiet Hours

Users should configure:
- quiet hours
- sleep hours
- notification windows

Default quiet hours:
- 10:00 PM → 7:00 AM

---

# 10. Personalization Strategy

Notifications are personalized using:
- hobbies
- long-term goals
- task purpose
- streaks
- progress history

---

# 10.1 Example Inputs

User hobby:
- traveling

User goal:
- become a senior iOS developer

Task:
- portfolio application

---

# 10.2 Example Notifications

Examples:

> "Every focused session moves you closer to your goals."

> "Small progress today still matters."

> "Your future self will thank you for this session."

> "One more session toward your dream project."

---

# 11. Tone Guidelines

Notifications should feel:
- calm
- human
- supportive
- emotionally safe

Avoid:
- harsh productivity language
- guilt-based motivation
- toxic hustle culture tone

---

# 11.1 Avoid Examples

Do NOT generate:

> "You're falling behind."

> "You skipped your work again."

> "Failure starts with procrastination."

---

# 11.2 Preferred Examples

Prefer:

> "A small step today is still progress."

> "Focus for a few minutes and build momentum."

> "Consistency matters more than perfection."

---

# 12. Notification Timing

---

# 12.1 Recommended Reminder Timing

Examples:
- morning planning reminder
- afternoon focus reminder
- evening reflection reminder

Avoid:
- hourly reminders
- frequent interruptions

---

# 12.2 Session Notifications

Focus session notifications:
- session completed
- session paused too long
- optional reminder to continue

Rest session notifications:
- break completed
- encourage return to focus

---

# 13. Notification Permission Flow

The permission request should:
- explain value clearly
- avoid requesting immediately on launch

Recommended timing:
- after onboarding
- after first focus session

---

# 13.1 Permission Education

Before requesting permission:

Explain:
- focus reminders
- progress encouragement
- session completion alerts

Avoid:
- generic system-only explanation

---

# 14. Notification Data Model

Example persistence model:

```swift id="rlovqx"
struct NotificationPreferences {
    var isEnabled: Bool
    var quietHoursEnabled: Bool
    var quietHoursStart: Date
    var quietHoursEnd: Date
    var reminderFrequency: ReminderFrequency
}
```

---

# 15. Scheduling Persistence

Persist:
- reminder preferences
- quiet hours
- enabled categories

Do NOT persist:
- temporary scheduled notification instances unnecessarily

---

# 16. Notification Identifiers

Use structured identifiers.

Example:

```text id="ckdfqr"
focus_reminder_daily
focus_completed_session
rest_session_completed
encouragement_daily
```

Avoid:
- random unmanaged identifiers

---

# 17. Accessibility Considerations

Notifications should:
- remain concise
- support VoiceOver readability
- avoid excessive emoji usage
- avoid unreadable formatting

---

# 18. Offline Strategy

The notification system must:
- function fully offline
- generate messages locally
- avoid network dependency

All scheduling logic remains local.

---

# 19. Future Expansion Strategy

Future improvements may include:
- AI-generated encouragement
- adaptive scheduling
- intelligent inactivity detection
- focus habit insights
- widget integration

The MVP architecture should remain flexible enough to support these later.

---

# 20. Testing Strategy

Priority testing targets:
- notification scheduling
- quiet hour logic
- permission flow
- message generation
- duplicate notification prevention

---

# 21. Anti-Patterns To Avoid

Avoid:
- notification spam
- guilt-based reminders
- excessive scheduling
- aggressive productivity language
- server-dependent notifications
- random uncontrolled timing
- notifications during quiet hours

---

# 22. Engineering Philosophy

The notification system should feel:
- supportive
- calm
- emotionally intelligent
- lightweight
- privacy-friendly

The architecture prioritizes:
- user trust
- emotional safety
- simplicity
- offline reliability

```