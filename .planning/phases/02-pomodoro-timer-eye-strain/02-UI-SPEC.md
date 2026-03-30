---
phase: 02
slug: pomodoro-timer-eye-strain
status: approved
shadcn_initialized: false
preset: none
created: 2026-03-30
---

# Phase 2 — UI Design Contract

> Visual and interaction contract for the Pomodoro Timer & Eye-Strain phase. Adapted for native macOS SwiftUI (no web tooling).

---

## Design System

| Property          | Value                                        |
| ----------------- | -------------------------------------------- |
| Tool              | SwiftUI native (no component library)        |
| Preset            | macOS system appearance                      |
| Component library | SwiftUI built-in controls                    |
| Icon library      | SF Symbols (system-provided)                 |
| Font              | System font (SF Pro via `.font()` modifiers) |

**Platform:** macOS menu bar popover (320pt wide, `.menuBarExtraStyle(.window)`)

---

## Spacing Scale

All spacing uses SwiftUI's point system. Values match Phase 1 established patterns.

| Token | Value | Usage                                                          |
| ----- | ----- | -------------------------------------------------------------- |
| xs    | 4pt   | Inline label gaps                                              |
| sm    | 8pt   | Compact element spacing (e.g., between session label and ring) |
| md    | 16pt  | Default horizontal padding (matches Phase 1: `.padding(16)`)   |
| lg    | 24pt  | Section vertical spacing                                       |
| xl    | 32pt  | Major section breaks                                           |

Exceptions: The circular ring itself uses frame-based sizing (not spacing tokens). Ring diameter: 160pt. Ring stroke width: 10pt.

---

## Typography

All roles use SwiftUI system font modifiers — no custom fonts.

| Role                 | SwiftUI Modifier                                             | Weight     | Usage                                                    |
| -------------------- | ------------------------------------------------------------ | ---------- | -------------------------------------------------------- |
| Phase label          | `.font(.caption)`                                            | `.regular` | "Work Session" / "Short Break" / "Long Break" above ring |
| Countdown            | `.font(.system(size: 40, weight: .light, design: .rounded))` | `.light`   | "24:15" in ring center                                   |
| Session count        | `.font(.footnote)`                                           | `.regular` | "Session 2 of 4" below ring                              |
| Button label         | `.font(.body)`                                               | `.regular` | "Start Focus" / "Pause" / "Stop"                         |
| Duration subtitle    | `.font(.caption)`                                            | `.regular` | "25 min work session" under idle CTA                     |
| Auto-start countdown | `.font(.system(size: 40, weight: .light, design: .rounded))` | `.light`   | "5" in ring center during transition                     |

---

## Color

Follows macOS system appearance (light/dark automatic). No hardcoded colors — use semantic SwiftUI colors.

| Role                    | SwiftUI Color                | Usage                                  |
| ----------------------- | ---------------------------- | -------------------------------------- |
| Dominant background     | System default (automatic)   | Popover background                     |
| Work ring stroke        | `.blue` (`Color.blue`)       | Circular ring during work sessions     |
| Short break ring stroke | `.green` (`Color.green`)     | Circular ring during short breaks      |
| Long break ring stroke  | `.green` (`Color.green`)     | Circular ring during long breaks       |
| Idle ring track         | `.secondary.opacity(0.2)`    | Empty ring background track            |
| Primary text            | `.primary`                   | Countdown, session count               |
| Secondary text          | `.secondary`                 | Phase label, duration subtitle, footer |
| Accent controls         | `.accentColor` (system blue) | Buttons                                |

Accent reserved for: "Start Focus" button (`.borderedProminent`), "Pause" button. NOT used for labels, icons, or decorative elements.

---

## Copywriting Contract

| Element                                     | Copy                                                       |
| ------------------------------------------- | ---------------------------------------------------------- |
| **Idle state CTA**                          | "Start Focus"                                              |
| **Idle duration subtitle**                  | "25 min work session" (dynamic: "{N} min work session")    |
| **Phase label — work**                      | "Work Session"                                             |
| **Phase label — short break**               | "Short Break"                                              |
| **Phase label — long break**                | "Long Break"                                               |
| **Session counter**                         | "Session {N} of {total}"                                   |
| **Work complete notification title**        | "Time for a Break!"                                        |
| **Work complete notification body**         | "Great focus! Rest your eyes and stretch."                 |
| **Work complete + eye-strain body**         | "Great focus! Look at something 20 feet away and stretch." |
| **Short break complete notification title** | "Break Over"                                               |
| **Short break complete notification body**  | "Ready for another focus session?"                         |
| **Long break complete notification title**  | "Long Break Over"                                          |
| **Long break complete notification body**   | "Feeling refreshed? Let's get back to it."                 |
| **Eye-strain reminder title**               | "Rest Your Eyes"                                           |
| **Eye-strain reminder body**                | "Look at something 20 feet away for 20 seconds."           |
| **Auto-start countdown**                    | "{N}" (just the number, in the ring center)                |
| **Pause button**                            | "Pause"                                                    |
| **Resume button**                           | "Resume"                                                   |
| **Stop button**                             | "Stop"                                                     |
| **Skip button**                             | "Skip" (during breaks only)                                |

Tone: Encouraging, not nagging. "Great focus!" not "STOP WORKING." Per user's specific direction.

---

## Layout Specification

### Popover Structure (320pt wide)

```
┌──────────────────────────────── 320pt ──────────────────────────────┐
│                                                                      │
│   Phase label (.caption, .secondary)          "Work Session"         │
│                                                             8pt gap  │
│                     ┌──────────────┐                                 │
│                     │              │                                  │
│                     │   Ring 160pt │   ← stroke: 10pt               │
│                     │   "24:15"    │   ← countdown centered         │
│                     │              │                                  │
│                     └──────────────┘                                 │
│                                                             8pt gap  │
│   Session count (.footnote)                "Session 2 of 4"         │
│                                                            24pt gap  │
│   ┌─────────┐  ┌─────────┐  ┌────────┐                              │
│   │  Pause  │  │  Stop   │  │  Skip  │   ← HStack, centered        │
│   └─────────┘  └─────────┘  └────────┘                              │
│                                                            16pt pad  │
│   ──────────── Divider ─────────────                                 │
│   Settings…                          Quit PomoHydro   ← 8pt v-pad  │
└──────────────────────────────────────────────────────────────────────┘
```

### Idle State (replaces ring area)

```
┌──────────────────────────────── 320pt ──────────────────────────────┐
│                                                                      │
│                                                                      │
│                     ┌─────────────────┐                              │
│                     │  Start Focus    │   ← .borderedProminent       │
│                     └─────────────────┘      .controlSize(.large)   │
│                     "25 min work session"  ← .caption, .secondary   │
│                                                                      │
│                                                                      │
│   ──────────── Divider ─────────────                                 │
│   Settings…                          Quit PomoHydro                 │
└──────────────────────────────────────────────────────────────────────┘
```

### Auto-Start Countdown State

```
┌──────────────────────────────── 320pt ──────────────────────────────┐
│                                                                      │
│   "Break starting in..."  (.caption, .secondary)                    │
│                                                             8pt gap  │
│                     ┌──────────────┐                                 │
│                     │              │                                  │
│                     │   Ring 160pt │   ← ring at 100%, green/blue   │
│                     │     "5"      │   ← countdown number           │
│                     │              │                                  │
│                     └──────────────┘                                 │
│                                                            24pt gap  │
│           ┌──────────────────┐                                       │
│           │  Start Now       │   ← skip countdown                   │
│           └──────────────────┘                                       │
│                                                                      │
│   ──────────── Divider ─────────────                                 │
│   Settings…                          Quit PomoHydro                 │
└──────────────────────────────────────────────────────────────────────┘
```

---

## Menu Bar Icon States (per D-05)

| State              | SF Symbol           | Description                             |
| ------------------ | ------------------- | --------------------------------------- |
| Idle               | `timer`             | Default timer icon, no fill             |
| Working            | `timer.circle.fill` | Filled circle timer — visually "active" |
| Break (short/long) | `cup.and.saucer`    | Rest/break metaphor                     |

Icon changes are driven by `PomodoroService.state` and applied via the `MenuBarExtra` label's `systemImage`.

---

## Circular Progress Ring Specification

| Property           | Value                                                     |
| ------------------ | --------------------------------------------------------- |
| Diameter           | 160pt                                                     |
| Stroke width       | 10pt                                                      |
| Stroke cap         | `.round` (rounded ends)                                   |
| Background track   | `.secondary.opacity(0.2)`, same stroke width              |
| Progress direction | Clockwise, starting from 12 o'clock (rotation: -90°)      |
| Animation          | `.linear` on trim change (smooth countdown, not stepping) |

Implementation: SwiftUI `Circle().trim(from: 0, to: progress).stroke(...)` with `.rotationEffect(.degrees(-90))` to start from top.

---

## Controls Specification

### Working State

- **Pause** — `.bordered` button style, centered
- **Stop** — `.bordered` button style, `.secondary` destructive feel

### Paused State

- **Resume** — `.borderedProminent`, replaces Pause
- **Stop** — same as working state

### Break State

- **Skip** — `.bordered`, allows skipping remainder of break

### Idle State

- **Start Focus** — `.borderedProminent`, `.controlSize(.large)`, centered

All buttons use system accent color. No custom button styles needed.

---

## Interaction Patterns

| Interaction            | Behavior                                                                        |
| ---------------------- | ------------------------------------------------------------------------------- |
| Start Focus tap        | Transition idle → working, ring animates from full to depleting                 |
| Pause tap              | Timer freezes, ring holds position, button swaps to Resume                      |
| Resume tap             | Timer resumes from stored endDate recalculation, ring continues                 |
| Stop tap               | Timer cancels, return to idle state, session NOT counted                        |
| Skip (break) tap       | Break ends immediately, start next work session (or idle if auto-start off)     |
| Work session completes | Notification fires, ring resets, state → break, 5s auto-start countdown if D-06 |
| Break completes        | Notification fires, ring resets, state → work (or idle if auto-start off)       |
| Auto-start countdown   | 5→4→3→2→1 in ring center, then auto-transition. "Start Now" skips.              |
| Popover close          | Timer continues in background (App Nap prevented). Ring updates on reopen.      |

---

## Accessibility

| Element          | Label                                                  | Trait                |
| ---------------- | ------------------------------------------------------ | -------------------- |
| Ring + countdown | "Timer: {minutes} minutes {seconds} seconds remaining" | `.updatesFrequently` |
| Start Focus      | "Start Focus, {N} minute work session"                 | button               |
| Pause            | "Pause timer"                                          | button               |
| Resume           | "Resume timer"                                         | button               |
| Stop             | "Stop timer"                                           | button               |
| Skip             | "Skip break"                                           | button               |
| Phase label      | Read automatically (above ring)                        | staticText           |
| Session count    | "Session {N} of {total}"                               | staticText           |

---

## Registry Safety

| Registry           | Blocks Used                                    | Safety Gate                |
| ------------------ | ---------------------------------------------- | -------------------------- |
| SF Symbols (Apple) | `timer`, `timer.circle.fill`, `cup.and.saucer` | not required (first-party) |
| SwiftUI built-in   | `Circle`, `Button`, `Text`, `VStack`, `HStack` | not required (first-party) |

No third-party UI dependencies.

---

## Checker Sign-Off

- [x] Dimension 1 Copywriting: PASS — All notification copy, button labels, and state labels specified with encouraging tone
- [x] Dimension 2 Visuals: PASS — Layout spec with exact dimensions, ring spec, icon states, interaction patterns
- [x] Dimension 3 Color: PASS — System semantic colors, no hardcoded values, light/dark automatic
- [x] Dimension 4 Typography: PASS — All text roles mapped to SwiftUI font modifiers
- [x] Dimension 5 Spacing: PASS — Consistent spacing tokens matching Phase 1 patterns
- [x] Dimension 6 Registry Safety: PASS — All first-party Apple components, zero third-party

**Approval:** approved 2026-03-30
