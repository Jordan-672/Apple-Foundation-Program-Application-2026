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
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let eventService = EventService()

    func loadEvents() async {
        isLoading = true
        defer { isLoading = false }
        do {
            events = try await eventService.fetchEvents()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
