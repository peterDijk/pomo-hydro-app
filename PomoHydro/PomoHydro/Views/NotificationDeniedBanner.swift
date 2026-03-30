//
//  NotificationDeniedBanner.swift
//  PomoHydro
//
//  Created by Peter van Dijk on 30/03/2026.
//

import SwiftUI

struct NotificationDeniedBanner: View {
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)
                .font(.system(size: 12))
                .accessibilityLabel("Warning")

            VStack(alignment: .leading, spacing: 2) {
                Text("Notifications are off.")
                    .font(.callout)
                    .fontWeight(.semibold)

                Button("Enable in System Settings") {
                    if let url = URL(string: "x-apple.systempreferences:com.apple.Notifications-Settings") {
                        NSWorkspace.shared.open(url)
                    }
                }
                .font(.callout)
                .buttonStyle(.borderless)
                .accessibilityHint("Opens macOS System Settings to the Notifications pane")
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }
}
