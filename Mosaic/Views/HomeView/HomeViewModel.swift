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
    var isLoading = false
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
}
