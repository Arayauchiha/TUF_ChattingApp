import SwiftUI
import PhotosUI

// MARK: - Preference Keys
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct ChatDetailView: View {
    @ObservedObject var viewModel: ChatViewModel
    let contact: ChatUser
    
    @State private var messageText = ""
    @FocusState private var isFocused: Bool
    @State private var selectedItem: PhotosPickerItem?
    @State private var showScrollToBottom = false
    
    var body: some View {
        VStack(spacing: 0) {
            messageThread
            inputBar
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            navigationToolbar
        }
    }
    
    // MARK: - Subviews
    
    private var messageThread: some View {
        ScrollViewReader { proxy in
            ZStack(alignment: .bottom) {
                ScrollView {
                    scrollContent
                }
                .coordinateSpace(name: "scroll")
                
                if showScrollToBottom {
                    scrollToBottomButton(proxy: proxy)
                }
            }
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                showScrollToBottom = value < -200
            }
            .onChange(of: viewModel.messages) { _ in
                scrollToBottom(proxy: proxy)
            }
            .onAppear {
                viewModel.markAsRead(for: contact)
                scrollToBottom(proxy: proxy)
            }
        }
        .background(Color(UIColor.systemBackground))
    }
    
    private var scrollContent: some View {
        LazyVStack(spacing: 4) {
            let messages = viewModel.messages(for: contact)
            ForEach(messages) { message in
                MessageBubble(
                    message: message,
                    isCurrentUser: message.senderId == viewModel.currentUser.id
                )
                .id(message.id)
            }
        }
        .padding(.top)
        .background(scrollDetector)
    }
    
    private var scrollDetector: some View {
        GeometryReader { geo in
            Color.clear.preference(
                key: ScrollOffsetPreferenceKey.self,
                value: geo.frame(in: .named("scroll")).minY
            )
        }
    }
    
    private func scrollToBottomButton(proxy: ScrollViewProxy) -> some View {
        Button {
            scrollToBottom(proxy: proxy)
        } label: {
            Image(systemName: "chevron.down.circle.fill")
                .resizable()
                .frame(width: 35, height: 35)
                .foregroundColor(.blue)
                .background(Circle().fill(Color(UIColor.systemBackground)))
                .shadow(radius: 4)
        }
        .padding(.bottom, 15)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
    
    private var inputBar: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack(spacing: 12) {
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    Image(systemName: "paperclip")
                        .font(.system(size: 20))
                        .foregroundColor(.blue)
                }
                .onChange(of: selectedItem) { newItem in
                    handleImageSelection(newItem)
                }
                
                HStack {
                    TextField("Message...", text: $messageText, axis: .vertical)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .lineLimit(1...5)
                        .focused($isFocused)
                        .foregroundColor(.primary)
                }
                .background(Color(.systemGray6))
                .clipShape(Capsule())
                
                Button(action: handleSendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .resizable()
                        .frame(width: 32, height: 32)
                        .foregroundColor(canSend ? .blue : .gray.opacity(0.5))
                }
                .disabled(!canSend)
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background(Color.black.ignoresSafeArea())
        }
    }
    
    private var navigationToolbar: some ToolbarContent {
        Group {
            ToolbarItem(placement: .principal) {
                HStack(spacing: 8) {
                    Image(systemName: contact.avatarSymbol)
                        .foregroundColor(.blue)
                    Text(contact.name)
                        .font(.headline)
                }
            }
            
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button { } label: { Image(systemName: "video") }
                Button { } label: { Image(systemName: "phone") }
            }
        }
    }
    
    // MARK: - Logic
    
    private var canSend: Bool {
        !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func handleSendMessage() {
        if canSend {
            viewModel.sendMessage(text: messageText, to: contact)
            messageText = ""
        }
    }
    
    private func handleImageSelection(_ item: PhotosPickerItem?) {
        Task {
            if let data = try? await item?.loadTransferable(type: Data.self) {
                await MainActor.run {
                    viewModel.sendImage(data: data, to: contact)
                }
            }
        }
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy) {
        if let lastId = viewModel.messages(for: contact).last?.id {
            withAnimation {
                proxy.scrollTo(lastId, anchor: .bottom)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ChatDetailView(
            viewModel: ChatViewModel(),
            contact: ChatUser(name: "Alice", avatarSymbol: "person.circle.fill", isOnline: true)
        )
    }
}
