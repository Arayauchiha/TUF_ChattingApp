import Foundation

struct ChatUser: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let avatarSymbol: String
    let isOnline: Bool
    
    init(id: UUID = UUID(), name: String, avatarSymbol: String, isOnline: Bool = false) {
        self.id = id
        self.name = name
        self.avatarSymbol = avatarSymbol
        self.isOnline = isOnline
    }
}

struct Message: Identifiable, Codable, Hashable {
    let id: UUID
    let senderId: UUID
    let receiverId: UUID
    let text: String
    let imageData: Data?
    let timestamp: Date
    var isRead: Bool

    init(id: UUID = UUID(), senderId: UUID, receiverId: UUID, text: String = "", imageData: Data? = nil, timestamp: Date = Date(), isRead: Bool = false) {
        self.id = id
        self.senderId = senderId
        self.receiverId = receiverId
        self.text = text
        self.imageData = imageData
        self.timestamp = timestamp
        self.isRead = isRead
    }
}
