//
//  mock_callApp.swift
//  mock call
//

import SwiftUI
import SwiftData
import FirebaseCore
import GoogleSignIn

@main
struct mock_callApp: App {
    @State private var authManager: AuthManager
    @State private var callManager = CallManager()

    init() {
        if AppConfig.useFirebaseAuth {
            FirebaseApp.configure()
        }
        _authManager = State(initialValue: AuthManager())
    }

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
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
