//
//  ContentView.swift
//  mock call
//
//  App root: routes between Login and the main tab flow, shows the
//  one-time compliance disclosure, and presents the ringing/in-call
//  screens full-screen based on CallManager's phase.
//
//  Ringing UI: RingingView (custom, fallback mode) covers the phone's
//  own system call screen when AppConfig.useRealCallKit is false — real
//  CallKit's ringing screen is drawn by the system itself, so we never
//  show our own on top of it.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(AuthManager.self) private var auth
    @Environment(CallManager.self) private var callManager
    @Environment(\.modelContext) private var modelContext
    @AppStorage("hasSeenDisclosure") private var hasSeenDisclosure = false

    var body: some View {
        Group {
            if auth.isLoggedIn {
                MainTabView()
            } else {
                LoginView()
            }
        }
        .sheet(isPresented: disclosureBinding) {
            DisclosureView(hasSeenDisclosure: $hasSeenDisclosure)
                .interactiveDismissDisabled()
        }
        .fullScreenCover(isPresented: ringingBinding) {
            RingingView()
        }
        .fullScreenCover(isPresented: inCallBinding) {
            InCallView()
        }
        .alert(
            "Couldn't start call",
            isPresented: errorAlertBinding,
            actions: {
                Button("OK") { callManager.clearError() }
            },
            message: {
                Text(callManager.lastErrorMessage ?? "Unknown error")
            }
        )
        .onChange(of: callManager.phase) { oldPhase, newPhase in
            guard case .ended = newPhase else { return }
            switch oldPhase {
            case .active(let caller, let total):
                modelContext.insert(CallHistoryEntry(
                    callerName: caller.name,
                    durationSeconds: total - callManager.remainingSeconds,
                    wasAnswered: true
                ))
            case .ringing(let caller):
                modelContext.insert(CallHistoryEntry(
                    callerName: caller.name,
                    durationSeconds: 0,
                    wasAnswered: false
                ))
            default:
                break
            }
            callManager.resetToIdle()
        }
    }

    private var disclosureBinding: Binding<Bool> {
        Binding(get: { !hasSeenDisclosure }, set: { hasSeenDisclosure = !$0 })
    }

    private var errorAlertBinding: Binding<Bool> {
        Binding(get: { callManager.lastErrorMessage != nil }, set: { _ in callManager.clearError() })
    }

    private var ringingBinding: Binding<Bool> {
        Binding(
            get: {
                guard !AppConfig.useRealCallKit else { return false }
                if case .ringing = callManager.phase { return true }
                return false
            },
            set: { _ in }
        )
    }

    private var inCallBinding: Binding<Bool> {
        Binding(
            get: {
                if case .active = callManager.phase { return true }
                return false
            },
            set: { _ in }
        )
    }
}

#Preview {
    ContentView()
        .environment(AuthManager())
        .environment(CallManager())
        .modelContainer(for: [CallerPreset.self, CallHistoryEntry.self], inMemory: true)
}
