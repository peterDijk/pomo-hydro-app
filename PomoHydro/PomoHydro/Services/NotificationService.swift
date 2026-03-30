//
//  NotificationService.swift
//  PomoHydro
//
//  Created by Peter van Dijk on 30/03/2026.
//

import Foundation
import UserNotifications
import Observation

@Observable
@MainActor
final class NotificationService: NSObject, UNUserNotificationCenterDelegate {
    var authorizationStatus: UNAuthorizationStatus = .notDetermined

    private let center = UNUserNotificationCenter.current()

    // MARK: - Hydration Service Dependency
    private var hydrationService: HydrationService?

    func setHydrationService(_ service: HydrationService) {
        self.hydrationService = service
    }

    // MARK: - Pomodoro Service Dependency
    private var pomodoroService: PomodoroService?

    func setPomodoroService(_ service: PomodoroService) {
        self.pomodoroService = service
    }

    override init() {
        super.init()
        center.delegate = self
        registerCategories()
        Task {
            await checkStatus()
        }
    }

    // MARK: - Notification Categories

    private func registerCategories() {
        let logGlassAction = UNNotificationAction(
            identifier: "LOG_GLASS",
            title: "Log Glass",
            options: .foreground
        )
        let hydrationCategory = UNNotificationCategory(
            identifier: "HYDRATION_REMINDER",
            actions: [logGlassAction],
            intentIdentifiers: [],
            options: []
        )

        let okAction = UNNotificationAction(
            identifier: "EYE_STRAIN_OK",
            title: "OK",
            options: []
        )
        let eyeStrainCategory = UNNotificationCategory(
            identifier: "EYE_STRAIN",
            actions: [okAction],
            intentIdentifiers: [],
            options: .customDismissAction
        )

        let startSessionAction = UNNotificationAction(
            identifier: "START_SESSION",
            title: "OK",
            options: []
        )
        let breakCompleteCategory = UNNotificationCategory(
            identifier: "BREAK_COMPLETE",
            actions: [startSessionAction],
            intentIdentifiers: [],
            options: .customDismissAction
        )

        center.setNotificationCategories([hydrationCategory, eyeStrainCategory, breakCompleteCategory])
    }

    // MARK: - UNUserNotificationCenterDelegate

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        if response.actionIdentifier == "LOG_GLASS" {
            Task { @MainActor in
                self.hydrationService?.logGlass()
            }
        } else if response.actionIdentifier == "START_SESSION" {
            Task { @MainActor in
                self.pomodoroService?.start()
            }
        }
        completionHandler()
    }

    func checkStatus() async {
        let settings = await center.notificationSettings()
        authorizationStatus = settings.authorizationStatus
    }

    func requestPermission() async {
        do {
            let _ = try await center.requestAuthorization(options: [.alert, .sound])
            await checkStatus()
        } catch {
            await checkStatus()
        }
    }

    func sendTestNotification() async {
        let content = UNMutableNotificationContent()
        content.title = "PomoHydro"
        content.body = "Notifications are working! You'll receive reminders here."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )

        do {
            try await center.add(request)
        } catch {
            await checkStatus()
        }
    }

    // MARK: - Timer Notifications

    func sendWorkCompleteNotification(includeEyeStrain: Bool) async {
        let content = UNMutableNotificationContent()
        content.title = "Time for a Break!"
        if includeEyeStrain {
            content.body = "Great focus! Look at something 20 feet away and stretch."
        } else {
            content.body = "Great focus! Rest your eyes and stretch."
        }
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "work-complete",
            content: content,
            trigger: trigger
        )
        try? await center.add(request)
    }

    func sendBreakCompleteNotification(isLongBreak: Bool) async {
        let content = UNMutableNotificationContent()
        content.title = isLongBreak ? "Long Break Over" : "Break Over"
        content.body = isLongBreak
            ? "Feeling refreshed? Let's get back to it."
            : "Ready for another focus session?"
        content.sound = .default
        content.categoryIdentifier = "BREAK_COMPLETE"

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "break-complete",
            content: content,
            trigger: trigger
        )
        try? await center.add(request)
    }

    func sendEyeStrainNotification() async {
        let content = UNMutableNotificationContent()
        content.title = "Rest Your Eyes"
        content.body = "Look at something 20 feet away for 20 seconds."
        content.sound = .default
        content.categoryIdentifier = "EYE_STRAIN"

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "eye-strain-\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        try? await center.add(request)
    }

    func cancelTimerNotifications() {
        center.removePendingNotificationRequests(withIdentifiers: ["work-complete", "break-complete"])
    }

    // MARK: - Hydration Notifications

    func sendHydrationReminder() async {
        let content = UNMutableNotificationContent()
        content.title = "Time to Hydrate"
        content.body = "Take a moment to drink some water."
        content.sound = .default
        content.categoryIdentifier = "HYDRATION_REMINDER"

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "hydration-reminder",
            content: content,
            trigger: trigger
        )
        try? await center.add(request)
    }

    func sendCombinedBreakNotification(includeEyeStrain: Bool) async {
        let content = UNMutableNotificationContent()
        content.title = "Break Time — Hydrate!"
        content.body = includeEyeStrain
            ? "Look away for 20 seconds, stretch, and drink some water."
            : "Rest your eyes, stretch, and drink some water."
        content.sound = .default
        content.categoryIdentifier = "HYDRATION_REMINDER"

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "break-combined",
            content: content,
            trigger: trigger
        )
        try? await center.add(request)
    }
}
