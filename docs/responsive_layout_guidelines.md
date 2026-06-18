# Responsive Layout Guidelines

# 1. Overview

This document defines responsive layout rules for FocusUp.

The application is a universal app supporting:
- iPhone
- iPad
- portrait orientation
- landscape orientation
- split screen multitasking
- Stage Manager

Goals:
- adaptive layouts
- consistent UX across devices
- maintainable responsive architecture
- modern SwiftUI layout practices
- avoid device-specific duplication

The responsive system should feel:
- natural
- fluid
- calm
- platform-native

---

# 2. Responsive Design Philosophy

The UI should:
- adapt gracefully
- preserve hierarchy
- maintain readability
- scale spacing naturally

Avoid:
- stretching phone layouts to iPad
- hardcoded device assumptions
- duplicated iPhone/iPad screens

---

# 3. Core Responsive Principles

Always prioritize:
- content readability
- adaptive spacing
- flexible layouts
- maintainable code

Avoid:
- hardcoded dimensions
- fixed-width layouts
- excessive device branching

---

# 4. Supported Layout Classes

The app should support:

| Environment | Support |
|---|---|
| Compact Width | Yes |
| Regular Width | Yes |
| Compact Height | Yes |
| Regular Height | Yes |
| Landscape | Yes |
| Split Screen | Yes |
| Stage Manager | Yes |

---

# 5. Responsive Layout Tools

Preferred SwiftUI tools:

| Tool | Purpose |
|---|---|
| AnyLayout | Dynamic layout switching |
| ViewThatFits | Adaptive fallback layouts |
| Grid | Responsive dashboard layouts |
| LazyVGrid | Adaptive card layouts |
| NavigationSplitView | iPad navigation |
| GeometryReader | Limited layout measurement |
| safeAreaInset | Adaptive safe area handling |

---

# 6. AnyLayout Guidelines

AnyLayout is the preferred layout adaptation mechanism.

Use AnyLayout for:
- HStack ↔ VStack transitions
- compact ↔ regular layout changes
- adaptive dashboard arrangements

---

# 6.1 Preferred Usage

Example:

```swift id="5n6ruv"
let layout = isCompact
    ? AnyLayout(VStackLayout())
    : AnyLayout(HStackLayout())
```

---

# 6.2 Avoid

Avoid:
- duplicated iPhone/iPad view trees
- deeply nested if-else layout branches

---

# 7. Navigation Strategy

---

# 7.1 iPhone Navigation

Use:
- NavigationStack

Preferred behavior:
- single-column navigation
- push-based flows

---

# 7.2 iPad Navigation

Prefer:
- NavigationSplitView

Use when:
- content-detail workflows exist
- task-detail navigation benefits from sidebars

Examples:
- Tasks list + task detail
- Statistics sidebar + chart detail

---

# 7.3 Navigation Principles

Navigation should:
- remain predictable
- restore correctly
- adapt naturally to size class changes

Avoid:
- separate navigation systems per device

---

# 8. Dashboard Layout Guidelines

The dashboard is one of the most responsive-heavy screens.

---

# 8.1 iPhone Dashboard

Prefer:
- vertical scrolling
- single-column card layout
- focused content density

---

# 8.2 iPad Dashboard

Prefer:
- multi-column layouts
- adaptive card grids
- increased whitespace
- dashboard sections side-by-side

Avoid:
- stretched edge-to-edge cards
- oversized empty layouts

---

# 8.3 Grid Guidelines

Prefer:
- adaptive columns
- minimum width constraints
- spacing consistency

Example:

```swift id="rfzj14"
GridItem(.adaptive(minimum: 300))
```

---

# 9. Form Layout Guidelines

Forms should adapt based on available width.

---

# 9.1 iPhone Forms

Prefer:
- full-width forms
- stacked sections
- scrollable content

---

# 9.2 iPad Forms

Prefer:
- centered constrained width
- improved readability
- floating-card appearance

Recommended max width:
- 700–900pt

---

# 9.3 Avoid

Avoid:
- edge-to-edge text forms on iPad
- extremely wide text layouts

---

# 10. Content Width Rules

Readable content should remain constrained.

---

# 10.1 Maximum Width Recommendations

| Content Type | Recommended Max Width |
|---|---|
| Forms | 700–900pt |
| Text-heavy content | 700pt |
| Dashboard sections | 1200pt |
| Timer screens | 600–800pt |

---

# 10.2 Centering Strategy

On large screens:
- center important content
- avoid stretched layouts
- preserve whitespace

---

# 11. Timer Screen Responsiveness

Timer screens are immersive experiences.

---

# 11.1 iPhone Timer Layout

Prefer:
- vertically centered layout
- full-screen focus experience
- large circular timer

---

# 11.2 iPad Timer Layout

Prefer:
- centered immersive layout
- larger breathing space
- optional supporting side content

Avoid:
- oversized stretched countdown circles

---

# 12. Split Screen Support

The application must support:
- split view multitasking
- Stage Manager resizing

---

# 12.1 Split Screen Rules

Layouts should:
- adapt dynamically
- preserve usability
- remain readable at narrow widths

Avoid:
- assuming full screen width
- static grid column counts

---

# 13. Landscape Support

Landscape layouts should:
- remain intentional
- avoid awkward whitespace
- preserve readability

---

# 13.1 Landscape Recommendations

Prefer:
- side-by-side layouts
- adaptive dashboards
- horizontal content grouping

Avoid:
- simply rotating portrait layouts unchanged

---

# 14. Dynamic Type Support

Responsive layouts must support:
- Dynamic Type scaling
- accessibility font sizes

Use:
- flexible containers
- adaptive spacing
- multiline text support

Avoid:
- fixed-height text containers

---

# 15. Safe Area Guidelines

Always respect:
- safe areas
- Dynamic Island
- iPad multitasking insets

Use:
- safeAreaInset
- contentMargins where appropriate

Avoid:
- ignoring system insets

---

# 16. Responsive Animation Rules

Animations should adapt naturally.

Avoid:
- hardcoded animation offsets
- fixed screen-size assumptions

Prefer:
- container-relative animations
- adaptive transitions

---

# 17. Adaptive Component Strategy

Reusable components should:
- support multiple widths
- remain composable
- avoid device assumptions

---

# 17.1 Component Rules

Components should:
- grow naturally
- shrink gracefully
- avoid internal hardcoded sizing

---

# 18. Device Detection Rules

Avoid:
- UIDevice checks
- device model branching

Prefer:
- size class awareness
- geometry-driven adaptation
- layout-driven responsiveness

---

# 19. Responsive Testing Checklist

All major screens should be tested on:

## iPhone
- standard portrait
- landscape
- Dynamic Type

## iPad
- portrait
- landscape
- split view
- Stage Manager

---

# 20. Performance Guidelines

Avoid:
- excessive GeometryReader nesting
- overly complex layout calculations
- duplicated view hierarchies

Prefer:
- lightweight adaptive layouts
- reusable responsive containers

---

# 21. Screenshot Reference Usage

Use MVP-1 screenshot references as:
- visual direction
- spacing guidance
- hierarchy reference

Do NOT:
- blindly force pixel-perfect recreation across all devices

The layout should adapt intelligently.

---

# 22. Future Expansion Considerations

The responsive system should support future:
- macOS adaptation
- keyboard shortcuts
- external display support
- multiwindow support

without major redesign.

---

# 23. Anti-Patterns To Avoid

Avoid:
- duplicated iPad/iPhone screens
- hardcoded widths/heights
- edge-to-edge text layouts
- stretched tablet UI
- giant empty whitespace regions
- fixed column counts
- layout logic scattered everywhere

---

# 24. Engineering Philosophy

Responsive layouts should feel:
- natural
- fluid
- modern
- platform-native
- maintainable

The layout system prioritizes:
- adaptability
- readability
- consistency
- SwiftUI-native responsiveness

```