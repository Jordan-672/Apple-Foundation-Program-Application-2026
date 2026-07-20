//
//  AuthViewModel.swift
//  Mosaic
//
//  Created by Gahyeon Kim on 20/7/2026.
//

import Combine
import Foundation

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var isLoggedIn: Bool
    @Published var errorMessage: String?
    @Published var isLoading = false

    private let authService = AuthService()

    init() {
        isLoggedIn = authService.isLoggedIn
    }

    func signIn(email: String, password: String) async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }
        do {
            _ = try await authService.signInWithEmail(email: email, password: password)
            isLoggedIn = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func signUp(email: String, password: String, firstName: String, lastName: String, location: String, country: String) async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }
        do {
            _ = try await authService.signUpWithEmail(email: email, password: password, firstName: firstName, lastName: lastName, location: location, country: country)
            isLoggedIn = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func signInWithGoogle() async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }
        do {
            let (uid, isNewUser, firstName, lastName) = try await authService.signInWithGoogle()
            if isNewUser {
                try await authService.createUserProfile(uid: uid, firstName: firstName, lastName: lastName, location: "", country: "")
            }
            isLoggedIn = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func signOut() {
        do {
            try authService.signOut()
            isLoggedIn = false
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
