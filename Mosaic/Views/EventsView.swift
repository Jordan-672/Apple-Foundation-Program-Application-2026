//
//  EventsView.swift
//  Mosaic
//
//  Created by Gahyeon Kim on 21/7/2026.
//

import SwiftUI

struct EventsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var vm = EventsViewModel()
    @State private var selectedTab = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("", selection: $selectedTab) {
                    Text("All Events").tag(0)
                    Text("My Events").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()

                if selectedTab == 0 {
                    eventList(vm.events, emptyMessage: "No events yet.")
                } else if !authViewModel.isLoggedIn {
                    VStack(spacing: 16) {
                        Text("Sign in to see your registered events")
                            .foregroundStyle(.secondary)
                        Button("Sign In") {
                            authViewModel.showLoginSheet = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    eventList(vm.registeredEvents, emptyMessage: "You haven't registered for any events yet.")
                }
            }
            .navigationTitle("Events")
            .task {
                await vm.loadEvents()
            }
            .task(id: selectedTab) {
                if selectedTab == 1, let uid = authViewModel.currentUserId {
                    await vm.loadRegisteredEvents(userId: uid)
                }
            }
        }
    }

    @ViewBuilder
    private func eventList(_ events: [Event], emptyMessage: String) -> some View {
        if vm.isLoading {
            ProgressView("Loading events...")
                .frame(maxHeight: .infinity)
        } else if let error = vm.errorMessage {
            Text(error)
                .foregroundStyle(.red)
        } else if events.isEmpty {
            Text(emptyMessage)
                .foregroundStyle(.secondary)
                .frame(maxHeight: .infinity)
        } else {
            List(events) { event in
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
}

#Preview {
    EventsView()
        .environmentObject(AuthViewModel())
}
