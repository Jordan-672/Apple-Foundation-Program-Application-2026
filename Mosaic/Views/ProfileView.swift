//
//  ProfileView.swift
//  Mosaic
//
//  Created by Gahyeon Kim on 21/7/2026.
//

// Temporary placeholder — a teammate is building the real Profile screen.
// Keep the type name `ProfileView` so ContentView's TabView doesn't need to
// change when that file replaces this one.

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Profile")
                    .foregroundStyle(.secondary)

                if authViewModel.isLoggedIn {
                    Button("Log Out", role: .destructive) {
                        authViewModel.signOut()
                    }
                }
            }
            .navigationTitle("Profile")
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
}
