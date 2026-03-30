# Project Research Summary

**Project:** PomoHydro — macOS menu bar health/productivity app
**Domain:** macOS native utility (Pomodoro timer + eye-strain reminders + hydration tracking)
**Researched:** 2026-03-30
**Confidence:** HIGH

## Executive Summary

PomoHydro is a lightweight macOS menu bar utility that combines three health/productivity concerns — Pomodoro timer, 20-20-20 eye-strain reminders, and hydration tracking — into a single native app. No existing macOS app does this; users currently need 2-3 separate apps (e.g., Flow + Time Out + WaterMinder) fighting for notification attention. The recommended approach is a **pure Apple-stack SwiftUI app** using `MenuBarExtra` (macOS 13+), `@Observable` services, `UserDefaults`/`@AppStorage` persistence, and `UserNotifications` for local alerts. Zero third-party dependencies. The entire app is ~10 source files.

The architecture follows a **service-layer pattern**: three `@Observable` classes (`PomodoroService`, `HydrationService`, `NotificationService`) own all business logic, injected into thin SwiftUI views via `@Environment`. Pomodoro and Hydration run as independent timer domains — the only coupling is at the notification layer where the app's **killer differentiator** lives: a single combined break notification that says "rest, look away, drink water" instead of three separate alerts.

The primary risks are macOS platform behaviors that are invisible during development: **App Nap silently throttling timers** (fix: `ProcessInfo.beginActivity`), **notification permission denied with no error** (fix: check status + in-app fallback UI), and **MenuBarExtra auto-termination losing state** (fix: persist end-times to UserDefaults on every mutation). All three must be addressed in the first timer implementation phase — they're not polish items.

## Key Findings

### Recommended Stack

Pure first-party Apple stack targeting **macOS 14.0+ (Sonoma)** with **Swift 6** and **Xcode 26.1+**. The macOS 14 floor is driven by `@Observable` (Swift 5.9+ macro); `MenuBarExtra` only needs macOS 13.

**Core technologies:**
- **SwiftUI `MenuBarExtra`** with `.menuBarExtraStyle(.window)` — official menu bar app API, handles status item and popover lifecycle automatically
- **`@Observable` + `@Environment`** — modern state management, fine-grained view updates, testable injection (replaces `ObservableObject`/Combine)
- **`@AppStorage` / `UserDefaults`** — persistence for ~12 primitive settings. NOT SwiftData — no relational data, no complex queries
- **`UserNotifications` (`UNUserNotificationCenter`)** — local notifications with triggers, permission management, custom content
- **Foundation `Timer` + `Date`-based deadlines** — 1-second UI refresh ticks; actual timer deadlines stored as absolute `Date` values
- **Swift Testing** — modern `@Test`/`#expect` for unit tests on service logic
- **`LSUIElement = true`** — hides from Dock/Cmd+Tab, standard for menu-bar-only apps

**No external dependencies.** No CocoaPods, no SPM packages. Apple frameworks cover 100% of requirements.

### Expected Features

**Must have (table stakes):**
- Pomodoro timer: start/stop/pause, configurable work/break durations, long break every N sessions, session counter, completion notifications
- 20-20-20 eye-strain reminders during work blocks (folded into break notifications)
- Hydration tracker: one-click glass logging, daily count + goal, independent reminder timer
- Menu bar icon with live state, countdown in popover, notification permission handling

**Should have (differentiators — v1):**
- **Combined break notification** — "Rest. Look away. Drink water." in one alert. No competitor does this. This IS the product.
- **Timer countdown in menu bar text** — visible without opening popover (Be Focused and Flow pattern)
- **Daily reset at midnight** — session and glass counts auto-reset

**Defer to v2:**
- Launch at login (`SMAppService`)
- Idle detection / auto-pause
- Global keyboard shortcuts
- Progress bar visualization
- Break suggestions/tips

**Never build:** Task management, app blocking, gamification, cloud sync, iOS/Watch, themes, ambient sounds, screen overlays.

### Architecture Approach

Service-layer pattern with three `@Observable` `@MainActor` service classes created as `@State` on the App struct and injected via `.environment()`. Views are thin consumers — read state, call methods, no business logic. Pomodoro and Hydration are **independent timer domains** (learning from Stretchly's over-coupled `BreaksPlanner`), coordinated only at the notification layer for combined break messages.

**Major components:**
1. **`PomodoroService`** — State machine (idle→working→shortBreak/longBreak→idle), date-based timer, eye-strain sub-timer, session counting
2. **`HydrationService`** — Independent reminder timer, glass logging, daily count/goal tracking
3. **`NotificationService`** — Permission management, notification composition (including combined break), `UNUserNotificationCenter` wrapper
4. **`SettingsView`** — macOS `Settings` scene with tabs per domain, two-way `@AppStorage` bindings
5. **View layer** (~5 views) — `MenuBarLabel`, `MenuBarView`, `PomodoroSection`, `HydrationSection`, `SettingsView`

**File structure:** ~10 files in `Services/`, `Models/`, `Views/` plus app entry point. Deliberately minimal — no abstractions, no protocol-oriented over-engineering.

### Critical Pitfalls

1. **App Nap throttles timers** — Menu bar apps with closed popovers hit all App Nap criteria. Timers drift by seconds to minutes. **Fix:** `ProcessInfo.processInfo.beginActivity(options: .userInitiatedAllowingIdleSystemSleep, reason:)` when any timer is active. End when all timers stop. **Invisible during development** — Xcode debugger prevents App Nap.

2. **Timer display drift from decrementing counters** — Foundation Timer is explicitly "not a real-time mechanism." **Fix:** Store target end time as `Date`, compute remaining on each tick. Schedule notifications via `UNTimeIntervalNotificationTrigger` (system scheduling, survives app death).

3. **Notification permission denied silently** — `UNUserNotificationCenter.add()` succeeds without error even when denied. App appears functional but never notifies. **Fix:** Check `authorizationStatus` before relying on notifications; show in-app banner when denied with link to System Settings.

4. **MenuBarExtra auto-termination** — User can Cmd-drag the icon away, app terminates immediately with no quit event. **Fix:** Persist all mutable state (end-times, glass count, session count) to `UserDefaults` on every mutation. Restore on launch.

5. **Notification fatigue from three timer domains** — Eye-strain (20 min), Pomodoro (25 min), and hydration (45 min) can cluster. **Fix:** Fold eye-strain into Pomodoro breaks; suppress hydration during breaks; debounce notifications (never fire two within 30 seconds).

## Implications for Roadmap

Based on dependency analysis from ARCHITECTURE.md, build order constraints from FEATURES.md, and pitfall phase-mappings from PITFALLS.md:

### Phase 1: Project Setup + Menu Bar Shell
**Rationale:** Every component lives inside the menu bar shell. Can't test anything without it. Also the right time to configure Swift 6 strict concurrency (Pitfall 12 — retrofitting is painful).
**Delivers:** Xcode project, `Info.plist` with `LSUIElement`, `PomoHydroApp.swift` with `MenuBarExtra` scene, empty popover that opens/closes, no Dock icon.
**Addresses:** Menu bar app UX (table stakes container)
**Avoids:** Pitfall 12 (Swift 6 concurrency) — enable strict checking from day one

### Phase 2: Notification Infrastructure
**Rationale:** Both timer services depend on notifications. Build and test in isolation before adding consumers. Permission handling is a critical pitfall that must be right before any notification-dependent feature is "done."
**Delivers:** `NotificationService` with permission request, status checking, in-app denied-state banner, test notification capability.
**Addresses:** Notification permission UX (table stakes)
**Avoids:** Pitfall 3 (permission denied silently)

### Phase 3: Pomodoro Timer Core
**Rationale:** Most complex component, primary feature, prerequisite for eye-strain. Must nail App Nap prevention and date-based timer architecture from the start — these are not refactorable later.
**Delivers:** `PomodoroService` with state machine (idle/working/shortBreak/longBreak), start/stop/pause, configurable durations, session counting, break notifications, `PomodoroSection` view.
**Addresses:** All Pomodoro table stakes
**Avoids:** Pitfall 1 (App Nap), Pitfall 2 (timer drift), Pitfall 9 (state persistence across restart), Pitfall 4 (auto-termination data loss)

### Phase 4: Eye-Strain Integration
**Rationale:** Piggybacks on working Pomodoro timer. Small scope — adds sub-timer and updates notification content. Creates the combined break notification that's the product's differentiator.
**Delivers:** 20-20-20 reminders during work blocks, eye-strain message folded into break notifications.
**Addresses:** Eye-strain table stakes + combined notification differentiator
**Avoids:** Pitfall 5 (notification clustering) — suppress near break boundaries

### Phase 5: Hydration Tracker
**Rationale:** Fully independent of Pomodoro — could be parallel but sequencing is simpler. Completes the combined notification (all three domains active).
**Delivers:** `HydrationService`, glass logging, independent reminder timer, daily count/goal, hydration section in popover, hydration nudge in combined break notification.
**Addresses:** All hydration table stakes
**Avoids:** Pitfall 7 (daily reset edge cases), Pitfall 4 (persist on every mutation)

### Phase 6: Settings + Configuration
**Rationale:** Needs all services to exist — configures each one. Also the natural place for daily reset logic (touches both services).
**Delivers:** macOS `Settings` scene with tabs (Pomodoro, Hydration, General), `@AppStorage` two-way bindings, daily midnight reset logic.
**Addresses:** All configurable values from table stakes
**Avoids:** Pitfall 7 (daily reset) — implemented with date comparison, not midnight timer

### Phase 7: Polish + Menu Bar UX
**Rationale:** Final phase — everything works, now make it delightful. Timer countdown in menu bar text, notification sound strategy, final UI pass.
**Delivers:** Menu bar countdown text, notification sound differentiation (Pitfall 11), compact label strategy (Pitfall 10), overall UI polish.
**Addresses:** Timer-in-menu-bar differentiator, notification sound UX
**Avoids:** Pitfall 6 (popover dismissed — mitigated by menu bar countdown), Pitfall 10 (menu bar space), Pitfall 11 (sound fatigue)

### Phase Ordering Rationale

- **Phases 1→2→3 are strictly sequential** — shell contains everything, notifications underpin both timer services, Pomodoro is prerequisite for eye-strain
- **Phases 3-4 and Phase 5 are architecturally independent** — Pomodoro and Hydration are separate timer domains. Ordered 3→4→5 because Pomodoro is more complex and is the primary feature
- **Phase 6 requires Phases 3-5** — Settings configures all services, needs them to exist
- **App Nap prevention (Pitfall 1) is embedded in Phase 3** — not a separate phase, it's a timer architecture requirement
- **Combined break notification evolves across Phases 4-5** — starts with eye-strain in Phase 4, adds hydration nudge in Phase 5

### Research Flags

**Phases likely needing deeper research during planning:**
- **Phase 3 (Pomodoro Timer):** `ProcessInfo.beginActivity` integration with timer lifecycle needs testing. Timer state persistence/restoration on relaunch is non-trivial. How `Timer.publish` interacts with MenuBarExtra popover open/close cycle.

**Phases with standard patterns (skip `/gsd-research-phase`):**
- **Phase 1 (Shell):** MenuBarExtra setup is well-documented with Apple sample code
- **Phase 2 (Notifications):** UNUserNotificationCenter is thoroughly documented
- **Phase 4 (Eye-Strain):** Small addition to existing Pomodoro service
- **Phase 5 (Hydration):** Mirror of Pomodoro patterns, simpler state machine
- **Phase 6 (Settings):** Standard SwiftUI Settings scene + @AppStorage bindings
- **Phase 7 (Polish):** UI refinement, no new patterns

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | HIGH | Pure first-party Apple stack, all APIs verified via Context7 and official docs. Zero dependency risk. |
| Features | HIGH | Competitive analysis of 6+ apps (Be Focused, Flow, Time Out, Stretchly, WaterMinder). Feature boundaries and anti-features are well-defined. |
| Architecture | HIGH | Service-layer pattern based on Apple's @Observable recommendations + Stretchly's open-source architecture (6.1k★). ~10 files, clear boundaries. |
| Pitfalls | HIGH | All critical pitfalls verified against Apple documentation (App Nap, Timer, MenuBarExtra auto-termination, UNUserNotificationCenter). Phase-mapped. |

**Overall confidence: HIGH** — This is a well-understood domain (menu bar utilities) built with established first-party APIs. No novel technical challenges.

### Gaps to Address

- **App Nap prevention testing:** Can only be validated with debugger detached. Must be tested explicitly in Phase 3 — add to UAT criteria.
- **MenuBarExtra label dynamic text:** Using `Text("24:15")` as the label for live countdown — verify this updates correctly when popover is closed. May need `@Observable` binding verification.
- **Combined notification UX:** The exact copy/format of the combined break notification needs user testing. Research confirms the concept; wording needs iteration.
- **Swift 6 strict concurrency with Timer callbacks:** Timer.publish + @MainActor should be safe, but Timer.scheduledTimer closures may need `@Sendable` annotation. Verify in Phase 3.

## Sources

### Primary (HIGH confidence)
- Apple Developer: MenuBarExtra, MenuBarExtraStyle.window, Building and customizing the menu bar (Context7)
- Apple Developer: SwiftData (used for "why not" rationale, Context7)
- Apple Developer: UserNotifications, scheduling local notifications (Context7)
- Apple Developer: Foundation Timer ("not a real-time mechanism" warning)
- Apple Developer: ProcessInfo.beginActivity / ActivityOptions (App Nap prevention)
- Apple Developer: SMAppService (launch at login)
- Apple Developer: @Observable / Observation framework patterns (Context7)

### Secondary (MEDIUM confidence)
- Stretchly (GitHub, 6.1k★) — BreaksPlanner architecture, break de-duplication, idle detection patterns
- Be Focused, Flow, Time Out, WaterMinder — competitive feature analysis (App Store listings)

---
*Research completed: 2026-03-30*
*Ready for roadmap: yes*
