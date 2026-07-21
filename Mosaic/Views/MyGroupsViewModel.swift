//
//  MyGroupsViewModel.swift
//  Mosaic
//
//  Created by Gahyeon Kim on 21/7/2026.
//

import Combine
import Foundation

@MainActor
final class MyGroupsViewModel: ObservableObject {
    @Published var groups: [Group] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let groupService = GroupService()

    func loadJoinedGroups(userId: String) async {
        isLoading = true
        defer { isLoading = false }
        do {
            groups = try await groupService.fetchJoinedGroups(userId: userId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
