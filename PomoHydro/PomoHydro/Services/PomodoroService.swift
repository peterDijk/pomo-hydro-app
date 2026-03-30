//
//  PomodoroService.swift
//  PomoHydro
//
//  Created by Peter van Dijk on 30/03/2026.
//

import Foundation
import Observation
import SwiftUI

enum PomodoroState: String, Codable {
    case idle
    case working
    case shortBreak
    case longBreak
    case autoStartCountdown
}

@Observable
@MainActor
final class PomodoroService {
    // MARK: - Published State (drives UI)
    private(set) var state: PomodoroState = .idle
    private(set) var secondsRemaining: Int = 0
    private(set) var totalSeconds: Int = 0
    private(set) var sessionsCompleted: Int = 0
    private(set) var autoStartSecondsRemaining: Int = 5

    // MARK: - Settings (@ObservationIgnored required for @AppStorage in @Observable)
    @ObservationIgnored @AppStorage("workDuration") var workDuration: Int = 25
    @ObservationIgnored @AppStorage("shortBreakDuration") var shortBreakDuration: Int = 5
    @ObservationIgnored @AppStorage("longBreakDuration") var longBreakDuration: Int = 15
    @ObservationIgnored @AppStorage("sessionsBeforeLongBreak") var sessionsBeforeLongBreak: Int = 4
    @ObservationIgnored @AppStorage("autoStartBreak") var autoStartBreak: Bool = true
    @ObservationIgnored @AppStorage("autoStartWork") var autoStartWork: Bool = true
    @ObservationIgnored @AppStorage("allPaused") var allPaused: Bool = false
    @ObservationIgnored @AppStorage("eyeStrainInterval") var eyeStrainInterval: Int = 20

    // MARK: - Crash Recovery Persistence (CROSS-05)
    @ObservationIgnored @AppStorage("savedEndTime") private var savedEndTimeInterval: Double = 0
    @ObservationIgnored @AppStorage("savedState") private var savedStateRaw: String = "idle"
    @ObservationIgnored @AppStorage("savedTotalSeconds") private var savedTotalSeconds: Int = 0
    @ObservationIgnored @AppStorage("savedSessionsCompleted") private var savedSessionsCompleted: Int = 0
    @ObservationIgnored @AppStorage("savedSessionsDate") private var savedSessionsDateString: String = ""

    // MARK: - Notification Service Dependency
    private var notificationService: NotificationService?

    func setNotificationService(_ service: NotificationService) {
        self.notificationService = service
    }

    // MARK: - Hydration Service Dependency (CROSS-01)
    private var hydrationService: HydrationService?

    func setHydrationService(_ service: HydrationService) {
        self.hydrationService = service
    }

    // MARK: - Internal Timer State
    private var endDate: Date?
    private var displayTimer: Timer?
    private var autoStartTimer: Timer?
    private var activityToken: NSObjectProtocol?
    private var pendingAutoStartState: PomodoroState?

    // MARK: - Eye-Strain Sub-Timer (EYE-01, EYE-02)
    private var eyeStrainTimer: Timer?
    private var eyeStrainSuppressed: Bool = false

    // MARK: - Computed Properties

    var progress: Double {
        guard totalSeconds > 0 else { return 0 }
        return 1.0 - Double(secondsRemaining) / Double(totalSeconds)
    }

    var menuBarIcon: String {
        if allPaused { return "pause.circle" }
        switch state {
        case .idle, .autoStartCountdown: return "timer"
        case .working: return "timer.circle.fill"
        case .shortBreak, .longBreak: return "cup.and.saucer"
        }
    }

    var formattedTime: String {
        let minutes = secondsRemaining / 60
        let seconds = secondsRemaining % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    // MARK: - Init / Restore

    init() {
        restoreState()
    }

    private func restoreState() {
        // Restore session count if same day
        let todayString = dateString(for: Date())
        if savedSessionsDateString == todayString {
            sessionsCompleted = savedSessionsCompleted
        } else {
            sessionsCompleted = 0
            savedSessionsCompleted = 0
            savedSessionsDateString = todayString
        }

        // Restore active timer if end time is in the future
        guard let savedState = PomodoroState(rawValue: savedStateRaw),
              savedState != .idle,
              savedEndTimeInterval > Date().timeIntervalSince1970 else {
            state = .idle
            savedStateRaw = "idle"
            savedEndTimeInterval = 0
            return
        }

        let endTime = Date(timeIntervalSince1970: savedEndTimeInterval)
        let remaining = max(0, Int(ceil(endTime.timeIntervalSinceNow)))

        if remaining > 0 {
            state = savedState
            endDate = endTime
            totalSeconds = savedTotalSeconds > 0 ? savedTotalSeconds : remaining
            secondsRemaining = remaining
            beginAppNapPrevention()
            startDisplayTimer()
        }
    }

    // MARK: - Public Actions

    func start() {
        guard !allPaused else { return }
        state = .working
        totalSeconds = workDuration * 60
        secondsRemaining = totalSeconds
        endDate = Date().addingTimeInterval(TimeInterval(totalSeconds))
        beginAppNapPrevention()
        startEyeStrainTimer()
        persistState()
        startDisplayTimer()
    }

    func pause() {
        guard let endDate else { return }
        let remaining = max(0, Int(ceil(endDate.timeIntervalSinceNow)))
        displayTimer?.invalidate()
        displayTimer = nil
        secondsRemaining = remaining
        self.endDate = nil
        stopEyeStrainTimer()
        persistState()
    }

    func resume() {
        endDate = Date().addingTimeInterval(TimeInterval(secondsRemaining))
        startEyeStrainTimer()
        persistState()
        startDisplayTimer()
    }

    func stop() {
        displayTimer?.invalidate()
        displayTimer = nil
        autoStartTimer?.invalidate()
        autoStartTimer = nil
        pendingAutoStartState = nil
        stopEyeStrainTimer()
        state = .idle
        secondsRemaining = 0
        totalSeconds = 0
        endDate = nil
        endAppNapPrevention()
        persistState()
    }

    func skip() {
        completeCurrentPhase()
    }

    func pauseAll() {
        switch state {
        case .working, .shortBreak, .longBreak:
            pause()
        case .autoStartCountdown:
            autoStartTimer?.invalidate()
            autoStartTimer = nil
            pendingAutoStartState = nil
            state = .idle
        default:
            break
        }
        stopEyeStrainTimer()
        endAppNapPrevention()
    }

    func resumeAll() {
        state = .idle
        secondsRemaining = 0
        totalSeconds = 0
        endDate = nil
        persistState()
    }

    func recalculateEndDate(oldDuration: Int, newDuration: Int) {
        guard state == .working || state == .shortBreak || state == .longBreak,
              let currentEnd = endDate else { return }
        let delta = TimeInterval((newDuration - oldDuration) * 60)
        endDate = currentEnd.addingTimeInterval(delta)
        totalSeconds = newDuration * 60
        secondsRemaining = max(0, Int(ceil(endDate!.timeIntervalSinceNow)))
        persistState()
    }

    func skipAutoStart() {
        autoStartTimer?.invalidate()
        autoStartTimer = nil
        guard let nextState = pendingAutoStartState else {
            state = .idle
            persistState()
            return
        }
        pendingAutoStartState = nil
        transitionTo(nextState)
    }

    // MARK: - Display Timer

    private func startDisplayTimer() {
        displayTimer?.invalidate()
        displayTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tick()
            }
        }
    }

    private func tick() {
        // Midnight session reset (POMO-04)
        checkMidnightReset()

        guard let endDate else { return }
        let remaining = max(0, Int(ceil(endDate.timeIntervalSinceNow)))
        secondsRemaining = remaining

        if remaining <= 0 {
            completeCurrentPhase()
        }
    }

    // MARK: - Phase Transitions

    private func completeCurrentPhase() {
        displayTimer?.invalidate()
        displayTimer = nil

        switch state {
        case .working:
            sessionsCompleted += 1

            // CROSS-01: Check if hydration is due within 5-minute merge window (D-06)
            let hydrationDue = hydrationService?.isHydrationDue(within: 300) ?? false
            Task {
                if hydrationDue {
                    // Send combined notification instead of separate work-complete + hydration
                    await notificationService?.sendCombinedBreakNotification(includeEyeStrain: eyeStrainSuppressed)
                    // Reset hydration reminder since we just notified
                    hydrationService?.startReminders()
                } else {
                    await notificationService?.sendWorkCompleteNotification(includeEyeStrain: eyeStrainSuppressed)
                }
            }
            stopEyeStrainTimer()

            let nextBreakState: PomodoroState =
                (sessionsCompleted % sessionsBeforeLongBreak == 0)
                ? .longBreak : .shortBreak

            if autoStartBreak && !allPaused {
                startAutoStartCountdown(nextState: nextBreakState)
            } else {
                state = .idle
                endDate = nil
                endAppNapPrevention()
            }

        case .shortBreak, .longBreak:
            // Send break complete notification — next session starts on user OK
            let isLong = state == .longBreak
            Task {
                await notificationService?.sendBreakCompleteNotification(isLongBreak: isLong)
            }

            state = .idle
            endDate = nil
            endAppNapPrevention()

        default:
            break
        }

        persistState()
    }

    // MARK: - Auto-Start Countdown

    private func startAutoStartCountdown(nextState: PomodoroState) {
        state = .autoStartCountdown
        autoStartSecondsRemaining = 5
        pendingAutoStartState = nextState

        autoStartTimer?.invalidate()
        autoStartTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.autoStartTick()
            }
        }
    }

    private func autoStartTick() {
        autoStartSecondsRemaining -= 1
        if autoStartSecondsRemaining <= 0 {
            autoStartTimer?.invalidate()
            autoStartTimer = nil
            guard let nextState = pendingAutoStartState else { return }
            pendingAutoStartState = nil
            transitionTo(nextState)
        }
    }

    private func transitionTo(_ nextState: PomodoroState) {
        switch nextState {
        case .working:
            state = .working
            totalSeconds = workDuration * 60
            secondsRemaining = totalSeconds
            endDate = Date().addingTimeInterval(TimeInterval(totalSeconds))
            beginAppNapPrevention()
            startEyeStrainTimer()
            persistState()
            startDisplayTimer()

        case .shortBreak:
            state = .shortBreak
            totalSeconds = shortBreakDuration * 60
            secondsRemaining = totalSeconds
            endDate = Date().addingTimeInterval(TimeInterval(totalSeconds))
            persistState()
            startDisplayTimer()

        case .longBreak:
            state = .longBreak
            totalSeconds = longBreakDuration * 60
            secondsRemaining = totalSeconds
            endDate = Date().addingTimeInterval(TimeInterval(totalSeconds))
            persistState()
            startDisplayTimer()

        default:
            break
        }
    }

    // MARK: - Eye-Strain Sub-Timer (20-20-20 Rule)

    private func startEyeStrainTimer() {
        eyeStrainTimer?.invalidate()
        eyeStrainSuppressed = false
        // Fire at configured interval during work
        eyeStrainTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(eyeStrainInterval * 60), repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.handleEyeStrainTick()
            }
        }
    }

    private func stopEyeStrainTimer() {
        eyeStrainTimer?.invalidate()
        eyeStrainTimer = nil
    }

    private func handleEyeStrainTick() async {
        // D-04: If break is starting within 3 minutes, suppress and fold into break notification
        guard state == .working, let endDate else { return }
        let timeUntilBreak = endDate.timeIntervalSinceNow
        if timeUntilBreak <= 180 {
            eyeStrainSuppressed = true
            return
        }
        // Fire standalone eye-strain notification (EYE-01)
        await notificationService?.sendEyeStrainNotification()
    }

    // MARK: - App Nap Prevention (CROSS-04)

    private func beginAppNapPrevention() {
        guard activityToken == nil else { return }
        activityToken = ProcessInfo.processInfo.beginActivity(
            options: .userInitiatedAllowingIdleSystemSleep,
            reason: "PomoHydro timer is running"
        )
    }

    private func endAppNapPrevention() {
        if let token = activityToken {
            ProcessInfo.processInfo.endActivity(token)
            activityToken = nil
        }
    }

    // MARK: - Persistence (CROSS-05)

    private func persistState() {
        savedStateRaw = state.rawValue
        savedEndTimeInterval = endDate?.timeIntervalSince1970 ?? 0
        savedTotalSeconds = totalSeconds
        savedSessionsCompleted = sessionsCompleted
        savedSessionsDateString = dateString(for: Date())
    }

    // MARK: - Midnight Reset (POMO-04)

    private func checkMidnightReset() {
        let todayString = dateString(for: Date())
        if savedSessionsDateString != todayString {
            sessionsCompleted = 0
            savedSessionsCompleted = 0
            savedSessionsDateString = todayString
        }
    }

    // MARK: - Helpers

    private func dateString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    /// Whether the timer is currently paused (working state but no active countdown)
    var isPaused: Bool {
        state == .working && endDate == nil
    }

    /// Name of the pending auto-start state for UI label customization
    var pendingAutoStartStateName: String? {
        pendingAutoStartState?.rawValue
    }
}
