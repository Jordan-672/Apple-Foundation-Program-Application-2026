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

    
    func signUpWithEmail(email: String, password: String, firstName: String, lastName: String, location: String, country: String) async throws -> String {
        let uid = try await signUpWithEmail(email: email, password: password)
        try await createUserProfile(uid: uid, firstName: firstName, lastName: lastName, location: location, country: country)
        return uid
    }

    var currentUserId: String? {
        Auth.auth().currentUser?.uid
    }

    var isLoggedIn: Bool {
        currentUserId != nil
    }

    var accountCreatedAt: Date? {
        Auth.auth().currentUser?.metadata.creationDate
    }

    func signInWithEmail(email: String, password: String) async throws -> String {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        return result.user.uid
    }


    func signInWithGoogle() async throws -> (uid: String, isNewUser: Bool, firstName: String, lastName: String) {
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
        let firstName = result.user.profile?.givenName ?? ""
        let lastName = result.user.profile?.familyName ?? ""
        return (authResult.user.uid, isNewUser, firstName, lastName)
    }

    func signOut() throws {
        try Auth.auth().signOut()
        GIDSignIn.sharedInstance.signOut()
    }


    func createUserProfile(uid: String, firstName: String, lastName: String, location: String, country: String) async throws {
        let user = User(id: uid, firstName: firstName, lastName: lastName, profileImage: "", location: location, country: country)
        try Firestore.firestore().collection("users").document(uid).setData(from: user)
    }

    
    func updateUserLocationCountry(uid: String, location: String, country: String) async throws {
        try await Firestore.firestore().collection("users").document(uid).setData([
            "location": location,
            "country": country
        ], merge: true)
    }
}
