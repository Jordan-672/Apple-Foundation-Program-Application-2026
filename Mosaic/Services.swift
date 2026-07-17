//
//  Services.swift
//  Mosaic
//
//  Created by Gahyeon Kim on 17/7/2026.
//

// This file provides data-fetching functions for Group, Event, and User.
// Right now each function returns hardcoded sample data

import Foundation

struct GroupService {
    func fetchGroups() async -> [Group] {
        return [
            Group(id: "1", name: "Perth Pho Lovers", description: "Weekly meetup to try the best pho spots in Perth", coverImage: "", memberIds: ["u1", "u2"]),
            Group(id: "2", name: "Pasta Night Club", description: "Homemade Italian pasta nights, everyone cooks together", coverImage: "", memberIds: ["u3"]),
            Group(id: "3", name: "Biryani & Curry Fans", description: "Exploring the best Indian and Bangladeshi curry houses", coverImage: "", memberIds: ["u4"]),
            Group(id: "4", name: "Korean BBQ Crew", description: "Grilling and sharing Korean BBQ together", coverImage: "", memberIds: ["u5"])
        ]
    }

    func fetchGroup(id: String) async -> Group? {
        await fetchGroups().first { $0.id == id }
    }
}

struct EventService {
    func fetchEvents() async -> [Event] {
        return [
            Event(id: "e1", groupId: "1", title: "Best Pho in Northbridge", description: "Group visit to try 3 different pho restaurants", location: "Northbridge, Perth", startAt: Date(), coverImage: "", registeredUserIds: ["u1", "u2"]),
            Event(id: "e2", groupId: "2", title: "Homemade Carbonara Night", description: "Cook and share authentic carbonara together", location: "Community Kitchen, Perth CBD", startAt: Date(), coverImage: "", registeredUserIds: ["u3"]),
            Event(id: "e3", groupId: "3", title: "Biryani Cook-off", description: "Compare curry recipes", location: "Hyde Park, Perth", startAt: Date(), coverImage: "", registeredUserIds: ["u4"]),
            Event(id: "e4", groupId: "4", title: "Samgyeopsal Night", description: "Korean BBQ pork belly night with soju", location: "Perth CBD", startAt: Date(), coverImage: "", registeredUserIds: ["u5"])
        ]
    }

    func fetchEvents(groupId: String) async -> [Event] {
        await fetchEvents().filter { $0.groupId == groupId }
    }

    func fetchEvent(id: String) async -> Event? {
        await fetchEvents().first { $0.id == id }
    }
}

struct UserService {
    func fetchUser(id: String) async -> User? {
        let users = [
            User(id: "u1", name: "Anh Nguyen", profileImage: "", location: "Northbridge, Perth", country: "Vietnam"),
            User(id: "u2", name: "Raj Patel", profileImage: "", location: "Mirrabooka, Perth", country: "India"),
            User(id: "u3", name: "Marco Rossi", profileImage: "", location: "Fremantle, Perth", country: "Italy"),
            User(id: "u4", name: "Fatima Rahman", profileImage: "", location: "Victoria Park, Perth", country: "Bangladesh"),
            User(id: "u5", name: "Minsu Kim", profileImage: "", location: "Malaga, Perth", country: "South Korea")
        ]
        return users.first { $0.id == id }
    }
}
