//
//  AppServices.swift
//  Mosaic
//
//  Created by Gahyeon Kim on 17/7/2026.
//

import Foundation
import FirebaseFirestore

struct GroupService {
    private let db = Firestore.firestore()
    
    func fetchGroups() async throws -> [Group] {
        let snapshot = try await db.collection("groups").getDocuments()
        return snapshot.documents.compactMap { doc in
            try? doc.data(as: Group.self)
        }
    }
    
    func fetchGroup(id: String) async throws -> Group? {
        try await db.collection("groups").document(id).getDocument().data(as: Group.self)
    }

    func joinGroup(groupId: String, userId: String) async throws {
        try await db.collection("groups").document(groupId).updateData([
            "memberIds": FieldValue.arrayUnion([userId]),
            "memberJoinDates.\(userId)": FieldValue.serverTimestamp()
        ])
    }

    func leaveGroup(groupId: String, userId: String) async throws {
        try await db.collection("groups").document(groupId).updateData([
            "memberIds": FieldValue.arrayRemove([userId]),
            "memberJoinDates.\(userId)": FieldValue.delete()
        ])
    }

    func fetchJoinedGroups(userId: String) async throws -> [Group] {
        let snapshot = try await db.collection("groups")
            .whereField("memberIds", arrayContains: userId)
            .getDocuments()
        return snapshot.documents.compactMap { doc in
            try? doc.data(as: Group.self)
        }
    }
}

struct EventService {
    private let db = Firestore.firestore()
    
    func fetchEvents() async throws -> [Event] {
        let snapshot = try await db.collection("events")
            .order(by: "startAt")
            .getDocuments()
        return snapshot.documents.compactMap { doc in
            try? doc.data(as: Event.self)
        }
    }

    func fetchEvents(groupId: String) async throws-> [Event] {
        let snapshot = try await db.collection("events")
            .whereField("groupId", isEqualTo: groupId)
            .order(by: "startAt")
            .getDocuments()
        return snapshot.documents.compactMap { doc in
            try? doc.data(as: Event.self)
        }
    }

    func fetchEvent(id: String) async throws -> Event? {
        try await db.collection("events").document(id).getDocument().data(as: Event.self)
    }

    func registerForEvent(eventId: String, userId: String) async throws {
        try await db.collection("events").document(eventId).updateData([
            "registeredUserIds": FieldValue.arrayUnion([userId])
        ])
    }

    func unregisterFromEvent(eventId: String, userId: String) async throws {
        try await db.collection("events").document(eventId).updateData([
            "registeredUserIds": FieldValue.arrayRemove([userId])
        ])
    }

    func createEvent(groupId: String, title: String, description: String, location: String, startAt: Date, coverImage: String) async throws {
        let event = Event(
            groupId: groupId,
            title: title,
            description: description,
            location: location,
            startAt: startAt,
            coverImage: coverImage,
            registeredUserIds: [],
            spotlight: false,
            priority: nil
        )
        _ = try db.collection("events").addDocument(from: event)
    }
}

struct UserService {
    private let db = Firestore.firestore()
    
    func fetchUser(id: String) async throws -> User? {
        try await db.collection("users").document(id).getDocument().data(as: User.self)
    }
    
    func fetchUsers(ids:[String]) async throws -> [User] {
        guard !ids.isEmpty else { return [] }
        
        let snapshot = try await db.collection("users")
            .whereField(FieldPath.documentID(), in: ids)
            .getDocuments()
        
        return snapshot.documents.compactMap { doc in
            try? doc.data(as: User.self)
        }
    }
}

final class SpotlightService {
    private let db = Firestore.firestore()
    
    func fetchSpotlights() async throws -> [Event] {
        // Fetch all spotlight events without ordering (to avoid needing a Firebase index)
        let snapshot = try await db.collection("events")
            .whereField("spotlight", isEqualTo: true)
            .getDocuments()
        
        // Convert to Event objects
        let events = snapshot.documents.compactMap { doc in
            try? doc.data(as: Event.self)
        }
        
        // Sort by priority in-memory (lower numbers first, events without priority go last)
        return events.sorted { (event1, event2) in
            let priority1 = event1.priority ?? Int.max
            let priority2 = event2.priority ?? Int.max
            return priority1 < priority2
        }
    }
}
