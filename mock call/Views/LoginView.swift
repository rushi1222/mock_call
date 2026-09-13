//
//  LoginView.swift
//  mock call
//

import SwiftUI

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
                Text("Any username and password works — this is a local prototype.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                TextField("Username", text: $username)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.never)
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

                Spacer()
            }
            .padding()
        }
    }
}
