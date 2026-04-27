import SwiftUI

struct MessageBubble: View {
    let message: Message
    let isCurrentUser: Bool
    
    var body: some View {
        VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 4) {
            HStack {
                if isCurrentUser { Spacer() }
                
                Group {
                    if let imageData = message.imageData, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: UIScreen.main.bounds.width * 0.7)
                            .clipShape(ChatBubbleShape(isCurrentUser: isCurrentUser))
                            .overlay(alignment: .bottomTrailing) {
                                timestampOverlay
                            }
                    } else {
                        VStack(alignment: .trailing, spacing: 4) {
                            Text(message.text)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .foregroundColor(isCurrentUser ? .white : .primary)
                                .background(
                                    ChatBubbleShape(isCurrentUser: isCurrentUser)
                                        .fill(isCurrentUser ? Color.blue.gradient : Color(UIColor.systemGray5).gradient)
                                )
                            
                            timestampLabel
                                .padding(.trailing, 8)
                                .padding(.bottom, 2)
                        }
                    }
                }
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                
                if !isCurrentUser { Spacer() }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
    }
    
    // Transparent overlay for images
    private var timestampOverlay: some View {
        HStack(spacing: 4) {
            Text(formatDate(message.timestamp))
                .font(.system(size: 10))
                .foregroundColor(.white)
            
            if isCurrentUser {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 10))
                    .foregroundColor(message.isRead ? .blue : .white)
            }
        }
        .padding(6)
        .background(Color.black.opacity(0.4))
        .clipShape(Capsule())
        .padding(8)
    }
    
    // Standard label for text bubbles
    private var timestampLabel: some View {
        HStack(spacing: 4) {
            Text(formatDate(message.timestamp))
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.secondary)
            
            if isCurrentUser {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 10))
                    .foregroundColor(message.isRead ? .blue : .gray)
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// Keeping ChatBubbleShape for reference (assuming it's in the same file or accessible)
struct ChatBubbleShape: Shape {
    let isCurrentUser: Bool
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: [
                .topLeft,
                .topRight,
                isCurrentUser ? .bottomLeft : .bottomRight
            ],
            cornerRadii: CGSize(width: 18, height: 18)
        )
        return Path(path.cgPath)
    }
}
