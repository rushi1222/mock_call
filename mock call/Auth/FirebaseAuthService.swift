//
//  FirebaseAuthService.swift
//  mock call
//
//  Thin wrapper around FirebaseAuth + GoogleSignIn + Sign in with Apple.
//  Firebase persists the signed-in session itself (Keychain-backed under
//  the hood), so AuthManager reads state from Auth.auth().currentUser
//  instead of the old custom KeychainHelper token.
//

import Foundation
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import AuthenticationServices
import CryptoKit
import UIKit

enum FirebaseAuthService {
    static func currentUser() -> FirebaseAuth.User? {
        Auth.auth().currentUser
    }

    /// Signs in with email/password, creating the account on first use —
    /// mirrors the old mock's "any credentials work" UX for a fresh app.
    /// Recent Firebase projects return the generic .invalidCredential for
    /// both "wrong password" and "no such user" (to avoid leaking which),
    /// so a failed sign-in always falls through to account creation; if
    /// that then fails with .emailAlreadyInUse, the password really was
    /// wrong and that's the error worth surfacing.
    static func signInWithEmail(email: String, password: String) async throws {
        do {
            try await Auth.auth().signIn(withEmail: email, password: password)
        } catch {
            do {
                try await Auth.auth().createUser(withEmail: email, password: password)
            } catch let createError as NSError where createError.code == AuthErrorCode.emailAlreadyInUse.rawValue {
                throw error
            }
        }
    }

    @MainActor
    static func signInWithGoogle() async throws {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw AuthServiceError.missingGoogleClientID
        }
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)

        guard let rootViewController = UIApplication.shared.connectedScenes
            .compactMap({ ($0 as? UIWindowScene)?.keyWindow })
            .first?.rootViewController
        else {
            throw AuthServiceError.noPresentingViewController
        }

        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
        guard let idToken = result.user.idToken?.tokenString else {
            throw AuthServiceError.missingGoogleToken
        }
        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: result.user.accessToken.tokenString
        )
        try await Auth.auth().signIn(with: credential)
    }

    /// Generates a random nonce for the Apple Sign-In request, hashed with
    /// SHA256 per Apple/Firebase's replay-protection requirement.
    static func randomNonce(length: Int = 32) -> String {
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remaining = length
        while remaining > 0 {
            var random: UInt8 = 0
            _ = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
            if random < charset.count {
                result.append(charset[Int(random)])
                remaining -= 1
            }
        }
        return result
    }

    static func sha256(_ input: String) -> String {
        SHA256.hash(data: Data(input.utf8)).map { String(format: "%02x", $0) }.joined()
    }

    static func signInWithApple(authorization: ASAuthorization, rawNonce: String) async throws {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let tokenData = credential.identityToken,
              let idTokenString = String(data: tokenData, encoding: .utf8)
        else {
            throw AuthServiceError.missingAppleToken
        }
        let firebaseCredential = OAuthProvider.appleCredential(
            withIDToken: idTokenString,
            rawNonce: rawNonce,
            fullName: credential.fullName
        )
        try await Auth.auth().signIn(with: firebaseCredential)
    }

    static func signOut() throws {
        try Auth.auth().signOut()
        GIDSignIn.sharedInstance.signOut()
    }
}

enum AuthServiceError: LocalizedError {
    case noPresentingViewController
    case missingGoogleToken
    case missingGoogleClientID
    case missingAppleToken

    var errorDescription: String? {
        switch self {
        case .noPresentingViewController: "Couldn't find a screen to present sign-in from."
        case .missingGoogleToken: "Google didn't return a valid sign-in token."
        case .missingGoogleClientID: "Firebase config is missing a Google client ID."
        case .missingAppleToken: "Apple didn't return a valid sign-in token."
        }
    }
}
