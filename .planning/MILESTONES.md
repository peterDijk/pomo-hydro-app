# Milestones

## v1.0 MVP (Shipped: 2026-03-30)

**Phases completed:** 8 phases, 10 plans, 22 tasks

**Key accomplishments:**

- MenuBarExtra popover shell with @Observable NotificationService, scenePhase-based status refresh, and LSUIElement configuration
- Explain-then-request notification permission flow with denied-state banner, System Settings deep link, and test notification infrastructure
- Complete Pomodoro timer engine with deadline-based countdown, 5-state machine, auto-start transitions, App Nap prevention, and UserDefaults crash-recovery persistence
- Eye-strain 20-20-20 sub-timer with 3-minute suppression, timer notification methods for work-complete/break-complete/eye-strain, wired into PomodoroService state transitions
- Circular progress ring, PomodoroView with all states (idle/working/break/auto-start), dynamic menu bar icon, and Pause/Resume controls wired into MenuBarView
- HydrationService with glass logging (3 sizes), daily goal tracking, configurable reminder timer, midnight reset, and @AppStorage persistence. NotificationService extended with hydration reminders, combined break notifications, and actionable "Log Glass" button via UNNotificationCategory.
- HydrationView with glass count display, cyan progress bar, Log Glass button with drop.fill icon, S/M/L segmented size picker. Wired into MenuBarView below PomodoroView. Combined "Break Time — Hydrate!" notification when Pomodoro break starts within 5-min hydration window.

---
