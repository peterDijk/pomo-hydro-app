# Phase 4: Settings & Polish - Context

**Gathered:** 2026-03-30
**Status:** Ready for planning

<domain>
## Phase Boundary

Settings window with tabbed configuration for Pomodoro, Hydration, and General preferences, plus a global pause control accessible from the dropdown. All existing @AppStorage settings get a GUI surface; changes take effect immediately including mid-session timer adjustments.

</domain>

<decisions>
## Implementation Decisions

### Settings Window Approach
- **D-01:** Custom `Window` scene opened via `openWindow` environment action. The gear button in MenuBarView footer triggers it. Not a SwiftUI `Settings` scene — a standalone Window with its own identifier.
- **D-02:** No Cmd+, keyboard shortcut. Settings are accessible only via the gear button in the popover footer.

### Tab Layout & Controls
- **D-03:** Three tabs — Pomodoro, Hydration, General — using SwiftUI `TabView`. Tab labels with SF Symbols for visual consistency.
- **D-04:** Sliders for all duration/count settings. Each slider shows the current value label (e.g., "25 min") and has a defined range:
  - Work duration: 5–60 min
  - Short break: 1–15 min
  - Long break: 5–30 min
  - Sessions before long break: 2–8
  - Hydration reminder interval: 15–120 min
  - Daily water goal: 1–20 glasses
- **D-05:** Toggle switches for boolean settings (autoStartBreak, autoStartWork).
- **D-06:** Each tab has a "Restore Defaults" button at the bottom that resets only that tab's values to their original defaults.

### Global Pause
- **D-07:** Pause toggle lives in both the popover footer (next to the gear button, quick-access) and the General settings tab (for discoverability). Both reflect the same `@AppStorage("allPaused")` value.
- **D-08:** Pausing stops everything — all timers (Pomodoro, hydration reminders) stop, all notifications suppressed. Unpause resumes/restarts timers from fresh.
- **D-09:** When paused, menu bar icon changes to `pause.circle` SF Symbol, overriding the normal idle/working/break icons. Provides at-a-glance visibility that the app is paused.

### Immediate-Effect Behavior
- **D-10:** All settings changes take effect immediately via @AppStorage. Duration changes during an active timer session recalculate the timer's end time based on the new duration value. This may extend or shorten the current session.

### Agent's Discretion
- Window sizing and minimum dimensions
- Exact slider step increments
- Tab ordering (Pomodoro/Hydration/General suggested but flexible)
- Amount of explanatory text per setting (keep minimal)
- General tab contents beyond pause toggle (e.g., notification permission status display, about info)

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

No external specs — requirements fully captured in decisions above and REQUIREMENTS.md.

### Existing Code
- `PomoHydro/PomoHydro/Services/PomodoroService.swift` — All Pomodoro @AppStorage properties (workDuration, shortBreakDuration, longBreakDuration, sessionsBeforeLongBreak, autoStartBreak, autoStartWork)
- `PomoHydro/PomoHydro/Services/HydrationService.swift` — All Hydration @AppStorage properties (reminderInterval, dailyWaterGoal)
- `PomoHydro/PomoHydro/Views/MenuBarView.swift` — Existing gear button scaffolding (empty action, line 38-40), footer layout
- `PomoHydro/PomoHydro/PomoHydroApp.swift` — App entry point where Window scene must be added

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `@ObservationIgnored @AppStorage` pattern: established in both PomodoroService and HydrationService for settings in @Observable classes
- NotificationDeniedBanner: orange banner pattern from Phase 1 — similar visual pattern could inform the "paused" indicator style
- SF Symbols already used: `timer`, `timer.circle.fill`, `cup.and.saucer`, `gear`, `drop.fill`

### Established Patterns
- Services use `@Observable @MainActor final class` pattern
- Deadline-based timer using `Date` math (store endDate, compute remaining)
- `@Environment` injection for service access in views
- All mutable state persists to `@AppStorage` on every mutation (CROSS-05)

### Integration Points
- MenuBarView gear button (line 38) — currently has empty action, needs `openWindow` call
- PomoHydroApp.swift — needs `Window` scene declaration alongside existing `MenuBarExtra`
- PomodoroService + HydrationService — both need to respect `allPaused` flag
- Menu bar icon logic — needs `pause.circle` override when paused

</code_context>

<specifics>
## Specific Ideas

No specific requirements — open to standard approaches within the decisions above.

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.

</deferred>

---

*Phase: 04-settings-polish*
*Context gathered: 2026-03-30*
