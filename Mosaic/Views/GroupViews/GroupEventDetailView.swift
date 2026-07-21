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

    var body: some View {

        VStack(spacing: 20) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 100))
                .foregroundColor(.blue)

            Text("\(event.title) \(event.startAt.formatted(date: .abbreviated, time: .shortened))")

            HStack {
                Text("Nationality: ")
                Circle()
                    .fill(Color.blue)
                    .frame(width: 30, height: 30)
                    .padding(5)
                            }

            Spacer()

            Button {
                Task {
                    await authViewModel.performIfLoggedIn(successMessage: "You've registered for \(event.title)!") {
                        guard let eventId = event.id, let userId = authViewModel.currentUserId else { return }
                        try await EventService().registerForEvent(eventId: eventId, userId: userId)
                        if !event.registeredUserIds.contains(userId) {
                            event.registeredUserIds.append(userId)
                        }
                    }
                }
            } label: {
                Text(event.registeredUserIds.contains(authViewModel.currentUserId ?? "") ? "Registered" : "Join")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(event.registeredUserIds.contains(authViewModel.currentUserId ?? "") ? .gray : .red)
            .disabled(event.registeredUserIds.contains(authViewModel.currentUserId ?? ""))
        }
        .padding()
        .navigationTitle(Text(event.title))
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
