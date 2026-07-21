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
                TabView {
                    NavigationStack {
                        HomeView()
                    }
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }

                    MyGroupsView()
                        .tabItem {
                            Label("My Groups", systemImage: "person.3")
                        }

                    ProfileView()
                        .tabItem {
                            Label("Profile", systemImage: "person.circle")
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
