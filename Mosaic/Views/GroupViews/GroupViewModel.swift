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
}
