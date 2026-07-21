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
            "memberIds": FieldValue.arrayUnion([userId])
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
        let snapshot = try await db.collection("events")
            .whereField("spotlight", isEqualTo: true)
            .order(by: "priority")
            .getDocuments()
        return snapshot.documents.compactMap { doc in
            try? doc.data(as: Event.self)
        }
    }
}
