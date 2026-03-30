//
//  HydrationService.swift
//  PomoHydro
//
//  Created by Peter van Dijk on 30/03/2026.
//

import Foundation
import Observation
import SwiftUI

enum GlassSize: Int, CaseIterable {
    case small = 150
    case medium = 250
    case large = 500

    var label: String {
        switch self {
        case .small: "S"
        case .medium: "M"
        case .large: "L"
        }
    }

    var mlLabel: String {
        "\(rawValue) mL"
    }
}

@Observable
@MainActor
final class HydrationService {
    // MARK: - Published State (drives UI)
    private(set) var glassesConsumed: Int = 0
    private(set) var totalMl: Int = 0
    private(set) var currentGoal: Int = 8
    var selectedSize: GlassSize = .medium

    // MARK: - Settings (@ObservationIgnored required for @AppStorage in @Observable)
    @ObservationIgnored @AppStorage("hydrationReminderInterval") var reminderInterval: Int = 45
    @ObservationIgnored @AppStorage("dailyWaterGoal") var dailyWaterGoal: Int = 8
    @ObservationIgnored @AppStorage("allPaused") var allPaused: Bool = false

    // MARK: - Persistence
    @ObservationIgnored @AppStorage("savedGlassesConsumed") private var savedGlassesConsumed: Int = 0
    @ObservationIgnored @AppStorage("savedTotalMl") private var savedTotalMl: Int = 0
    @ObservationIgnored @AppStorage("savedGlassesDate") private var savedGlassesDateString: String = ""
    @ObservationIgnored @AppStorage("savedHydrationEndTime") private var savedHydrationEndTimeInterval: Double = 0

    // MARK: - Internal Timer State
    private var reminderEndDate: Date?
    private var reminderTimer: Timer?

    // MARK: - Notification Service Dependency
    private var notificationService: NotificationService?

    func setNotificationService(_ service: NotificationService) {
        self.notificationService = service
    }

    // MARK: - Computed Properties

    var progress: Double {
        guard currentGoal > 0 else { return 0 }
        return min(1.0, Double(glassesConsumed) / Double(currentGoal))
    }

    var goalReached: Bool {
        glassesConsumed >= currentGoal
    }

    var formattedMl: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter.string(from: NSNumber(value: totalMl)) ?? "\(totalMl)"
    }

    var isReminderActive: Bool {
        reminderEndDate != nil
    }

    // MARK: - Init / Restore

    init() {
        restoreState()
    }

    private func restoreState() {
        // Restore glass count if same day (CROSS-02)
        let todayString = dateString(for: Date())
        currentGoal = dailyWaterGoal
        if savedGlassesDateString == todayString {
            glassesConsumed = savedGlassesConsumed
            totalMl = savedTotalMl
        } else {
            glassesConsumed = 0
            totalMl = 0
            savedGlassesConsumed = 0
            savedTotalMl = 0
            savedGlassesDateString = todayString
        }

        // Restore active reminder timer if end time is in the future
        if savedHydrationEndTimeInterval > Date().timeIntervalSince1970 {
            let endTime = Date(timeIntervalSince1970: savedHydrationEndTimeInterval)
            reminderEndDate = endTime
            startDisplayTimer()
        }
    }

    // MARK: - Public Actions

    func logGlass(size: GlassSize? = nil) {
        let s = size ?? selectedSize
        glassesConsumed += 1
        totalMl += s.rawValue
        persistState()
        // User just drank — reset countdown to next reminder
        startReminderTimer()
    }

    func startReminders() {
        guard !allPaused else { return }
        startReminderTimer()
    }

    func stopReminders() {
        reminderTimer?.invalidate()
        reminderTimer = nil
        reminderEndDate = nil
        persistState()
    }

    func restartWithNewInterval() {
        guard !allPaused else { return }
        startReminderTimer()
    }

    func refreshGoal() {
        currentGoal = dailyWaterGoal
    }

    /// Check if hydration reminder is due within the given time window (for merge window D-06)
    func isHydrationDue(within seconds: TimeInterval) -> Bool {
        guard let end = reminderEndDate else { return false }
        return end.timeIntervalSinceNow <= seconds
    }

    // MARK: - Reminder Timer

    private func startReminderTimer() {
        reminderTimer?.invalidate()
        reminderEndDate = Date().addingTimeInterval(TimeInterval(reminderInterval * 60))
        persistState()
        startDisplayTimer()
    }

    private func startDisplayTimer() {
        reminderTimer?.invalidate()
        reminderTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tick()
            }
        }
    }

    private func tick() {
        checkMidnightReset()
        guard !allPaused else { return }

        guard let reminderEndDate else { return }
        if Date() >= reminderEndDate {
            // Fire notification and restart timer for next cycle
            Task {
                await notificationService?.sendHydrationReminder()
            }
            startReminderTimer()
        }
    }

    // MARK: - Midnight Reset (CROSS-02)

    private func checkMidnightReset() {
        let todayString = dateString(for: Date())
        if savedGlassesDateString != todayString {
            glassesConsumed = 0
            totalMl = 0
            savedGlassesConsumed = 0
            savedTotalMl = 0
            savedGlassesDateString = todayString
        }
    }

    // MARK: - Persistence

    private func persistState() {
        savedGlassesConsumed = glassesConsumed
        savedTotalMl = totalMl
        savedGlassesDateString = dateString(for: Date())
        savedHydrationEndTimeInterval = reminderEndDate?.timeIntervalSince1970 ?? 0
    }

    // MARK: - Helpers

    private func dateString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
