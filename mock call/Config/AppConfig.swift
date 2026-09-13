//
//  AppConfig.swift
//  mock call
//
//  Central place that decides whether the app talks to mock or live
//  services. iOS has no native .env; the long-term plan is per-scheme
//  .xcconfig files (Config-Mock / Config-Staging / Config-Prod) feeding
//  Info.plist keys read here. Wiring those up requires adding new
//  build configurations and schemes in Xcode's UI (Project > Info >
//  Configurations, and Product > Scheme > New Scheme) — safer to do by
//  hand there than by scripting the .xcodeproj blindly. Until that's
//  done, this single switch is the source of truth, so nothing else
//  in the app ever branches on mock-vs-live itself.
//

import Foundation

enum AppConfig {
    /// Flip to false once LiveAPIClient is implemented and reachable.
    static let useMockAPIs = true

    /// Firebase Auth (email/password, Google, Apple) replaces the mock
    /// username/password login. Independent of useMockAPIs since the rest
    /// of the API surface (ringtone catalog, etc.) has no backend yet.
    static let useFirebaseAuth = true

    /// Placeholder — replace when useMockAPIs is false.
    static let apiBaseURL = URL(string: "https://api.example.com")!

    /// Real CallKit incoming-call reporting (CXProvider) requires a paid
    /// Apple Developer Program account — on a free Personal Team account
    /// it gets silently rejected (the provider resets immediately, no
    /// error surfaces). Until that account exists, calls go through a
    /// custom full-screen "ringing" UI + a manually played, silent-mode-
    /// overriding ringtone instead of the real system call screen. Flip
    /// this to true once you've enrolled — CallManager already has the
    /// CXProvider code path ready to go.
    static let useRealCallKit = false

    static var apiClient: APIClientProtocol {
        useMockAPIs ? MockAPIClient() : LiveAPIClient(baseURL: apiBaseURL)
    }
}
