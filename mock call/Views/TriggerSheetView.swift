//
//  TriggerSheetView.swift
//  mock call
//
//  Delay is foreground-only in v1 (a DispatchQueue timer) — reliable
//  background/zero-tap firing needs BGTaskScheduler + widgets/Shortcuts,
//  which is Phase 2 in the build plan.
//

import SwiftUI

struct TriggerSheetView: View {
    let preset: CallerPreset

    @Environment(\.dismiss) private var dismiss
    @Environment(CallManager.self) private var callManager
    @AppStorage("defaultDurationSeconds") private var storedDefaultDuration = 32

    @State private var delayMinutes = 0
    @State private var useCustomDuration = false
    @State private var customDuration = 32

    var body: some View {
        NavigationStack {
            Form {
                Section("When") {
                    Picker("Delay", selection: $delayMinutes) {
                        Text("Now").tag(0)
                        ForEach([1, 2, 5, 10, 15], id: \.self) { minutes in
                            Text("In \(minutes) min").tag(minutes)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Duration") {
                    Toggle("Custom duration", isOn: $useCustomDuration)
                    if useCustomDuration {
                        Stepper("\(customDuration) seconds", value: $customDuration, in: 30...300, step: 5)
                    } else {
                        Text("30–35 seconds (randomized)")
                            .foregroundStyle(.secondary)
                    }
                }

                if delayMinutes > 0 {
                    Text("This only fires while Mock Call stays open in the foreground — background scheduling is coming in a later update.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Call from \(preset.name)")
            .onAppear { customDuration = storedDefaultDuration }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(delayMinutes == 0 ? "Call Now" : "Schedule") {
                        scheduleCall()
                    }
                }
            }
        }
    }

    private func scheduleCall() {
        let duration = useCustomDuration ? customDuration : Int.random(in: 30...35)
        let delaySeconds = Double(delayMinutes * 60)
        let caller = CallerInfo(name: preset.name, symbolName: preset.symbolName, tintHex: preset.tintHex)
        print("[trace] scheduleCall tapped: caller=\(caller.name) duration=\(duration) delay=\(delaySeconds)s")
        dismiss()
        DispatchQueue.main.asyncAfter(deadline: .now() + delaySeconds) {
            print("[trace] asyncAfter fired, calling startFakeIncomingCall")
            callManager.startFakeIncomingCall(caller: caller, durationSeconds: duration)
        }
    }
}
