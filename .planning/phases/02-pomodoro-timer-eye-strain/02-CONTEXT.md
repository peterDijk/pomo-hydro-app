# Phase 2: Pomodoro Timer & Eye-Strain - Context

**Gathered:** 2026-03-30
**Status:** Ready for planning

<domain>
## Phase Boundary

Deliver a fully functional Pomodoro timer with configurable work/break durations, session counting, auto long breaks, integrated 20-20-20 eye-strain reminders, dynamic menu bar icons, App Nap prevention, and UserDefaults persistence. This phase replaces the Phase 1 placeholder content with the real timer UI.

</domain>

<decisions>
## Implementation Decisions

### Timer UI Layout
- **D-01:** Circular progress ring with phase label above ("Work Session" / "Short Break" / "Long Break"), countdown time in the center, session count below ("Session 2 of 4"), and start/pause/stop controls at the bottom.
- **D-02:** Idle state shows a prominent "Start Focus" button with duration subtitle (e.g. "25 min work session") instead of an empty ring. One tap to begin.

### Eye-Strain Integration
- **D-03:** Eye-strain reminders are notification-only — native macOS notification saying "Look at something 20 feet away for 20 seconds" with a dismiss action (EYE-03). No in-app UI change when the reminder fires.
- **D-04:** If the 20-minute eye-strain interval would fire within 3 minutes of the work session ending, suppress it and fold the "look away" message into the upcoming break notification instead (satisfies EYE-02 naturally).

### Menu Bar Icon States
- **D-05:** Three distinct SF Symbols for menu bar state: `timer` (idle), `timer.circle.fill` (working), `cup.and.saucer` (break). Clearly distinguishable at a glance.

### Auto-Start & Session Transitions
- **D-06:** When auto-start is enabled, a 5-second countdown ("Break starting in 5...") displays in the ring before the next phase begins automatically. Gives the user a beat to intervene.
- **D-07:** Auto-start is ON by default. Users who prefer manual control can toggle it off (configurable via Phase 4 settings, stored in @AppStorage now).

### Agent's Discretion
- Ring color/style (stroke width, gradient, colors for work vs break)
- Exact notification copy for work-end, break-end, and eye-strain reminders
- Internal timer architecture (Timer vs DispatchSourceTimer vs async sleep)
- UserDefaults key naming conventions
- How the 5-second auto-start countdown animates

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Research
- `.planning/research/STACK.md` — Recommended stack, MenuBarExtra setup, @Observable patterns
- `.planning/research/ARCHITECTURE.md` — Service-layer pattern, component boundaries
- `.planning/research/PITFALLS.md` — Critical pitfalls: App Nap (#1), timer accuracy (#2), notification permission denial (#3), auto-termination (#4), Swift 6 concurrency (#12)

### Project
- `.planning/PROJECT.md` — Project vision, constraints, key decisions
- `.planning/REQUIREMENTS.md` — Phase 2 requirements: POMO-01 through POMO-06, EYE-01 through EYE-03, UX-02, CROSS-04, CROSS-05

### Phase 1 Implementation
- `.planning/phases/01-app-shell-notifications/01-01-SUMMARY.md` — App shell, MenuBarExtra, NotificationService
- `.planning/phases/01-app-shell-notifications/01-02-SUMMARY.md` — Permission views, denied banner

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `NotificationService` (`Services/NotificationService.swift`): @Observable, @MainActor, already handles authorization, permission requests, and sending notifications. Phase 2 extends this for timer-specific notifications.
- `MenuBarView` (`Views/MenuBarView.swift`): Root popover view with auth status switching and footer (Settings/Quit). Phase 2 replaces `PlaceholderContentView` with the timer UI.
- `PomoHydroApp.swift`: @main entry with MenuBarExtra — the `systemImage` in the label needs to become dynamic based on timer state.

### Established Patterns
- `@Observable` services injected via `.environment()` — Phase 2 adds a `PomodoroService` following this same pattern
- `@AppStorage` for UserDefaults persistence (established in Phase 1 decisions, used for CROSS-05)
- Source files live at `PomoHydro/PomoHydro/` (nested Xcode path)
- Xcode uses `PBXFileSystemSynchronizedRootGroup` — auto-discovers new Swift files, no pbxproj edits needed

### Integration Points
- `PomoHydroApp.swift` label: `systemImage` must change dynamically based on `PomodoroService.timerState`
- `MenuBarView` replaces `PlaceholderContentView()` with the timer ring view
- `NotificationService.sendTestNotification()` pattern reused for timer notifications
- `ProcessInfo.processInfo.beginActivity()` for App Nap prevention (CROSS-04)

</code_context>

<specifics>
## Specific Ideas

- The circular ring should feel like a native macOS timer — clean, minimal, no flashy animations
- Break notifications should feel encouraging, not nagging: "Time for a break! Rest your eyes." rather than "STOP WORKING"
- The 5-second auto-start countdown should be subtle — a number ticking down in the ring center, not a modal alert

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.

</deferred>

---

*Phase: 02-pomodoro-timer-eye-strain*
*Context gathered: 2026-03-30*
