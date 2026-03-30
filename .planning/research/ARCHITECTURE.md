# Architecture Patterns

**Domain:** macOS menu bar health/productivity app (Pomodoro + eye-strain + hydration)
**Researched:** 2026-03-30
**Overall confidence:** HIGH — Based on Apple's SwiftUI documentation (Context7), Stretchly's open-source architecture (6.1k★), and established macOS menu bar app patterns.

---

## Recommended Architecture

### Overview

PomoHydro is a single-process macOS menu bar app with no main window. The app lives entirely in the menu bar via SwiftUI's `MenuBarExtra` scene. Architecture follows the **service-layer pattern**: `@Observable` service classes own all business logic and timer state, SwiftUI views are thin consumers of that state.

```
┌─────────────────────────────────────────────────────────────────┐
│                     PomoHydroApp (@main)                        │
│                                                                 │
│  ┌────────────────────────┐    ┌────────────────────────────┐   │
│  │    MenuBarExtra        │    │     Settings Scene         │   │
│  │  (.window style)       │    │   (macOS preferences)      │   │
│  │                        │    │                            │   │
│  │  ┌──────────────────┐  │    │  ┌──────────────────────┐  │   │
│  │  │ MenuBarView      │  │    │  │ SettingsView         │  │   │
│  │  │  ├─ PomodoroTab  │  │    │  │  ├─ PomodoroSettings │  │   │
│  │  │  ├─ HydrationTab │  │    │  │  ├─ HydrationSettings│  │   │
│  │  │  └─ Controls     │  │    │  │  └─ GeneralSettings  │  │   │
│  │  └──────────────────┘  │    │  └──────────────────────┘  │   │
│  └────────────────────────┘    └────────────────────────────┘   │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │                    Service Layer                          │   │
│  │                                                          │   │
│  │  ┌─────────────────┐  ┌──────────────────┐              │   │
│  │  │ PomodoroService │  │ HydrationService │              │   │
│  │  │  └─ EyeStrain   │  │                  │              │   │
│  │  └─────────────────┘  └──────────────────┘              │   │
│  │                                                          │   │
│  │  ┌──────────────────────────────────────────────────┐    │   │
│  │  │            NotificationService                    │    │   │
│  │  └──────────────────────────────────────────────────┘    │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │              @AppStorage / UserDefaults                    │   │
│  └──────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

### Why This Shape

**Stretchly's architecture** (the closest open-source analog) reveals the key insight: timer/break apps grow complex fast because of state interactions (pause, resume, idle detection, DND, break overlaps). Stretchly manages this with a `BreaksPlanner` event emitter that coordinates `Scheduler`, `NaturalBreaksManager`, `DndManager`, and `AppExclusionsManager` — all separate modules with clear boundaries.

For PomoHydro, the same principle applies but with SwiftUI's `@Observable` replacing event emitters. The service layer is simpler because:
- Two independent timer domains (Pomodoro, Hydration) instead of Stretchly's interleaved mini/long breaks
- Eye-strain is a sub-concern of Pomodoro, not a separate timer domain
- No full-screen break windows, app exclusions, or break health scoring

---

## Component Boundaries

### 1. App Entry Point — `PomoHydroApp`

| Property | Value |
|----------|-------|
| **File** | `PomoHydroApp.swift` |
| **Responsibility** | Declare scenes, create services, inject into environment |
| **Contains** | `MenuBarExtra` scene + `Settings` scene |
| **Creates** | `PomodoroService`, `HydrationService`, `NotificationService` |
| **Pattern** | `@main struct`, services as `@State` properties, injected via `.environment()` |

```swift
@main
struct PomoHydroApp: App {
    @State private var pomodoroService = PomodoroService()
    @State private var hydrationService = HydrationService()
    @State private var notificationService = NotificationService()

    var body: some Scene {
        MenuBarExtra {
            MenuBarView()
        } label: {
            MenuBarLabel()
        }
        .menuBarExtraStyle(.window)
        .environment(pomodoroService)
        .environment(hydrationService)
        .environment(notificationService)

        Settings {
            SettingsView()
        }
        .environment(pomodoroService)
        .environment(hydrationService)
    }
}
```

**Key decision:** Services are `@State` on the App struct, not singletons. This is the recommended SwiftUI pattern — the App struct owns the lifecycle, views receive via `@Environment`.

**Info.plist:** `LSUIElement = true` to hide from Dock and Cmd+Tab.

---

### 2. PomodoroService — Timer Engine

| Property | Value |
|----------|-------|
| **File** | `Services/PomodoroService.swift` |
| **Responsibility** | Pomodoro work/break cycle, session counting, eye-strain coordination |
| **Communicates with** | `NotificationService` (triggers notifications), `@AppStorage` (reads durations) |
| **Does NOT** | Render UI, manage hydration, persist history |

```swift
@Observable
@MainActor
final class PomodoroService {
    // MARK: - Published State (drives UI)
    private(set) var state: PomodoroState = .idle      // .idle, .working, .shortBreak, .longBreak
    private(set) var secondsRemaining: Int = 0
    private(set) var sessionsCompleted: Int = 0

    // MARK: - Eye-Strain Sub-Timer
    private(set) var eyeStrainDue: Bool = false         // true when 20-min mark hit during work

    // MARK: - Settings (read from UserDefaults)
    @AppStorage("workDuration") var workDuration: Int = 25
    @AppStorage("shortBreakDuration") var shortBreakDuration: Int = 5
    @AppStorage("longBreakDuration") var longBreakDuration: Int = 15
    @AppStorage("sessionsBeforeLongBreak") var sessionsBeforeLongBreak: Int = 4
    @AppStorage("autoStartBreak") var autoStartBreak: Bool = false
    @AppStorage("autoStartWork") var autoStartWork: Bool = false

    // MARK: - Internal
    private var timer: Timer?
    private var endDate: Date?
    private var eyeStrainTimer: Timer?
}
```

**State machine:**

```
         start()
  idle ──────────► working ──┐
   ▲                         │ timer completes
   │                         ▼
   │  skip/stop    ┌─────────────────┐
   └───────────────┤  shortBreak     │
                   │  (or longBreak  │
                   │   every N)      │
                   └────────┬────────┘
                            │ timer completes
                            ▼
                     idle (or auto-start → working)
```

**Eye-strain integration:** During `working` state, a secondary 20-minute repeating timer fires `eyeStrainDue = true`. This flag is consumed by the notification service to fold "look away for 20 seconds" into the next available notification. When a break starts, eye-strain timer pauses. When work resumes, it resets.

**Timer approach:** Store `endDate = Date().addingTimeInterval(duration)`, compute `secondsRemaining` each tick. This survives app naps better than decrementing a counter (lesson from Stretchly's `Scheduler` which stores timestamps, not decrements).

---

### 3. HydrationService — Independent Tracker

| Property | Value |
|----------|-------|
| **File** | `Services/HydrationService.swift` |
| **Responsibility** | Water reminder timer, glass logging, daily count |
| **Communicates with** | `NotificationService` (triggers reminders), `@AppStorage` (reads interval) |
| **Does NOT** | Know about Pomodoro state, render UI |

```swift
@Observable
@MainActor
final class HydrationService {
    // MARK: - Published State
    private(set) var glassesLogged: Int = 0
    private(set) var secondsUntilReminder: Int = 0

    // MARK: - Settings
    @AppStorage("hydrationInterval") var hydrationInterval: Int = 45  // minutes
    @AppStorage("glassSize") var glassSize: Int = 250                 // mL
    @AppStorage("dailyGoal") var dailyGoal: Int = 8                   // glasses

    // MARK: - Computed
    var totalML: Int { glassesLogged * glassSize }
    var goalReached: Bool { glassesLogged >= dailyGoal }

    // MARK: - Internal
    private var reminderTimer: Timer?
    private var nextReminderDate: Date?
}
```

**Key behaviors:**
- `logGlass()` increments `glassesLogged`, no notification needed
- Reminder timer fires independently of Pomodoro — hydration doesn't care if you're in a work session or break
- Daily reset: on each timer tick or app foregrounding, check if the date has changed since last reset. If yes, zero out `glassesLogged` and `sessionsCompleted` (on PomodoroService). Simpler and more reliable than scheduling a midnight timer.

**Independence from Pomodoro is deliberate.** Stretchly's architecture couples mini-breaks and long-breaks through a shared `BreaksPlanner`, which creates complex state interactions (pause one → affects the other). PomoHydro avoids this: Pomodoro and Hydration are fully independent services that can be paused/resumed separately.

---

### 4. NotificationService — Cross-Cutting

| Property | Value |
|----------|-------|
| **File** | `Services/NotificationService.swift` |
| **Responsibility** | Permission requests, notification creation, combined break notifications |
| **Communicates with** | `UNUserNotificationCenter` (system API) |
| **Called by** | `PomodoroService`, `HydrationService` |

```swift
@Observable
@MainActor
final class NotificationService {
    private(set) var isAuthorized: Bool = false

    func requestPermission() async { ... }
    func sendPomodoroBreakNotification(includeEyeStrain: Bool) { ... }
    func sendWorkResumeNotification() { ... }
    func sendHydrationReminder(glassesLogged: Int, dailyGoal: Int) { ... }
    func sendCombinedBreakNotification(includeHydration: Bool) { ... }
}
```

**The combined notification is the killer feature.** When a Pomodoro break starts AND it's been a while since water, `sendCombinedBreakNotification` fires: "Break time! Rest your eyes — look at something 20ft away. And drink some water (3/8 glasses today)." This is the one notification that replaces three separate apps.

**Implementation:** Each service calls `NotificationService` methods directly — no pub/sub or event bus needed. The notification service is stateless except for the `isAuthorized` flag. Notification content is composed from parameters, not by reading other services' state (avoids coupling).

---

### 5. Settings Layer — @AppStorage

| Property | Value |
|----------|-------|
| **Mechanism** | `@AppStorage` property wrappers on service classes |
| **Storage** | `UserDefaults.standard` (automatic, no custom suite needed) |
| **UI Binding** | SwiftUI `$service.propertyName` two-way binding in SettingsView |

**No dedicated settings model class.** Each service owns its own settings via `@AppStorage`. This is intentional:
- Settings are co-located with the logic that uses them
- No need for a `SettingsManager` indirection layer
- SwiftUI `@AppStorage` provides automatic persistence and UI binding
- Total settings count is ~12 primitives — well within UserDefaults' sweet spot

**Settings keys (exhaustive list for v1):**

| Key | Type | Default | Owner |
|-----|------|---------|-------|
| `workDuration` | Int (minutes) | 25 | PomodoroService |
| `shortBreakDuration` | Int (minutes) | 5 | PomodoroService |
| `longBreakDuration` | Int (minutes) | 15 | PomodoroService |
| `sessionsBeforeLongBreak` | Int | 4 | PomodoroService |
| `autoStartBreak` | Bool | false | PomodoroService |
| `autoStartWork` | Bool | false | PomodoroService |
| `hydrationInterval` | Int (minutes) | 45 | HydrationService |
| `glassSize` | Int (mL) | 250 | HydrationService |
| `dailyGoal` | Int (glasses) | 8 | HydrationService |

---

### 6. View Layer — Thin UI

| Component | File | Reads From | Actions |
|-----------|------|------------|---------|
| `MenuBarLabel` | `Views/MenuBarLabel.swift` | PomodoroService (state, time), HydrationService (count) | None — display only |
| `MenuBarView` | `Views/MenuBarView.swift` | Both services | Start/stop/pause, log glass |
| `PomodoroSection` | `Views/PomodoroSection.swift` | PomodoroService | Start, pause, stop, skip |
| `HydrationSection` | `Views/HydrationSection.swift` | HydrationService | Log glass |
| `SettingsView` | `Views/SettingsView.swift` | Both services (bindings) | Modify settings |

**Views follow one rule:** read service state, call service methods. No business logic in views. No timer math, no notification scheduling, no state machine transitions.

```swift
struct PomodoroSection: View {
    @Environment(PomodoroService.self) private var pomodoro

    var body: some View {
        VStack {
            Text(pomodoro.state.displayName)
            Text(pomodoro.formattedTimeRemaining)
                .font(.system(.title, design: .monospaced))

            HStack {
                Button("Start") { pomodoro.start() }
                    .disabled(pomodoro.state != .idle)
                Button("Pause") { pomodoro.pause() }
                    .disabled(pomodoro.state == .idle)
                Button("Stop") { pomodoro.stop() }
                    .disabled(pomodoro.state == .idle)
            }

            Text("Sessions: \(pomodoro.sessionsCompleted)")
        }
    }
}
```

---

## Data Flow

### Timer Tick Flow (every 1 second)

```
Timer.publish(every: 1)
    │
    ▼
PomodoroService.tick()
    ├── Compute secondsRemaining from endDate
    ├── If secondsRemaining <= 0:
    │       ├── Transition state machine
    │       ├── Call notificationService.sendBreakNotification(...)
    │       └── Update sessionsCompleted
    └── If eyeStrainTimer fired during work:
            └── Set eyeStrainDue = true (consumed on next break notification)
    │
    ▼
SwiftUI re-renders ONLY views that read changed properties
(@Observable tracks access automatically — no manual objectWillChange)
```

### Hydration Flow

```
User taps "+1 Glass" in MenuBarView
    │
    ▼
hydrationService.logGlass()
    ├── glassesLogged += 1
    └── SwiftUI updates HydrationSection and MenuBarLabel
```

```
Hydration reminder timer fires
    │
    ▼
hydrationService → notificationService.sendHydrationReminder(...)
    │
    ▼
macOS shows notification: "Time for water! (3/8 glasses today)"
```

### Combined Break Notification Flow

```
PomodoroService timer completes (work → break)
    │
    ▼
PomodoroService checks:
    ├── eyeStrainDue? → include eye-strain message
    ├── hydrationService.shouldRemind? → include hydration nudge
    │
    ▼
notificationService.sendCombinedBreakNotification(
    includeEyeStrain: true,
    includeHydration: true,
    glassesLogged: 3,
    dailyGoal: 8
)
    │
    ▼
macOS notification:
    "Break time! 🎯 Session 3/4 complete.
     Look at something 20ft away for 20 seconds.
     Stay hydrated — 3/8 glasses today."
```

**Cross-service communication for combined notification:** PomodoroService reads `hydrationService.glassesLogged` and `hydrationService.dailyGoal` at notification time. This is the ONLY point where the two services interact. The PomodoroService receives HydrationService via its initializer (or via environment) — not by owning it.

### Daily Reset Flow

```
Any timer tick or app becomes active
    │
    ▼
Check: has calendar day changed since lastResetDate?
    │
    YES ─► pomodoroService.resetDaily()  // sessionsCompleted = 0
    │      hydrationService.resetDaily() // glassesLogged = 0
    │      UserDefaults["lastResetDate"] = today
    │
    NO ──► continue
```

---

## File Structure

```
PomoHydro/
├── PomoHydroApp.swift              # @main, scene declarations, service creation
├── Info.plist                       # LSUIElement = true
│
├── Services/
│   ├── PomodoroService.swift        # Pomodoro state machine + eye-strain sub-timer
│   ├── HydrationService.swift       # Water tracking + reminder timer
│   └── NotificationService.swift    # UNUserNotificationCenter wrapper
│
├── Models/
│   └── PomodoroState.swift          # enum: idle, working, shortBreak, longBreak
│
├── Views/
│   ├── MenuBarLabel.swift           # SF Symbol icon + optional countdown text
│   ├── MenuBarView.swift            # Main popover content (sections for each feature)
│   ├── PomodoroSection.swift        # Timer display + controls
│   ├── HydrationSection.swift       # Glass count + log button
│   └── SettingsView.swift           # macOS preferences window (TabView with tabs)
│
└── Assets.xcassets/                 # App icon (if needed for About window)
```

**~10 files total for v1.** This is deliberately small. No `Utilities/`, no `Extensions/`, no `Protocols/` folders. If a helper is needed, it goes in the file that uses it until a second consumer appears.

---

## Patterns to Follow

### Pattern 1: Date-Based Timers (Not Decrementing Counters)

**What:** Store the target end time as a `Date`, compute remaining seconds on each tick.

**Why:** Decrementing a counter (`remaining -= 1`) drifts over time and breaks if the app is suspended (macOS App Nap). Stretchly's `Scheduler` class uses timestamps for exactly this reason. Date-based approach survives suspension: when the app wakes, `endDate - now` gives the correct remaining time (which might be zero or negative → trigger completion).

**Example:**
```swift
func start(durationMinutes: Int) {
    endDate = Date().addingTimeInterval(TimeInterval(durationMinutes * 60))
    timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
        self?.tick()
    }
}

private func tick() {
    guard let endDate else { return }
    let remaining = Int(endDate.timeIntervalSinceNow)
    if remaining <= 0 {
        timerCompleted()
    } else {
        secondsRemaining = remaining
    }
}
```

### Pattern 2: Service Layer with @Observable + @Environment

**What:** Business logic lives in `@Observable` classes. Views access them via `@Environment`. No singletons, no global state.

**Why:** Apple's recommended pattern since Swift 5.9. `@Observable` only triggers re-renders for properties that a specific view actually reads (fine-grained tracking). `@Environment` injection is testable — you can inject mock services in previews and tests.

**Example:**
```swift
// Service
@Observable @MainActor
final class PomodoroService {
    var secondsRemaining: Int = 0
    func start() { ... }
}

// Injection at App level
.environment(pomodoroService)

// Consumption in view
@Environment(PomodoroService.self) private var pomodoro
```

### Pattern 3: Enum State Machine for Timer States

**What:** Model timer phases as an enum, transition via explicit methods.

**Why:** Prevents invalid states (e.g., "paused while idle"). Makes the state transitions explicit and testable. Stretchly uses string-based `reference` properties on its scheduler — an enum is the Swift equivalent with compiler safety.

```swift
enum PomodoroState {
    case idle
    case working
    case shortBreak
    case longBreak

    var isActive: Bool {
        self != .idle
    }

    var displayName: String {
        switch self {
        case .idle: "Ready"
        case .working: "Focus"
        case .shortBreak: "Short Break"
        case .longBreak: "Long Break"
        }
    }
}
```

### Pattern 4: Notification Content Composition

**What:** Build notification content from parameters, not by reading other services.

**Why:** Keeps NotificationService decoupled. It doesn't need to know about PomodoroService or HydrationService — it just receives text/data and formats a `UNNotificationContent`.

```swift
func sendCombinedBreakNotification(
    sessionNumber: Int,
    totalSessions: Int,
    includeEyeStrain: Bool,
    includeHydration: Bool,
    glassesLogged: Int,
    dailyGoal: Int
) {
    var body = "Session \(sessionNumber)/\(totalSessions) complete."
    if includeEyeStrain {
        body += "\nLook at something 20ft away for 20 seconds."
    }
    if includeHydration {
        body += "\nStay hydrated — \(glassesLogged)/\(dailyGoal) glasses today."
    }
    // schedule UNNotificationRequest with this content
}
```

---

## Anti-Patterns to Avoid

### Anti-Pattern 1: Singleton Services

**What:** `static let shared = PomodoroService()` accessed globally.

**Why bad:** Untestable (can't inject mocks), invisible dependencies, initialization order issues. SwiftUI's `@Environment` exists specifically to replace this pattern.

**Instead:** Create services as `@State` on the `App` struct, inject via `.environment()`.

### Anti-Pattern 2: Timer Logic in Views

**What:** Putting `Timer.publish()` and state transitions directly in SwiftUI view bodies.

**Why bad:** Views redraw frequently and unpredictably. Timer setup in `onAppear`/`onDisappear` is fragile — the popover appears/disappears as the user clicks the menu bar icon, which would start/stop the timer. Stretchly's architecture keeps ALL timer logic in `BreaksPlanner`, not in the tray menu renderer.

**Instead:** Services own timers. Views only read state and call methods.

### Anti-Pattern 3: Shared Timer for Pomodoro + Hydration

**What:** One timer engine that manages both Pomodoro and hydration countdowns.

**Why bad:** Creates coupling. Pausing Pomodoro shouldn't affect hydration reminders. Stretchly's complexity comes partly from coupling mini-breaks and long-breaks through a shared `BreaksPlanner`. Two independent timers are simpler.

**Instead:** Each service has its own timer. They're independent by default, coordinated only at the notification layer (combined break notification).

### Anti-Pattern 4: Combine for Reactive Plumbing

**What:** Using `PassthroughSubject`, `@Published`, `sink`, `combineLatest` for inter-service communication.

**Why bad:** Combine is in maintenance mode at Apple. `@Observable` + direct method calls replaces its use cases for new code. Adding Combine creates two reactive systems that don't compose well.

**Instead:** Direct method calls between services. `@Observable` handles the reactivity to views automatically.

### Anti-Pattern 5: Over-Abstracting the Timer

**What:** Creating a `TimerProtocol`, `TimerFactory`, generic `CountdownTimer<State>` — abstracting for hypothetical future timer types.

**Why bad:** There are exactly two timer domains and they're known upfront. Abstractions for two consumers add indirection without value. YAGNI.

**Instead:** Each service has a `Timer?` property and a `tick()` method. Duplicate 5 lines of timer setup rather than build an abstraction.

---

## Scalability Considerations

| Concern | PomoHydro v1 (1 user, 1 Mac) | If Growing to v2+ |
|---------|-------------------------------|---------------------|
| **State persistence** | `UserDefaults` — perfect for ~12 keys | If adding history/stats: migrate to SwiftData or JSON file. Don't add SwiftData premptively. |
| **Timer accuracy** | Foundation `Timer` + Date-based — accurate to ~100ms | Sufficient. Only visible countdown needs 1s resolution. |
| **Service count** | 3 services — easy to hold in head | If adding Focus mode, Siri, Widgets: each gets its own service. Same @Environment pattern scales. |
| **View count** | ~5 views — one file each | If settings grow complex: split SettingsView into tab-specific files. |
| **Testing** | Swift Testing on services (pure logic, no UI dependency) | If adding UI tests: XCUITest for the popover. Unlikely needed for personal tool. |

---

## Build Order (Dependency-Driven)

The architecture has clear dependency chains that dictate what must be built first:

### Phase 1: Shell + Foundation
**Build:** `PomoHydroApp.swift`, `MenuBarLabel.swift`, `MenuBarView.swift` (empty), `Info.plist`
**Result:** App appears in menu bar, popover opens on click, no Dock icon
**Why first:** Every other component lives inside this shell. Can't test anything without it.

### Phase 2: Notification Infrastructure
**Build:** `NotificationService.swift`
**Result:** Permission request on first launch, can send test notification
**Why second:** Both timer services depend on this. Build and test it in isolation before adding consumers.

### Phase 3: Pomodoro Timer
**Build:** `PomodoroService.swift`, `PomodoroState.swift`, `PomodoroSection.swift`
**Result:** Start/stop/pause timer, work→break transitions, session counting, break notifications
**Why third:** Core feature, most complex state machine. Eye-strain is a sub-feature added to this.
**Depends on:** Phase 1 (shell to display in), Phase 2 (notifications for break alerts)

### Phase 4: Eye-Strain Integration
**Build:** Add eye-strain sub-timer to `PomodoroService`, update `NotificationService` with combined messages
**Result:** 20-20-20 reminders during work blocks, folded into break notifications
**Why fourth:** Piggybacks on Pomodoro — needs working Pomodoro timer and notification service.
**Depends on:** Phase 3 (Pomodoro must be working)

### Phase 5: Hydration Tracker
**Build:** `HydrationService.swift`, `HydrationSection.swift`
**Result:** Water reminders, log glasses, daily count, combined break notifications
**Why fifth:** Fully independent of Pomodoro. Can be built and tested in isolation.
**Depends on:** Phase 1 (shell), Phase 2 (notifications). Does NOT depend on Phases 3-4.

### Phase 6: Settings
**Build:** `SettingsView.swift` with tab sections for Pomodoro, Hydration, General
**Result:** All configurable values editable in standard macOS preferences window
**Why last:** Needs all services to exist (configures all of them). Settings without features to configure are useless.
**Depends on:** Phases 3-5 (all services must exist)

### Phase 7: Polish
**Build:** Daily reset logic, menu bar countdown text, final UI polish
**Result:** Complete v1
**Depends on:** Everything above

```
Phase 1 (Shell) ──► Phase 2 (Notifications) ──┬──► Phase 3 (Pomodoro) ──► Phase 4 (Eye-Strain)
                                               │
                                               └──► Phase 5 (Hydration)
                                                          │
        Phase 3 + Phase 5 ──► Phase 6 (Settings) ──► Phase 7 (Polish)
```

**Note:** Phases 3-4 and Phase 5 are independent branches — they could be built in parallel or in either order. The recommended order (Pomodoro first) is because it's the most complex component and the primary feature.

---

## Sources

- **Apple SwiftUI Documentation (Context7):** `MenuBarExtra` scene API, `.menuBarExtraStyle(.window)`, `Settings` scene, `@Observable` macro patterns — all verified current as of macOS 13+/Swift 5.9+. HIGH confidence.
- **SwiftUI Expert Skill (Context7):** `@Observable` + `@Environment` state management patterns, service-layer architecture with `@State` on App struct. HIGH confidence.
- **Stretchly (GitHub, 6.1k★):** `BreaksPlanner` architecture with `Scheduler`, `NaturalBreaksManager`, `DndManager`, `AppExclusionsManager` — real-world timer/break app architecture patterns. Used for structural insights, not code. HIGH confidence.
- **Apple Developer Documentation:** `UNUserNotificationCenter`, `LSUIElement`, `SMAppService` for launch-at-login. HIGH confidence.
