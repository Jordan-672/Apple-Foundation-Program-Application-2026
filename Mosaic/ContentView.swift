//
//  ContentView.swift
//  Mosaic
//
//  Created by Jordan Joseph on 16/7/2026.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()

    var body: some View {
        SwiftUI.Group {
            if authViewModel.isLoggedIn && authViewModel.needsProfileCompletion {
                CompleteProfileView()
            } else {
                NavigationStack {
                    HomeView()
                        .toolbar {
                            if authViewModel.isLoggedIn {
                                ToolbarItem(placement: .topBarTrailing) {
                                    Button("Logout") {
                                        authViewModel.signOut()
                                    }
                                }
                            }
                        }
                }
            }
        }
        .environmentObject(authViewModel)
        .sheet(isPresented: $authViewModel.showLoginSheet) {
            SignInView()
                .environmentObject(authViewModel)
        }
    }
}

#Preview {
    ContentView()
}
