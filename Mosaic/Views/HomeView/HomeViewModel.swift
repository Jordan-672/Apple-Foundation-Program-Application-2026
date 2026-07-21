//
//  HomeViewModel.swift
//  Mosaic
//
//  Created by Gahyeon Kim on 21/7/2026.
//

import Combine
import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var groups: [Group] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let groupService = GroupService()

    func loadGroups() async {
        isLoading = true
        defer { isLoading = false }
        do {
            groups = try await groupService.fetchGroups()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // Updates the local copy after a successful join so the card flips to
    // "Joined" immediately, without needing to refetch the whole list.
    func markJoined(groupId: String, userId: String) {
        guard let index = groups.firstIndex(where: { $0.id == groupId }) else { return }
        if !groups[index].memberIds.contains(userId) {
            groups[index].memberIds.append(userId)
        }
    }
}
