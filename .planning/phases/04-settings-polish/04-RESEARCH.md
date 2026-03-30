# Phase 4: Settings & Polish — Research

**Date:** 2026-03-30
**Phase Requirements:** SET-01, SET-02, SET-03, UX-04

## Standard Stack

- **SwiftUI Window scene** — `Window(id:)` for single-instance settings window (not `WindowGroup` which allows multiple instances, not `Settings` which uses Cmd+, which user declined per D-02)
- **`@Environment(\.openWindow)`** — Environment action to programmatically open the Window scene from MenuBarView's gear button
- **`TabView(selection:)`** — SwiftUI native tab control for Pomodoro/Hydration/General tabs
- **`@AppStorage`** — Already established pattern in both PomodoroService and HydrationService; settings views will bind directly to UserDefaults via their own @AppStorage properties (mirrors the service @AppStorage keys)
- **`Slider`** — SwiftUI native control for numeric range values (durations, counts)
- **`Toggle`** — SwiftUI native control for boolean settings (autoStartBreak, autoStartWork)
- **`.defaultSize(width:height:)`** — Scene modifier for initial window dimensions
- **`.windowResizability(.contentSize)`** — Lock window to content size (settings windows shouldn't freely resize)

## Architecture Patterns

### Window Scene Declaration

The `Window` scene type (macOS 13+) creates a single-instance window. When `openWindow(id:)` is called and the window is already open, it brings it to the front rather than creating a new one.

```swift
// In PomoHydroApp.swift body
Window("PomoHydro Settings", id: "settings") {
    SettingsView()
        .environment(pomodoroService)
        .environment(hydrationService)
}
.defaultSize(width: 450, height: 350)
.windowResizability(.contentSize)
```

### openWindow from MenuBarExtra

MenuBarExtra views can access `@Environment(\.openWindow)` and call it:

```swift
// In MenuBarView.swift
@Environment(\.openWindow) private var openWindow

Button {
    openWindow(id: "settings")
} label: {
    Label("Settings…", systemImage: "gear")
}
```

### Settings ↔ Service Binding via @AppStorage

Because services use `@ObservationIgnored @AppStorage("key")`, the settings UI can independently declare `@AppStorage("key")` bindings with the same keys. Both read/write the same UserDefaults store. When the UI changes a value, the service's @AppStorage property reflects it on next access.

This means settings views do NOT need to reference service objects for settings values — they bind directly to UserDefaults. Services are only needed in settings views if we want to trigger an immediate recalculation (D-10).

### Mid-Session Timer Recalculation (D-10)

When a user changes `workDuration` mid-session while a Pomodoro timer is running:

1. The `endDate` needs recalculating: `endDate = startDate + (newDuration * 60)`
2. Since we store `endDate` (not startDate), we need: `newEndDate = endDate - (oldDuration * 60) + (newDuration * 60)`
3. Simpler: `newEndDate = endDate + ((newDuration - oldDuration) * 60)`

Approach: Add a method to PomodoroService like `recalculateEndDate(oldDuration:newDuration:)` that adjusts the running timer. The settings view calls this when a pomodoro duration slider changes. Same pattern for HydrationService reminder interval.

For HydrationService: when `reminderInterval` changes, restart the reminder timer from now with the new interval.

### Global Pause (D-07, D-08, D-09)

`@AppStorage("allPaused")` is the single source of truth. When set to `true`:

- PomodoroService: pause the running timer (if active), suppress auto-start
- HydrationService: stop reminder timer
- MenuBarView icon: override to `pause.circle`

Implementation: Both services should check `allPaused` on their timer ticks. Or better: the settings/MenuBarView that toggles `allPaused` should directly call service pause/resume methods.

Recommended approach:

1. Add `@ObservationIgnored @AppStorage("allPaused") var allPaused: Bool = false` to each service
2. Add `pauseAll()` and `resumeAll()` methods to each service
3. The View that toggles pause calls these methods on both services via their environment references

### Tab Structure

```swift
enum SettingsTab: String, CaseIterable {
    case pomodoro
    case hydration
    case general

    var label: String { ... }
    var icon: String { ... }  // SF Symbol name
}
```

### Restore Defaults (D-06)

Each tab view has a "Restore Defaults" button that resets only that tab's @AppStorage values. This is simply setting each @AppStorage property back to its default value:

```swift
Button("Restore Defaults") {
    workDuration = 25
    shortBreakDuration = 5
    // etc.
}
```

## Don't Hand-Roll

- **Don't use NSWindow** — SwiftUI `Window` scene handles everything needed
- **Don't use Combine/NotificationCenter for settings sync** — `@AppStorage` reads from the same UserDefaults automatically
- **Don't build custom tab bar** — SwiftUI `TabView` is the standard macOS approach
- **Don't create a SettingsManager/SettingsStore class** — Direct @AppStorage in views is the established pattern

## Common Pitfalls

1. **MenuBarExtra + openWindow**: `@Environment(\.openWindow)` works inside MenuBarExtra views. However, the settings window needs its own `.environment()` modifiers since it's a separate scene — it doesn't inherit from MenuBarExtra's environment.

2. **@AppStorage in @Observable**: Must use `@ObservationIgnored @AppStorage` pattern (already established). Settings views that are plain structs (not @Observable) can use `@AppStorage` directly without `@ObservationIgnored`.

3. **Slider binding with Int**: SwiftUI `Slider` works with `Double` by default. Need `Binding<Double>` adapter when binding to `@AppStorage` Int values. Use a computed binding or the `Slider(value:in:step:)` with appropriate conversion.

4. **Window lifecycle**: `Window` scene creates the window lazily on first `openWindow(id:)` call. The window can be closed by the user. Subsequent `openWindow(id:)` calls reopen it or bring it to front.

5. **allPaused state must be checked on timer tick**: If we just set the @AppStorage flag without actively stopping timers, timers will keep running. Need to actively pause/resume services when the flag changes.

---

_Research completed: 2026-03-30_
