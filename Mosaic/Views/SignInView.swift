//
//  SignInView.swift
//  Mosaic
//
<<<<<<< Updated upstream
//  Created by Gahyeon Kim on 20/7/2026.
=======
//  Created by Jordan Joseph on 18/7/2026.
>>>>>>> Stashed changes
//

import SwiftUI

struct SignInView: View {
<<<<<<< Updated upstream
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showSignUp = false

    var body: some View {
        VStack(spacing: 16) {
            Text("Mosaic")
                .font(.largeTitle.bold())
                .padding(20)

            TextField(" Username or Email", text: $email)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .textFieldStyle(.roundedBorder)

            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)

            if let error = authViewModel.errorMessage {
                Text(error)
                    .foregroundStyle(.red)
                    .font(.footnote)
            }

            Button {
                Task { await authViewModel.signIn(email: email, password: password) }
            } label: {
                if authViewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Sign In")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(email.isEmpty || password.isEmpty || authViewModel.isLoading)

            Button {
                Task { await authViewModel.signInWithGoogle() }
            } label: {
                Text("Sign In with Google")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .disabled(authViewModel.isLoading)

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
=======
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
>>>>>>> Stashed changes
    }
}

#Preview {
    SignInView()
<<<<<<< Updated upstream
        .environmentObject(AuthViewModel())
=======
>>>>>>> Stashed changes
}
