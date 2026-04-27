//
//  ChatViewModel.swift
//  chattingApp
//
//  Created by Aryan singh on 27/04/26.
//

import Foundation
import Combine

class ChatViewModel: ObservableObject {
    @Published var currentUser: ChatUser
    @Published var contacts: [ChatUser]
    @Published var messages: [Message] = [] {
        didSet {
            saveMessages()
        }
    }
    
    private let messagesStorageKey = "saved_messages"
    
    init() {
        // Initialize current user
        self.currentUser = ChatUser(name: "Aryan", avatarSymbol: "person.crop.circle.fill", isOnline: true)
        
        // Initialize mock contacts
        self.contacts = [
            ChatUser(name: "Alice", avatarSymbol: "person.circle.fill", isOnline: true),
            ChatUser(name: "Bob", avatarSymbol: "person.circle.fill", isOnline: false),
            ChatUser(name: "Charlie", avatarSymbol: "person.circle.fill", isOnline: true)
        ]
        
        loadMessages()
        
        if messages.isEmpty {
            setupMockMessages()
        }
    }
    
    // MARK: - Core Chat Logic
    
    func messages(for contact: ChatUser) -> [Message] {
        return messages.filter { message in
            (message.senderId == currentUser.id && message.receiverId == contact.id) ||
            (message.senderId == contact.id && message.receiverId == currentUser.id)
        }.sorted { $0.timestamp < $1.timestamp }
    }
    
    func sendMessage(text: String, to contact: ChatUser) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let newMessage = Message(senderId: currentUser.id, receiverId: contact.id, text: text)
        messages.append(newMessage)
        
        // Simulate automated reply
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let replyText = "This is an automated reply to: \"\(text)\""
            let replyMessage = Message(senderId: contact.id, receiverId: self.currentUser.id, text: replyText)
            self.messages.append(replyMessage)
        }
    }
    
    func sendImage(data: Data, to contact: ChatUser) {
        let newMessage = Message(senderId: currentUser.id, receiverId: contact.id, text: "Sent a photo", imageData: data)
        messages.append(newMessage)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let replyMessage = Message(senderId: contact.id, receiverId: self.currentUser.id, text: "Nice photo!")
            self.messages.append(replyMessage)
        }
    }
    
    func lastMessage(for contact: ChatUser) -> Message? {
        return messages(for: contact).last
    }
    
    func unreadCount(for contact: ChatUser) -> Int {
        return messages(for: contact).filter { $0.senderId == contact.id && !$0.isRead }.count
    }
    
    func markAsRead(for contact: ChatUser) {
        for index in messages.indices {
            if messages[index].senderId == contact.id && messages[index].receiverId == currentUser.id {
                messages[index].isRead = true
            }
        }
    }
    
    func deleteConversation(for contact: ChatUser) {
        messages.removeAll { message in
            (message.senderId == currentUser.id && message.receiverId == contact.id) ||
            (message.senderId == contact.id && message.receiverId == currentUser.id)
        }
    }
    
    func startNewChat(with contactName: String, messageText: String) {
        // Find or create a mock contact
        let contact = contacts.first(where: { $0.name == contactName }) ?? ChatUser(name: contactName, avatarSymbol: "person.circle.fill")
        if !contacts.contains(where: { $0.id == contact.id }) {
            contacts.append(contact)
        }
        sendMessage(text: messageText, to: contact)
    }
    
    // MARK: - Persistence
    
    private func saveMessages() {
        if let encoded = try? JSONEncoder().encode(messages) {
            UserDefaults.standard.set(encoded, forKey: messagesStorageKey)
        }
    }
    
    private func loadMessages() {
        if let data = UserDefaults.standard.data(forKey: messagesStorageKey),
           let decoded = try? JSONDecoder().decode([Message].self, from: data) {
            self.messages = decoded
        }
    }
    
    private func setupMockMessages() {
        let welcomeMessage = Message(
            senderId: contacts[0].id,
            receiverId: currentUser.id,
            text: "Hey there! How's the prototype coming along?"
        )
        self.messages = [welcomeMessage]
    }
}
