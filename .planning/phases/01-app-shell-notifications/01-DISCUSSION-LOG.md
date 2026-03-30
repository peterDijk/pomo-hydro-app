# Phase 1: App Shell & Notifications - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-03-30
**Phase:** 1-App Shell & Notifications
**Areas discussed:** Menu bar icon & popover, Notification permission UX, Project structure, App identity

---

## Menu Bar Icon & Popover

### Q1: Which SF Symbol for the menu bar icon (base/idle state)?

| Option | Description | Selected |
|--------|-------------|----------|
| timer (SF Symbol) | Timer + water drop combined — unique to PomoHydro | ✓ |
| clock (SF Symbol) | Generic but universally recognizable as a timer app | |
| leaf.fill (SF Symbol) | Health/leaf metaphor — represents the wellness angle | |

**User's choice:** timer (SF Symbol)
**Notes:** None

### Q2: How large should the dropdown popover be?

| Option | Description | Selected |
|--------|-------------|----------|
| Small popover | Compact — ~280x320pt, fits naturally next to menu bar (Recommended) | |
| Medium popover | ~320x400pt, more breathing room for layout | ✓ |
| You decide | What makes sense for the content | |

**User's choice:** Medium popover
**Notes:** None

---

## Notification Permission UX

### Q3: When should the app request notification permission?

| Option | Description | Selected |
|--------|-------------|----------|
| Request on first launch | macOS system prompt appears as soon as app opens (Recommended) | |
| Explain then request | Show a brief explanation first then trigger the system prompt | ✓ |
| Request on first timer start | Wait until user starts their first timer | |

**User's choice:** Explain then request
**Notes:** None

### Q4: What should happen if the user denies notification permission?

| Option | Description | Selected |
|--------|-------------|----------|
| Subtle in-app banner | Small banner at top of popover with "Enable in Settings" link (Recommended) | ✓ |
| Warning-style banner | Yellow/orange banner that's more visually prominent | |
| No banner, just work without | App works silently without notifications | |

**User's choice:** Subtle in-app banner
**Notes:** None

---

## Project Structure

### Q5: How should Swift files be organized?

| Option | Description | Selected |
|--------|-------------|----------|
| Flat with folders | PomoHydroApp.swift + Services/ Views/ Models/ (Recommended) | ✓ |
| Feature-based grouping | Pomodoro/ Hydration/ Shared/ — grouped by domain | |
| You decide | Whatever makes sense for ~10 files | |

**User's choice:** Flat with folders
**Notes:** None

### Q6: Swift 6 strict concurrency checking from day one?

| Option | Description | Selected |
|--------|-------------|----------|
| Strict concurrency | Strict from day one — prevents concurrency issues (Recommended) | ✓ |
| Complete concurrency checking off | Start permissive, tighten later | |

**User's choice:** Strict concurrency
**Notes:** None

---

## App Identity

### Q7: App display name?

| Option | Description | Selected |
|--------|-------------|----------|
| PomoHydro | Matching the project name | ✓ |
| Different name | Something else | |

**User's choice:** PomoHydro
**Notes:** None

### Q8: Bundle identifier?

| Option | Description | Selected |
|--------|-------------|----------|
| com.petervandijk.PomoHydro | Standard reverse-domain for personal projects (Recommended) | ✓ |
| Custom bundle ID | Type your preferred bundle identifier | |

**User's choice:** com.petervandijk.PomoHydro
**Notes:** None

### Q9: Deployment target?

| Option | Description | Selected |
|--------|-------------|----------|
| macOS 14 (Sonoma) | Enables @Observable, covers 90%+ of Macs (Recommended) | ✓ |
| macOS 13 (Ventura) | Enables MenuBarExtra but loses @Observable | |

**User's choice:** macOS 14 (Sonoma)
**Notes:** None

---

## Agent's Discretion

- Xcode project setup specifics (build settings, scheme configuration)
- Exact popover layout scaffold (placeholder content)
- NotificationService internal implementation patterns

## Deferred Ideas

None — discussion stayed within phase scope.
