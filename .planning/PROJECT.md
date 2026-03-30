# PomoHydro

## What This Is

A native macOS menu bar health companion that bundles Pomodoro focus sessions, 20-20-20 eye-strain reminders, and a hydration tracker into one lightweight app. Lives in the menu bar, notifies via native macOS alerts, and uses a custom clock+waterdrop icon as its brand mark.

## Core Value

Keep you healthy and focused during long work sessions — without getting in the way.

## Requirements

### Validated

- ✓ macOS native app (SwiftUI) — v1.0
- ✓ Native macOS notifications for all reminders — v1.0
- ✓ Pomodoro timer with configurable work/break durations — v1.0
- ✓ 20-20-20 eye-strain reminders at 20-minute intervals during work blocks — v1.0
- ✓ Combined break notification ("Rest. Look away. Drink water.") — v1.0
- ✓ Menu bar icon with dropdown showing active timer countdown and water count — v1.0
- ✓ Hydration reminders at configurable intervals (default 45 min) — v1.0
- ✓ Log glasses of water with a single action (S/M/L sizes) — v1.0
- ✓ Track daily water count (glasses + derived mL) — v1.0
- ✓ Settings window with tabs (Pomodoro, Hydration, General) — v1.0
- ✓ Global pause/resume all reminders from dropdown — v1.0
- ✓ Mid-session timer recalculation when settings change — v1.0

### Active

(None — next milestone requirements TBD)

### Out of Scope

- Statistics/history across days — keep it simple for v1
- iOS companion app — macOS only
- Cloud sync — local only
- Custom sounds — use system defaults
- Social features / sharing

## Context

Shipped v1.0 with 1,836 LOC Swift across 14 files.
Tech stack: SwiftUI, AppKit (MenuBarExtra), UNUserNotificationCenter, @AppStorage/UserDefaults.
All built in a single day using GSD workflow (4 phases, 9 plans).
Post-v1.0 backlog items captured: hydration log-by-day, cloud collector, Slack integration, custom icon.

## Constraints

- **Platform**: macOS only — SwiftUI + AppKit for menu bar integration
- **Distribution**: Local build initially, no App Store
- **Permissions**: Needs notification permission from macOS

## Key Decisions

| Decision                                  | Rationale                                                          | Outcome      |
| ----------------------------------------- | ------------------------------------------------------------------ | ------------ |
| Menu bar app (no dock icon)               | Minimal footprint, always accessible, non-intrusive                | ✓ Good       |
| Eye-strain folds into Pomodoro            | Avoids notification fatigue, natural pairing                       | ✓ Good       |
| Fixed hydration interval (45 min default) | Simple, adjustable, no complex adaptive logic                      | ✓ Good       |
| SwiftUI + native macOS                    | Best menu bar integration, native notifications, no Electron bloat | ✓ Good       |
| 250mL per glass assumption                | Standard glass size, simplifies tracking                           | ✓ Good       |
| Deadline-based timer (Date math)          | Accurate timing even with popover closed / App Nap                 | ✓ Good       |
| Service wiring via set*Service() + .task  | Avoids init-order issues with @Observable                          | ✓ Good       |
| Combined break notification (CROSS-01)    | Single "Rest. Look away. Drink." is the killer differentiator      | ✓ Good       |
| @AppStorage for all persistence           | Simple, survives crashes, no CoreData overhead                     | ✓ Good       |

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `/gsd-transition`):

1. Requirements invalidated? → Move to Out of Scope with reason
2. Requirements validated? → Move to Validated with phase reference
3. New requirements emerged? → Add to Active
4. Decisions to log? → Add to Key Decisions
5. "What This Is" still accurate? → Update if drifted

**After each milestone** (via `/gsd-complete-milestone`):

1. Full review of all sections
2. Core Value check — still the right priority?
3. Audit Out of Scope — reasons still valid?
4. Update Context with current state

---

_Last updated: 2026-03-30 after v1.0 milestone_
