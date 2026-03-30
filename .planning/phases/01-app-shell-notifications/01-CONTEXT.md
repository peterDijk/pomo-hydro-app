# Phase 1: App Shell & Notifications - Context

**Gathered:** 2026-03-30
**Status:** Ready for planning

<domain>
## Phase Boundary

Deliver the foundational macOS menu bar app: Xcode project with `MenuBarExtra`, no Dock icon, an empty popover scaffold, and notification permission infrastructure with denied-state fallback. This is the container everything else lives in.

</domain>

<decisions>
## Implementation Decisions

### Menu Bar Icon & Popover

- **D-01:** Use `timer` SF Symbol for the menu bar icon (idle/base state). Phase 2 will add state-specific icon changes (working, break).
- **D-02:** Medium popover size (~320x400pt) using `MenuBarExtra` with `.menuBarExtraStyle(.window)`.

### Notification Permission UX

- **D-03:** Show a brief in-app explanation ("PomoHydro needs notifications to remind you to rest and stay hydrated") before triggering the macOS system permission prompt. Not on raw first launch — explain first.
- **D-04:** If permission is denied, show a subtle in-app banner at the top of the popover with an "Enable in System Settings" link. Persistent but non-blocking — the app still works, timers still count in UI.

### Project Structure

- **D-05:** Flat-with-folders layout: `PomoHydroApp.swift` at root, plus `Services/`, `Views/`, `Models/` folders. ~10 files for v1.
- **D-06:** Swift 6 strict concurrency checking enabled from day one. Do not defer — retrofitting is painful (research pitfall #12).

### App Identity

- **D-07:** App display name: "PomoHydro"
- **D-08:** Bundle identifier: `com.petervandijk.PomoHydro`
- **D-09:** Deployment target: macOS 14.0 (Sonoma) — required for `@Observable`.
- **D-10:** `LSUIElement = true` in Info.plist — no Dock icon, no Cmd+Tab entry.

### Agent's Discretion

- Xcode project setup specifics (build settings, scheme configuration)
- Exact popover layout scaffold (placeholder content is fine for phase 1)
- NotificationService internal implementation patterns

</decisions>

<canonical_refs>

## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Research

- `.planning/research/STACK.md` — Recommended stack, MenuBarExtra setup, @Observable patterns
- `.planning/research/ARCHITECTURE.md` — Service-layer pattern, component boundaries
- `.planning/research/PITFALLS.md` — Critical pitfalls: App Nap (#1), notification permission denial (#3), auto-termination (#4), Swift 6 concurrency (#12)
- `.planning/research/SUMMARY.md` — Synthesized findings and phase ordering rationale

### Project

- `.planning/PROJECT.md` — Project vision, constraints, key decisions
- `.planning/REQUIREMENTS.md` — Phase 1 requirements: UX-01, UX-05, CROSS-03

</canonical_refs>

<code_context>

## Existing Code Insights

### Reusable Assets

No existing code — greenfield project.

### Established Patterns

None yet. Phase 1 establishes the foundational patterns:

- SwiftUI `MenuBarExtra` with `.window` style
- `@Observable` service classes injected via `.environment()`
- `@AppStorage` for UserDefaults persistence

### Integration Points

- `PomoHydroApp.swift` will be the entry point. Phase 2+ adds services and views that plug into this shell.
- `NotificationService` created here will be consumed by Pomodoro (phase 2) and Hydration (phase 3).

</code_context>

<specifics>
## Specific Ideas

- Explanation-before-permission pattern: show a brief human-readable reason before the system dialog appears. Not a full onboarding flow — just a sentence of context.
- Denied banner should feel informational, not alarming. Subtle, persistent, with a direct link to the relevant System Settings pane.

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.

</deferred>

---

_Phase: 01-app-shell-notifications_
_Context gathered: 2026-03-30_
