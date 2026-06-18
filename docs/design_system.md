# Design System

# 1. Overview

This document defines the visual design system for FocusUp.

Goals:
- consistent UI
- calm visual experience
- modern Apple-inspired aesthetics
- strong dark mode support
- accessible interfaces
- reusable design primitives

The design system prioritizes:
- simplicity
- readability
- emotional calmness
- minimal distraction
- smooth focus experience

---

# 2. MVP-1 UI Screenshot References

The following screenshots are the primary visual references for MVP-1 implementation.

These screenshots should guide:
- layout structure
- spacing consistency
- typography hierarchy
- visual tone
- component styling
- animation direction

Store screenshots inside:

```text id="5s3fkr"
Docs/UIReferences/
```

---

# 2.1 Screenshot List

| Screen | File Name |
|---|---|
| Onboarding 1 | onboarding_1.png |
| Onboarding 2 | onboarding_2.png |
| Onboarding 3 | onboarding_3.png |
| Home Overview | home_overview.png |
| Tasks List | tasks_list.png |
| Task Detail | task_detail.png |
| Create Task | create_task.png |
| Focus Timer Start | focus_timer_start.png |
| Focus Timer Active | focus_timer_active.png |
| Rest Timer | rest_timer.png |
| Progress Overview | progress_overview.png |
| Weekly Statistics | statistics_weekly.png |

---

# 2.2 Screenshot Usage Guidelines

These screenshots are:
- visual references
- UX direction references
- layout inspiration

They are NOT:
- pixel-perfect final specifications
- strict implementation constraints

The implementation should preserve:
- overall visual mood
- spacing consistency
- hierarchy
- calm UI feeling

while still adapting naturally to:
- Dynamic Type
- accessibility
- device sizes
- landscape layouts

---

# 2.3 Cursor AI Guidance

When generating UI code:
- follow the screenshots closely
- maintain visual consistency
- preserve spacing hierarchy
- keep animations subtle
- preserve dark/light theme behavior

Avoid:
- inventing completely new layouts
- changing visual direction dramatically
- introducing inconsistent styling

---

# 3. Design Philosophy

FocusUp is designed to feel:

- calm
- modern
- lightweight
- intentional
- emotionally supportive

The UI should never feel:
- overwhelming
- noisy
- overly gamified
- visually aggressive

---

# 4. Visual Inspiration

Inspired by:
- :contentReference[oaicite:0]{index=0} Health app
- :contentReference[oaicite:1]{index=1}
- :contentReference[oaicite:2]{index=2}
- :contentReference[oaicite:3]{index=3}

---

# 5. Color System

The application uses a calm Indigo-centered palette.

---

# 5.1 Primary Colors

| Name | Hex | Usage |
|---|---|---|
| Primary Indigo | #4F46E5 | Main brand color |
| Focus Red | #EF4444 | Focus sessions |
| Rest Green | #10B981 | Rest sessions |
| Soft Cyan | #22D3EE | Accent/highlight |

---

# 5.2 Background Colors

| Name | Hex | Usage |
|---|---|---|
| Light Background | #F8FAFC | Light mode screens |
| Dark Background | #0F172A | Dark mode screens |
| Card Light | #FFFFFF | Light cards |
| Card Dark | #1E293B | Dark cards |

---

# 5.3 Text Colors

| Name | Hex | Usage |
|---|---|---|
| Primary Text Light | #0F172A | Main light text |
| Secondary Text Light | #475569 | Secondary light text |
| Primary Text Dark | #F8FAFC | Main dark text |
| Secondary Text Dark | #CBD5E1 | Secondary dark text |

---

# 5.4 Semantic Colors

| Name | Hex | Usage |
|---|---|---|
| Success | #10B981 | Success state |
| Warning | #F59E0B | Warnings |
| Error | #EF4444 | Error state |
| Info | #3B82F6 | Informational state |

---

# 6. Typography

Typography should feel:
- clean
- spacious
- readable
- modern

Use Apple system fonts.

Preferred:
- SF Pro Display
- SF Pro Text

---

# 6.1 Typography Scale

| Style | Size | Weight | Usage |
|---|---|---|---|
| Large Title | 34 | Bold | Hero sections |
| Title 1 | 28 | Semibold | Main screen titles |
| Title 2 | 22 | Semibold | Section headers |
| Headline | 17 | Semibold | Card titles |
| Body | 17 | Regular | Standard content |
| Subheadline | 15 | Regular | Supporting content |
| Caption | 13 | Medium | Metadata |
| Small Caption | 11 | Medium | Tiny labels |

---

# 6.2 Typography Guidelines

Prefer:
- strong hierarchy
- generous spacing
- consistent line height

Avoid:
- tiny unreadable text
- excessive font weight variation

---

# 7. Spacing System

Use consistent spacing scale.

---

# 7.1 Spacing Values

| Token | Value |
|---|---|
| xs | 4 |
| sm | 8 |
| md | 12 |
| lg | 16 |
| xl | 24 |
| xxl | 32 |
| xxxl | 40 |

---

# 7.2 Layout Guidelines

Prefer:
- generous whitespace
- breathing room
- visual calmness

Avoid:
- crowded layouts
- dense dashboards
- aggressive information density

---

# 8. Corner Radius

Use soft rounded corners.

---

# 8.1 Radius Scale

| Token | Value |
|---|---|
| small | 8 |
| medium | 12 |
| large | 20 |
| extraLarge | 28 |

Preferred:
- 16–20pt radius for cards
- circular elements for timers

---

# 9. Shadows

Use soft subtle shadows only.

---

# 9.1 Shadow Style

Prefer:
- low opacity
- large blur radius
- subtle elevation

Avoid:
- harsh shadows
- neumorphism
- excessive layering

---

# 10. Buttons

Buttons should feel:
- clear
- soft
- accessible
- touch-friendly

---

# 10.1 Primary Button

Usage:
- primary actions

Style:
- filled background
- white text
- medium-large corner radius

Example:
- Start Focus
- Save Task

---

# 10.2 Secondary Button

Usage:
- less prominent actions

Style:
- outlined
- soft background
- lower emphasis

---

# 10.3 Destructive Button

Usage:
- delete
- archive
- destructive actions

Use:
- Error Red

Avoid:
- overusing destructive styling

---

# 11. Cards

Cards are a major visual component.

Cards should:
- feel lightweight
- use soft spacing
- support dark mode elegantly

---

# 11.1 Card Styling

Use:
- medium corner radius
- subtle shadow
- soft background contrast

Avoid:
- strong borders
- aggressive gradients

---

# 12. Progress Indicators

Progress visualization is a core UX element.

---

# 12.1 Progress Rings

Used for:
- focus sessions
- daily progress
- milestone tracking

Focus:
- red ring

Rest:
- green ring

Progress animations should feel:
- smooth
- calming
- intentional

---

# 12.2 Progress Bars

Use:
- rounded edges
- subtle animation
- lightweight styling

---

# 13. Timer UI

The timer experience is a signature feature.

---

# 13.1 Focus Mode

Focus timer should:
- feel immersive
- reduce distractions
- emphasize concentration

Use:
- red accent
- large countdown
- subtle breathing animation

---

# 13.2 Rest Mode

Rest timer should:
- feel calming
- encourage relaxation

Use:
- green accent
- soft gradients
- slower animations

---

# 14. Animation System

Animations should:
- guide attention
- communicate state
- improve perceived smoothness

Avoid:
- flashy motion
- excessive transitions
- animation overload

---

# 14.1 Preferred Animations

Use:
- spring animations
- fade transitions
- scale transitions
- PhaseAnimator
- SymbolEffect

---

# 14.2 Animation Timing

| Usage | Duration |
|---|---|
| Small interaction | 0.2s |
| Standard transition | 0.3s |
| Large transition | 0.45s |

---

# 15. Iconography

Use:
- SF Symbols

Prefer:
- rounded
- minimal
- clean icons

Examples:
- timer
- target
- flame
- checkmark
- moon
- sparkles

Avoid:
- inconsistent icon weights
- decorative icon overload

---

# 16. Navigation Design

Navigation should:
- remain lightweight
- avoid visual clutter
- prioritize focus

Preferred:
- TabView
- large titles
- simple navigation hierarchy

---

# 17. Empty States

Empty states should:
- feel encouraging
- reduce anxiety
- guide next action

Avoid:
- robotic empty messages

Example:
> "Start your first focus session today."

---

# 18. Notification Design

Notifications should:
- feel emotionally supportive
- avoid guilt
- encourage gradual progress

Preferred tone:
- calm
- motivational
- gentle

Avoid:
- pressure-heavy wording
- aggressive productivity language

---

# 19. Accessibility Guidelines

Support:
- Dynamic Type
- VoiceOver
- sufficient color contrast
- reduced motion

Buttons and touch targets:
- minimum 44x44pt

---

# 20. Dark Mode Strategy

Dark mode is a first-class experience.

Dark mode should:
- reduce eye strain
- maintain strong contrast
- avoid pure black backgrounds

Prefer:
- deep navy backgrounds
- softened contrast
- muted surfaces

---

# 21. Responsive Layout Strategy

# Universal Layout Support

The application supports:
- iPhone
- iPad
- portrait
- landscape
- split screen multitasking

Layouts should adapt gracefully using:
- AnyLayout
- adaptive grids
- dynamic spacing
- responsive containers

Avoid:
- hardcoded widths
- full-width stretched content on iPad

---

# 22. Reusable Design Tokens

Recommended token structure:

```text id="0cmm4p"
DesignSystem/
├── Colors/
├── Typography/
├── Spacing/
├── Radius/
├── Shadows/
├── Buttons/
├── Animations/
└── Components/
```

---

# 23. Component Philosophy

Reusable components should:
- remain composable
- remain lightweight
- support accessibility
- support theming

Avoid:
- giant configurable mega-components

---

# 24. Anti-Patterns To Avoid

Avoid:
- cluttered dashboards
- aggressive gradients
- inconsistent spacing
- excessive glassmorphism
- heavy neumorphism
- visually noisy screens
- inconsistent typography
- animation overload

---

# 25. Engineering Philosophy

The UI should feel:
- calm
- intentional
- modern
- premium
- emotionally supportive

The design system prioritizes:
- clarity
- focus
- accessibility
- consistency
- long-term maintainability

```

# 26. Content Width Guidelines

On iPad:
- forms should use constrained width
- text content should avoid edge-to-edge layouts
- dashboard cards should use grid layouts

Recommended maximum readable width:
- 700–900pt

```

# 27. iPad Dashboard Layout

On iPad:
- use multi-column dashboard layouts
- use adaptive card grids
- preserve generous whitespace
- avoid oversized empty layouts

```