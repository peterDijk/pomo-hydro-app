//
//  PomodoroView.swift
//  PomoHydro
//
//  Created by Peter van Dijk on 30/03/2026.
//

import SwiftUI

struct PomodoroView: View {
    @Environment(PomodoroService.self) private var pomodoroService

    var body: some View {
        VStack(spacing: 0) {
            switch pomodoroService.state {
            case .idle:
                idleView
            case .working, .shortBreak, .longBreak:
                activeTimerView
            case .autoStartCountdown:
                autoStartView
            }
        }
        .padding(16)
    }

    // MARK: - Idle State

    private var idleView: some View {
        VStack(spacing: 16) {
            Spacer()
            Button("Start Focus") {
                pomodoroService.start()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .accessibilityLabel("Start Focus, \(pomodoroService.workDuration) minute work session")

            Text("\(pomodoroService.workDuration) min work session")
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
        }
    }

    // MARK: - Active Timer State

    private var activeTimerView: some View {
        VStack(spacing: 8) {
            // Phase label
            Text(phaseLabel)
                .font(.caption)
                .foregroundStyle(.secondary)

            // Ring with countdown
            ZStack {
                TimerRingView(
                    progress: pomodoroService.progress,
                    strokeColor: ringColor
                )
                Text(pomodoroService.formattedTime)
                    .font(.system(size: 40, weight: .light, design: .rounded))
                    .monospacedDigit()
                    .accessibilityLabel("Timer: \(pomodoroService.secondsRemaining / 60) minutes \(pomodoroService.secondsRemaining % 60) seconds remaining")
            }

            // Session count
            Text("Session \(pomodoroService.sessionsCompleted + (pomodoroService.state == .working ? 1 : 0)) of \(pomodoroService.sessionsBeforeLongBreak)")
                .font(.footnote)
                .foregroundStyle(.secondary)

            Spacer().frame(height: 16)

            // Controls
            controlsView
        }
    }

    // MARK: - Auto-Start Countdown State

    private var autoStartView: some View {
        VStack(spacing: 8) {
            Text(autoStartLabel)
                .font(.caption)
                .foregroundStyle(.secondary)

            ZStack {
                TimerRingView(progress: 1.0, strokeColor: autoStartRingColor)
                Text("\(pomodoroService.autoStartSecondsRemaining)")
                    .font(.system(size: 40, weight: .light, design: .rounded))
            }

            Spacer().frame(height: 16)

            Button("Start Now") { pomodoroService.skipAutoStart() }
                .buttonStyle(.bordered)
        }
    }

    // MARK: - Controls

    @ViewBuilder
    private var controlsView: some View {
        HStack(spacing: 12) {
            if pomodoroService.state == .working {
                if pomodoroService.isPaused {
                    Button("Resume") { pomodoroService.resume() }
                        .buttonStyle(.borderedProminent)
                        .accessibilityLabel("Resume timer")
                } else {
                    Button("Pause") { pomodoroService.pause() }
                        .buttonStyle(.bordered)
                        .accessibilityLabel("Pause timer")
                }
                Button("Stop") { pomodoroService.stop() }
                    .buttonStyle(.bordered)
                    .foregroundStyle(.secondary)
                    .accessibilityLabel("Stop timer")
            } else if pomodoroService.state == .shortBreak || pomodoroService.state == .longBreak {
                Button("Skip") { pomodoroService.skip() }
                    .buttonStyle(.bordered)
                    .accessibilityLabel("Skip break")
            }
        }
    }

    // MARK: - Computed Properties

    private var ringColor: Color {
        switch pomodoroService.state {
        case .working: return .blue
        case .shortBreak, .longBreak: return .green
        default: return .secondary
        }
    }

    private var phaseLabel: String {
        switch pomodoroService.state {
        case .idle: return ""
        case .working: return "Work Session"
        case .shortBreak: return "Short Break"
        case .longBreak: return "Long Break"
        case .autoStartCountdown: return ""
        }
    }

    private var autoStartLabel: String {
        if let pending = pomodoroService.pendingAutoStartStateName {
            return pending == "working" ? "Work starting in..." : "Break starting in..."
        }
        return "Starting in..."
    }

    private var autoStartRingColor: Color {
        if let pending = pomodoroService.pendingAutoStartStateName {
            return pending == "working" ? .blue : .green
        }
        return .green
    }
}
