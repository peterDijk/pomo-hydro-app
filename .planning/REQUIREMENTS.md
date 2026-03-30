# Requirements — PomoHydro v1

## v1 Requirements

### Pomodoro Timer

- [ ] **POMO-01**: User can start, stop, and pause a Pomodoro work session from the menu bar dropdown
- [ ] **POMO-02**: User can configure work duration (default 25 min) and short/long break durations (default 5 min / 15 min)
- [ ] **POMO-03**: App automatically offers a long break after every N work sessions (default 4, configurable)
- [ ] **POMO-04**: User can see how many Pomodoro sessions they've completed today (daily counter, resets at midnight)
- [ ] **POMO-05**: User receives a native macOS notification when a work session or break ends
- [ ] **POMO-06**: User can toggle auto-start for the next session (auto-start work after break, auto-start break after work)

### Eye-Strain (20-20-20)

- [ ] **EYE-01**: User receives a "look at something 20 feet away for 20 seconds" nudge at 20-minute intervals during work blocks
- [ ] **EYE-02**: Eye-strain reminders fold into Pomodoro break notifications (no separate interruption)
- [ ] **EYE-03**: User can skip/dismiss an eye-strain reminder from the notification

### Hydration Tracker

- [ ] **HYDR-01**: User can log a glass of water with a single click in the menu bar dropdown
- [ ] **HYDR-02**: User can see their daily water count (glasses + derived mL at 250mL/glass) in the dropdown
- [ ] **HYDR-03**: User can configure the hydration reminder interval (default 45 min)
- [ ] **HYDR-04**: User receives a native macOS notification to drink water at the configured interval
- [ ] **HYDR-05**: User can set a daily water goal (default 8 glasses) and see progress toward it

### Menu Bar UX

- [ ] **UX-01**: App lives in the macOS menu bar with no Dock icon (LSUIElement)
- [ ] **UX-02**: Menu bar icon reflects live state (idle, working, on break)
- [ ] **UX-03**: Dropdown shows active timer countdown and current water count
- [ ] **UX-04**: User can pause all reminders temporarily from the dropdown
- [ ] **UX-05**: App respects macOS Do Not Disturb (handled automatically by UNUserNotificationCenter)

### Cross-Cutting

- [ ] **CROSS-01**: When a Pomodoro break starts, user receives a single combined notification: "Rest. Look away. Drink water." instead of separate alerts (the killer differentiator)
- [ ] **CROSS-02**: Session count and glass count auto-reset at midnight daily
- [ ] **CROSS-03**: User is prompted for notification permission on first launch; if denied, app shows in-app fallback explaining how to enable
- [ ] **CROSS-04**: App prevents App Nap from throttling timers when any timer is active (ProcessInfo.beginActivity)
- [ ] **CROSS-05**: All mutable state (timer end-times, glass count, session count) persists to UserDefaults on every mutation so state survives unexpected termination

### Settings

- [ ] **SET-01**: User can open a settings window from the dropdown via a config button
- [ ] **SET-02**: Settings window has tabs for Pomodoro, Hydration, and General configuration
- [ ] **SET-03**: All configurable values use @AppStorage with sensible defaults and take effect immediately

## v2 Requirements (Deferred)

- Launch at login via SMAppService
- Timer countdown text in menu bar (next to icon)
- Idle detection / auto-pause when user is away
- Global keyboard shortcut to log water
- Configurable glass size (mL per glass)
- Progress bar visualization in dropdown
- Custom notification sounds per timer type
- Break suggestions / tips during breaks

## Out of Scope

- Task management / labels — PomoHydro is a health companion, not a project manager
- App/website blocking — use macOS Focus mode or dedicated blockers
- Multiple beverage types — water only, keep it simple
- Gamification / achievements — clean and minimal, no badges
- Cloud sync — local UserDefaults only
- iOS / Apple Watch companion — macOS only
- Custom themes / colors — follow system appearance
- Ambient sounds / white noise — users have dedicated music apps
- Screen dimming / full-screen break overlays — native notifications only, non-modal
- Statistics / history across days — v1 tracks today only

## Traceability

*Populated by roadmapper — maps REQ-IDs to phases.*

| REQ-ID | Phase | Status |
|--------|-------|--------|
| — | — | — |

---
*Created: 2026-03-30*
