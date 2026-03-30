# Phase 3: Hydration Tracker & Combined Notifications - Context

**Gathered:** 2026-03-30
**Status:** Ready for planning

<domain>
## Phase Boundary

Add hydration tracking (daily glass goal, logging, reminders) and integrate notifications so Pomodoro breaks and hydration reminders work as a unified system. Covers HYDR-01 through HYDR-05, CROSS-01, CROSS-02, and UX-03.

</domain>

<decisions>
## Implementation Decisions

### Hydration UI Layout
- **D-01:** Stacked sections — Pomodoro timer on top, hydration section below, separated by a divider, both always visible. Popover grows taller to accommodate both sections.
- **D-02:** Linear progress bar for daily goal visualization. Distinct from the circular timer ring — shows glasses consumed / daily goal with a horizontal bar and text label (e.g., "4 / 8 glasses").

### Combined Notifications
- **D-03:** Stacked but grouped notifications — separate notifications grouped under the app. "Break started" and "Time to hydrate" appear as a notification stack; user can act on each independently.
- **D-04:** Hydration notification includes a "Log Glass" action button — user can log a glass directly from the notification without opening the popover. Uses UNNotificationAction with a custom category.

### Logging Interaction
- **D-05:** Quick-add with size options — default prominent "Log Glass" button (250ml) plus a small dropdown/segmented control for alternate sizes: small (150ml), medium (250ml), large (500ml). Single tap for the common case, one extra tap for size variants.

### Hydration Reminder Behavior
- **D-06:** Pomodoro-aware hydration reminders — hydration timer runs on a 45-min cycle, but if a Pomodoro break starts within 5 minutes of the scheduled hydration reminder, the reminder merges with the break notification (advances or delays to coincide). Avoids interrupting focus sessions while ensuring reminders aren't lost.

### Agent's Discretion
- Exact hydration section layout spacing and typography
- How "undo" for accidental glass logging works (brief undo toast vs. minus button)
- Midnight reset implementation for daily glass count (same pattern as Pomodoro session reset)
- Whether hydration reminder icon changes in menu bar or stays Pomodoro-focused

</decisions>

<specifics>
## Specific Ideas

- The linear progress bar should feel lightweight — not competing visually with the timer ring
- "Log Glass" notification action should use `UNNotificationAction` with identifier, registered via `UNNotificationCategory`
- The 5-minute merge window for Pomodoro-aware reminders: if hydration due at T and break starts at T-5..T+5, combine them; otherwise fire hydration independently
- Size options (150/250/500ml) map to a simple enum, stored in ml internally, displayed as "Small / Medium / Large" labels

</specifics>

<canonical_refs>
## Canonical References

No external specs — requirements are fully captured in decisions above and in REQUIREMENTS.md (HYDR-01 through HYDR-05, CROSS-01, CROSS-02, UX-03).

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- **TimerRingView.swift**: Circular progress ring — NOT reused for hydration (linear bar chosen instead), but pattern of extracting reusable views is established
- **NotificationService.swift**: Already has `requestPermission()`, `sendWorkCompleteNotification()`, `sendBreakCompleteNotification()`, `sendEyeStrainNotification()`, `cancelTimerNotifications()` — extend with hydration notification methods and `UNNotificationCategory` registration for "Log Glass" action
- **PomodoroService.swift**: Has deadline-based timer pattern, `@Observable` + `@MainActor`, `@ObservationIgnored @AppStorage` for persistence — HydrationService should follow identical patterns

### Established Patterns
- **Service layer**: `@Observable @MainActor` classes with `@ObservationIgnored @AppStorage` for UserDefaults persistence
- **Timer**: Deadline-based using Date math (endDate + Timer.publish), not decrementing counter
- **App Nap**: `ProcessInfo.processInfo.beginActivity()` for background timer reliability
- **Notification wiring**: Service receives NotificationService via setter method, calls it on state transitions
- **Environment injection**: Services created as `@State` in PomoHydroApp, injected via `.environment()`

### Integration Points
- **PomoHydroApp.swift**: Must add `@State private var hydrationService = HydrationService()`, inject via `.environment()`, wire to NotificationService
- **MenuBarView.swift**: Must add HydrationView below PomodoroView with a Divider
- **NotificationService.swift**: Add `sendHydrationReminder()`, `registerHydrationCategory()` with "Log Glass" action, handle notification response for glass logging
- **PomodoroService.swift**: Needs to expose break-start events so HydrationService can detect the 5-min merge window (or HydrationService observes PomodoroService state)

</code_context>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.

</deferred>

---

*Phase: 03-hydration-tracker-combined-notifications*
*Context gathered: 2026-03-30*
