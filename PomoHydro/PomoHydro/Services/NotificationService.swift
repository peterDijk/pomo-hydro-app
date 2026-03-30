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
}
