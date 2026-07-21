//
//  EventsViewModel.swift
//  Mosaic
//
//  Created by Gahyeon Kim on 21/7/2026.
//

import Combine
import Foundation

@MainActor
final class EventsViewModel: ObservableObject {
    @Published var events: [Event] = []
    @Published var registeredEvents: [Event] = []
    @Published var groupNames: [String: String] = [:]
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let eventService = EventService()
    private let groupService = GroupService()

    func loadEvents() async {
        isLoading = true
        defer { isLoading = false }
        do {
            events = try await eventService.fetchEvents()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // Events from different groups show up mixed together here, so each row
    // needs to say which group it belongs to.
    func loadGroupNames() async {
        guard let groups = try? await groupService.fetchGroups() else { return }
        groupNames = Dictionary(uniqueKeysWithValues: groups.compactMap { group in
            group.id.map { ($0, group.name) }
        })
    }

    func loadRegisteredEvents(userId: String) async {
        isLoading = true
        defer { isLoading = false }
        do {
            registeredEvents = try await eventService.fetchRegisteredEvents(userId: userId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
