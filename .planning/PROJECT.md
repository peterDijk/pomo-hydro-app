# PomoHydro

## What This Is

A native macOS menu bar app that bundles three health-focused timers into one lightweight companion: Pomodoro focus sessions with integrated 20-20-20 eye-strain reminders, and a hydration tracker that nudges you to drink water and counts your daily intake. Lives in the menu bar, notifies via native macOS notifications.

## Core Value

Keep you healthy and focused during long work sessions — without getting in the way.

## Requirements

### Validated

- [x] macOS native app (SwiftUI) — Validated in Phase 1: App Shell & Notifications
- [x] Native macOS notifications for all reminders — Validated in Phase 1: App Shell & Notifications
- [x] Pomodoro timer with configurable work/break durations — Validated in Phase 2: Pomodoro Timer & Eye-Strain
- [x] 20-20-20 eye-strain reminders at 20-minute intervals during Pomodoro work blocks — Validated in Phase 2: Pomodoro Timer & Eye-Strain
- [x] Combined break notification that mentions both rest and eye strain — Validated in Phase 2: Pomodoro Timer & Eye-Strain
- [x] Menu bar icon with dropdown showing active timer countdown and water count — Validated in Phase 3: Hydration Tracker & Combined Notifications
- [x] Hydration reminders at configurable intervals (default 45 min) — Validated in Phase 3: Hydration Tracker & Combined Notifications
- [x] Log glasses of water with a single action — Validated in Phase 3: Hydration Tracker & Combined Notifications
- [x] Track daily water count (glasses + derived mL) — Validated in Phase 3: Hydration Tracker & Combined Notifications

### Active

- [ ] Config button in dropdown that opens a settings modal

### Out of Scope

- Statistics/history across days — keep it simple for v1
- iOS companion app — macOS only
- Cloud sync — local only
- Custom sounds — use system defaults
- Social features / sharing

## Context

- Personal side project — just for the developer's own use initially
- macOS-only, targeting current macOS versions
- Menu bar app pattern — no dock icon, lives in the system tray
- Three features share the screen real estate: the timers are coordinated so eye-strain reminders fold into the Pomodoro cycle naturally
- Hydration runs on its own independent timer
- Glass size assumed at ~250mL for deriving total mL from glass count

## Constraints

- **Platform**: macOS only — SwiftUI + AppKit for menu bar integration
- **Distribution**: Local build initially, no App Store
- **Permissions**: Needs notification permission from macOS

## Key Decisions

| Decision                                  | Rationale                                                          | Outcome   |
| ----------------------------------------- | ------------------------------------------------------------------ | --------- |
| Menu bar app (no dock icon)               | Minimal footprint, always accessible, non-intrusive                | — Pending |
| Eye-strain folds into Pomodoro            | Avoids notification fatigue, natural pairing                       | — Pending |
| Fixed hydration interval (45 min default) | Simple, adjustable, no complex adaptive logic                      | — Pending |
| SwiftUI + native macOS                    | Best menu bar integration, native notifications, no Electron bloat | — Pending |
| 250mL per glass assumption                | Standard glass size, simplifies tracking                           | — Pending |

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

_Last updated: 2026-03-30 — Phase 3 (Hydration Tracker & Combined Notifications) complete. 3 of 4 phases done._
