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

    init(event: Event) {
        _event = State(initialValue: event)
    }

    private var isRegistered: Bool {
        event.registeredUserIds.contains(authViewModel.currentUserId ?? "")
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                AsyncImage(url: URL(string: event.coverImage)) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Image(systemName: "photo")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                }
                .frame(height: 200)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 16))

                Text(event.title)
                    .font(.title.bold())

                Label(event.location, systemImage: "mappin.and.ellipse")
                    .foregroundStyle(.secondary)

                Label(event.startAt.formatted(date: .abbreviated, time: .shortened), systemImage: "calendar")
                    .foregroundStyle(.secondary)

                if !event.description.isEmpty {
                    Text(event.description)
                        .font(.body)
                        .padding(.top, 4)
                }

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
                .padding(.top, 8)
            }
            .padding()
        }
        .navigationTitle(event.title)
        .navigationBarTitleDisplayMode(.inline)
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
