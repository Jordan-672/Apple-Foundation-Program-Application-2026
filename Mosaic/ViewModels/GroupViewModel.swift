//
//  GroupViewModel.swift
//  Mosaic
//
//  Created by Jordan Joseph on 20/7/2026.
//

import SwiftUI

@MainActor
final class GroupViewModel: ObservableObject {
    @Published var group: Group?
    @Published var events: [Event] = []
    @Published var isLoading = true

    private let service = GroupService()

    func load(groupId: String) async {
        do {
            let fetchedGroup = try await service.fetchGroup(groupId: groupId)
            let fetchedEvents = try await service.fetchEvents(for: groupId)

            self.group = fetchedGroup
            self.events = fetchedEvents
            self.isLoading = false
        } catch {
            print("Error loading group:", error)
            self.isLoading = false
        }
    }
}

