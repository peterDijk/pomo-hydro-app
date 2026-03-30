# Plan 04-01 Summary: Settings Window & Global Pause

## Outcome
All 3 tasks completed. Build succeeds. Commit: `b87f99b`

## What Was Built

### Task 1: SettingsView with TabView
- Created `PomoHydro/PomoHydro/Views/SettingsView.swift`
- `SettingsTab` enum (pomodoro, hydration, general) with label/icon
- `SettingsView` with `TabView(selection:)`, frame 400×300 min
- `PomodoroSettingsTab`: 4 sliders (workDuration 5–60, shortBreak 1–15, longBreak 5–30, sessions 2–8), 2 toggles (autoStartBreak, autoStartWork), Restore Defaults
- `HydrationSettingsTab`: 2 sliders (reminderInterval 15–120, dailyWaterGoal 1–20), Restore Defaults
- `GeneralSettingsTab`: Pause All Reminders toggle with onChange → pauseAll/resumeAll, Restore Defaults
- Reusable `sliderRow()` helper with `Binding<Double>` adapter for Int @AppStorage

### Task 2: Window Scene & Gear Button Wiring
- Added `Window("PomoHydro Settings", id: "settings")` scene to `PomoHydroApp.swift` with `.defaultSize(width: 450, height: 350)` and `.windowResizability(.contentSize)`
- Added `@Environment(\.openWindow)` to `MenuBarView.swift`
- Wired gear button action: `openWindow(id: "settings")`

### Task 3: Global Pause Logic
- **PomodoroService**: Added `@AppStorage("allPaused")`, `pauseAll()` (pauses active timer, cancels auto-start, stops eye-strain, ends App Nap), `resumeAll()` (resets to idle), `menuBarIcon` returns "pause.circle" when paused, `start()` guards against allPaused, auto-start checks allPaused
- **HydrationService**: Added `@AppStorage("allPaused")`, `startReminders()` guards against allPaused, `tick()` guards against allPaused

## Files Modified
- `PomoHydro/PomoHydro/Views/SettingsView.swift` (created)
- `PomoHydro/PomoHydro/PomoHydroApp.swift` (Window scene added)
- `PomoHydro/PomoHydro/Views/MenuBarView.swift` (openWindow + gear button)
- `PomoHydro/PomoHydro/Services/PomodoroService.swift` (allPaused, pauseAll, resumeAll)
- `PomoHydro/PomoHydro/Services/HydrationService.swift` (allPaused guards)

## Key Decisions
- Per D-01: Custom `Window` scene, not `Settings` scene
- Per D-02: Gear button only, no Cmd+, shortcut
- Per D-08: Unpause resets to idle (fresh start)
- Per D-09: pause.circle icon takes highest priority in menuBarIcon
