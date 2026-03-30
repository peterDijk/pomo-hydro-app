# Phase 4: Settings & Polish - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-03-30
**Phase:** 04-settings-polish
**Areas discussed:** Settings window approach, Tab layout & controls, Global pause behavior, Immediate-effect behavior

---

## Settings Window Approach

| Option           | Description                                                       | Selected |
| ---------------- | ----------------------------------------------------------------- | -------- |
| Settings scene   | Native macOS Preferences window — idiomatic, gets Cmd+, for free  |          |
| Custom Window    | openWindow environment action — more control over sizing/behavior | ✓        |
| In-popover sheet | Settings within the 320pt popover — compact but cramped           |          |

**User's choice:** Custom Window with openWindow
**Notes:** None

### Follow-up: Keyboard shortcut

| Option           | Description                          | Selected |
| ---------------- | ------------------------------------ | -------- |
| Wire Cmd+, too   | Users expect it for preferences      |          |
| Just gear button | Keep it simple, no keyboard shortcut | ✓        |

**User's choice:** Gear button only, no Cmd+, shortcut
**Notes:** None

---

## Tab Layout & Controls

### Control type for durations/counts

| Option       | Description                                          | Selected |
| ------------ | ---------------------------------------------------- | -------- |
| Steppers     | Compact, precise, standard macOS feel                |          |
| Sliders      | Visual range selection, discoverable                 | ✓        |
| Presets only | Predefined options, fastest but limits customization |          |

**User's choice:** Sliders with value labels
**Notes:** None

### Reset to defaults

| Option          | Description                                  | Selected |
| --------------- | -------------------------------------------- | -------- |
| One per tab     | Each tab has its own Restore Defaults button | ✓        |
| One global      | Single reset for all tabs                    |          |
| No reset button | Users adjust manually                        |          |

**User's choice:** One Restore Defaults button per tab
**Notes:** None

---

## Global Pause Behavior

### Toggle location

| Option                  | Description                                         | Selected |
| ----------------------- | --------------------------------------------------- | -------- |
| Popover footer only     | Quick access, always visible                        |          |
| Both popover + settings | Toggle in dropdown + matching toggle in General tab | ✓        |
| Settings tab only       | Keep popover clean                                  |          |

**User's choice:** Both popover footer and General settings tab
**Notes:** None

### What pauses

| Option                                  | Description                                   | Selected |
| --------------------------------------- | --------------------------------------------- | -------- |
| Notifications only                      | Timers keep running silently                  |          |
| Everything                              | Timers stop, notifications stop, fully quiet  | ✓        |
| Notifications + hydration, not Pomodoro | Pomodoro keeps counting, reminders suppressed |          |

**User's choice:** Everything stops — timers and notifications
**Notes:** None

### Visual indicator

| Option               | Description                        | Selected |
| -------------------- | ---------------------------------- | -------- |
| Change menu bar icon | pause.circle SF Symbol when paused | ✓        |
| In-popover banner    | Subtle banner inside the popover   |          |
| Both                 | Icon + banner                      |          |

**User's choice:** Menu bar icon changes to pause.circle
**Notes:** None

---

## Immediate-Effect Behavior

### Mid-session duration changes

| Option                       | Description                                | Selected |
| ---------------------------- | ------------------------------------------ | -------- |
| Apply next session           | Current session keeps original duration    |          |
| Apply immediately            | Recalculate end time based on new duration | ✓        |
| Disable editing while active | Grey out sliders when timer running        |          |

**User's choice:** Apply immediately — recalculate timer end time
**Notes:** None

---

## Agent's Discretion

- Window sizing and minimum dimensions
- Exact slider step increments
- Tab ordering
- Amount of explanatory text per setting
- General tab contents beyond pause toggle

## Deferred Ideas

None — discussion stayed within phase scope.
