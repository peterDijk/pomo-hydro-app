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
final class NotificationService {
    var authorizationStatus: UNAuthorizationStatus = .notDetermined

    private let center = UNUserNotificationCenter.current()

    init() {
        Task {
            await checkStatus()
        }
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
}
