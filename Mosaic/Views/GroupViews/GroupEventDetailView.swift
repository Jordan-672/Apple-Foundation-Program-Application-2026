//
//  EventDetailView.swift
//  learning 2
//
//  Created by Vittoria Castagna on 20/7/2026.
//

import SwiftUI

struct EventDetailsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var event: Event
    @State private var registeredUsers: [User] = []
    @State private var groupName: String?

    init(event: Event) {
        _event = State(initialValue: event)
    }

    private var isRegistered: Bool {
        event.registeredUserIds.contains(authViewModel.currentUserId ?? "")
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 16) {
                    AsyncImage(url: URL(string: event.coverImage)) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        ZStack {
                            Color(.systemGray5)
                            Image(systemName: "photo")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .frame(height: 200)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(event.title)
                            .font(.title.bold())

                        if let groupName {
                            Text("Hosted by \(groupName)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Label(event.location, systemImage: "mappin.and.ellipse")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Label(event.startAt.formatted(date: .abbreviated, time: .shortened), systemImage: "calendar")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    if !event.description.isEmpty {
                        Text(event.description)
                            .font(.body)
                            .padding(.top, 4)
                    }

                    if !registeredUsers.isEmpty {
                        Divider()

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Who's Going")
                                .font(.subheadline.bold())

                            HStack(spacing: -8) {
                                ForEach(registeredUsers.prefix(5)) { user in
                                    AsyncImage(url: URL(string: user.profileImage)) { image in
                                        image.resizable().scaledToFill()
                                    } placeholder: {
                                        Image(systemName: "person.circle.fill")
                                            .resizable()
                                            .foregroundColor(.gray)
                                    }
                                    .frame(width: 32, height: 32)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color(.systemBackground), lineWidth: 2))
                                }

                                if registeredUsers.count > 5 {
                                    Text("+\(registeredUsers.count - 5)")
                                        .font(.caption2)
                                        .frame(width: 32, height: 32)
                                        .background(Circle().fill(Color(.systemGray5)))
                                        .overlay(Circle().stroke(Color(.systemBackground), lineWidth: 2))
                                }
                            }

                            Text("\(registeredUsers.count) \(registeredUsers.count == 1 ? "person" : "people") going")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)

                Button {
                    Task {
                        if isRegistered {
                            await authViewModel.performIfLoggedIn(successMessage: "You've cancelled your registration for \(event.title).") {
                                guard let eventId = event.id, let userId = authViewModel.currentUserId else { return }
                                try await EventService().unregisterFromEvent(eventId: eventId, userId: userId)
                                event.registeredUserIds.removeAll { $0 == userId }
                            }
                        } else {
                            await authViewModel.performIfLoggedIn(successMessage: "You've registered for \(event.title)!") {
                                guard let eventId = event.id, let userId = authViewModel.currentUserId else { return }
                                try await EventService().registerForEvent(eventId: eventId, userId: userId)
                                if !event.registeredUserIds.contains(userId) {
                                    event.registeredUserIds.append(userId)
                                }
                            }
                        }
                    }
                } label: {
                    Text(isRegistered ? "Registered" : "Join")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(isRegistered ? .gray : .red)
                .controlSize(.large)
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(event.title)
        .navigationBarTitleDisplayMode(.inline)
        .task(id: event.registeredUserIds) {
            registeredUsers = (try? await UserService().fetchUsers(ids: event.registeredUserIds)) ?? []
        }
        .task(id: event.groupId) {
            groupName = try? await GroupService().fetchGroup(id: event.groupId)?.name
        }
    }
}

/*#Preview {
    EventDetailsView(
        event: Event(
            id: "preview",
            groupId: "preview-group",
            title: "DUMPLINGS NIGHT 🥟",
            description: "",
            location: "",
            startAt: Date(),
            coverImage: "",
            registeredUserIds: [],
            spotlight: false,
            priotity: nil
        )
    )
    .environmentObject(AuthViewModel())
}*/
