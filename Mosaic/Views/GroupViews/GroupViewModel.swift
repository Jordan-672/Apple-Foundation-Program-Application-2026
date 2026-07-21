//
//  GroupViewModel.swift
//  Mosaic
//
//  Created by Gahyeon Kim on 20/7/2026.
//

import Combine
import Foundation

@MainActor
final class GroupViewModel: ObservableObject {
    @Published var group: Group?
    @Published var events: [Event] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let groupService = GroupService()
    private let eventService = EventService()

    func load(groupId: String) async {
        isLoading = true
        defer { isLoading = false }
        do {
            group = try await groupService.fetchGroup(id: groupId)
            events = try await eventService.fetchEvents(groupId: groupId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // Updates the local copy after a successful join so the button flips to
    // "Joined" immediately, without needing to refetch.
    func markJoined(userId: String) {
        if group != nil && !(group?.memberIds.contains(userId) ?? true) {
            group?.memberIds.append(userId)
        }
    }
}
