//
//  EventsView.swift
//  Mosaic
//
//  Created by Gahyeon Kim on 21/7/2026.
//

import SwiftUI

struct EventsView: View {
    @StateObject private var vm = EventsViewModel()

    var body: some View {
        NavigationStack {
            SwiftUI.Group {
                if vm.isLoading {
                    ProgressView("Loading events...")
                } else if let error = vm.errorMessage {
                    Text(error)
                        .foregroundStyle(.red)
                } else if vm.events.isEmpty {
                    Text("No events yet.")
                        .foregroundStyle(.secondary)
                } else {
                    List(vm.events) { event in
                        NavigationLink(destination: EventDetailsView(event: event)) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(event.title)
                                    .font(.headline)
                                HStack {
                                    Text(event.location)
                                    Spacer()
                                    Text(event.startAt.formatted(date: .abbreviated, time: .shortened))
                                }
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Events")
            .task {
                await vm.loadEvents()
            }
        }
    }
}

#Preview {
    EventsView()
        .environmentObject(AuthViewModel())
}
