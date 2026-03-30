# Phase 3 Research: Hydration Tracker & Combined Notifications

**Researched:** 2026-03-30
**Discovery Level:** 1 (Quick Verification — all patterns established, confirming notification action API)

## Standard Stack

No new dependencies. Phase 3 uses exclusively:

- Swift + SwiftUI (same as Phase 1-2)
- UserNotifications framework (already imported)
- `@Observable` + `@MainActor` service pattern (established in Phase 2)
- `@ObservationIgnored @AppStorage` for persistence (established in Phase 2)

## Key Technical Findings

### 1. Actionable Notifications (UNNotificationAction + UNNotificationCategory)

For D-04 ("Log Glass" from notification), the pattern is:

```swift
// 1. Define action
let logGlassAction = UNNotificationAction(
    identifier: "LOG_GLASS",
    title: "Log Glass",
    options: .foreground  // or [] for background
)

// 2. Create category with action
let hydrationCategory = UNNotificationCategory(
    identifier: "HYDRATION_REMINDER",
    actions: [logGlassAction],
    intentIdentifiers: [],
    options: []
)

// 3. Register category with notification center
UNUserNotificationCenter.current().setNotificationCategories([hydrationCategory])

// 4. Set content.categoryIdentifier when creating notification
content.categoryIdentifier = "HYDRATION_REMINDER"

// 5. Handle response via UNUserNotificationCenterDelegate
func userNotificationCenter(_ center: UNUserNotificationCenter,
                           didReceive response: UNNotificationResponse,
                           withCompletionHandler completionHandler: @escaping () -> Void) {
    if response.actionIdentifier == "LOG_GLASS" {
        // Log the glass
    }
    completionHandler()
}
```

**Important:** Delegate must be set before app finishes launching. In SwiftUI MenuBarExtra app, use `init()` of the App struct or a `.task` modifier.

**Decision: Use `.foreground` option** — keeps it simple. Background execution for @MainActor service updates would require careful threading. Since the app is a menu bar utility, foregrounding is minimal disruption.

### 2. Hydration Timer Architecture

Follows PomodoroService deadline-based pattern exactly:

- Store `hydrationEndDate` for next reminder
- `Timer.publish` or `Timer.scheduledTimer` for countdown display
- `@AppStorage` for persistence of glass count, goal, interval, last reminder date

**Difference from Pomodoro:** Hydration timer is simpler — no state machine, just a repeating interval. States: `idle` (paused/no reminders) vs `active` (counting down to next reminder).

### 3. Pomodoro-Aware Merge Window (D-06)

The 5-minute merge window requires HydrationService to know when Pomodoro breaks start. Two approaches:

**Option A: Direct observation** — HydrationService receives PomodoroService reference and checks `state` changes.
**Option B: Callback/delegate** — PomodoroService calls HydrationService on break start.

**Decision: Option A (observation).** HydrationService gets `setPomodoroService()` (mirrors existing `setNotificationService()` pattern). When hydration reminder fires, check if Pomodoro break started within ±5 min window. If so, suppress standalone hydration notification (it merges into the combined break notification).

The combined notification logic lives in NotificationService — a new method `sendCombinedBreakNotification()` that PomodoroService calls on break start when hydration is due.

### 4. Midnight Reset for Glass Count (CROSS-02)

Same pattern as PomodoroService session count reset:

- Store date string in `@AppStorage("glassesDate")`
- On each tick / each access, compare to today string
- If different day, reset `glassesConsumed` to 0

### 5. UX-03: Dropdown Shows Timer + Water Count

MenuBarView already shows PomodoroView. Add HydrationView below with Divider separator (per D-01). Both sections always visible.

## Architecture Patterns

| Component           | Pattern                                       | Follows         |
| ------------------- | --------------------------------------------- | --------------- |
| HydrationService    | `@Observable @MainActor` + `@AppStorage`      | PomodoroService |
| HydrationView       | `@Environment(HydrationService.self)`         | PomodoroView    |
| Notification wiring | `setNotificationService()` + `.task` modifier | Phase 2 pattern |
| Timer               | Deadline-based Date math                      | PomodoroService |
| Persistence         | `@ObservationIgnored @AppStorage`             | PomodoroService |

## Don't Hand-Roll

- Notification scheduling — use `UNTimeIntervalNotificationTrigger`
- Timer accuracy — use deadline-based Date math (not decrementing counter)
- Persistence — use `@AppStorage` (not custom file I/O)

## Common Pitfalls

1. **Notification category registration timing** — Must register categories before any notification with that category is delivered. Register in app init.
2. **Delegate assignment timing** — UNUserNotificationCenter delegate must be set early. Use App init or `.task` modifier at top level.
3. **Multiple notification categories** — `setNotificationCategories` replaces ALL categories. Must register all categories (hydration + any future ones) in a single call.
4. **Merge window race condition** — If hydration timer and Pomodoro break fire at exact same time, need to handle gracefully. Solution: PomodoroService checks hydration state before sending break notification and sends combined version if hydration is due.

## Risks

- **Low risk:** All patterns are established from Phase 2
- **Medium risk:** Notification action delegate handling in SwiftUI MenuBarExtra — less common pattern, but well-documented

---

_Phase: 03-hydration-tracker-combined-notifications_
_Research completed: 2026-03-30_
