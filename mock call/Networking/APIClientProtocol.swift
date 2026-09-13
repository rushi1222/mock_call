//
//  APIClientProtocol.swift
//  mock call
//

import Foundation

struct AuthTokenResponse: Sendable {
    let token: String
    let expiresAt: Date
}

struct RingtoneCatalogItem: Identifiable, Sendable, Hashable {
    let id: String
    let displayName: String
    let fileName: String
}

/// One seam for every network-shaped call the app makes. MockAPIClient
/// answers locally; LiveAPIClient hits a real backend later. Call sites
/// never know which one they're talking to.
protocol APIClientProtocol: Sendable {
    func login(username: String, password: String) async throws -> AuthTokenResponse
    func refreshToken(_ token: String) async throws -> AuthTokenResponse
    func logout(token: String) async throws
    func fetchRingtoneCatalog() async throws -> [RingtoneCatalogItem]
}
