//
//  DisclosureView.swift
//  mock call
//
//  One-time first-launch disclosure required by the compliance note in
//  the build plan.
//

import SwiftUI

struct DisclosureView: View {
    @Binding var hasSeenDisclosure: Bool

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "phone.badge.checkmark")
                .font(.system(size: 48))
                .foregroundStyle(.tint)
            Text("Before you start")
                .font(.title2.bold())
            Text("Mock Call simulates incoming calls on this device. No calls are made or received.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            Spacer()
            Button("Got it") {
                hasSeenDisclosure = true
            }
            .buttonStyle(.borderedProminent)
            .padding(.bottom)
        }
        .padding()
    }
}
