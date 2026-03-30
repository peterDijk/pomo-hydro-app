---
phase: 01-app-shell-notifications
plan: 01
subsystem: app-shell
tags: [swiftui, menubarextra, observable, usernotifications, macos]

requires:
  - phase: none
    provides: "First phase — no prior dependencies"
provides:
  - "MenuBarExtra app shell with timer SF Symbol icon"
  - "NotificationService @Observable class tracking UNAuthorizationStatus"
  - "Popover window with auth-status-based view switching"
  - "PlaceholderContentView for future timer content"
  - "Stub views for PermissionPromptView and NotificationDeniedBanner"
affects: [01-02, 02-pomodoro-timer]

tech-stack:
  added: [SwiftUI MenuBarExtra, UserNotifications, Observation framework]
  patterns: ["@Observable service injection via .environment()", "scenePhase monitoring for popover re-focus", "LSUIElement for menu-bar-only app"]

key-files:
  created:
    - PomoHydro/PomoHydro/PomoHydroApp.swift
    - PomoHydro/PomoHydro/Services/NotificationService.swift
    - PomoHydro/PomoHydro/Views/MenuBarView.swift
    - PomoHydro/PomoHydro/Views/PlaceholderContentView.swift
    - PomoHydro/PomoHydro/Views/PermissionPromptView.swift
    - PomoHydro/PomoHydro/Views/NotificationDeniedBanner.swift
  modified:
    - PomoHydro/PomoHydro/PomoHydroApp.swift

key-decisions:
  - "Xcode project created manually via GUI (review concern: AI pbxproj corruption)"
  - "Used PBXFileSystemSynchronizedRootGroup (Xcode 26 auto-discovery of Swift files)"
  - "Added @Environment(\\.scenePhase) to MenuBarView for popover re-focus notification status refresh"
  - "Created stub views for PermissionPromptView/NotificationDeniedBanner to enable compilation (Plan 01-02 replaces)"

patterns-established:
  - "@Observable service pattern: create as @State on App, inject via .environment()"
  - "View switching via authorizationStatus enum — extensible for future states"
  - "scenePhase monitoring — recheck external state when popover reopens"

requirements-completed: [UX-01, UX-05]

duration: 12min
completed: 2026-03-30
---

# Phase 01 Plan 01: App Shell & NotificationService Summary

**MenuBarExtra popover shell with @Observable NotificationService, scenePhase-based status refresh, and LSUIElement configuration**

## Performance

- **Duration:** 12 min
- **Started:** 2026-03-30T14:32:59Z
- **Completed:** 2026-03-30T14:45:00Z
- **Tasks:** 3
- **Files modified:** 6

## Accomplishments
- Xcode project created with LSUIElement=YES, Swift 6 strict concurrency
- MenuBarExtra with `timer` SF Symbol, `.window` style popover at 320pt width
- NotificationService tracks UNAuthorizationStatus reactively via @Observable
- scenePhase monitoring refreshes notification status on popover re-focus
- Build verified: `xcodebuild BUILD SUCCEEDED`

## Task Commits

Each task was committed atomically:

1. **Task 1: Create Xcode project manually** — `560dc6e` (checkpoint:human-action — user created via Xcode GUI)
2. **Task 2: Configure MenuBarExtra shell and add scene phase handling** — `5284c06` (feat)
3. **Task 3: Implement NotificationService with authorization tracking** — `babe7b0` (feat)

**Cleanup commits:**
- `a1d1afd` — chore: remove default ContentView.swift
- `0e22929` — fix: add UserNotifications import and stub views for compilation

## Files Created/Modified
- `PomoHydro/PomoHydro/PomoHydroApp.swift` — @main entry point with MenuBarExtra scene
- `PomoHydro/PomoHydro/Services/NotificationService.swift` — @Observable notification wrapper
- `PomoHydro/PomoHydro/Views/MenuBarView.swift` — Root popover view with auth status switching
- `PomoHydro/PomoHydro/Views/PlaceholderContentView.swift` — Empty state placeholder
- `PomoHydro/PomoHydro/Views/PermissionPromptView.swift` — Stub (Plan 01-02 replaces)
- `PomoHydro/PomoHydro/Views/NotificationDeniedBanner.swift` — Stub (Plan 01-02 replaces)

## Decisions Made
- Xcode project structure: `PomoHydro/PomoHydro/` (standard Xcode nesting, deeper than plan expected)
- All plan file paths adapted from `PomoHydro/` to `PomoHydro/PomoHydro/` to match actual layout

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] File path nesting mismatch**
- **Found during:** Task 2 (MenuBarExtra shell)
- **Issue:** Plan referenced `PomoHydro/*.swift` but Xcode created `PomoHydro/PomoHydro/*.swift`
- **Fix:** All files created at `PomoHydro/PomoHydro/` path
- **Files modified:** All source files
- **Verification:** Build succeeded
- **Committed in:** 5284c06

**2. [Rule 3 - Blocking] Missing UserNotifications import in MenuBarView**
- **Found during:** Build verification
- **Issue:** MenuBarView.swift switches on UNAuthorizationStatus cases but only imports SwiftUI
- **Fix:** Added `import UserNotifications`
- **Files modified:** PomoHydro/PomoHydro/Views/MenuBarView.swift
- **Verification:** xcodebuild BUILD SUCCEEDED
- **Committed in:** 0e22929

**3. [Rule 3 - Blocking] Missing stub views for compilation**
- **Found during:** Build verification
- **Issue:** MenuBarView references PermissionPromptView and NotificationDeniedBanner (Plan 01-02)
- **Fix:** Created minimal stub views to enable compilation
- **Files modified:** PermissionPromptView.swift, NotificationDeniedBanner.swift
- **Verification:** xcodebuild BUILD SUCCEEDED
- **Committed in:** 0e22929

---

**Total deviations:** 3 auto-fixed (3x Rule 3 - Blocking)
**Impact on plan:** All fixes necessary for compilation. No scope creep. Stubs will be replaced by Plan 01-02.

## Issues Encountered
None — build compiles cleanly after blocking fixes.

## User Setup Required
None — no external service configuration required.

## Next Phase Readiness
Ready for Plan 01-02 (Wave 2): PermissionPromptView, NotificationDeniedBanner, and test notification wiring. Stub views exist and will be replaced with full implementations.

---
*Phase: 01-app-shell-notifications*
*Completed: 2026-03-30*
