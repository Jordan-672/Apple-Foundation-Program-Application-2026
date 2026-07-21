//
//  HomeView.swift
//  Mosaic
//
//  Created by Jordan Joseph on 17/7/2026.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var vm = HomeViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if vm.isLoading {
                    ProgressView("Loading groups...")
                        .padding()
                } else if let error = vm.errorMessage {
                    Text(error)
                        .foregroundStyle(.red)
                } else {
                    ForEach(vm.groups) { group in
                        GroupCard(
                            group: group,
                            isJoined: group.memberIds.contains(authViewModel.currentUserId ?? "")
                        ) {
                            Task {
                                await authViewModel.performIfLoggedIn(successMessage: "You've joined \(group.name)!") {
                                    guard let groupId = group.id, let userId = authViewModel.currentUserId else { return }
                                    try await GroupService().joinGroup(groupId: groupId, userId: userId)
                                    vm.markJoined(groupId: groupId, userId: userId)
                                }
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .task {
            await vm.loadGroups()
        }
    }
}

struct GroupCard: View {
    let group: Group
    let isJoined: Bool
    let onJoin: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            NavigationLink(destination: GroupView(groupId: group.id ?? "")) {
                VStack(alignment: .leading, spacing: 8) {
                    AsyncImage(url: URL(string: group.coverImage)) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Image(systemName: "photo")
                            .font(.system(size: 80))
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                    }
                    .frame(height: 150)
                    .clipped()

                    Text(group.name)
                        .font(.title2)
                        .bold()
                        .foregroundStyle(.primary)

                    Text(group.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            .buttonStyle(.plain)

            HStack {
                Spacer()
                Button(isJoined ? "Joined" : "Join", action: onJoin)
                    .buttonStyle(.borderedProminent)
                    .tint(isJoined ? .gray : .red)
                    .disabled(isJoined)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 4)
    }
}

#Preview {
    NavigationStack {
        HomeView()
            .environmentObject(AuthViewModel())
    }
}
