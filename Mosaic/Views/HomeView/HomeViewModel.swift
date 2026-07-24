//
//  HomeViewModel.swift
//  Mosaic
//
//  Created by Gahyeon Kim on 21/7/2026.
//

import Foundation
import Observation

@MainActor
@Observable
class HomeViewModel {
    var groups: [Group] = []
    var spotlights: [Event] = []
    var isLoading = true
    var errorMessage: String?
    
    private let groupService = GroupService()
    private let spotlightService = SpotlightService()
    
    func fetchData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            async let groupsTask = groupService.fetchGroups()
            async let spotlightsTask = spotlightService.fetchSpotlights()
            
            groups = try await groupsTask
            spotlights = try await spotlightsTask
            
            print("✅ Fetched \(groups.count) groups")
            print("✅ Fetched \(spotlights.count) spotlights")
        } catch {
            print("❌ Error fetching data: \(error)")
            errorMessage = "Failed to load data: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func markJoined(groupId: String, userId: String) {
        if let index = groups.firstIndex(where: { $0.id == groupId }) {
            groups[index].memberIds.append(userId)
        }
    }

    func markLeft(groupId: String, userId: String) {
        guard let index = groups.firstIndex(where: { $0.id == groupId }) else { return }
        groups[index].memberIds.removeAll { $0 == userId }
    }
}
