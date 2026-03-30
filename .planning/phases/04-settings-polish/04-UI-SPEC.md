---
phase: 04
slug: settings-polish
status: approved
shadcn_initialized: false
preset: none
created: 2026-03-30
---

# Phase 4 — UI Design Contract

> Visual and interaction contract for Phase 4: Settings & Polish.
> Extends Phase 1 + 2 + 3 design system. All existing values carry forward unchanged.
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

No changes from Phase 1/2/3.

---

## Spacing Scale

Unchanged from prior phases. All tokens carry forward.

| Token | Value | Usage                                        |
| ----- | ----- | -------------------------------------------- |
| xs    | 4pt   | Inline label gaps                            |
| sm    | 8pt   | Compact element spacing                      |
| md    | 16pt  | Default content padding, popover edge insets |
| lg    | 24pt  | Section vertical spacing                     |
| xl    | 32pt  | Major section breaks                         |

New exceptions for settings window:

- Settings window content padding: 20pt (standard macOS settings inset)
- Slider row vertical spacing: 12pt (between stacked slider rows)
- Tab content inner padding: 16pt
- "Restore Defaults" button bottom margin: 16pt

---

## Typography

Extends Phase 3. New elements map to existing or standard macOS settings roles.

| Role                | SwiftUI Modifier        | Weight      | Usage                                         |
| ------------------- | ----------------------- | ----------- | --------------------------------------------- |
| Tab label           | `.font(.body)`          | `.regular`  | "Pomodoro" / "Hydration" / "General" tab text |
| Setting label       | `.font(.body)`          | `.regular`  | "Work Duration", "Short Break", etc.          |
| Setting value       | `.font(.body)`          | `.semibold` | "25 min" value display next to slider         |
| Setting description | `.font(.caption)`       | `.regular`  | Optional hint text below a setting            |
| Section header      | `.font(.headline)`      | `.semibold` | Section divider within a tab (if needed)      |
| Button label        | `.font(.body)`          | `.regular`  | "Restore Defaults" button text                |
| Pause label         | `.font(.callout)`       | `.regular`  | "Pause All" toggle label in popover footer    |

---

## Color

No new semantic colors. Settings window follows macOS system appearance automatically.

| Role                | SwiftUI Color              | Usage                                    |
| ------------------- | -------------------------- | ---------------------------------------- |
| Dominant background | System default (automatic) | Settings window background               |
| Primary text        | `.primary`                 | Setting labels, values                   |
| Secondary text      | `.secondary`               | Description hints, tab icons             |
| Accent controls     | `.accentColor` (system)    | Sliders, toggles, selected tab indicator |
| Pause icon          | `.orange`                  | Pause.circle menu bar icon when paused   |

**Why `.orange` for paused state:** Distinct from all existing states (blue=work, green=break, default=idle). Orange conveys "caution/paused" universally. High visibility in both light and dark mode.

Accent reserved for: Same as prior phases — interactive controls only (sliders, toggles, buttons).

---

## Copywriting Contract

### Settings Window

| Element                               | Copy                                                |
| ------------------------------------- | --------------------------------------------------- |
| **Window title**                      | "PomoHydro Settings"                                |
| **Pomodoro tab label**                | "Pomodoro" with SF Symbol `timer`                   |
| **Hydration tab label**               | "Hydration" with SF Symbol `drop.fill`              |
| **General tab label**                 | "General" with SF Symbol `gearshape`                |

### Pomodoro Tab Settings

| Element                               | Copy                                                |
| ------------------------------------- | --------------------------------------------------- |
| **Work duration label**               | "Work Duration"                                     |
| **Work duration value format**        | "{N} min" (e.g., "25 min")                          |
| **Work duration range**               | 5–60 min                                            |
| **Short break label**                 | "Short Break"                                       |
| **Short break value format**          | "{N} min" (e.g., "5 min")                           |
| **Short break range**                 | 1–15 min                                            |
| **Long break label**                  | "Long Break"                                        |
| **Long break value format**           | "{N} min" (e.g., "15 min")                          |
| **Long break range**                  | 5–30 min                                            |
| **Sessions before long break label**  | "Sessions Before Long Break"                        |
| **Sessions value format**             | "{N}" (e.g., "4")                                   |
| **Sessions range**                    | 2–8                                                 |
| **Auto-start break toggle**          | "Auto-Start Break"                                  |
| **Auto-start work toggle**           | "Auto-Start Next Session"                           |
| **Restore defaults button**           | "Restore Defaults"                                  |

### Hydration Tab Settings

| Element                               | Copy                                                |
| ------------------------------------- | --------------------------------------------------- |
| **Reminder interval label**           | "Reminder Interval"                                 |
| **Reminder interval value format**    | "{N} min" (e.g., "45 min")                          |
| **Reminder interval range**           | 15–120 min                                          |
| **Daily goal label**                  | "Daily Goal"                                        |
| **Daily goal value format**           | "{N} glasses" (e.g., "8 glasses")                   |
| **Daily goal range**                  | 1–20 glasses                                        |
| **Restore defaults button**           | "Restore Defaults"                                  |

### General Tab

| Element                               | Copy                                                |
| ------------------------------------- | --------------------------------------------------- |
| **Pause toggle label**                | "Pause All Reminders"                               |
| **Pause description**                 | "Stops all timers and suppresses notifications"     |
| **Restore defaults button**           | "Restore Defaults"                                  |

### Popover Footer (Updated)

| Element                               | Copy                                                |
| ------------------------------------- | --------------------------------------------------- |
| **Pause toggle (popover)**            | Toggle with SF Symbol `pause.circle` / `play.circle`|
| **Settings button**                   | "Settings…" with SF Symbol `gear` (unchanged)       |
| **Quit button**                       | "Quit PomoHydro" (unchanged)                        |

Tone: Consistent with prior phases — clean, minimal, descriptive. Setting labels use standard macOS conventions (title case, no colons).

---

## Layout Specification

### Settings Window (450 × 350pt default)

Per D-01: Custom `Window` scene, not `Settings` scene. Opened via gear button.
Per D-03: TabView with 3 tabs.

```
┌──────────────────────── 450pt ────────────────────────┐
│  ┌─ 🕐 Pomodoro ─┐ ┌─ 💧 Hydration ─┐ ┌─ ⚙ General ─┐  │  ← TabView
│  └────────────────┘ └────────────────┘ └──────────────┘  │
│                                                           │
│   ┌─────────────────────────────────────────────────┐    │
│   │                                                   │    │
│   │  [Tab content area — see detail below]           │    │
│   │                                                   │    │
│   │                                                   │    │
│   │                                                   │    │
│   │                               Restore Defaults   │    │
│   └─────────────────────────────────────────────────┘    │
│                                                           │
└───────────────────────────────────────────────────────────┘
```

### Pomodoro Tab Detail

```
┌─────────────────── Pomodoro Tab ──────────────────────┐
│  padding: 20pt                                         │
│                                                        │
│  Work Duration                              25 min     │
│  ═══════════════════════●══════════════                │  ← Slider 5–60
│                                            12pt gap    │
│  Short Break                                 5 min     │
│  ═══════●══════════════════════════════                │  ← Slider 1–15
│                                            12pt gap    │
│  Long Break                                 15 min     │
│  ═══════════════●══════════════════════                │  ← Slider 5–30
│                                            12pt gap    │
│  Sessions Before Long Break                    4       │
│  ══════════════●═══════════════════════                │  ← Slider 2–8
│                                            16pt gap    │
│  Auto-Start Break                          [Toggle]    │
│  Auto-Start Next Session                   [Toggle]    │
│                                                        │
│                              ┌──────────────────────┐  │
│                              │  Restore Defaults     │  │
│                              └──────────────────────┘  │
└────────────────────────────────────────────────────────┘
```

Each slider row layout:
```
┌──────────────────── Slider Row ──────────────────────┐
│  HStack {                                             │
│    Text("Work Duration")     Spacer()  Text("25 min") │
│  }                                                    │
│  Slider(value: $workDuration, in: 5...60, step: 1)    │
└───────────────────────────────────────────────────────┘
```

### Hydration Tab Detail

```
┌─────────────────── Hydration Tab ─────────────────────┐
│  padding: 20pt                                         │
│                                                        │
│  Reminder Interval                          45 min     │
│  ═══════════════════●══════════════════════            │  ← Slider 15–120
│                                            12pt gap    │
│  Daily Goal                              8 glasses     │
│  ═══════════════●══════════════════════════            │  ← Slider 1–20
│                                                        │
│                              ┌──────────────────────┐  │
│                              │  Restore Defaults     │  │
│                              └──────────────────────┘  │
└────────────────────────────────────────────────────────┘
```

### General Tab Detail

```
┌──────────────────── General Tab ──────────────────────┐
│  padding: 20pt                                         │
│                                                        │
│  Pause All Reminders                       [Toggle]    │
│  Stops all timers and suppresses            .caption   │
│  notifications                             .secondary  │
│                                                        │
│                              ┌──────────────────────┐  │
│                              │  Restore Defaults     │  │
│                              └──────────────────────┘  │
└────────────────────────────────────────────────────────┘
```

### Updated Popover Footer

Per D-07: Pause toggle added next to gear button.

```
┌──────────── Updated Footer (16pt h-pad, 8pt v-pad) ──────────────┐
│                                                                    │
│  [⏸/▶]  ⚙ Settings…                        Quit PomoHydro       │
│                                                                    │
└────────────────────────────────────────────────────────────────────┘
```

- Pause toggle: Small icon button (SF Symbol `pause.circle` when unpaused, `play.circle` when paused)
- Gear button: unchanged from current scaffolding
- Quit button: unchanged

### Menu Bar Icon States (Updated)

Per D-09: New paused state overrides all other icons.

| App State    | SF Symbol          | Color    |
| ------------ | ------------------ | -------- |
| Idle         | `timer`            | default  |
| Working      | `timer.circle.fill`| default  |
| On break     | `cup.and.saucer`   | default  |
| **Paused**   | `pause.circle`     | default  |

Paused state takes highest priority — if paused while working, show `pause.circle` not `timer.circle.fill`.

---

## Interaction Specification

### Settings Window Lifecycle

1. User clicks gear button in popover → `openWindow(id: "settings")` fires
2. If window already open → brought to front (SwiftUI Window scene default)
3. Window has standard macOS close button (red traffic light)
4. Closing window saves nothing explicitly — @AppStorage writes instantly on every change

### Slider Interaction

- Continuous slider (not discrete steps visually, but snaps to integer values)
- Value label updates in real-time as user drags
- Per D-10: Changes take effect immediately — if Pomodoro timer is running and user changes work duration, the timer end time recalculates

### Pause Toggle Interaction

- Toggle in popover footer: compact icon button, not a full Toggle control
- Toggle in General tab: standard SwiftUI `Toggle` with label
- Both reflect same `@AppStorage("allPaused")` value
- When toggled ON:
  - All running timers stop immediately
  - Menu bar icon changes to `pause.circle`
  - No notifications fire while paused
- When toggled OFF:
  - Pomodoro returns to idle state (does not resume mid-timer)
  - Hydration reminders restart from fresh interval
  - Menu bar icon returns to normal state

### Restore Defaults

- Per D-06: Each tab has its own "Restore Defaults" button
- Only resets that tab's values, not all settings
- No confirmation dialog — immediate reset (values are trivially re-adjustable)
- Pomodoro defaults: work=25, shortBreak=5, longBreak=15, sessions=4, autoStartBreak=true, autoStartWork=true
- Hydration defaults: reminderInterval=45, dailyWaterGoal=8
- General defaults: allPaused=false

---

## Registry Safety

| Registry        | Blocks Used | Safety Gate  |
| --------------- | ----------- | ------------ |
| SF Symbols      | System      | not required |
| No third-party  | —           | —            |

---

## Checker Sign-Off

- [x] Dimension 1 Copywriting: PASS
- [x] Dimension 2 Visuals: PASS
- [x] Dimension 3 Color: PASS
- [x] Dimension 4 Typography: PASS
- [x] Dimension 5 Spacing: PASS
- [x] Dimension 6 Registry Safety: PASS

**Approval:** approved 2026-03-30
