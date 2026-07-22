//
//  SignInView.swift
//  Mosaic
//
//  Created by Gahyeon Kim on 20/7/2026.
//

import SwiftUI

private struct AuthField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var isSecure = false
    var keyboardType: UIKeyboardType = .default

    @State private var isSecureVisible = false

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(.secondary)
                .frame(width: 20)

            SwiftUI.Group {
                if isSecure && !isSecureVisible {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                }
            }
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .keyboardType(keyboardType)

            if isSecure {
                Button {
                    isSecureVisible.toggle()
                } label: {
                    Image(systemName: isSecureVisible ? "eye.slash" : "eye")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(12)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

struct SignInView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showSignUp = false

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 4) {
                Image("LaunchLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 56, height: 56)

                Text("Mosaic")
                    .font(.largeTitle.bold())
            }
            .padding(.top, 24)

            VStack(spacing: 12) {
                AuthField(icon: "envelope", placeholder: "Email", text: $email, keyboardType: .emailAddress)
                AuthField(icon: "lock", placeholder: "Password", text: $password, isSecure: true)
            }

            if let error = authViewModel.errorMessage {
                Text(error)
                    .foregroundStyle(.red)
                    .font(.footnote)
            }

            VStack(spacing: 12) {
                Button {
                    Task { await authViewModel.signIn(email: email, password: password) }
                } label: {
                    if authViewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Sign In")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(email.isEmpty || password.isEmpty || authViewModel.isLoading)

                HStack(spacing: 8) {
                    Rectangle().fill(Color(.separator)).frame(height: 1)
                    Text("OR")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Rectangle().fill(Color(.separator)).frame(height: 1)
                }

                Button {
                    Task { await authViewModel.signInWithGoogle() }
                } label: {
                    HStack(spacing: 10) {
                        Image("GoogleLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 18, height: 18)
                        Text("Sign in with Google")
                            .fontWeight(.medium)
                            .foregroundStyle(.primary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(.separator), lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
                .disabled(authViewModel.isLoading)
            }

            Button("Don't have an account? Sign Up") {
                showSignUp = true
            }
            .font(.footnote)
        }
        .padding()
        .sheet(isPresented: $showSignUp) {
            SignUpView()
                .environmentObject(authViewModel)
        }
    }
}

#Preview {
    SignInView()
        .environmentObject(AuthViewModel())
}
