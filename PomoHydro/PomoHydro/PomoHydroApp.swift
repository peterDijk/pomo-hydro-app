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

    var body: some Scene {
        MenuBarExtra {
            MenuBarView()
                .environment(notificationService)
                .environment(pomodoroService)
        } label: {
            Label("PomoHydro", systemImage: "timer")
        }
        .menuBarExtraStyle(.window)
    }
}
