//
//  HydrationView.swift
//  PomoHydro
//
//  Created by Peter van Dijk on 30/03/2026.
//

import SwiftUI

struct HydrationView: View {
    @Environment(HydrationService.self) private var hydrationService

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Section label
            Text("Hydration")
                .font(.caption)
                .foregroundStyle(.secondary)

            // Glass count + unit
            VStack(alignment: .leading, spacing: 2) {
                Text("\(hydrationService.glassesConsumed) / \(hydrationService.dailyWaterGoal)")
                    .font(.title3)
                    .fontWeight(.semibold)

                Text("glasses · \(hydrationService.formattedMl) mL")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(hydrationService.glassesConsumed) of \(hydrationService.dailyWaterGoal) glasses consumed, \(hydrationService.totalMl) milliliters")

            // Progress bar with percentage
            HStack(spacing: 8) {
                HydrationProgressBar(progress: hydrationService.progress)
                    .accessibilityLabel("Hydration progress: \(Int(hydrationService.progress * 100)) percent")

                Text(hydrationService.goalReached ? "Goal reached!" : "\(Int(hydrationService.progress * 100))%")
                    .font(.caption)
                    .foregroundStyle(hydrationService.goalReached ? .cyan : .secondary)
            }

            Spacer().frame(height: 4)

            // Log button + size picker row
            HStack {
                @Bindable var service = hydrationService

                Button {
                    hydrationService.logGlass()
                } label: {
                    Label("Log Glass", systemImage: "drop.fill")
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.regular)
                .accessibilityLabel("Log glass of water, \(hydrationService.selectedSize.rawValue) milliliters")

                Spacer()

                Picker("Size", selection: $service.selectedSize) {
                    ForEach(GlassSize.allCases, id: \.self) { size in
                        Text(size.label).tag(size)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 120)
                .accessibilityLabel("Glass size")
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}
