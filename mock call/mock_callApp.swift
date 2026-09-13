//
//  mock_callApp.swift
//  mock call
//

import SwiftUI
import SwiftData

@main
struct mock_callApp: App {
    @State private var authManager = AuthManager()
    @State private var callManager = CallManager()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([CallerPreset.self, CallHistoryEntry.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        return try! ModelContainer(for: schema, configurations: [configuration])
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(authManager)
                .environment(callManager)
        }
        .modelContainer(sharedModelContainer)
    }
}
