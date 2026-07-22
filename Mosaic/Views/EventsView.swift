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
                .padding(.horizontal)
                .padding(.top, 8)

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
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    eventList(vm.registeredEvents, emptyMessage: "You haven't registered for any events yet.")
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Events")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await vm.loadEvents()
                await vm.loadGroupNames()
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
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let error = vm.errorMessage {
            Text(error)
                .foregroundStyle(.red)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if events.isEmpty {
            Text(emptyMessage)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            List(events) { event in
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

                            if let groupName = vm.groupNames[event.groupId] {
                                Text("Hosted by \(groupName)")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }

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
}

#Preview {
    EventsView()
        .environmentObject(AuthViewModel())
}
