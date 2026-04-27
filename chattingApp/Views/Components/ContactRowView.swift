import SwiftUI

struct ContactRowView: View {
    let user: ChatUser
    let lastMessage: Message?
    let unreadCount: Int
    
    var body: some View {
        HStack(spacing: 15) {
            // Avatar with online indicator
            ZStack(alignment: .bottomTrailing) {
                Image(systemName: user.avatarSymbol)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 55, height: 55)
                    .foregroundColor(.blue)
                    .background(Circle().fill(Color.blue.opacity(0.1)))
                
                if user.isOnline {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 14, height: 14)
                        .overlay(Circle().stroke(Color(UIColor.systemBackground), lineWidth: 2))
                }
            }
            
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(user.name)
                        .font(.headline)
                    
                    Spacer()
                    
                    if let lastMessage = lastMessage {
                        Text(formatDate(lastMessage.timestamp))
                            .font(.caption2)
                            .foregroundColor(unreadCount > 0 ? .green : .secondary)
                    }
                }
                
                HStack {
                    Text(lastMessage?.text ?? "No messages yet")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    if unreadCount > 0 {
                        Text("\(unreadCount)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 20, height: 20)
                            .background(Circle().fill(Color.green))
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        if Calendar.current.isDateInToday(date) {
            formatter.timeStyle = .short
        } else {
            formatter.dateStyle = .short
        }
        return formatter.string(from: date)
    }
}

#Preview {
    List {
        ContactRowView(
            user: ChatUser(name: "Alice", avatarSymbol: "person.circle.fill", isOnline: true),
            lastMessage: Message(senderId: UUID(), receiverId: UUID(), text: "Hey! Are you coming?"),
            unreadCount: 2
        )
    }
}
