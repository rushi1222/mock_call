//
//  SettingsView.swift
//  mock call
//

import SwiftUI

struct SettingsView: View {
    @Environment(AuthManager.self) private var auth
    @AppStorage("defaultDurationSeconds") private var defaultDuration = 32

    var body: some View {
        NavigationStack {
            Form {
                Section("Call Defaults") {
                    Stepper("Default duration: \(defaultDuration)s", value: $defaultDuration, in: 30...300, step: 5)
                    LabeledContent("Audio") {
                        Text("Muted").foregroundStyle(.secondary)
                    }
                }
                Section {
                    Text("Voice clips during calls are a planned premium feature.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                Section {
                    Button("Log Out", role: .destructive) {
                        auth.logout()
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}
