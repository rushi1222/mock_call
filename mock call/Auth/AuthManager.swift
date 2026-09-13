//
//  AuthManager.swift
//  mock call
//
//  AppConfig.useFirebaseAuth switches between the original mock login
//  (any credentials accepted, fake token in Keychain) and real Firebase
//  Auth (email/password, Google, Apple). Firebase owns its own session
//  persistence, so isLoggedIn reads Auth.auth().currentUser in that mode.
//

import Foundation
import FirebaseAuth
import AuthenticationServices

@MainActor
@Observable
final class AuthManager {
    private(set) var isLoggedIn: Bool
    private(set) var isLoggingIn = false
    var errorMessage: String?

    private let apiClient: APIClientProtocol

    // AuthManager lives for the whole app lifetime (owned by the App
    // struct), so the listener never needs explicit teardown.
    init(apiClient: APIClientProtocol = AppConfig.apiClient) {
        self.apiClient = apiClient
        if AppConfig.useFirebaseAuth {
            self.isLoggedIn = FirebaseAuthService.currentUser() != nil
            Auth.auth().addStateDidChangeListener { [weak self] _, user in
                self?.isLoggedIn = user != nil
            }
        } else {
            self.isLoggedIn = KeychainHelper.loadToken() != nil
        }
    }

    func login(username: String, password: String) async {
        isLoggingIn = true
        errorMessage = nil
        defer { isLoggingIn = false }
        do {
            if AppConfig.useFirebaseAuth {
                try await FirebaseAuthService.signInWithEmail(email: username, password: password)
            } else {
                let response = try await apiClient.login(username: username, password: password)
                KeychainHelper.save(token: response.token)
                isLoggedIn = true
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func signInWithGoogle() async {
        isLoggingIn = true
        errorMessage = nil
        defer { isLoggingIn = false }
        do {
            try await FirebaseAuthService.signInWithGoogle()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Nonce used for the in-flight Apple Sign-In request, so the completion
    /// handler can verify the response against it.
    private(set) var appleSignInNonce: String?

    func prepareAppleSignInRequest(_ request: ASAuthorizationAppleIDRequest) {
        let nonce = FirebaseAuthService.randomNonce()
        appleSignInNonce = nonce
        request.requestedScopes = [.fullName, .email]
        request.nonce = FirebaseAuthService.sha256(nonce)
    }

    func handleAppleSignInCompletion(_ result: Result<ASAuthorization, Error>) async {
        errorMessage = nil
        guard let nonce = appleSignInNonce else { return }
        switch result {
        case .success(let authorization):
            isLoggingIn = true
            defer { isLoggingIn = false }
            do {
                try await FirebaseAuthService.signInWithApple(authorization: authorization, rawNonce: nonce)
            } catch {
                errorMessage = error.localizedDescription
            }
        case .failure(let error):
            if (error as? ASAuthorizationError)?.code != .canceled {
                errorMessage = error.localizedDescription
            }
        }
    }

    func logout() {
        if AppConfig.useFirebaseAuth {
            do {
                try FirebaseAuthService.signOut()
            } catch {
                errorMessage = error.localizedDescription
            }
        } else {
            KeychainHelper.deleteToken()
            isLoggedIn = false
        }
    }
}
