# Feature Landscape

**Domain:** macOS menu bar health/productivity app (Pomodoro + eye-strain + hydration)
**Researched:** 2026-03-30
**Overall confidence:** HIGH — Based on analysis of Be Focused, Flow, Time Out, Stretchly, WaterMinder, and broader ecosystem patterns.

## Competitive Landscape Summary

Three distinct app categories exist today, but **no single macOS menu bar app combines all three**. Users currently need 2-3 separate apps (e.g., Flow + Time Out + WaterMinder), each fighting for notification attention and menu bar space. This is PomoHydro's core value proposition: one lightweight native app replacing three.

**Competitors analyzed:**
- **Pomodoro:** Be Focused (macOS, 5M+ users), Flow (cross-platform, 4.8★), Session, Pomatez
- **Eye-strain/breaks:** Time Out (macOS, long-standing), Stretchly (open source, 6.1k★, Electron)
- **Hydration:** WaterMinder (iOS/watchOS, 33K ratings, Editors' Choice)

---

## Table Stakes

Features users expect from each individual domain. Missing = product feels broken or incomplete.

### Pomodoro Timer

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| Start/stop/pause timer | Core function — every timer app has this | Low | Single-click from menu bar dropdown |
| Configurable work duration | Users have different focus capacities (15–60 min) | Low | `@AppStorage` + Settings view, default 25 min |
| Configurable break duration | Short breaks vary by preference (3–10 min) | Low | Default 5 min short, 15 min long |
| Long break after N sessions | Standard Pomodoro technique — every app supports this | Low | Default: long break every 4 sessions |
| Session counter | Users want to know "how many Pomodoros today?" | Low | Simple Int counter, resets daily |
| Notification when timer completes | The entire point — user needs to know work/break ended | Low | `UNUserNotificationCenter` local notification |
| Auto-start next session (optional) | Be Focused, Flow both offer this — expected toggle | Low | Setting: auto-start work after break, auto-start break after work |

### Eye-Strain (20-20-20)

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| Reminder at 20-min intervals | Core 20-20-20 rule — every eye care app does this | Low | Timer fires every 20 min during work blocks |
| "Look at something 20ft away for 20s" nudge | The actual medical recommendation needs to be communicated | Low | Notification content text |
| Skip/dismiss option | Time Out, Stretchly both allow this — users revolt without it | Low | Action button on notification |

### Hydration Tracker

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| Log water with single action | WaterMinder's core UX — one tap/click to log | Low | Button in dropdown: "+1 glass" |
| Daily water count visible | Users need to see progress toward goal | Low | Display in menu bar dropdown |
| Configurable reminder interval | WaterMinder, all hydration apps have this | Low | Default 45 min, `@AppStorage` |
| Notification to drink water | Core function of a hydration reminder | Low | Independent timer from Pomodoro |
| Daily goal | Users expect a target (e.g., 8 glasses) | Low | Default 8 glasses, configurable |

### Menu Bar App UX

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| Menu bar icon with live state | Users expect visual indication — is timer running? | Low | SF Symbol, possibly changes between states |
| Countdown visible in dropdown | Time Out, Be Focused show remaining time in tray/popover | Low | Text label in `MenuBarExtra` popover |
| Launch at login option | Every menu bar utility has this — Time Out, Stretchly, Be Focused all do | Low | `SMAppService.mainApp.register()` (macOS 13+) |
| Pause all reminders | Time Out and Stretchly both let you pause everything temporarily | Low | "Pause for 30min / 1hr / until tomorrow" |
| Respect Do Not Disturb | Stretchly monitors DND — users expect notifications to respect system settings | Low | Handled by macOS automatically for `UNUserNotificationCenter`; no extra code needed |

---

## Differentiators

Features that set PomoHydro apart. Not expected by default, but create competitive advantage.

### High-Value Differentiators (recommended for v1 or early v2)

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| **Combined break notification** | "Take a break. Rest your eyes. Drink some water." — One unified nudge instead of 3 separate apps nagging you | Low | Merge eye-strain + Pomodoro break notification into single rich notification. THIS is the killer feature — no competitor does it. |
| **Timer in menu bar text** | Show countdown "23:41" next to icon — visible without clicking | Low | `MenuBarExtra` supports title text. Be Focused and Flow both do this. Difference: also shows water count (e.g., "23:41 💧5"). |
| **Idle detection → auto-pause** | Stretchly pauses automatically when user is idle 5+ min. Prevents phantom breaks. | Med | Requires monitoring system idle time. Can use `CGEventSource.secondsSinceLastEventType` or IOKit. |
| **Keyboard shortcut to log water** | Log water without touching mouse — "just hit ⌘⇧W" | Low | Global hotkey via `NSEvent.addGlobalMonitorForEvents` or `MASShortcut`-style approach. |
| **Daily reset at midnight** | Water count and session count auto-reset. No manual action needed. | Low | Schedule reset via `Calendar`-based timer or check on each interaction. |

### Medium-Value Differentiators (nice-to-have, consider for v2)

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| Configurable glass size (mL) | Some glasses are 200mL, some 350mL. Let user set once. | Low | Already in PROJECT.md scope (250mL default) |
| Progress bar in dropdown | Visual "4/8 glasses" bar more motivating than plain number | Low | SwiftUI `ProgressView` or `Gauge` |
| Break suggestions | "Stretch your neck" / "Walk to the kitchen" — like Stretchly's break ideas | Low | Array of strings, random pick per break notification |
| Custom notification sounds per type | Different sound for "Pomodoro done" vs "drink water" — less notification fatigue | Low | `UNNotificationSound` with bundled system sounds |
| Quick-adjust timer from dropdown | "+5 min" / "-5 min" buttons to extend current session without entering settings | Low | Two buttons modifying the running timer's end-time |

### Lower-Value Differentiators (defer to v3+)

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| Statistics/history across days | Track trends: "averaging 6 glasses/day", "12 Pomodoros this week" | Med-High | Requires persistent storage (SwiftData or JSON file), chart views. Explicitly out of scope for v1. |
| Focus mode integration (macOS) | Auto-enable macOS Focus mode during Pomodoro work sessions | Med | Requires Shortcuts/Intents or direct Focus API |
| Siri Shortcuts | "Hey Siri, start a Pomodoro" / "Log water" | Med | App Intents framework. |
| Widgets | Lock screen / Notification Center widget showing timer + water | Med-High | WidgetKit — separate target, timeline providers |
| Calendar-aware scheduling | Skip reminders during calendar events marked "busy" | Med | EventKit permissions, calendar access |

---

## Anti-Features

Features to explicitly NOT build. Each one is tempting but wrong for this app.

| Anti-Feature | Why Avoid | What to Do Instead |
|--------------|-----------|-------------------|
| **Task management / labels** | Be Focused adds tasks, tags, due dates — it turns a timer into a project manager. PomoHydro is a health companion, not a task tracker. Scope creep kills simplicity. | Let users manage tasks in their existing tools (Things, Todoist, etc.). Timer is just a timer. |
| **App/website blocking** | Flow and Be Focused block distracting apps. This is a separate concern and adds accessibility/security complexity (requires screen recording permissions, browser extensions). | Users who want blocking can use Focus mode or dedicated blockers (Cold Turkey, SelfControl). |
| **Multiple beverage types** | WaterMinder tracks coffee, juice, beer — this adds type picker UI, calorie logic, caffeine tracking. Massive scope expansion for marginal value in a personal tool. | Track water only. Log glasses. Keep it dead simple. |
| **Gamification / achievements** | WaterMinder has 50+ characters, achievements, streaks. Adds motivational mechanics that feel corporate. This is a dev tool, not a lifestyle app. | Clean, minimal UI. The reward is feeling healthy, not a badge. |
| **Cloud sync** | Flow, Be Focused sync across devices. Requires backend, auth, conflict resolution. PomoHydro lives on one Mac. | `UserDefaults` local only. If needed later, iCloud key-value store is trivial to add. |
| **iOS / Apple Watch companion** | WaterMinder has Watch, Siri, Widgets. This is a macOS menu bar app. Multi-platform splits focus. | macOS only. If demand arises, this is a v3+ consideration. |
| **Subscription model** | Flow/WaterMinder use subscriptions. This is a personal tool, not a business. | Free. Open source if desired. No monetization overhead. |
| **Custom themes / colors** | Stretchly has color pickers, custom themes, transparent mode. Visual customization is a rabbit hole. | Follow system appearance (light/dark mode). Use SF Symbols. Look native. |
| **Ambient sounds / white noise** | Some Pomodoro apps play rain, café, or lofi sounds. Requires audio session management, sound files, mixing. | Users have Spotify, Apple Music, or standalone ambient apps. A timer shouldn't play music. |
| **Screen dimming / full-screen break overlays** | Time Out and Stretchly can take over the entire screen during breaks. Aggressive interruption pattern that frustrates power users. | Native notifications only. Non-modal, dismissible. Respect the user's workflow. |

---

## Feature Dependencies

```
                    ┌──────────────────┐
                    │  Menu Bar Shell  │
                    │  (MenuBarExtra)  │
                    └────────┬─────────┘
                             │
              ┌──────────────┼──────────────┐
              ▼              ▼              ▼
     ┌────────────┐  ┌────────────┐  ┌────────────┐
     │  Pomodoro  │  │  Hydration │  │  Settings  │
     │   Timer    │  │  Tracker   │  │    View    │
     └─────┬──────┘  └────────────┘  └────────────┘
           │
           ▼
     ┌────────────┐
     │  Eye-Strain│
     │  20-20-20  │
     └────────────┘
```

**Key dependency chain:**
1. **Menu Bar Shell** must exist first → all other features live inside it
2. **Pomodoro Timer** is prerequisite for **Eye-Strain** → 20-20-20 reminders fire during work blocks
3. **Hydration Tracker** is independent — no dependency on Pomodoro
4. **Settings View** depends on all features existing (configures each one)
5. **Notifications** are cross-cutting — all three features need them, so notification permission request should happen on first launch
6. **Daily reset** depends on both Pomodoro (session count) and Hydration (glass count)
7. **Launch at login** is independent of all features

**Build order implication:**
1. Menu bar app shell + notifications permission
2. Pomodoro timer (core loop)
3. Eye-strain reminders (piggybacks on Pomodoro)
4. Hydration tracker (independent)
5. Settings view (configures everything)
6. Polish (launch at login, idle detection, daily reset)

---

## MVP Recommendation

**Prioritize (v1 — ship to validate):**
1. Menu bar shell with dropdown (table stakes — the container for everything)
2. Pomodoro timer with start/stop/pause, configurable durations (core value)
3. 20-20-20 eye-strain reminders folded into Pomodoro work blocks (the natural pairing)
4. Hydration tracker with one-click logging and reminders (independent timer)
5. Combined break notification (the differentiator — "rest, look away, drink water")
6. Settings view for all configurable values
7. Daily session + glass counter with midnight reset

**Defer to v2:**
- Launch at login
- Idle detection / auto-pause
- Global keyboard shortcuts
- Timer countdown in menu bar text
- Progress bar visualization
- Break suggestions / tips

**Defer to v3+:**
- Statistics / history
- Focus mode integration
- Siri Shortcuts
- Widgets

**Never build:**
- Task management, app blocking, gamification, cloud sync, multi-platform, themes, ambient sounds, screen overlays

---

## Sources

- **Be Focused** (Mac App Store) — Task management, timer control, customization, focus/blocking, reports, device sync, widgets, hotkeys. 5M+ users.
- **Flow: Focus & Pomodoro Timer** (Mac App Store, 4.8★, 1.7K ratings) — Pomodoro timer, statistics, app/web blocking, commitment mode, metronome, calendar sync, Health sync, Live Activities.
- **Time Out - Break Reminders** (Mac App Store) — Normal breaks (10 min/hr) + Micro breaks (15s/15min), customizable themes, HTML break screens, action scripting, sound/speech, natural break detection.
- **Stretchly** (GitHub, 6.1k★, Electron) — Mini breaks (20s/10min) + Long breaks (5min/30min), idle detection, DND monitoring, strict mode, app exclusions, break ideas, custom sounds, Break Health Mode, 260+ contributors.
- **WaterMinder** (iOS App Store, 33K ratings, Editors' Choice) — Pre-defined cups, custom drinks, multiple beverage types, visual characters, achievements, Apple Health sync, Siri Shortcuts, Apple Watch, widgets, challenges.
