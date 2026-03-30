# Phase 1 Research: App Shell & Notifications

**Phase:** 01 - App Shell & Notifications
**Researched:** 2026-03-30
**Confidence:** HIGH — all APIs are first-party Apple, verified via Context7

## Implementation Approach

### Xcode Project Setup

Create via Xcode: File → New → Project → macOS → App. Settings:
- Interface: SwiftUI
- Language: Swift
- Storage: None (UserDefaults, not SwiftData)
- Bundle ID: `com.petervandijk.PomoHydro`
- Deployment target: macOS 14.0

Post-creation:
- Set `LSUIElement = true` in Info.plist (or target's custom macOS Application Target Properties)
- Enable Swift 6 strict concurrency: Build Settings → Swift Compiler → Strict Concurrency Checking → Complete
- Set SWIFT_VERSION to 6 in build settings

### MenuBarExtra Scene

```swift
@main
struct PomoHydroApp: App {
    @State private var notificationService = NotificationService()

    var body: some Scene {
        MenuBarExtra {
            MenuBarView()
                .environment(notificationService)
        } label: {
            Label("PomoHydro", systemImage: "timer")
        }
        .menuBarExtraStyle(.window)
    }
}
```

Key API facts (verified via Context7):
- `MenuBarExtra` is a `Scene` type, available macOS 13.0+
- `.menuBarExtraStyle(.window)` returns `WindowMenuBarExtraStyle` — renders as popover-like window
- Label uses `systemImage:` for SF Symbol icon
- The `.window` style supports all standard SwiftUI controls (ScrollView, buttons, text, etc.)
- No explicit window sizing API — content drives size via `.frame()` on the root view

### Notification Permission Flow

Verified API pattern from Apple docs:

```swift
// 1. Request authorization
let center = UNUserNotificationCenter.current()
try await center.requestAuthorization(options: [.alert, .sound])

// 2. Check status later
let settings = await center.notificationSettings()
// settings.authorizationStatus: .notDetermined, .denied, .authorized, .provisional

// 3. Schedule a notification
let content = UNMutableNotificationContent()
content.title = "Test"
content.body = "Notification infrastructure works"
content.sound = .default

let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
try await center.add(request)
```

### NotificationService Design

`@Observable` class that wraps UNUserNotificationCenter:
- Tracks `authorizationStatus` as a published property
- `requestPermission()` async method — calls `requestAuthorization(options: [.alert, .sound])`
- `checkStatus()` async method — calls `notificationSettings()`, updates status
- `sendTestNotification()` async method — schedules a 1-second delayed notification
- Check status on init and when popover appears

### Open System Settings (Denied State)

```swift
NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.Notifications-Settings")!)
```

## Key Risks

1. **LSUIElement in SwiftUI projects**: In modern Xcode, set via Info tab on the target, not a separate Info.plist file. Key is "Application is agent (UIElement)" = YES.
2. **Swift 6 strict concurrency**: `UNUserNotificationCenter` calls are async but the center itself is `@Sendable`. Access from `@MainActor`-isolated views needs care — mark NotificationService as `@MainActor` or use `nonisolated` methods.
3. **Popover sizing**: No explicit width/height API on `MenuBarExtra`. Use `.frame(width: 320, minHeight: 400)` on the root view inside the content closure.

## Standard Stack (Phase 1 subset)

- SwiftUI MenuBarExtra + .window style
- UNUserNotificationCenter (UserNotifications framework)
- @Observable + @Environment for state
- SF Symbols for icons
- San Francisco system font
- No external dependencies

## Architecture Patterns

- Service-layer: NotificationService owns notification logic, views consume via @Environment
- View state machine: MenuBarView switches between .notDetermined → PermissionPromptView, .authorized → PlaceholderContentView, .denied → DeniedBanner + PlaceholderContentView
