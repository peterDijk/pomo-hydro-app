# Domain Pitfalls

**Domain:** macOS menu bar health/productivity app (Pomodoro + eye-strain + hydration)
**Researched:** 2026-03-30
**Overall confidence:** HIGH — Based on Apple developer documentation (Timer, App Nap, MenuBarExtra, UNUserNotificationCenter), Stretchly issue patterns, and macOS platform behavior analysis.

---

## Critical Pitfalls

Mistakes that cause rewrites, broken core functionality, or apps that silently fail.

### Pitfall 1: App Nap Throttles Timers — Notifications Fire Late or Never

**What goes wrong:** macOS App Nap detects that a menu bar app (especially `LSUIElement = true` apps with no visible windows) isn't doing "important user work" and throttles its timers. A 25-minute Pomodoro timer fires at 27 minutes. A 20-minute eye-strain reminder fires at 24 minutes. A 45-minute hydration reminder fires at 52 minutes. The app looks broken but produces no errors.

**Why it happens:** App Nap criteria are: (1) not the foreground app, (2) hasn't recently drawn to a visible window, (3) not audible, (4) no process activity assertions. A menu bar app with a closed popover hits ALL four conditions simultaneously. App Nap then applies **timer throttling** — reducing frequency at which `Foundation.Timer` fires — and **priority reduction**. The Apple docs explicitly state: "timer throttling reduces the frequency with which the app's timers are fired."

**Consequences:** Every timer in the app drifts by seconds to minutes. Notifications arrive late. Users lose trust immediately — a timer that's off by 2 minutes is worse than no timer at all.

**Warning signs:**
- Timers work perfectly during development (Xcode debugger prevents App Nap)
- Timers work when the popover is open but drift when it's closed
- Works on the developer's machine but not after distributing to others
- Timer accuracy degrades over time when the Mac is under load

**Prevention:** Use `ProcessInfo.processInfo.beginActivity(options:reason:)` to prevent App Nap during active timer sessions. Specifically:
```swift
// When any timer starts
let activity = ProcessInfo.processInfo.beginActivity(
    options: .userInitiatedAllowingIdleSystemSleep,
    reason: "PomoHydro timer is running"
)
// Store `activity` and call endActivity() when ALL timers stop
```
Use `.userInitiatedAllowingIdleSystemSleep` (not `.userInitiated`) so the system can still sleep the display — we don't need the screen, just accurate timers. End the activity when no timers are running to be a good power citizen.

**Detection:** Test with Xcode detached (Product > Scheme > Edit Scheme > uncheck "Debug executable"). Monitor via Activity Monitor > Energy tab > App Nap column. Run timers with the popover closed for 30+ minutes.

**Phase mapping:** Must be addressed in the very first timer implementation phase. If the Pomodoro timer phase doesn't include this, every subsequent feature built on timers inherits the bug.

**Confidence:** HIGH — Verified in Apple's App Nap documentation and ProcessInfo.ActivityOptions reference.

---

### Pitfall 2: Timer Display Drift — Counting Down Seconds By Decrementing

**What goes wrong:** Developer implements the countdown by storing `remainingSeconds = 1500` and decrementing it every time a `Timer` fires. The displayed countdown gradually falls behind the real elapsed time. A 25-minute timer shows "0:03 remaining" when the real time says the 25 minutes are already up.

**Why it happens:** Foundation `Timer` is explicitly **not** a real-time mechanism. From Apple's docs: "If a timer's firing time occurs during a long run loop callout or while the run loop is in a mode that isn't monitoring the timer, the timer doesn't fire until the next time the run loop checks the timer. Therefore, the actual time at which a timer fires can be significantly later." Additionally, Apple says the system reserves the right to add tolerance even to zero-tolerance timers.

**Consequences:** The countdown display shows incorrect time. Over a 25-minute Pomodoro, the drift is typically 1-5 seconds — enough for the user to notice "it said 0:02 but the notification came 4 seconds later." Over multiple sessions, trust in the app erodes.

**Warning signs:**
- Timer sometimes shows 0:01 for too long before the notification fires
- Elapsed real-world time doesn't match the counter when you check manually
- Timer is more inaccurate when the Mac is busy

**Prevention:** Store the **target end time** as a `Date`, not a decrementing counter:
```swift
let endTime = Date().addingTimeInterval(25 * 60) // absolute target
// On each Timer tick, compute:
let remaining = endTime.timeIntervalSinceNow
```
The 1-second UI timer is purely for display refresh. The actual deadline is an absolute `Date`. Schedule the notification independently using `UNTimeIntervalNotificationTrigger` — the notification system has its own scheduling that's more reliable than your Timer.

**Phase mapping:** Timer implementation phase. This is an architecture decision that must be right from the start. Refactoring from decrement to deadline-based later means rewiring all state.

**Confidence:** HIGH — Apple's Timer documentation explicitly warns about this behavior.

---

### Pitfall 3: Notification Permission Denied Silently — App Appears Broken

**What goes wrong:** The app schedules notifications but they never appear. No error is thrown. `UNUserNotificationCenter.add()` succeeds without error even when the user has denied notification permission. The app looks functional (timers count down, UI updates) but the entire purpose — reminding the user — fails silently.

**Why it happens:** macOS asks the user for notification permission exactly once. If the user clicks "Don't Allow" (which easily happens if the prompt appears at app launch before the user understands the app), all subsequent notification scheduling succeeds with no error but the system swallows the notifications. There's no built-in re-prompt.

**Consequences:** The app is completely pointless — it's a timer that never tells you when time's up. The user doesn't know notifications are blocked; they think the app is buggy. Since macOS won't re-prompt, the user must manually go to System Settings > Notifications to fix it — which they'll never think to do.

**Warning signs:**
- "The app doesn't notify me" bug reports
- Timer completes but nothing happens
- Works fine on the developer's machine (where permission was granted)

**Prevention:**
1. **Check permission status before relying on it.** On first launch and periodically, call `UNUserNotificationCenter.current().getNotificationSettings()` and check `settings.authorizationStatus`.
2. **Request permission at the right moment** — not on app launch, but after the user has started their first timer (when they understand why they need notifications).
3. **Show an in-app fallback when denied.** If `authorizationStatus == .denied`, display a banner in the popover: "Notifications are disabled. Enable in System Settings > Notifications > PomoHydro" with a button that opens System Settings.
4. **Never silently fail.** If the user has denied notifications, the app must tell them visually.

**Phase mapping:** Notification setup phase. Must be handled before any feature that depends on notifications is considered "done."

**Confidence:** HIGH — This is documented behavior of UNUserNotificationCenter.

---

### Pitfall 4: MenuBarExtra Auto-Termination — App Quits Unexpectedly

**What goes wrong:** The user removes the menu bar icon (macOS allows this by holding Cmd and dragging), and the app terminates immediately. A running Pomodoro timer disappears. Daily water count resets. No warning, no save.

**Why it happens:** Apple's `MenuBarExtra` documentation states: "An app that only shows in the menu bar will be automatically terminated if the user removes the extra from the menu bar." This is by design for utility apps. When the `MenuBarExtra` is the only scene (no `WindowGroup`), removing it = quitting.

**Consequences:** Data loss (unsaved water count, lost session progress). User confusion — "the app just disappeared." Particularly dangerous because many macOS users don't even know they can drag status items away; they might do it accidentally.

**Warning signs:**
- App "randomly" disappears from the menu bar
- Water count resets to zero when reopened
- Timer state lost

**Prevention:**
1. **Persist state on every mutation.** Write water count and timer state to `UserDefaults` immediately when they change (which `@AppStorage` already does — but only for the properties that use it). Don't batch-save on quit because you won't get a quit event.
2. **On launch, restore previous state.** Check if a timer was running (stored end-time is in the future). Check if the same calendar day's water count exists.
3. **Accept the auto-termination** — don't fight it. Apple designed this behavior intentionally. Just make sure nothing is lost.

**Phase mapping:** Data persistence and timer-state design. Must be considered in the earliest timer and hydration phases.

**Confidence:** HIGH — Explicitly documented in Apple's MenuBarExtra docs.

---

## Moderate Pitfalls

### Pitfall 5: Notification Fatigue — Three Timer Domains Competing

**What goes wrong:** The app fires a Pomodoro break notification, then 30 seconds later an eye-strain notification, then 2 minutes later a hydration notification. The user is bombarded with 3 notifications in quick succession, gets annoyed, and either disables notifications or uninstalls.

**Why it happens:** The three timer domains (Pomodoro, eye-strain, hydration) run independently. Without coordination, their fire times can cluster. Over a 25-minute work session: eye-strain fires at 20:00, Pomodoro ends at 25:00, hydration fires at 25:00-ish. That's two near-simultaneous notifications.

**Prevention:**
1. **Eye-strain folds into Pomodoro breaks.** The PROJECT.md already specifies this — eye-strain reminders only fire during work blocks, and the break notification mentions both rest and eye care. Don't fire a separate eye-strain notification if a Pomodoro break is about to start within 2-3 minutes.
2. **Suppress hydration during breaks.** If the user is already on a Pomodoro break, defer the hydration reminder to after they resume work. They're already away from the screen.
3. **Never fire two notifications within 30 seconds.** Implement a simple debounce/queue in the `NotificationService`.

**Phase mapping:** Notification coordination. Should be addressed when the second timer domain is added alongside the first.

**Confidence:** HIGH — Standard UX pitfall; Stretchly explicitly has break de-duplication logic for this reason.

---

### Pitfall 6: MenuBarExtra .window Style Popover Dismissed on Focus Loss

**What goes wrong:** The user opens the menu bar popover to check their timer, then clicks on their editor to continue working, and the popover closes. They now have no persistent countdown visible. To check the timer they must click the menu bar icon again every time.

**Why it happens:** `.menuBarExtraStyle(.window)` creates a non-activating panel (popover) that dismisses when the user clicks outside of it. This is standard macOS behavior for menu bar popovers — it's by design, not a bug. But for a timer app, it means the countdown is only visible when the popover is open.

**Prevention:**
1. **Accept the pattern** — this is how every macOS menu bar app works (Dropbox, 1Password, Bartender). Don't try to keep the popover pinned.
2. **Show timer state in the menu bar icon itself.** Either use a dynamic SF Symbol (e.g., filled vs outlined to indicate running) or — for maximum information — show the remaining time as text next to the icon in the menu bar. Many timer apps (Flow, Be Focused) display "24:15" right in the menu bar.
3. **Use `Text` as the label** in `MenuBarExtra` which allows dynamic content: `MenuBarExtra { ... } label: { Text("24:15") }`. Note: this takes up more menu bar space but is the standard pattern for timer apps.

**Phase mapping:** Menu bar UI phase. Must decide on icon strategy early since it affects the `MenuBarExtra` label API choice.

**Confidence:** HIGH — Verified behavior of `.menuBarExtraStyle(.window)`.

---

### Pitfall 7: Daily Water Count Reset Logic — Timezone and Sleep Edge Cases

**What goes wrong:** The user logs 6 glasses of water at 11 PM, puts their Mac to sleep, opens it at 8 AM the next day, and still sees "6 glasses." Or worse: they open it at 12:01 AM (still awake, working late) and the count resets to zero mid-session.

**Why it happens:** "Reset at midnight" requires careful handling of:
- The app was asleep/terminated across midnight — need to check the date on wake/launch
- The user's timezone changes (travel, DST)
- The user crosses midnight while actively using the app

**Prevention:**
1. **Store the date alongside the count.** Save `lastLogDate: Date` (or just the calendar day component) in UserDefaults alongside the count.
2. **On every access, compare calendar days.** If `Calendar.current.isDateInToday(lastLogDate)` is false, reset the count.
3. **Check on app wake.** Listen for `NSWorkspace.willSleepNotification` / `NSWorkspace.didWakeNotification` and re-evaluate the date.
4. **Don't use a timer for midnight reset.** Timers are unreliable across sleep (see Pitfall 1). Just check the date when the app wakes or when the user interacts.

**Phase mapping:** Hydration feature phase.

**Confidence:** HIGH — Standard date/time handling pitfall.

---

### Pitfall 8: Launch at Login Requires SMAppService — Not NSWorkspace or Login Items

**What goes wrong:** Developer uses the deprecated `NSWorkspace.shared.loginItemsSettings` or the legacy "Login Items" approach. It either doesn't work, requires special entitlements, or creates a confusing duplicate entry in System Settings.

**Why it happens:** macOS has gone through multiple "launch at login" APIs:
1. ~~Shared File List~~ (deprecated, removed)
2. ~~`SMLoginItemSetEnabled` with helper app~~ (deprecated)
3. **`SMAppService.mainApp.register()`** (macOS 13+, current)

Old tutorials and Stack Overflow answers point to the deprecated approaches.

**Prevention:** Use `SMAppService.mainApp.register()` (Service Management framework, macOS 13+). This is the modern, correct API. It registers the app to launch at login and appears properly in System Settings > General > Login Items. Since PomoHydro already targets macOS 13+ (for `MenuBarExtra`), this API is available.

```swift
import ServiceManagement
try SMAppService.mainApp.register()
```

**Phase mapping:** Settings/configuration phase. Low risk since the correct API is simple, but must use the right one.

**Confidence:** HIGH — `SMAppService` is documented as the replacement. Other approaches are deprecated.

---

### Pitfall 9: Timer State Survives Popover Close but Not App Restart Without Explicit Persistence

**What goes wrong:** The user starts a 25-minute Pomodoro, the menu bar icon shows it's running, the app crashes (or macOS kills it for memory, or auto-terminates per Pitfall 4). On relaunch, the timer is gone — the remaining 18 minutes are lost.

**Why it happens:** `@Observable` / `@State` properties live in memory. They survive popover open/close (good) but not process termination (bad). Unlike iOS where app state restoration is a framework concern, macOS menu bar apps have no built-in state restoration.

**Prevention:**
1. **Persist the end-time, not the remaining seconds.** When a timer starts, write `pomodoroEndTime: Date` to `UserDefaults`. This is idempotent and survives restarts.
2. **On launch, check if `pomodoroEndTime` is in the future.** If yes, resume the timer. If it's in the past (the notification should have fired while the app was dead), show a "you missed a break" state.
3. **Persist timer phase** (working, short break, long break, idle) and session count to UserDefaults.
4. **Schedule notifications independently** via `UNTimeIntervalNotificationTrigger`. These survive app termination — the system delivers them even if the app is dead.

**Phase mapping:** Timer implementation phase. Notification scheduling should be done at timer-start time, not at the moment the timer reaches zero.

**Confidence:** HIGH — Standard macOS app lifecycle knowledge.

---

## Minor Pitfalls

### Pitfall 10: Menu Bar Space — Timer Text Pushes Other Icons Off Screen

**What goes wrong:** Displaying "🍅 24:15 | 💧 6/8" in the menu bar label takes ~120px. On a 13" MacBook with the notch and several status icons, this pushes other icons offscreen or gets cut off itself.

**Prevention:** Keep the menu bar label compact. Options:
- Icon only (16px) — least informative but safest
- Icon + abbreviated countdown ("24:15") — ~50px, reasonable
- Let the user choose in settings: "Show timer in menu bar" toggle
- Never show water count in the menu bar text — save it for the popover

**Phase mapping:** Menu bar UI phase.

**Confidence:** MEDIUM — Depends on user's screen size and status bar contents.

---

### Pitfall 11: Notification Sound Overuse — System Default Gets Annoying

**What goes wrong:** Every notification (Pomodoro end, break end, eye-strain, hydration) uses the system default notification sound. With notifications firing every 20-45 minutes, the repeated "ding" becomes Pavlovian stress.

**Prevention:**
- Use `.default` sound only for the high-priority notification (Pomodoro work session end)
- Use no sound (`.none` or omit the sound property) for lower-priority ones (hydration reminders, eye-strain nudges)
- Let the user configure sound per notification type in settings

**Phase mapping:** Notification feature phase.

**Confidence:** MEDIUM — UX preference, not a technical risk.

---

### Pitfall 12: Swift 6 Strict Concurrency — Timer Callbacks on Wrong Actor

**What goes wrong:** Swift 6's complete concurrency checking flags warnings or errors when `Timer` callbacks or `UNUserNotificationCenter` delegate methods access `@MainActor`-isolated state. The app compiles with warnings in Swift 5 mode but fails or requires annotation changes in Swift 6.

**Why it happens:** `Timer.scheduledTimer` callbacks and `UNUserNotificationCenter` delegate methods may not run on the main actor. Accessing `@Observable` state (which is implicitly `@MainActor` in SwiftUI) from these callbacks triggers data race warnings under strict concurrency.

**Prevention:**
- Use `Timer.publish(every:on:in:)` with `.onReceive()` in SwiftUI — this delivers on the main run loop, inherently `@MainActor`-safe.
- For notification delegate methods, use `@MainActor` annotation or `MainActor.run { }`.
- Enable strict concurrency checking from the start (`SWIFT_STRICT_CONCURRENCY = complete` in build settings). Don't defer this to later.

**Phase mapping:** Project setup / first phase. Must be enabled from the start; retrofitting strict concurrency onto an existing codebase is painful.

**Confidence:** HIGH — Swift 6 strict concurrency is the default in Xcode 26.

---

## Phase-Specific Warnings

| Phase Topic | Likely Pitfall | Mitigation |
|---|---|---|
| Project setup | Pitfall 12 (Swift 6 concurrency) | Enable strict concurrency checking from day one |
| Menu bar UI | Pitfall 6 (popover dismisses), Pitfall 10 (space) | Decide icon vs. text label strategy early |
| Pomodoro timer | Pitfall 1 (App Nap), Pitfall 2 (timer drift), Pitfall 9 (state persistence) | Use `ProcessInfo.beginActivity`, deadline-based timer, persist end-time |
| Notifications | Pitfall 3 (permission denied), Pitfall 5 (fatigue), Pitfall 11 (sound) | Check permission status, coordinate notification firing, vary sounds |
| Eye-strain integration | Pitfall 5 (notification clustering) | Fold eye-strain into Pomodoro break, suppress near break boundaries |
| Hydration feature | Pitfall 7 (daily reset), Pitfall 4 (auto-termination data loss) | Date-based reset check, persist on every mutation |
| Settings / launch at login | Pitfall 8 (deprecated API) | Use `SMAppService.mainApp.register()` only |
| Distribution / testing | Pitfall 1 (App Nap invisible in dev) | Test with debugger detached, monitor Activity Monitor |

---

## Sources

- **Apple: App Nap / Energy Efficiency Guide** — https://developer.apple.com/library/archive/documentation/Performance/Conceptual/power_efficiency_guidelines_osx/AppNap.html (Confidence: HIGH)
- **Apple: ProcessInfo.ActivityOptions** — https://developer.apple.com/documentation/foundation/processinfo/activityoptions (Confidence: HIGH)
- **Apple: ProcessInfo.beginActivity(options:reason:)** — https://developer.apple.com/documentation/foundation/processinfo/beginactivity(options:reason:) (Confidence: HIGH)
- **Apple: Foundation Timer** — https://developer.apple.com/documentation/foundation/timer (Confidence: HIGH, explicitly warns "not a real-time mechanism")
- **Apple: MenuBarExtra** — https://developer.apple.com/documentation/swiftui/menubarextra (Confidence: HIGH, auto-termination documented)
- **Apple: UNUserNotificationCenter** — https://developer.apple.com/documentation/usernotifications/unusernotificationcenter (Confidence: HIGH)
- **Apple: Scheduling local notifications** — https://developer.apple.com/documentation/usernotifications/scheduling-a-notification-locally-from-your-app (Confidence: HIGH)
- **Apple: SMAppService** — https://developer.apple.com/documentation/servicemanagement/smappservice (Confidence: HIGH)
- **Stretchly architecture** (open source, 6.1k★) — analyzed for break de-duplication and timer coordination patterns (Confidence: MEDIUM)
