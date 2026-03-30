# Roadmap: PomoHydro

## Overview

PomoHydro delivers a native macOS menu bar health companion in four phases: first the app shell and notification plumbing, then the Pomodoro timer with integrated eye-strain reminders, then an independent hydration tracker that completes the combined "rest, look away, drink water" notification (the killer differentiator), and finally a settings UI with global pause control. Each phase delivers a verifiable, end-to-end capability.

## Phases

**Phase Numbering:**

- Integer phases (1, 2, 3): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

Decimal phases appear between their surrounding integers in numeric order.

- [ ] **Phase 1: App Shell & Notifications** - Xcode project, menu bar presence, notification permission handling
- [ ] **Phase 2: Pomodoro Timer & Eye-Strain** - Focus sessions with configurable durations, breaks, session counting, and 20-20-20 reminders
- [ ] **Phase 3: Hydration Tracker & Combined Notifications** - Water logging, daily goals, independent reminders, and the unified break notification
- [ ] **Phase 4: Settings & Polish** - Settings window with tabs, global pause, immediate-effect configuration

## Phase Details

### Phase 1: App Shell & Notifications

**Goal**: App lives in the macOS menu bar and can deliver native notifications
**Depends on**: Nothing (first phase)
**Requirements**: UX-01, UX-05, CROSS-03
**Success Criteria** (what must be TRUE):

1. App appears as an icon in the macOS menu bar with no Dock icon visible
2. Clicking the menu bar icon opens a popover dropdown (scaffolding is fine)
3. App requests notification permission on first launch and shows in-app guidance if permission is denied
4. A test notification can be delivered through the app's notification infrastructure
   **Plans:** 2 plans
   Plans:

- [x] 01-01-PLAN.md — Xcode project, MenuBarExtra shell, NotificationService
- [x] 01-02-PLAN.md — Permission flow views, denied banner, test notification
      **UI hint**: yes

### Phase 2: Pomodoro Timer & Eye-Strain

**Goal**: Users can run Pomodoro focus sessions with integrated 20-20-20 eye-strain reminders
**Depends on**: Phase 1
**Requirements**: POMO-01, POMO-02, POMO-03, POMO-04, POMO-05, POMO-06, EYE-01, EYE-02, EYE-03, UX-02, CROSS-04, CROSS-05
**Success Criteria** (what must be TRUE):

1. User can start, pause, and stop a Pomodoro session from the dropdown and see a live countdown
2. User receives a native notification when a work session or break ends, with eye-strain message folded into break notifications
3. App automatically offers a long break after 4 work sessions, and the daily session counter shows completed count
4. Menu bar icon visually changes between idle, working, and break states
5. Timer runs accurately with popover closed (App Nap prevented) and all mutable state survives app restart
   **Plans:** 3 plans
   Plans:

- [x] 02-01-PLAN.md — PomodoroService: state machine, timer, persistence, App Nap
- [x] 02-02-PLAN.md — Eye-strain sub-timer + all timer notifications
- [x] 02-03-PLAN.md — Timer ring UI, PomodoroView, menu bar icon
   **UI hint**: yes

### Phase 3: Hydration Tracker & Combined Notifications

**Goal**: Users can track daily water intake and receive unified health reminders during breaks
**Depends on**: Phase 2
**Requirements**: HYDR-01, HYDR-02, HYDR-03, HYDR-04, HYDR-05, UX-03, CROSS-01, CROSS-02
**Success Criteria** (what must be TRUE):

1. User can log a glass of water with a single click and see daily count (glasses + mL) in the dropdown
2. User receives a native notification to drink water at the configured interval
3. User can set a daily water goal and see progress toward it in the dropdown
4. When a Pomodoro break starts, user receives ONE combined notification: "Rest. Look away. Drink water."
5. Session count and glass count auto-reset at midnight
   **Plans**: TBD
   **UI hint**: yes

### Phase 4: Settings & Polish

**Goal**: Users can configure all app behavior from a settings window and control reminder delivery
**Depends on**: Phase 3
**Requirements**: SET-01, SET-02, SET-03, UX-04
**Success Criteria** (what must be TRUE):

1. User can open a settings window from the dropdown with tabs for Pomodoro, Hydration, and General
2. Changing any setting takes effect immediately without restarting the app
3. User can pause all reminders temporarily from the dropdown and resume them later
   **Plans**: TBD
   **UI hint**: yes

## Progress

**Execution Order:**
Phases execute in numeric order: 1 → 2 → 3 → 4

| Phase                                         | Plans Complete | Status      | Completed |
| --------------------------------------------- | -------------- | ----------- | --------- |
| 1. App Shell & Notifications                  | 0/0            | Not started | -         |
| 2. Pomodoro Timer & Eye-Strain                | 0/0            | Not started | -         |
| 3. Hydration Tracker & Combined Notifications | 0/0            | Not started | -         |
| 4. Settings & Polish                          | 0/0            | Not started | -         |
