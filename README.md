# PomoHydro 🍅💧

**PomoHydro** is a native macOS menu bar health companion designed to keep you hydrated, focused, and free from eye strain during long work sessions—without getting in your way.

It seamlessly bundles a **Pomodoro timer**, **20-20-20 eye-strain reminders**, and a **hydration tracker** into one lightweight, beautiful app that lives right in your menu bar.

See [CHANGELOG.md](CHANGELOG.md) for post-`v1.0` changes and release notes.

---

## Getting Started

### 1. Installation

Download the latest release .zip file from the Releases page and unpack to find the PomoHydro.app file.

1. Drag **PomoHydro.app** into your `/Applications` folder.
2. Double-click to launch. You will see a new icon (a clock with a water droplet) appear in your macOS menu bar at the top right of your screen.
   _(Note: If macOS blocks the app from opening, see the [Troubleshooting (macOS Gatekeeper)](#troubleshooting-macos-gatekeeper) section)._

### 2. Permissions

PomoHydro relies heavily on macOS system notifications.

- On your **first launch**, macOS will prompt you to allow notifications from PomoHydro.
- **Please click Allow.** Without this permission, you won't receive your break, eye-strain, or hydration reminders.
- _If you missed it:_ Go to **System Settings > Notifications > PomoHydro** and ensure "Allow notifications" is turned on, choosing **Alerts** for the best experience.

---

## Feature Guide

### 🍅 The Pomodoro Timer

A 5-state timer that keeps your work structured into manageable sprints and rewarding breaks.

- **Start a Focus Session:** Click the menu bar icon and hit "Start Session."
- **Work Phase (Default: 50 min):** The menu bar icon turns into a filled circle with clock hands. Work uninterrupted until you receive a notification.
- **Break Phase (Default: 10 min):** Take a short break! When your work block ends, you'll get a unified notification: _"Rest. Look away. Drink water."_
- **Long Break:** After completing 4 sessions (configurable), the app automatically suggests a Long Break (default 15 mins) to help you fully recover.
- **Manual Control:** You can Pause, Resume, or Stop a session directly from the menu bar dropdown at any time.

_Note: PomoHydro requires manual confirmation (clicking "OK") after a break ends to start your next session. It never blindly starts a work timer while you are away!_

### 👁 20-20-20 Eye-Strain Reminders

Protect your vision using the medically recommended 20-20-20 rule.

- **How it works:** Every 20 minutes during an active work block, PomoHydro issues a gentle alert: _"Look at something 20 feet away for 20 seconds."_
- **Persistent Alerts:** These alerts stay on screen, so you don't miss them if you step away.
- **Smart Integration:** If your eye-strain reminder coincides with the end of a Pomodoro block, PomoHydro gracefully folds it into the Pomodoro break notification to avoid annoying you with duplicate alerts.

### 💧 Hydration Tracker

Keep your water intake on track effortlessly.

- **Log a Drink:** Click the PomoHydro menu bar icon and select a glass size to log water:
  - **Small (S):** ~150mL
  - **Medium (M):** ~250mL (Standard)
  - **Large (L):** ~350mL
- **Daily Goal:** Track your progress against a daily goal (Default: 8 glasses / 2,000mL) right from the dropdown menu.
- **Smart Reminders:** If you haven't logged water recently, the app sends a reminder to hydrate at a configurable interval (Default: 45 minutes).
- **Midnight Reset:** Your daily glass count automatically zeroes out at midnight.

---

## App Controls & Settings

### The Menu Bar Icon

Because PomoHydro is a pure menu bar app, it does not clutter your Dock. The icon itself tells you what state you are in:

- **Idle:** Outlined circle with clock hands.
- **Working:** Filled circle with clock hands.
- **On Break:** Distinct visual indicator showing break time.

### Global Pause

Need deep, uninterrupted focus for an unplannable amount of time? Open the menu bar dropdown and click **Pause All Reminders**. This acts as a global mute for the Pomodoro, Eye-strain, and Hydration systems until you resume them.

### Settings Window

Click the **Gear Icon ⚙️** in the menu bar dropdown to open Settings.
Here you can configure:

- **Pomodoro Tab:** Work duration, short/long break durations, and how many sessions trigger a long break.
- **Hydration Tab:** Your daily hydration goal and how often you want to be reminded to drink water.
- **Live Recalculation:** Changing timer durations mid-session? PomoHydro is smart enough to instantly recalculate your active timers on the fly.

---

## Behind the Scenes (Reliability)

- **Crash Recovery:** Accidental force quit? PomoHydro constantly saves its state. Just reopen the app, and your active Pomodoro timer and daily water count will pick up exactly where they left off.
- **App Nap Prevention:** macOS loves to put background apps to sleep ("App Nap") to save battery. PomoHydro uses native system APIs to ensure timers stay 100% accurate, even when tucked away in the background.

---

## Troubleshooting (macOS Gatekeeper)

Because PomoHydro is independently distributed and not yet notarized via the paid Apple Developer Program, macOS Gatekeeper may show a warning when you first open the downloaded app (e.g., _"Apple could not verify PomoHydro is free of malware"_).

This is completely normal for open-source and independent apps. **You can safely bypass this using one of these methods:**

### Method 1: The "Right-Click" Trick (Easiest)

Do this exactly once to permanently whitelist the app:

1. Open **Finder** and locate `PomoHydro.app`.
2. **Right-click** (or hold `Control` and click) on the app.
3. Choose **Open** from the context menu.
4. The warning will appear again, but this time it will have an **"Open"** button. Click it.

### Method 2: System Settings

1. Attempt to open the app normally by double-clicking.
2. Click "Done" or "Cancel" on the warning prompt.
3. Open **System Settings > Privacy & Security**.
4. Scroll down until you see the message _"PomoHydro was blocked from use because it is not from an identified developer."_
5. Click **Open Anyway**.

### Method 3: Terminal (If macOS says the app is "damaged")

If macOS is overly aggressive and claims the app is corrupted:

1. Ensure `PomoHydro.app` is in your `/Applications` folder.
2. Open the **Terminal** app.
3. Run this command to remove the quarantine flag: `xattr -cr /Applications/PomoHydro.app`
4. You can now open the app normally!
