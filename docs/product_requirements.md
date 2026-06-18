# Product Requirements Document (PRD)

# Application Name

FocusUp

Alternative names:
- PurposeFlow
- DeepMinute
- CalmFocus

---

# 1. Overview

FocusUp is a productivity and concentration iOS application designed to help users:

- manage meaningful tasks
- stay focused during work sessions
- maintain healthy rest periods
- track progress gradually
- stay emotionally motivated

The application focuses on:
- calm and minimal UX
- emotional encouragement
- realistic productivity
- offline-first experience
- modern iOS design

The app is intentionally simple and avoids overwhelming users with complex productivity systems.

---

# 2. Product Goals

## Primary Goals

- Help users maintain focus
- Encourage consistent progress
- Reduce productivity anxiety
- Create a calm working experience
- Support meaningful long-term goals

## Technical Goals

- Demonstrate modern iOS engineering skills
- Use modern SwiftUI architecture
- Showcase polished UI/UX
- Apply state restoration techniques
- Build maintainable scalable codebase

---

# 3. Target Users

## Primary Users

- students
- software engineers
- creators
- self-learners
- remote workers

## User Behaviors

Users:
- struggle with concentration
- procrastinate on long-term goals
- want gentle encouragement
- prefer minimal interfaces
- dislike overwhelming productivity apps

---

# 4. MVP Scope

The first MVP version includes only core productivity functionality.

## Included Features

- onboarding
- task management
- milestones/checkpoints
- focus timer
- rest timer
- local notifications
- progress tracking
- dark/light mode
- SceneStorage restoration
- offline persistence

## Excluded Features

- account system
- cloud sync
- Apple Watch app
- AI-generated notifications
- widgets
- Siri integration
- collaboration
- social features

---

# 5. Core User Flows

---

# 5.1 Onboarding Flow

User opens app for the first time.

User can:
- enter nickname
- choose hobbies
- define long-term goals
- select preferred theme
- select preferred focus duration

All onboarding fields except theme are optional.

The application stores preferences locally.

---

# 5.2 Task Creation Flow

User creates a task.

Task includes:
- title
- optional description
- deadline
- available work days
- daily target duration
- purpose/motivation
- hobbies/interests
- milestones

Example:

Task:
- Build portfolio app

Milestones:
- Setup architecture
- Build dashboard
- Create timer
- Add notifications

---

# 5.3 Focus Session Flow

User selects:
- task
- duration

Preset durations:
- 15 minutes
- 30 minutes
- 60 minutes

Application starts immersive focus mode.

Focus screen shows:
- animated red countdown circle
- remaining time
- selected task
- pause/resume controls

When timer completes:
- haptic feedback
- sound
- progress update
- encouragement message

---

# 5.4 Rest Session Flow

User starts rest session.

Preset durations:
- 15 minutes
- 30 minutes
- 60 minutes

Rest screen shows:
- animated green countdown circle
- calming interface
- remaining time

User can:
- pause
- resume
- cancel

---

# 5.5 Daily Progress Flow

Dashboard displays:
- daily focus target
- completed focus duration
- active tasks
- motivational message
- progress rings

Users can monitor progress gradually without pressure.

---

# 6. Functional Requirements

---

# 6.1 Task Management

## Requirements

User can:
- create task
- edit task
- archive task
- delete task
- complete task

Each task supports:
- milestones
- progress tracking
- deadlines
- work scheduling

Task progress updates automatically based on milestone completion.

---

# 6.2 Focus Timer

## Requirements

Application must:
- support countdown timers
- continue timer in background
- restore timer state after relaunch
- support pause/resume
- track completed focus duration

Timer durations:
- 15m
- 30m
- 60m
- custom duration

Focus sessions may optionally connect to tasks.

---

# 6.3 Rest Timer

## Requirements

Application must:
- support calming rest sessions
- use green visual theme
- continue timer in background
- restore timer state after relaunch

---

# 6.4 Notifications

## Requirements

Application uses local notifications only.

Notifications include:
- focus reminders
- encouragement reminders
- focus completion alerts

Notifications should:
- feel supportive
- avoid aggressive language
- avoid guilt-based messaging

Example:
"Every focused minute moves you closer to your dream."

---

# 6.5 Theme System

## Requirements

Application supports:
- Light Mode
- Dark Mode
- System Theme

Theme updates immediately without restart.

---

# 6.6 State Restoration

## Requirements

Application uses SceneStorage to restore:
- selected tab
- current navigation path
- active timer screen
- timer progress
- temporary draft states

Application restores focus/rest session state after relaunch.

---

# 6.7 Offline Persistence

## Requirements

Application works fully offline.

Persisted data includes:
- tasks
- milestones
- sessions
- preferences
- statistics

No network connection required.

---

# 7. Non-Functional Requirements

---

# 7.1 Performance

- Smooth 60 FPS animations
- Fast screen transitions
- Timer accuracy within 1 second

---

# 7.2 Accessibility

Application should support:
- Dynamic Type
- VoiceOver
- sufficient color contrast
- reduced motion support

---

# 7.3 Reliability

Application should:
- restore interrupted sessions
- avoid data loss
- handle background transitions safely

---

# 7.4 Privacy

- no analytics SDK in MVP
- no tracking
- local-first data storage

---

# 8. Design Guidelines

## Design Principles

- minimal
- calm
- modern
- emotionally supportive
- distraction-free

## Visual Direction

Inspired by:
- Apple Health
- Linear
- Notion
- Forest

## Theme Colors

Primary Indigo:
#4F46E5

Focus Red:
#EF4444

Rest Green:
#10B981

Dark Background:
#0F172A

Light Background:
#F8FAFC

---

# 9. Technical Constraints

## Platform

- iOS 17.5+

## Frameworks

- SwiftUI
- SwiftData
- Observation Framework
- ActivityKit
- UserNotifications

## Architecture

- MVVM
- Clean Architecture
- Feature-first organization

---

# 10. Success Metrics

MVP success indicators:

- user can complete full focus workflow
- timers remain reliable
- state restoration works correctly
- UI feels smooth and polished
- architecture remains maintainable
- application demonstrates senior-level SwiftUI skills

---

# 11. Future Enhancements

Potential future features:

- widgets
- Live Activities improvements
- AI-generated encouragement
- Siri shortcuts
- Apple Watch support
- analytics dashboard
- iCloud sync
- ambient sounds
- focus music integration
- smart scheduling

```

# 12. Platform Support

The application is a universal app supporting:
- iPhone
- iPad

The experience should adapt naturally to:
- compact layouts
- regular layouts
- split view multitasking
- landscape orientation

The app should preserve:
- calm UX
- spacing consistency
- accessibility
- restoration behavior

```