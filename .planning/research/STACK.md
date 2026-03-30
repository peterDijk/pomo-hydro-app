# Technology Stack

**Project:** PomoHydro — macOS menu bar health/productivity app
**Researched:** 2026-03-30
**Overall confidence:** HIGH — This is a pure first-party Apple stack with zero third-party dependencies.

## Recommended Stack

### Core Framework

| Technology | Version        | Purpose           | Why                                                                                                                                                                                                                   | Confidence |
| ---------- | -------------- | ----------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------- |
| Swift      | 6.x (Xcode 26) | Language          | Strict concurrency model (complete checking on by default), first-class Apple platform support. The user already has Xcode 26.1.1 installed.                                                                          | HIGH       |
| SwiftUI    | macOS 13+ APIs | UI framework      | `MenuBarExtra` scene (macOS 13+) is the official, supported way to build menu bar apps in SwiftUI — no AppKit shims needed. `.menuBarExtraStyle(.window)` gives us a popover with standard controls for the timer UI. | HIGH       |
| AppKit     | Minimal        | Menu bar fallback | Not needed as primary framework. `MenuBarExtra` handles everything. Only touch AppKit if we hit a SwiftUI limitation (unlikely for this scope).                                                                       | HIGH       |

### Menu Bar Integration

| Technology                    | API                                       | Purpose            | Why                                                                                                                                                                                                                                  | Confidence |
| ----------------------------- | ----------------------------------------- | ------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ---------- |
| SwiftUI `MenuBarExtra`        | `MenuBarExtra("PomoHydro", systemImage:)` | Menu bar presence  | Built-in SwiftUI scene type (macOS 13+). Handles NSStatusItem creation, popover lifecycle, and icon rendering automatically. No manual NSStatusBar/NSStatusItem management needed.                                                   | HIGH       |
| `.menuBarExtraStyle(.window)` | Modifier                                  | Rich popover UI    | Renders content as a popover-like window with standard SwiftUI controls. Supports ScrollView, grids, buttons, text — everything we need for timer display and water logging. Better than `.menu` style which only allows menu items. | HIGH       |
| `LSUIElement`                 | Info.plist key                            | Hide from Dock     | Set `LSUIElement = true` in Info.plist so the app doesn't appear in Dock or Cmd+Tab switcher. Standard pattern for menu-bar-only utilities. Verified in Apple docs.                                                                  | HIGH       |
| `Settings` scene              | SwiftUI Scene                             | Preferences window | Built-in SwiftUI scene that adds "Settings…" to the app menu. Opens a standard macOS preferences window. Pair with `MenuBarExtra` in the `App` body.                                                                                 | HIGH       |

### Notifications

| Technology        | Version      | Purpose             | Why                                                                                                                                                                                                                                                                                                       | Confidence |
| ----------------- | ------------ | ------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------- |
| UserNotifications | macOS 10.14+ | Local notifications | `UNUserNotificationCenter` for scheduling timed notifications. Supports repeating triggers via `UNTimeIntervalNotificationTrigger`. Handles permission requests, content customization (title, body, sound), and notification lifecycle. The only framework needed — no third-party notification library. | HIGH       |

### Data Persistence

| Technology     | Version          | Purpose          | Why                                                                                                                                                                       | Confidence |
| -------------- | ---------------- | ---------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------- |
| `@AppStorage`  | SwiftUI built-in | Settings binding | SwiftUI property wrapper over UserDefaults. Two-way binding for work duration, break duration, hydration interval, glass size. Settings UI updates storage automatically. | HIGH       |
| `UserDefaults` | Foundation       | Settings storage | Stores simple key-value pairs: timer durations (Int), glass size (Int), daily water count (Int), reminder toggles (Bool). Perfect for < 20 settings with primitive types. | HIGH       |

**NOT SwiftData.** SwiftData is designed for relational object graphs and is overkill for flat key-value settings. It adds model definitions, a container setup, and migration overhead we don't need. The app has no cross-day history, no relational data, no complex queries. UserDefaults + @AppStorage is the right tool.

**NOT Core Data.** Same reasoning as SwiftData but even more boilerplate.

**NOT a file-based store (JSON/plist).** UserDefaults already persists to a plist behind the scenes with zero code. Writing our own adds file I/O error handling for no benefit.

### Timer Infrastructure

| Technology              | API                                      | Purpose     | Why                                                                                                                                                       | Confidence |
| ----------------------- | ---------------------------------------- | ----------- | --------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------- |
| Foundation `Timer`      | `Timer.scheduledTimer` / `Timer.publish` | Timer ticks | Built-in, battle-tested. For SwiftUI, use `Timer.publish(every: 1, on: .main, in: .common)` with `.onReceive()` to update countdown display every second. | HIGH       |
| `Date` + `TimeInterval` | Foundation                               | Timer math  | Store timer end time as `Date`, compute remaining seconds. More robust than decrementing a counter (survives app backgrounding).                          | HIGH       |

### Build & Tooling

| Technology            | Version          | Purpose      | Why                                                                                                                                                  | Confidence |
| --------------------- | ---------------- | ------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------- | ---------- |
| Xcode                 | 26.1+            | IDE & build  | Standard Apple IDE. User already has 26.1.1. Includes SwiftUI previews, asset catalog, Info.plist editor, and notarization tools.                    | HIGH       |
| Swift Package Manager | Built into Xcode | Dependencies | No third-party dependencies expected, but SPM is there if we ever add one. No CocoaPods or Carthage needed.                                          | HIGH       |
| Xcode Previews        | Built into Xcode | UI iteration | `#Preview` macro for rapid SwiftUI iteration. Essential for designing the popover layout and settings view without launching the full app each time. | HIGH       |

### Testing

| Technology    | Version          | Purpose              | Why                                                                                                                                                                                         | Confidence |
| ------------- | ---------------- | -------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------- |
| Swift Testing | Swift 6+         | Unit tests           | Modern `@Test` and `@Suite` macros, `#expect` assertions. Cleaner than XCTest for new projects. Ships with Xcode 26. Use for timer logic, notification scheduling, and water tracking math. | HIGH       |
| XCTest        | Built into Xcode | UI tests (if needed) | Swift Testing doesn't yet support UI testing. If we need UI automation tests for the popover, XCTest's XCUITest is the only option. Likely unnecessary for v1 (personal tool).              | MEDIUM     |

### App Lifecycle & Architecture

| Pattern                           | Purpose                          | Why                                                                                                                                                                                                                           | Confidence |
| --------------------------------- | -------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------- |
| `@Observable` macro               | State management                 | Swift 5.9+ / Observation framework. Replaces `ObservableObject` + `@Published`. Simpler, more efficient — SwiftUI only re-renders views that read changed properties. Use for `TimerManager`, `HydrationTracker` view models. | HIGH       |
| Swift concurrency (`async/await`) | Notification permission requests | Built-in structured concurrency. `UNUserNotificationCenter.add(request)` is async. No need for Combine or completion handlers.                                                                                                | HIGH       |
| Single `@main App` struct         | App entry point                  | Standard SwiftUI lifecycle. Contains `MenuBarExtra` + `Settings` scenes. No `NSApplicationDelegate` needed unless we need AppKit hooks.                                                                                       | HIGH       |

## Alternatives Considered

| Category      | Recommended                  | Alternative                         | Why Not                                                                                                                                                               |
| ------------- | ---------------------------- | ----------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| UI Framework  | SwiftUI `MenuBarExtra`       | AppKit `NSStatusItem` + `NSPopover` | Manual management of status item, popover, and lifecycle. MenuBarExtra handles all of this. Only consider AppKit if MenuBarExtra hits a wall (hasn't for this scope). |
| UI Framework  | SwiftUI `MenuBarExtra`       | Electron / Tauri                    | Massive runtime overhead for a menu bar timer. 200MB+ Electron bundle vs ~5MB native. No justification for web tech in a single-platform utility.                     |
| UI Framework  | SwiftUI `MenuBarExtra`       | SwiftUI + `NSStatusItem` hybrid     | Unnecessary complexity. Would only make sense if we needed features MenuBarExtra doesn't support (e.g., dragging onto status item).                                   |
| Persistence   | `@AppStorage` / UserDefaults | SwiftData                           | Relational persistence layer for a flat key-value use case. Adds `@Model`, `ModelContainer`, and migration complexity for zero benefit.                               |
| Persistence   | `@AppStorage` / UserDefaults | Realm / SQLite                      | External dependency for trivial storage. Over-engineered.                                                                                                             |
| State         | `@Observable`                | `ObservableObject` + `@Published`   | Legacy pattern. `@Observable` is simpler, more performant, and the recommended path forward since Swift 5.9/macOS 14.                                                 |
| State         | `@Observable`                | Combine                             | Combine is in maintenance mode at Apple. `@Observable` + async/await replaces its use cases for new code.                                                             |
| Testing       | Swift Testing                | XCTest only                         | XCTest works but Swift Testing has better syntax (`#expect` vs `XCTAssert`), parameterized tests, and is Apple's direction forward.                                   |
| Timer         | Foundation `Timer`           | `DispatchSourceTimer`               | Lower-level API, harder to integrate with SwiftUI's run loop. Foundation Timer + `.onReceive` is the idiomatic SwiftUI approach.                                      |
| Notifications | UserNotifications            | Custom in-app alerts                | Would need the app to be frontmost. The whole point is background reminders. System notifications work when any app is in focus.                                      |

## What NOT to Use

| Technology                                                         | Why Not                                                                                                          |
| ------------------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------- |
| **Electron / Tauri**                                               | 40x the binary size, non-native notifications, no real menu bar integration. This is a 5MB app, not a 200MB one. |
| **SwiftData**                                                      | You're storing 6 settings values, not a relational graph. UserDefaults exists for exactly this.                  |
| **Combine**                                                        | In maintenance mode. `@Observable` + async/await covers all reactive needs for this app.                         |
| **CocoaPods / Carthage**                                           | Zero third-party dependencies. SPM is built-in if we ever add one.                                               |
| **NSApplicationDelegate**                                          | SwiftUI `@main App` struct handles lifecycle. No need to drop to AppKit delegation.                              |
| **Third-party notification libraries**                             | UserNotifications is simple, well-documented, and does everything we need.                                       |
| **GRDB / Realm / SQLite**                                          | Same as SwiftData argument. We're not persisting structured data.                                                |
| **Any menu bar helper library** (e.g., old `NSStatusBar` wrappers) | `MenuBarExtra` is first-party and handles everything. Third-party wrappers pre-date this API.                    |

## Zero External Dependencies

This app requires **no third-party packages**. The entire stack is Apple first-party:

- `SwiftUI` — UI and menu bar
- `Foundation` — Timers, dates, UserDefaults
- `UserNotifications` — System notifications
- `Observation` — `@Observable` macro
- `Swift Testing` — Test framework

This is intentional. A menu bar utility should be lightweight. Every external dependency adds binary size, update burden, and potential breakage. Apple's frameworks cover 100% of this app's needs.

## Project Setup

```bash
# Create via Xcode:
# File → New → Project → macOS → App
# Interface: SwiftUI
# Language: Swift
# Storage: None (we'll use UserDefaults, not SwiftData)
# Testing System: Swift Testing
```

### Info.plist Configuration

```xml
<!-- Hide from Dock and Cmd+Tab -->
<key>LSUIElement</key>
<true/>
```

### Minimum App Structure

```swift
@main
struct PomoHydroApp: App {
    var body: some Scene {
        MenuBarExtra("PomoHydro", systemImage: "drop.circle") {
            ContentView()
        }
        .menuBarExtraStyle(.window)

        Settings {
            SettingsView()
        }
    }
}
```

## Deployment Target

| Target        | Version       | Rationale                                                                                                                                                                                    |
| ------------- | ------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| macOS minimum | 14.0 (Sonoma) | Needed for `@Observable` macro. MenuBarExtra requires 13.0 but `@Observable` requires 14.0. Both are below the current macOS version. Personal use app — no need to support old OS versions. |
| Swift version | 6.x           | Ships with Xcode 26. Strict concurrency by default.                                                                                                                                          |
| Xcode         | 26.1+         | User already has 26.1.1 installed.                                                                                                                                                           |

## Sources

- [Apple Developer: MenuBarExtra](https://developer.apple.com/documentation/swiftui/menubarextra) — Verified via Context7 (HIGH confidence)
- [Apple Developer: MenuBarExtraStyle.window](https://developer.apple.com/documentation/swiftui/menubarextrastyle/window) — Verified via Context7 (HIGH confidence)
- [Apple Developer: Building and customizing the menu bar with SwiftUI](https://developer.apple.com/documentation/swiftui/building-and-customizing-the-menu-bar-with-swiftui) — Verified via Context7 (HIGH confidence)
- [Apple Developer: SwiftData](https://developer.apple.com/documentation/SwiftData) — Verified via Context7 (HIGH confidence, used for "why not" rationale)
- [Apple Developer: UserNotifications](https://developer.apple.com/documentation/UserNotifications) — Verified via Context7 (HIGH confidence)
- [Apple Developer: Scheduling local notifications](https://developer.apple.com/documentation/UserNotifications/scheduling-a-notification-locally-from-your-app) — Verified via Context7 (HIGH confidence)
