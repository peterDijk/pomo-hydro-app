//
//  MenuBarView.swift
//  PomoHydro
//
//  Created by Peter van Dijk on 30/03/2026.
//

import SwiftUI
import UserNotifications

struct MenuBarView: View {
    @Environment(NotificationService.self) private var notificationService
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        VStack(spacing: 0) {
            // Main content area switches based on notification auth status
            switch notificationService.authorizationStatus {
            case .notDetermined:
                PermissionPromptView()
            case .denied:
                NotificationDeniedBanner()
                PlaceholderContentView()
            default:
                PlaceholderContentView()
            }

            Divider()

            // Footer controls
            HStack {
                Button {
                    // Settings — Phase 4
                } label: {
                    Label("Settings…", systemImage: "gear")
                        .font(.callout)
                }
                .buttonStyle(.borderless)

                Spacer()

                Button("Quit PomoHydro") {
                    NSApplication.shared.terminate(nil)
                }
                .font(.callout)
                .foregroundStyle(.secondary)
                .buttonStyle(.borderless)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .frame(width: 320)
        .task {
            await notificationService.checkStatus()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                Task { await notificationService.checkStatus() }
            }
        }
    }
}
