//
//  MyGroupsView.swift
//  Mosaic
//
//  Created by Gahyeon Kim on 21/7/2026.
//

import SwiftUI

struct MyGroupsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var vm = MyGroupsViewModel()

    var body: some View {
        NavigationStack {
            SwiftUI.Group {
                if !authViewModel.isLoggedIn {
                    VStack(spacing: 16) {
                        Text("Sign in to see your groups")
                            .foregroundStyle(.secondary)
                        Button("Sign In") {
                            authViewModel.showLoginSheet = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if vm.isLoading {
                    ProgressView("Loading your groups...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if vm.groups.isEmpty {
                    Text("You haven't joined any groups yet.")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(vm.groups) { group in
                        NavigationLink(destination: GroupView(groupId: group.id ?? "")) {
                            VStack(alignment: .leading) {
                                Text(group.name)
                                    .font(.headline)
                                Text(group.description)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                                if let userId = authViewModel.currentUserId,
                                   let joinDate = group.memberJoinDates?[userId] {
                                    Text("Joined \(joinDate.formatted(date: .abbreviated, time: .omitted))")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                    .contentMargins(.top, 0, for: .scrollContent)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("My Groups")
            .navigationBarTitleDisplayMode(.inline)
            .task(id: authViewModel.currentUserId) {
                if let uid = authViewModel.currentUserId {
                    await vm.loadJoinedGroups(userId: uid)
                }
            }
        }
    }
}

#Preview {
    MyGroupsView()
        .environmentObject(AuthViewModel())
}
