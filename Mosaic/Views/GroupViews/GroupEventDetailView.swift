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
            
            Text ("\(event.eventname) \(event.date)")
            
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
        .navigationTitle(Text("\(event.eventname)"))
    }
}

#Preview {
    EventDetailsView(
        event: Event (eventname: "DUMPLINGS NIGHT 🥟", nationality: "China 🇨🇳,", date: "29/08/2026"))
}
