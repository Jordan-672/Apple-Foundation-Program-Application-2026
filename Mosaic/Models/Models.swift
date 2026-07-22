//
//  Models.swift
//  Mosaic
//
//  Created by Gahyeon Kim on 17/7/2026.
//

import Foundation
import SwiftUI
import FirebaseFirestore

struct User: Codable, Identifiable {
    @DocumentID var id: String?
    var firstName: String
    var lastName: String
    var profileImage: String
    var location: String
    var country: String
}

struct Group: Codable, Identifiable {
    @DocumentID var id: String?
    var name: String
    var description: String
    var coverImage: String
    var memberIds: [String]
    var memberJoinDates: [String: Date]?

    var memberCount: Int {memberIds.count}
}

struct Event: Codable, Identifiable, Hashable {
    @DocumentID var id: String?
    var groupId: String
    var title: String
    var description: String
    var location: String
    var startAt : Date
    var coverImage: String
    var registeredUserIds: [String]
    
    var spotlight: Bool = false
    var priority: Int?
    
    var registeredCount: Int {registeredUserIds.count}
}
