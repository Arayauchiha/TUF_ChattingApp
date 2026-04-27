import SwiftUI

struct ChatListView: View {
    @StateObject private var viewModel = ChatViewModel()
    @State private var showingNewMessageSheet = false
    @State private var selection = Set<ChatUser.ID>()
    @State private var editMode: EditMode = .inactive
    
    // Deletion states
    @State private var contactToDelete: ChatUser?
    @State private var showingDeleteAlert = false
    @State private var isBulkDeleting = false
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                List(selection: $selection) {
                    ForEach(viewModel.contacts) { contact in
                        NavigationLink(value: contact) {
                            ContactRowView(
                                user: contact,
                                lastMessage: viewModel.lastMessage(for: contact),
                                unreadCount: viewModel.unreadCount(for: contact)
                            )
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                contactToDelete = contact
                                showingDeleteAlert = true
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                contactToDelete = contact
                                showingDeleteAlert = true
                            } label: {
                                Label("Delete Chat", systemImage: "trash")
                            }
                            
                            Button {
                                viewModel.markAsRead(for: contact)
                            } label: {
                                Label("Mark as Read", systemImage: "checkmark.circle")
                            }
                        } preview: {
                            VStack {
                                ChatDetailView(viewModel: viewModel, contact: contact)
                                    .frame(width: 300, height: 400)
                            }
                        }
                    }
                }
                .listStyle(.inset)
                .navigationTitle("Messages")
                .environment(\.editMode, $editMode)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(editMode == .active ? "Done" : "Edit") {
                            withAnimation {
                                editMode = (editMode == .active) ? .inactive : .active
                                if editMode == .inactive { selection.removeAll() }
                            }
                        }
                        .fontWeight(editMode == .active ? .bold : .regular)
                    }
                    
                    if editMode == .active {
                        ToolbarItemGroup(placement: .bottomBar) {
                            Button("Select All") {
                                if selection.count == viewModel.contacts.count {
                                    selection.removeAll()
                                } else {
                                    selection = Set(viewModel.contacts.map { $0.id })
                                }
                            }
                            
                            Spacer()
                            
                            Button(role: .destructive) {
                                isBulkDeleting = true
                                showingDeleteAlert = true
                            } label: {
                                Text("Delete \(selection.isEmpty ? "" : "(\(selection.count))")")
                                    .foregroundColor(selection.isEmpty ? .gray : .red)
                            }
                            .disabled(selection.isEmpty)
                        }
                    }
                }
                
                // FAB
                if editMode == .inactive {
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
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .navigationDestination(for: ChatUser.self) { contact in
                ChatDetailView(viewModel: viewModel, contact: contact)
            }
            .sheet(isPresented: $showingNewMessageSheet) {
                NewMessageView(viewModel: viewModel)
            }
            // Deletion Alert
            .alert(isBulkDeleting ? "Delete \(selection.count) Chats?" : "Delete Chat?", isPresented: $showingDeleteAlert) {
                Button("Delete", role: .destructive) {
                    if isBulkDeleting {
                        deleteSelectedChats()
                    } else if let contact = contactToDelete {
                        withAnimation {
                            viewModel.deleteConversation(for: contact)
                        }
                    }
                    resetDeletionState()
                }
                Button("Cancel", role: .cancel) {
                    resetDeletionState()
                }
            } message: {
                Text(isBulkDeleting ? "Are you sure you want to delete these conversations? This action cannot be undone." : "Are you sure you want to delete this conversation? This action cannot be undone.")
            }
        }
    }
    
    private func resetDeletionState() {
        contactToDelete = nil
        isBulkDeleting = false
    }
    
    private func deleteSelectedChats() {
        withAnimation {
            for id in selection {
                if let contact = viewModel.contacts.first(where: { $0.id == id }) {
                    viewModel.deleteConversation(for: contact)
                }
            }
            selection.removeAll()
            editMode = .inactive
        }
    }
}

#Preview {
    ChatListView()
}
