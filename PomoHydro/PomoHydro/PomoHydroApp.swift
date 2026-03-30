//
//  PomoHydroApp.swift
//  PomoHydro
//
//  Created by Peter van Dijk on 30/03/2026.
//

import SwiftUI

@main
struct PomoHydroApp: App {
    @State private var notificationService = NotificationService()
    @State private var pomodoroService = PomodoroService()
    @State private var hydrationService = HydrationService()

    var body: some Scene {
        MenuBarExtra {
            MenuBarView()
                .environment(notificationService)
                .environment(pomodoroService)
                .environment(hydrationService)
                .task {
                    pomodoroService.setNotificationService(notificationService)
                    pomodoroService.setHydrationService(hydrationService)
                    hydrationService.setNotificationService(notificationService)
                    notificationService.setHydrationService(hydrationService)
                    hydrationService.startReminders()
                }
        } label: {
            Image(systemName: pomodoroService.menuBarIcon)
        }
        .menuBarExtraStyle(.window)

        Window("PomoHydro Settings", id: "settings") {
            SettingsView()
                .environment(pomodoroService)
                .environment(hydrationService)
        }
        .defaultSize(width: 450, height: 350)
        .windowResizability(.contentSize)
    }
}
