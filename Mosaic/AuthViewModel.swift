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
    @Published var needsProfileCompletion = false
    @Published var showLoginSheet = false
    @Published var successMessage: String?
    @Published var errorMessage: String?
    @Published var isLoading = false

    private let authService = AuthService()
    private let userService = UserService()

    var currentUserId: String? {
        authService.currentUserId
    }

    var accountCreatedAt: Date? {
        authService.accountCreatedAt
    }

    
    func performIfLoggedIn(successMessage: String? = nil, _ action: () async throws -> Void) async {
        guard isLoggedIn else {
            showLoginSheet = true
            return
        }
        do {
            try await action()
            if let successMessage {
                self.successMessage = successMessage
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    init() {
        isLoggedIn = authService.isLoggedIn
        if let uid = authService.currentUserId {
            Task { await refreshProfileCompletion(uid: uid) }
        }
    }

    private func refreshProfileCompletion(uid: String) async {
        let profile = try? await userService.fetchUser(id: uid)
        needsProfileCompletion = (profile?.location.isEmpty ?? true) || (profile?.country.isEmpty ?? true)
    }

    func signIn(email: String, password: String) async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }
        do {
            _ = try await authService.signInWithEmail(email: email, password: password)
            isLoggedIn = true
            showLoginSheet = false
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
            showLoginSheet = false
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
                needsProfileCompletion = true
            } else {
                await refreshProfileCompletion(uid: uid)
            }
            isLoggedIn = true
            showLoginSheet = false
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func completeProfile(location: String, country: String) async {
        guard let uid = authService.currentUserId else { return }
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }
        do {
            try await authService.updateUserLocationCountry(uid: uid, location: location, country: country)
            needsProfileCompletion = false
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func signOut() {
        do {
            try authService.signOut()
            isLoggedIn = false
            needsProfileCompletion = false
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
