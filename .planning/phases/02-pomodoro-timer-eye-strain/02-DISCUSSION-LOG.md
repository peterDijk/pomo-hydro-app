# Phase 2: Pomodoro Timer & Eye-Strain - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-03-30
**Phase:** 02-pomodoro-timer-eye-strain
**Areas discussed:** Timer UI layout, Eye-strain integration UX, Menu bar icon states, Auto-start & session transitions

---

## Timer UI Layout

### Q1: Countdown display style

| Option | Description | Selected |
|--------|-------------|----------|
| Circular ring | Large circular progress ring with time in center, session label above, controls below | ✓ |
| Big digits | Large monospace countdown text with thin linear progress bar underneath | |
| Compact card | Session label + countdown on one line, session count on another, compact layout | |

**User's choice:** Circular ring
**Notes:** Think macOS Timer app or Focus mode style.

### Q2: Information density around the ring

| Option | Description | Selected |
|--------|-------------|----------|
| Full context | Phase label above, ring + countdown center, session count below, start/pause/stop buttons at bottom | ✓ |
| Minimal | Just ring + countdown center with phase label, controls below, session count in footer | |
| Agent's discretion | Agent decides layout density | |

**User's choice:** Full context

### Q3: Idle/no-timer state

| Option | Description | Selected |
|--------|-------------|----------|
| Start-focused | Large "Start Focus" button taking the ring's place, with duration subtitle | ✓ |
| Empty ring | Circular ring at 100% with "Ready" in center, start button below | |
| Agent's discretion | Agent decides idle state | |

**User's choice:** Start-focused

---

## Eye-Strain Integration UX

### Q1: How the eye-strain reminder appears

| Option | Description | Selected |
|--------|-------------|----------|
| Notification only | Native macOS notification with dismiss action, no in-app UI change | ✓ |
| Notification + in-app overlay | Notification fires AND popover shows "Look away" overlay with 20s countdown | |
| Notification + ring pause | Notification fires, ring briefly shows "Look away" for 20s, timer keeps running | |

**User's choice:** Notification only

### Q2: Edge case — eye-strain near break boundary

| Option | Description | Selected |
|--------|-------------|----------|
| Send anyway | Fire reminder at 20 min regardless of break proximity | |
| Skip if break within 3 min | Suppress notification, fold "look away" into break notification | ✓ |
| Agent's discretion | Agent picks threshold | |

**User's choice:** Skip if break within 3 minutes

---

## Menu Bar Icon States

### Q1: Icon differentiation approach

| Option | Description | Selected |
|--------|-------------|----------|
| Different symbols | timer (idle), timer.circle.fill (working), cup.and.saucer (break) | ✓ |
| Same symbol, color tint | Always timer, tinted gray/green/orange | |
| Symbol + badge style | timer base with green dot (working) or pause.circle (break) | |
| Agent's discretion | Agent picks appropriate symbols | |

**User's choice:** Different symbols

---

## Auto-Start & Session Transitions

### Q1: Auto-start transition behavior

| Option | Description | Selected |
|--------|-------------|----------|
| Immediate transition | Work ends → break starts immediately, no delay | |
| Brief countdown | 5-second countdown in ring before next phase begins | ✓ |
| Agent's discretion | Agent decides | |

**User's choice:** Brief 5-second countdown

### Q2: Auto-start default

| Option | Description | Selected |
|--------|-------------|----------|
| Off by default | User manually starts each session/break, less surprising | |
| On by default | Seamless flow out of the box, easy to turn off | ✓ |

**User's choice:** On by default

---

## Agent's Discretion

- Ring color/style (stroke width, gradient, colors)
- Exact notification copy
- Internal timer architecture
- UserDefaults key naming
- Auto-start countdown animation style

## Deferred Ideas

None — discussion stayed within phase scope.
