//
//  EventDetailView.swift
//  learning 2
//
//  Created by Vittoria Castagna on 20/7/2026.
//

import SwiftUI

struct EventDetailsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    var event: Event

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
                    await authViewModel.performIfLoggedIn {
                        guard let eventId = event.id, let userId = authViewModel.currentUserId else { return }
                        try await EventService().registerForEvent(eventId: eventId, userId: userId)
                    }
                }
            } label: {
                Text("Join")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
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
