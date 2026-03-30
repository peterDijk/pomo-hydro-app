---
phase: 01-app-shell-notifications
status: human_needed
verified_at: 2026-03-30
score: 10/10
---

# Phase 01: App Shell & Notifications — Verification

## Automated Checks

All automated checks passed:

| Check | Status | Evidence |
|-------|--------|----------|
| MenuBarExtra configured with timer symbol | ✓ | PomoHydroApp.swift contains `MenuBarExtra` + `systemImage: "timer"` |
| .menuBarExtraStyle(.window) set | ✓ | PomoHydroApp.swift |
| NotificationService is @Observable | ✓ | NotificationService.swift contains `@Observable` |
| NotificationService is @MainActor | ✓ | NotificationService.swift contains `@MainActor` |
| NotificationService tracks authorizationStatus | ✓ | `var authorizationStatus: UNAuthorizationStatus` |
| MenuBarView switches on auth status | ✓ | switch statement with .notDetermined, .denied, default cases |
| PermissionPromptView explain-then-request | ✓ | "Stay on Track" + "Enable Notifications" CTA |
| NotificationDeniedBanner with System Settings | ✓ | "Enable in System Settings" + NSWorkspace deep link |
| scenePhase monitoring for re-focus | ✓ | `.onChange(of: scenePhase)` + checkStatus() |
| xcodebuild compilation | ✓ | BUILD SUCCEEDED |

**Score:** 10/10 must-haves verified

## Requirements Coverage

| REQ-ID | Description | Plan | Status |
|--------|-------------|------|--------|
| UX-01 | Menu bar presence, no Dock icon | 01-01 | ✓ Implemented (LSUIElement, MenuBarExtra) |
| UX-05 | Respects Do Not Disturb | 01-01 | ✓ Implemented (UNUserNotificationCenter handles automatically) |
| CROSS-03 | Permission prompt + denied fallback | 01-02 | ✓ Implemented (PermissionPromptView + NotificationDeniedBanner) |

## Human Verification Needed

The following items require manual testing by running the app:

1. **Menu bar icon visible:** App icon appears in macOS menu bar with no Dock icon visible
2. **Popover opens:** Clicking menu bar icon opens a ~320pt wide popover
3. **Permission prompt:** First launch shows "Stay on Track" explanation with "Enable Notifications" button
4. **System dialog:** Tapping "Enable Notifications" triggers macOS system permission dialog
5. **Granted state:** After granting, popover shows placeholder content + test notification button
6. **Denied state:** After denying, popover shows orange banner with "Enable in System Settings" link
7. **System Settings link:** Tapping banner link opens macOS System Settings → Notifications
8. **Test notification:** "Send Test Notification" button delivers a native macOS notification
9. **Re-focus refresh:** Opening popover after changing permission in System Settings reflects new status
