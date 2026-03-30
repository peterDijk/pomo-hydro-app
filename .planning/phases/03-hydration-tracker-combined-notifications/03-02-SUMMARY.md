---
phase: 03-hydration-tracker-combined-notifications
plan: 02
subsystem: ui
tags: [swift, swiftui, hydration-ui, progress-bar, menu-bar, combined-notifications]

requires:
  - phase: 03-hydration-tracker-combined-notifications/01
    provides: "HydrationService, GlassSize enum, NotificationService hydration methods"
provides:
  - "HydrationProgressBar reusable linear progress bar component"
  - "HydrationView with glass count, progress bar, Log Glass button, size picker"
  - "MenuBarView integration showing hydration below Pomodoro timer"
  - "Combined notification logic in PomodoroService for CROSS-01"
affects: [04-settings-polish]

tech-stack:
  added: []
  patterns:
    [
      "GeometryReader + RoundedRectangle for custom progress bar",
      "@Bindable for two-way binding in @Observable environment",
      "Picker(.segmented) for size selection",
    ]

key-files:
  created:
    - PomoHydro/PomoHydro/Views/HydrationProgressBar.swift
    - PomoHydro/PomoHydro/Views/HydrationView.swift
  modified:
    - PomoHydro/PomoHydro/Views/MenuBarView.swift
    - PomoHydro/PomoHydro/Services/PomodoroService.swift
    - PomoHydro/PomoHydro/PomoHydroApp.swift

key-decisions:
  - "HydrationProgressBar uses GeometryReader + RoundedRectangle (not ProgressView — custom cyan color needed)"
  - "@Bindable used for two-way selectedSize binding in HydrationView"
  - "Combined notification checks isHydrationDue(within: 300) — 5 min merge window per D-06"
  - "HydrationView always visible regardless of Pomodoro state"

patterns-established:
  - "GeometryReader for custom-colored progress bars in SwiftUI"
  - "@Bindable var service = environmentService for two-way bindings"

requirements-completed: [UX-03, CROSS-01]

duration: 3min
completed: 2026-03-30
---

# Phase 3 Plan 02: HydrationView UI + Combined Notification Logic Summary

**HydrationView with glass count display, cyan progress bar, Log Glass button with drop.fill icon, S/M/L segmented size picker. Wired into MenuBarView below PomodoroView. Combined "Break Time — Hydrate!" notification when Pomodoro break starts within 5-min hydration window.**

## Performance

- **Duration:** 3 min
- **Started:** 2026-03-30T16:29:30Z
- **Completed:** 2026-03-30T16:32:30Z
- **Tasks:** 2
- **Files modified:** 5

## Accomplishments

- Created HydrationProgressBar: GeometryReader + RoundedRectangle, 8pt height, 4pt corners, cyan fill, animated .easeInOut(0.3)
- Created HydrationView: section label, glass count (.title3 semibold), unit label with formatted mL, progress bar with percentage, Log Glass button (.borderedProminent + drop.fill icon), segmented S/M/L size picker
- Used @Bindable for two-way binding of selectedSize with @Observable HydrationService
- Wired HydrationView into MenuBarView between section Divider and footer Divider
- Added HydrationService @Environment to MenuBarView
- Added HydrationService dependency to PomodoroService with setHydrationService()
- Implemented CROSS-01: completeCurrentPhase() checks isHydrationDue(within: 300) — sends sendCombinedBreakNotification when true, sendWorkCompleteNotification when false
- Added pomodoroService.setHydrationService(hydrationService) wiring in PomoHydroApp
- All accessibility labels per UI-SPEC

## Task Commits

1. **Tasks 1+2: HydrationView UI + MenuBarView wiring + combined notification** - `65a575b` (feat)

## Files Created/Modified

- `PomoHydro/PomoHydro/Views/HydrationProgressBar.swift` - Custom cyan linear progress bar
- `PomoHydro/PomoHydro/Views/HydrationView.swift` - Full hydration section UI
- `PomoHydro/PomoHydro/Views/MenuBarView.swift` - Added HydrationView between Pomodoro and footer
- `PomoHydro/PomoHydro/Services/PomodoroService.swift` - Combined notification logic (CROSS-01)
- `PomoHydro/PomoHydro/PomoHydroApp.swift` - Added HydrationService→PomodoroService wiring

## Deviations from Plan

None — plan executed exactly as written.

## Self-Check: PASSED
