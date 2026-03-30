//
//  PlaceholderContentView.swift
//  PomoHydro
//
//  Created by Peter van Dijk on 30/03/2026.
//

import SwiftUI

struct PlaceholderContentView: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("PomoHydro")
                .font(.title3)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("Your timers will appear here.\nMore features coming soon.")
                .font(.body)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .frame(maxHeight: .infinity, alignment: .top)
    }
}
