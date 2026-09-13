//
//  LoginView.swift
//  mock call
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @Environment(AuthManager.self) private var auth
    @State private var username = ""
    @State private var password = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Spacer()
                Image(systemName: "phone.circle.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(.tint)
                Text("Mock Call")
                    .font(.largeTitle.bold())

                if AppConfig.useFirebaseAuth {
                    Text("Sign in with email, Google, or Apple.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                } else {
                    Text("Any username and password works — this is a local prototype.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                TextField(AppConfig.useFirebaseAuth ? "Email" : "Username", text: $username)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.never)
                    .keyboardType(AppConfig.useFirebaseAuth ? .emailAddress : .default)
                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)

                if let error = auth.errorMessage {
                    Text(error).font(.footnote).foregroundStyle(.red)
                }

                Button {
                    Task { await auth.login(username: username, password: password) }
                } label: {
                    if auth.isLoggingIn {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Log In").frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(username.isEmpty || password.isEmpty || auth.isLoggingIn)

                if AppConfig.useFirebaseAuth {
                    HStack {
                        VStack { Divider() }
                        Text("or").font(.caption).foregroundStyle(.secondary)
                        VStack { Divider() }
                    }

                    Button {
                        Task { await auth.signInWithGoogle() }
                    } label: {
                        Label("Continue with Google", systemImage: "g.circle.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .disabled(auth.isLoggingIn)

                    SignInWithAppleButton(.signIn) { request in
                        auth.prepareAppleSignInRequest(request)
                    } onCompletion: { result in
                        Task { await auth.handleAppleSignInCompletion(result) }
                    }
                    .signInWithAppleButtonStyle(.black)
                    .frame(height: 44)
                    .disabled(auth.isLoggingIn)
                }

                Spacer()
            }
            .padding()
        }
    }
}
