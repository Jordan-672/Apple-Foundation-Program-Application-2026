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
}
