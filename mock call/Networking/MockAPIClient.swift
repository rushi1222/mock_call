//
//  MockAPIClient.swift
//  mock call
//
//  Answers every call locally with fake-but-plausible data. Every build
//  runs against this until Phase 4 introduces a real backend.
//

import Foundation

struct MockAPIClient: APIClientProtocol {
    func login(username: String, password: String) async throws -> AuthTokenResponse {
        try await Task.sleep(nanoseconds: 300_000_000)
        let fakeToken = "mock.\(UUID().uuidString).token"
        return AuthTokenResponse(token: fakeToken, expiresAt: Date().addingTimeInterval(60 * 60 * 24 * 30))
    }

    func refreshToken(_ token: String) async throws -> AuthTokenResponse {
        try await Task.sleep(nanoseconds: 150_000_000)
        return AuthTokenResponse(token: token, expiresAt: Date().addingTimeInterval(60 * 60 * 24 * 30))
    }

    func logout(token: String) async throws {
        try await Task.sleep(nanoseconds: 100_000_000)
    }

    func fetchRingtoneCatalog() async throws -> [RingtoneCatalogItem] {
        try await Task.sleep(nanoseconds: 150_000_000)
        return [
            RingtoneCatalogItem(id: "default", displayName: "Default", fileName: "default_ringtone"),
            RingtoneCatalogItem(id: "classic", displayName: "Classic Phone", fileName: "classic_ringtone"),
            RingtoneCatalogItem(id: "chime", displayName: "Chime", fileName: "chime_ringtone")
        ]
    }
}
