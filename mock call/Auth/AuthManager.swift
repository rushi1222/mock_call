//
//  AuthManager.swift
//  mock call
//
//  Mock login: any credentials are accepted, a fake JWT-shaped token is
//  stored in Keychain. Phase 4 swaps AppConfig.apiClient to LiveAPIClient
//  and this class needs no changes.
//

import Foundation

@MainActor
@Observable
final class AuthManager {
    private(set) var isLoggedIn: Bool
    private(set) var isLoggingIn = false
    var errorMessage: String?

    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol = AppConfig.apiClient) {
        self.apiClient = apiClient
        self.isLoggedIn = KeychainHelper.loadToken() != nil
    }

    func login(username: String, password: String) async {
        isLoggingIn = true
        errorMessage = nil
        defer { isLoggingIn = false }
        do {
            let response = try await apiClient.login(username: username, password: password)
            KeychainHelper.save(token: response.token)
            isLoggedIn = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func logout() {
        KeychainHelper.deleteToken()
        isLoggedIn = false
    }
}
