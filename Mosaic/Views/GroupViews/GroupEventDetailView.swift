//
//  EventDetailView.swift
//  learning 2
//
//  Created by Vittoria Castagna on 20/7/2026.
//

import SwiftUI

struct EventDetailsView: View {
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
            
        }
        .padding()
        .navigationTitle(Text(event.title))
    }
}

#Preview {
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
}
