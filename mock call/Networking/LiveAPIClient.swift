//
//  LiveAPIClient.swift
//  mock call
//
//  Real backend implementation — fill in during Phase 4. Every method
//  currently throws so a misconfigured build fails loudly instead of
//  silently behaving like the mock.
//

import Foundation

struct LiveAPIClient: APIClientProtocol {
    let baseURL: URL

    func login(username: String, password: String) async throws -> AuthTokenResponse {
        throw LiveAPIError.notImplemented
    }

    func refreshToken(_ token: String) async throws -> AuthTokenResponse {
        throw LiveAPIError.notImplemented
    }

    func logout(token: String) async throws {
        throw LiveAPIError.notImplemented
    }

    func fetchRingtoneCatalog() async throws -> [RingtoneCatalogItem] {
        throw LiveAPIError.notImplemented
    }
}

enum LiveAPIError: LocalizedError {
    case notImplemented

    var errorDescription: String? {
        "The live backend isn't wired up yet. Switch AppConfig.useMockAPIs back to true, or implement this endpoint."
    }
}
