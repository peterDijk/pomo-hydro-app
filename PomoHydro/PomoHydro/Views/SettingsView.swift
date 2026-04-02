//
//  SettingsView.swift
//  PomoHydro
//
//  Created by Peter van Dijk on 30/03/2026.
//

import SwiftUI

enum SettingsTab: String, CaseIterable {
    case pomodoro
    case hydration
    case general

    var label: String {
        switch self {
        case .pomodoro: "Pomodoro"
        case .hydration: "Hydration"
        case .general: "General"
        }
    }

    var icon: String {
        switch self {
        case .pomodoro: "timer"
        case .hydration: "drop.fill"
        case .general: "gearshape"
        }
    }
}

struct SettingsView: View {
    @State private var selectedTab: SettingsTab = .pomodoro
    @Environment(PomodoroService.self) private var pomodoroService
    @Environment(HydrationService.self) private var hydrationService

    var body: some View {
        TabView(selection: $selectedTab) {
            PomodoroSettingsTab()
                .environment(pomodoroService)
                .tabItem {
                    Label(SettingsTab.pomodoro.label, systemImage: SettingsTab.pomodoro.icon)
                }
                .tag(SettingsTab.pomodoro)

            HydrationSettingsTab()
                .environment(hydrationService)
                .tabItem {
                    Label(SettingsTab.hydration.label, systemImage: SettingsTab.hydration.icon)
                }
                .tag(SettingsTab.hydration)

            GeneralSettingsTab()
                .environment(pomodoroService)
                .environment(hydrationService)
                .tabItem {
                    Label(SettingsTab.general.label, systemImage: SettingsTab.general.icon)
                }
                .tag(SettingsTab.general)
        }
        .frame(minWidth: 400, minHeight: 300)
        .padding(20)
    }
}

// MARK: - Pomodoro Settings Tab

private struct PomodoroSettingsTab: View {
    @AppStorage("workDuration") private var workDuration: Int = 50
    @AppStorage("shortBreakDuration") private var shortBreakDuration: Int = 10
    @AppStorage("longBreakDuration") private var longBreakDuration: Int = 15
    @AppStorage("sessionsBeforeLongBreak") private var sessionsBeforeLongBreak: Int = 4
    @AppStorage("autoStartBreak") private var autoStartBreak: Bool = true
    @AppStorage("autoStartWork") private var autoStartWork: Bool = true
    @AppStorage("eyeStrainInterval") private var eyeStrainInterval: Int = 20
    @AppStorage("eyeStrainSuppressBeforeBreak") private var eyeStrainSuppressBeforeBreak: Int = 5
    @AppStorage("freshAirInterval") private var freshAirInterval: Int = 60
    @AppStorage("freshAirSuppressBeforeBreak") private var freshAirSuppressBeforeBreak: Int = 5
    @Environment(PomodoroService.self) private var pomodoroService

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            sliderRow(label: "Work Duration", value: $workDuration, range: 1...60, format: "%d min")
                .onChange(of: workDuration) { oldValue, newValue in
                    if pomodoroService.state == .working {
                        pomodoroService.recalculateEndDate(oldDuration: oldValue, newDuration: newValue)
                    }
                }
            sliderRow(label: "Short Break", value: $shortBreakDuration, range: 1...15, format: "%d min")
                .onChange(of: shortBreakDuration) { oldValue, newValue in
                    if pomodoroService.state == .shortBreak {
                        pomodoroService.recalculateEndDate(oldDuration: oldValue, newDuration: newValue)
                    }
                }
            sliderRow(label: "Long Break", value: $longBreakDuration, range: 1...30, format: "%d min")
                .onChange(of: longBreakDuration) { oldValue, newValue in
                    if pomodoroService.state == .longBreak {
                        pomodoroService.recalculateEndDate(oldDuration: oldValue, newDuration: newValue)
                    }
                }
            sliderRow(label: "Sessions Before Long Break", value: $sessionsBeforeLongBreak, range: 2...8, format: "%d")
            sliderRow(label: "Eye-Strain Reminder", value: $eyeStrainInterval, range: 1...30, format: "%d min")
            sliderRow(label: "Skip Eye-Strain Reminder Near Break", value: $eyeStrainSuppressBeforeBreak, range: 0...10, format: "<= %d min")
            sliderRow(label: "Fresh Air Reminder", value: $freshAirInterval, range: 1...120, format: "%d min")
            sliderRow(label: "Skip Fresh Air Reminder Near Break", value: $freshAirSuppressBeforeBreak, range: 0...10, format: "<= %d min")

            Divider()
                .padding(.vertical, 4)

            Toggle("Auto-Start Break", isOn: $autoStartBreak)
            Toggle("Auto-Start Next Session", isOn: $autoStartWork)

            Spacer()

            HStack {
                Spacer()
                Button("Restore Defaults") {
                    workDuration = 50
                    shortBreakDuration = 10
                    longBreakDuration = 15
                    sessionsBeforeLongBreak = 4
                    eyeStrainInterval = 20
                    eyeStrainSuppressBeforeBreak = 5
                    freshAirInterval = 60
                    freshAirSuppressBeforeBreak = 5
                    autoStartBreak = true
                    autoStartWork = true
                }
                .buttonStyle(.borderless)
            }
        }
        .padding(16)
    }
}

// MARK: - Hydration Settings Tab

private struct HydrationSettingsTab: View {
    @AppStorage("hydrationReminderInterval") private var reminderInterval: Int = 45
    @AppStorage("dailyWaterGoal") private var dailyWaterGoal: Int = 8
    @Environment(HydrationService.self) private var hydrationService

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            sliderRow(label: "Reminder Interval", value: $reminderInterval, range: 1...120, format: "%d min")
                .onChange(of: reminderInterval) { _, _ in
                    hydrationService.restartWithNewInterval()
                }
            sliderRow(label: "Daily Goal", value: $dailyWaterGoal, range: 1...20, format: "%d glasses")
                .onChange(of: dailyWaterGoal) { _, _ in
                    hydrationService.refreshGoal()
                }

            Spacer()

            HStack {
                Spacer()
                Button("Restore Defaults") {
                    reminderInterval = 45
                    dailyWaterGoal = 8
                }
                .buttonStyle(.borderless)
            }
        }
        .padding(16)
    }
}

// MARK: - General Settings Tab

private struct GeneralSettingsTab: View {
    @AppStorage("allPaused") private var allPaused: Bool = false
    @Environment(PomodoroService.self) private var pomodoroService
    @Environment(HydrationService.self) private var hydrationService

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Toggle("Pause All Reminders", isOn: $allPaused)
                .onChange(of: allPaused) { _, newValue in
                    if newValue {
                        pomodoroService.pauseAll()
                        hydrationService.stopReminders()
                    } else {
                        pomodoroService.resumeAll()
                        hydrationService.startReminders()
                    }
                }

            Text("Stops all timers and suppresses notifications")
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer()

            HStack {
                Spacer()
                Button("Restore Defaults") {
                    if allPaused {
                        allPaused = false
                        pomodoroService.resumeAll()
                        hydrationService.startReminders()
                    }
                }
                .buttonStyle(.borderless)
            }
        }
        .padding(16)
    }
}

// MARK: - Slider Row Helper

private func sliderRow(label: String, value: Binding<Int>, range: ClosedRange<Int>, format: String) -> some View {
    VStack(alignment: .leading, spacing: 4) {
        HStack {
            Text(label)
                .font(.body)
            Spacer()
            Text(String(format: format, value.wrappedValue))
                .font(.body)
                .fontWeight(.semibold)
        }
        Slider(
            value: Binding<Double>(
                get: { Double(value.wrappedValue) },
                set: { value.wrappedValue = Int($0) }
            ),
            in: Double(range.lowerBound)...Double(range.upperBound),
            step: 1
        )
    }
}
