//
//  Message.swift
//  chattingApp
//
//  Created by Aryan singh on 27/04/26.
//

import Foundation

struct Message: Identifiable, Codable, Hashable {
    let id: UUID
    let senderId: UUID
    let reveiverId: UUID
    let text: String
    let timestamp: Date


    let attachmentName: String?

    var isRead: Bool


    init(id: UUID, senderId: UUID, reveiverId: UUID, text: String, timestamp: Date, attachmentName: String?, isRead: Bool) {
        self.id = id
        self.senderId = senderId
        self.reveiverId = reveiverId
        self.text = text
        self.timestamp = timestamp
        self.attachmentName = attachmentName
        self.isRead = isRead
    }
}

