//
//  User.swift
//  chattingApp
//
//  Created by Aryan singh on 27/04/26.
//

import Foundation

struct User: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let avatarURL: String
    let isOnline: Bool
    
    init(id: UUID, name: String, avatarURL: String, isOnline: Bool) {
        self.id = id
        self.name = name
        self.avatarURL = avatarURL
        self.isOnline = isOnline
    }
}
