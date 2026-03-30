---
phase: 03
slug: hydration-tracker-combined-notifications
status: approved
shadcn_initialized: false
preset: none
created: 2026-03-30
---

# Phase 3 — UI Design Contract

> Visual and interaction contract for Phase 3: Hydration Tracker & Combined Notifications.
> Extends Phase 1 + Phase 2 design system. All values carry forward unchanged.
> **Platform:** native macOS / SwiftUI — all values in Apple points (pt).

---

## Design System

| Property          | Value                                        |
| ----------------- | -------------------------------------------- |
| Tool              | SwiftUI native (no component library)        |
| Preset            | macOS system appearance                      |
| Component library | SwiftUI built-in controls                    |
| Icon library      | SF Symbols (system-provided)                 |
| Font              | System font (SF Pro via `.font()` modifiers) |

No changes from Phase 1/2.

---

## Spacing Scale

Unchanged from Phase 1/2. All tokens carry forward.

| Token | Value | Usage                                                          |
| ----- | ----- | -------------------------------------------------------------- |
| xs    | 4pt   | Inline label gaps                                              |
| sm    | 8pt   | Compact element spacing                                        |
| md    | 16pt  | Default content padding, popover edge insets                   |
| lg    | 24pt  | Section vertical spacing                                       |
| xl    | 32pt  | Major section breaks                                           |

New exceptions:
- Hydration section uses `VStack(spacing: 8)` internally (sm) matching PomodoroView pattern
- Divider between Pomodoro and Hydration sections has 0pt extra padding (Divider provides its own 8pt visual space)
- Progress bar height: 8pt
- Progress bar corner radius: 4pt

---

## Typography

Extends Phase 2. No new text styles — new elements map to existing roles.

| Role                     | SwiftUI Modifier                  | Weight     | Usage                                                |
| ------------------------ | --------------------------------- | ---------- | ---------------------------------------------------- |
| Section label            | `.font(.caption)`                 | `.regular` | "Hydration" section header                           |
| Glass count              | `.font(.title3)`                  | `.semibold` | "4 / 8" main count display                          |
| Unit label               | `.font(.footnote)`                | `.regular` | "glasses · 1,000 mL" below count                    |
| Progress label           | `.font(.caption)`                 | `.regular` | "50%" overlay or beside progress bar                 |
| Size option label        | `.font(.caption)`                 | `.regular` | "S" / "M" / "L" in segmented control                |
| Button label             | `.font(.body)`                    | `.regular` | "Log Glass" button text                              |

---

## Color

Extends Phase 2 semantic colors. One new role added for hydration.

| Role                    | SwiftUI Color                | Usage                                  |
| ----------------------- | ---------------------------- | -------------------------------------- |
| Dominant background     | System default (automatic)   | Popover background                     |
| Work ring stroke        | `.blue` (`Color.blue`)       | Unchanged from Phase 2                 |
| Break ring stroke       | `.green` (`Color.green`)     | Unchanged from Phase 2                 |
| **Hydration accent**    | `.cyan` (`Color.cyan`)       | Progress bar fill, "Log Glass" icon    |
| Hydration track         | `.secondary.opacity(0.2)`    | Empty progress bar background          |
| Primary text            | `.primary`                   | Glass count number                     |
| Secondary text          | `.secondary`                 | Section label, unit label, goal label  |
| Accent controls         | `.accentColor` (system blue) | Buttons remain system blue             |

**Why `.cyan`:** Visually distinct from Pomodoro blue (`.blue`) and break green (`.green`). Water association. High contrast in both light and dark mode. Does NOT conflict with accent color (system blue used for interactive controls).

Accent reserved for: Same as Phase 2 — buttons only. Cyan is decorative (progress bar fill), NOT used on interactive elements.

---

## Copywriting Contract

| Element                                        | Copy                                                                   |
| ---------------------------------------------- | ---------------------------------------------------------------------- |
| **Section label**                              | "Hydration"                                                            |
| **Glass count display**                        | "{N} / {goal}" (e.g., "4 / 8")                                        |
| **Unit label**                                 | "glasses · {N} mL" (e.g., "glasses · 1,000 mL")                       |
| **Log Glass button**                           | "Log Glass" with SF Symbol `drop.fill`                                 |
| **Size option: small**                         | "S" with subtitle "150 mL"                                             |
| **Size option: medium (default)**              | "M" with subtitle "250 mL"                                             |
| **Size option: large**                         | "L" with subtitle "500 mL"                                             |
| **Progress complete**                          | "Goal reached!" (replaces percentage when 100%)                        |
| **Hydration notification title**               | "Time to Hydrate"                                                      |
| **Hydration notification body**                | "Take a moment to drink some water."                                   |
| **Hydration notification action**              | "Log Glass" (UNNotificationAction title)                               |
| **Combined break + hydration notif title**     | "Break Time — Hydrate!"                                                |
| **Combined break + hydration notif body**      | "Rest your eyes, stretch, and drink some water."                       |
| **Combined + eye-strain notif body**           | "Look away for 20 seconds, stretch, and drink some water."             |
| **Midnight reset** (no UI — silent)            | N/A — count resets to 0 silently at midnight                           |

Tone: Same as Phase 2 — encouraging, not nagging. "Time to Hydrate" not "YOU HAVEN'T DRUNK WATER."

---

## Layout Specification

### Updated Popover Structure (320pt wide)

Per D-01: Stacked sections — Pomodoro on top, hydration below, both always visible. Popover grows taller.

```
┌──────────────────────────────── 320pt ──────────────────────────────┐
│                                                                      │
│   [PomodoroView — unchanged from Phase 2]                           │
│   Phase label, ring, countdown, session count, controls              │
│                                                                      │
│   ──────────── Divider ─────────────              ← section divider  │
│                                                                      │
│   "Hydration"                      (.caption, .secondary)  ← label  │
│                                                             8pt gap  │
│   ┌──────────────────────────────────────────────────────┐           │
│   │  4 / 8                (.title3, .semibold)           │           │
│   │  glasses · 1,000 mL  (.footnote, .secondary)        │           │
│   │                                                       │           │
│   │  ████████░░░░░░░░  50%  ← progress bar (8pt tall)   │           │
│   │                                                       │           │
│   │  ┌─────────────────────┐   ┌─S─┐ ┌─M─┐ ┌─L─┐       │           │
│   │  │ 💧 Log Glass        │   │   │ │   │ │   │       │           │
│   │  └─────────────────────┘   └───┘ └───┘ └───┘       │           │
│   └──────────────────────────────────────────────────────┘           │
│                                                            16pt pad  │
│   ──────────── Divider ─────────────              ← footer divider  │
│   ⚙️ Settings                    Quit PomoHydro   ← 8pt v-pad      │
└──────────────────────────────────────────────────────────────────────┘
```

### Hydration Section Detail

```
┌───────────────────────── Hydration Section ─────────────────────────┐
│  padding: 16pt horizontal                                            │
│                                                                      │
│  "Hydration"                              .caption, .secondary       │
│                                                          8pt gap     │
│  "4 / 8"                                  .title3, .semibold         │
│  "glasses · 1,000 mL"                     .footnote, .secondary     │
│                                                          8pt gap     │
│  ┌──────────────────────────────────────┐  8pt tall, full width     │
│  │████████████████░░░░░░░░░░░░░░░░░░░░│  .cyan fill / .secondary  │
│  └──────────────────────────────────────┘  track, 4pt cornerRadius  │
│                                                          12pt gap    │
│  ┌─────────────────┐  8pt gap  ┌─S──┐┌─M──┐┌─L──┐                  │
│  │ 💧 Log Glass    │           │150 ││250 ││500 │                  │
│  │ .borderedProm.  │           │ mL ││ mL ││ mL │                  │
│  └─────────────────┘           └────┘└────┘└────┘                  │
│                                                                      │
│  Button: .borderedProminent, .controlSize(.regular)                 │
│  Size picker: Picker with .segmented style                          │
└──────────────────────────────────────────────────────────────────────┘
```

### Layout Rules

- Log Glass button and size picker on same row, `HStack` with `Spacer()` between them
- Log Glass is leading (left), size picker is trailing (right)
- Size picker uses `Picker` with `.pickerStyle(.segmented)` — SwiftUI native
- Progress bar is a `GeometryReader` + `RoundedRectangle` (not `ProgressView` — need custom color)
- Glass count + unit label in a `VStack(alignment: .leading, spacing: 2)`

### Idle State (Pomodoro idle + Hydration)

When Pomodoro is idle, the PomodoroView shows just the "Start Focus" CTA. Hydration section still shows below:

```
┌──────────────────────────────── 320pt ──────────────────────────────┐
│                                                                      │
│              ┌─────────────────┐                                     │
│              │  Start Focus    │                                     │
│              └─────────────────┘                                     │
│              "25 min work session"                                   │
│                                                                      │
│   ──────────── Divider ─────────                                    │
│                                                                      │
│   "Hydration"                                                       │
│   4 / 8                                                             │
│   glasses · 1,000 mL                                                │
│   ████████░░░░░░░░  50%                                             │
│   [💧 Log Glass]     [S][M][L]                                      │
│                                                                      │
│   ──────────── Divider ─────────                                    │
│   Settings…           Quit PomoHydro                                │
└──────────────────────────────────────────────────────────────────────┘
```

---

## Progress Bar Specification

| Property           | Value                                              |
| ------------------ | -------------------------------------------------- |
| Height             | 8pt                                                |
| Corner radius      | 4pt (both track and fill)                          |
| Track color        | `.secondary.opacity(0.2)`                          |
| Fill color         | `.cyan`                                            |
| Fill width         | `geometry.size.width * (glassesConsumed / goal)`   |
| Animation          | `.easeInOut(duration: 0.3)` on fill width change   |
| Clip               | `.clipShape(RoundedRectangle(cornerRadius: 4))`    |

Implementation: `GeometryReader` wrapping two `RoundedRectangle` layers (track behind, fill in front). NOT `ProgressView` (cannot customize color reliably on macOS).

---

## Notification Specification

### Standalone Hydration Reminder

| Property           | Value                                               |
| ------------------ | --------------------------------------------------- |
| Identifier         | `"hydration-reminder"`                              |
| Category           | `"HYDRATION_REMINDER"`                              |
| Title              | "Time to Hydrate"                                   |
| Body               | "Take a moment to drink some water."                |
| Sound              | `.default`                                          |
| Action             | "Log Glass" (identifier: `"LOG_GLASS"`)             |
| Action option      | `.foreground`                                        |

### Combined Break + Hydration Notification

Sent when Pomodoro break starts AND hydration is due (within ±5 min merge window per D-06).

| Property           | Value                                                           |
| ------------------ | --------------------------------------------------------------- |
| Identifier         | `"break-combined"`                                              |
| Title              | "Break Time — Hydrate!"                                         |
| Body (no eye-strain) | "Rest your eyes, stretch, and drink some water."              |
| Body (with eye-strain) | "Look away for 20 seconds, stretch, and drink some water."  |
| Sound              | `.default`                                                       |
| Action             | "Log Glass" (identifier: `"LOG_GLASS"`)                         |
| Category           | `"HYDRATION_REMINDER"` (same category, same action)             |

### Notification Action Registration

Register on app launch (in NotificationService.init or a dedicated `registerCategories()` method):

```swift
let logGlassAction = UNNotificationAction(
    identifier: "LOG_GLASS",
    title: "Log Glass",
    options: .foreground
)
let hydrationCategory = UNNotificationCategory(
    identifier: "HYDRATION_REMINDER",
    actions: [logGlassAction],
    intentIdentifiers: [],
    options: []
)
UNUserNotificationCenter.current().setNotificationCategories([hydrationCategory])
```

### Notification Response Handling

NotificationService must conform to `UNUserNotificationCenterDelegate` and handle the `LOG_GLASS` action to increment the glass count via HydrationService.

---

## Interaction Patterns

| Interaction                     | Behavior                                                                     |
| ------------------------------- | ---------------------------------------------------------------------------- |
| Tap "Log Glass"                 | Increment glass count by selected size (default 250mL), animate progress bar |
| Tap size option (S/M/L)        | Change selected size for next Log Glass tap. Visual selection indicator.      |
| Progress bar reaches 100%      | "50%" text changes to "Goal reached!" in `.cyan` color                       |
| Hydration notification arrives  | Standard macOS notification with "Log Glass" action button                    |
| Tap "Log Glass" on notification | App foregrounds (if needed), glass logged at default 250mL size              |
| Midnight reset                  | Glass count silently resets to 0, progress bar empties                        |
| Pomodoro break starts (within merge window) | Combined notification sent instead of separate break + hydration |

---

## Accessibility

| Element                | Label                                                    | Trait                     |
| ---------------------- | -------------------------------------------------------- | ------------------------- |
| Glass count            | "{N} of {goal} glasses consumed, {mL} milliliters"      | `.updatesFrequently`      |
| Progress bar           | "Hydration progress: {percent} percent"                   | `.updatesFrequently`      |
| Log Glass button       | "Log glass of water, {size} milliliters"                 | button                    |
| Size picker            | "Glass size: Small 150 mL, Medium 250 mL, Large 500 mL" | picker                    |

---

## Registry Safety

| Registry         | Blocks Used | Safety Gate    |
| ---------------- | ----------- | -------------- |
| SwiftUI built-in | All native  | Not required   |
| SF Symbols       | `drop.fill` | Not required   |

---

## Checker Sign-Off

- [x] Dimension 1 Copywriting: PASS — All user-facing strings defined, tone consistent with Phase 2
- [x] Dimension 2 Visuals: PASS — Layout specified with exact spacing, progress bar spec complete
- [x] Dimension 3 Color: PASS — Semantic colors, `.cyan` distinct from existing palette, dark mode safe
- [x] Dimension 4 Typography: PASS — All elements mapped to existing font roles, no new styles
- [x] Dimension 5 Spacing: PASS — All gaps declared in 4pt multiples, matches Phase 1/2 scale
- [x] Dimension 6 Registry Safety: PASS — All native SwiftUI + SF Symbols, no third-party

**Approval:** approved 2026-03-30
