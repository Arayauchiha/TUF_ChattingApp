import SwiftUI

struct NewMessageView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: ChatViewModel
    
    @State private var recipientName = ""
    @State private var messageText = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Recipient") {
                    HStack {
                        Text("To:")
                            .foregroundColor(.secondary)
                        TextField("Name", text: $recipientName)
                    }
                }
                
                Section("Message") {
                    TextEditor(text: $messageText)
                        .frame(minHeight: 150)
                }
            }
            .navigationTitle("New Message")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Send") {
                        viewModel.startNewChat(with: recipientName, messageText: messageText)
                        dismiss()
                    }
                    .disabled(recipientName.isEmpty || messageText.isEmpty)
                }
            }
        }
    }
}

#Preview {
    NewMessageView(viewModel: ChatViewModel())
}
