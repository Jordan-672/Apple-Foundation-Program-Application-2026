import SwiftUI

struct GroupView: View {
    let groupId: String
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var vm = GroupViewModel()
    @State private var showAddEventView = false
    @State private var showJoinFirstAlert = false

    var body: some View {
        NavigationStack {
            if vm.isLoading {
                ProgressView("Loading group...")
            } else if let group = vm.group {
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(group.name)
                            .font(.system(size: 20, weight: .bold))
                            .fixedSize(horizontal: false, vertical: true)

                        Text(group.description)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.secondary)

                        AsyncImage(url: URL(string: group.coverImage)) { image in
                            image.resizable().scaledToFill()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(height: 160)
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                    }
                    .padding(16)
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .navigationTitle(group.name)
                    .navigationBarTitleDisplayMode(.inline)

                    List {
                        Section("Events") {
                            ForEach(vm.events) { event in
                                NavigationLink(destination: EventDetailsView(event: event)) {
                                    HStack(spacing: 12) {
                                        AsyncImage(url: URL(string: event.coverImage)) { image in
                                            image.resizable().scaledToFill()
                                        } placeholder: {
                                            Image(systemName: "photo")
                                                .foregroundColor(.gray)
                                        }
                                        .frame(width: 56, height: 56)
                                        .clipped()
                                        .clipShape(RoundedRectangle(cornerRadius: 8))

                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(event.title)
                                                .fontWeight(.bold)
                                            
                                            Text(event.location)
                                                .font(.caption)
                                                .foregroundStyle(.secondary)

                                            Text(event.startAt.formatted(date: .abbreviated, time: .shortened))
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                }
                            }
                        }
                    }

                    HStack(spacing: 12) {
                        Button {
                            if !authViewModel.isLoggedIn {
                                authViewModel.showLoginSheet = true
                            } else if !group.memberIds.contains(authViewModel.currentUserId ?? "") {
                                showJoinFirstAlert = true
                            } else {
                                showAddEventView = true
                            }
                        } label: {
                            HStack {
                                Text("Create an event")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                                Spacer(minLength: 4)
                                Image(systemName: "plus")
                                    .padding(8)
                                    .foregroundColor(.black)
                                    .background(Color.white)
                                    .clipShape(Circle())
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                            .background(Color.black)
                            .cornerRadius(20)
                        }

                        Button {
                            let isMember = group.memberIds.contains(authViewModel.currentUserId ?? "")
                            Task {
                                if isMember {
                                    await authViewModel.performIfLoggedIn(successMessage: "You've left the community.") {
                                        guard let userId = authViewModel.currentUserId else { return }
                                        try await GroupService().leaveGroup(groupId: groupId, userId: userId)
                                        vm.markLeft(userId: userId)
                                    }
                                } else {
                                    await authViewModel.performIfLoggedIn(successMessage: "You've joined the community!") {
                                        guard let userId = authViewModel.currentUserId else { return }
                                        try await GroupService().joinGroup(groupId: groupId, userId: userId)
                                        vm.markJoined(userId: userId)
                                    }
                                }
                            }
                        } label: {
                            Text(group.memberIds.contains(authViewModel.currentUserId ?? "") ? "Joined" : "Join")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .font(.headline)
                                .foregroundColor(.white)
                                .background(group.memberIds.contains(authViewModel.currentUserId ?? "") ? Color.gray : Color.red)
                                .cornerRadius(20)
                        }
                        .controlSize(.large)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }
                .background(Color(.systemGroupedBackground))
            } else {
                Text("Group not found.")
            }
        }
        .task {
            await vm.load(groupId: groupId)
        }
        .alert("Join to create an event", isPresented: $showJoinFirstAlert) {
            Button("OK") {}
        } message: {
            Text("You need to join this group before you can create an event.")
        }
        .sheet(isPresented: $showAddEventView) {
            AddEventView(groupId: groupId) {
                Task {
                    await vm.load(groupId: groupId)
                }
            }
        }
    }
}

#Preview {
    GroupView(groupId: "spicyFood")
        .environmentObject(AuthViewModel())
}

