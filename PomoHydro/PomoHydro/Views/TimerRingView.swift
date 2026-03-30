//
//  TimerRingView.swift
//  PomoHydro
//
//  Created by Peter van Dijk on 30/03/2026.
//

import SwiftUI

struct TimerRingView: View {
    let progress: Double   // 0.0 (empty) to 1.0 (full)
    let strokeColor: Color
    let lineWidth: CGFloat = 10
    let size: CGFloat = 160

    var body: some View {
        ZStack {
            // Background track
            Circle()
                .stroke(Color.secondary.opacity(0.2), lineWidth: lineWidth)

            // Progress arc
            Circle()
                .trim(from: 0, to: CGFloat(progress))
                .stroke(strokeColor, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: progress)
        }
        .frame(width: size, height: size)
    }
}
