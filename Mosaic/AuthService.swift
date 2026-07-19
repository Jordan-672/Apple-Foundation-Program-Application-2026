//
//  AuthService.swift
//  Mosaic
//
//  Created by Gahyeon Kim on 17/7/2026.
//

import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn
import UIKit

struct AuthService {
    func signUpWithEmail(email: String, password: String) async throws -> String {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        return result.user.uid
    }

    func signInWithEmail(email: String, password: String) async throws -> String {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        return result.user.uid
    }

    // isNewUser tells the caller whether this Google account just signed up
    // for the first time, so the caller knows whether to create a Firestore
    // profile or skip it for a returning user.
    func signInWithGoogle() async throws -> (uid: String, isNewUser: Bool) {
        guard let rootViewController = await UIApplication.shared.connectedScenes
            .compactMap({ ($0 as? UIWindowScene)?.keyWindow })
            .first?.rootViewController else {
            throw NSError(domain: "AuthService", code: -1)
        }

        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
        guard let idToken = result.user.idToken?.tokenString else {
            throw NSError(domain: "AuthService", code: -1)
        }

        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: result.user.accessToken.tokenString
        )

        let authResult = try await Auth.auth().signIn(with: credential)
        let isNewUser = authResult.additionalUserInfo?.isNewUser ?? false
        return (authResult.user.uid, isNewUser)
    }

    func signOut() throws {
        try Auth.auth().signOut()
        GIDSignIn.sharedInstance.signOut()
    }

    // Call this only right after signUpWithEmail, or after signInWithGoogle
    // when isNewUser is true. Calling it on every login would overwrite the
    // user's existing profile data.
    func createUserProfile(uid: String, name: String, location: String, country: String) async throws {
        let user = User(id: uid, name: name, profileImage: "", location: location, country: country)
        try Firestore.firestore().collection("users").document(uid).setData(from: user)
    }
}
