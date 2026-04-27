import SwiftUI

struct ChatListView: View {
    @StateObject private var viewModel = ChatViewModel()
    @State private var showingNewMessageSheet = false
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                List {
                    ForEach(viewModel.contacts) { contact in
                        NavigationLink(value: contact) {
                            ContactRowView(
                                user: contact,
                                lastMessage: viewModel.lastMessage(for: contact),
                                unreadCount: viewModel.unreadCount(for: contact)
                            )
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                withAnimation {
                                    viewModel.deleteConversation(for: contact)
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .navigationTitle("Messages")
                
                // FAB
                Button {
                    showingNewMessageSheet = true
                } label: {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(Color.blue)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                }
                .padding(.trailing, 20)
                .padding(.bottom, 20)
            }
            .navigationDestination(for: ChatUser.self) { contact in
                ChatDetailView(viewModel: viewModel, contact: contact)
            }
            .sheet(isPresented: $showingNewMessageSheet) {
                NewMessageView(viewModel: viewModel)
            }
        }
    }
}

#Preview {
    ChatListView()
}
