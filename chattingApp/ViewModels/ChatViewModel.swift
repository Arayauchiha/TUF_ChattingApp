//
//  ChatViewModel.swift
//  chattingApp
//
//  Created by Aryan singh on 27/04/26.
//

import Foundation
import Combine

class ChatViewModel: ObservableObject {

    @Published var currentUser: User
    @Published var contacts: [User]
    @Published var messages: [Message] = []


    private let messagesStorageKey = "saved_messages"

    init() {
        self.currentUser = User(name: "My Profile", avatarURL: "person.crop.circle.fill", isOnline: true)

        self.contacts = [
            User(name: "Alice", avatarURL: "person.circle.fill", isOnline: true),
            User(name: "Bob", avatarURL: "person.circle.fill", isOnline: false),
            User(name: "Charlie", avatarURL: "person.circle.fill", isOnline: true)
        ]
        loadMessages()

        if messages.isEmpty{
            setupMockMessages()
        }
    }

    //Mark: - Core Chat Logic
    func messages(for contact: User) -> [Message] {
        return messages.filter{ message in
            (message.senderId == currentUser.id && message.reveiverId == contact.id) ||
            (message.senderId == contact.id && message.reveiverId == currentUser.id)
        }.sorted{ $0.timestamp < $1.timestamp }
    }

    


    
}
