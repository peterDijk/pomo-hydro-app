//
//  PermissionPromptView.swift
//  PomoHydro
//
//  Created by Peter van Dijk on 30/03/2026.
//

import SwiftUI

struct PermissionPromptView: View {
    @Environment(NotificationService.self) private var notificationService

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 16) {
                Image(systemName: "bell.badge")
                    .font(.system(size: 48))
                    .foregroundStyle(.secondary)
                    .accessibilityLabel("Notification bell")

                Text("Stay on Track")
                    .font(.title3)
                    .fontWeight(.semibold)
            }

            Spacer().frame(height: 8)

            Text("PomoHydro needs notifications to remind you to rest and stay hydrated.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)

            Spacer().frame(height: 24)

            Button("Enable Notifications") {
                Task {
                    await notificationService.requestPermission()
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

            Spacer().frame(height: 8)

            Text("You can change this later in System Settings")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Spacer()
        }
        .padding(16)
        .frame(maxHeight: .infinity)
    }
}
