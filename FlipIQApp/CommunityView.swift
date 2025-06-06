//
//  CommunityView.swift
//  FlipIQApp
//
//  Created by _ on 6/5/25.
//


import SwiftUI
import Foundation

struct CommunityView: View {
    @EnvironmentObject var dataManager: StudyDataManager
    @State private var newMessage = ""
    
    var body: some View {
        NavigationView {
            VStack {

                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(dataManager.chatMessages) { message in
                            ChatMessageView(message: message)
                        }
                    }
                    .padding()
                }
                

                HStack {
                    TextField("Type a message...", text: $newMessage)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button("Send") {
                        sendMessage()
                    }
                    .disabled(newMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.roundedRectangle)
                    .tint(Color.primaryBlue)
                }
                .padding()
            }
            .navigationTitle("Study Community")
        }
    }
    
    private func sendMessage() {
        let trimmedMessage = newMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedMessage.isEmpty else { return }
        
        let message = ChatMessage(
            username: "You",
            message: trimmedMessage,
            timestamp: Date(),
            isCurrentUser: true
        )
        
        dataManager.addChatMessage(message)
        newMessage = ""
    }
}

struct ChatMessageView: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isCurrentUser {
                Spacer()
            }
            
            VStack(alignment: message.isCurrentUser ? .trailing : .leading, spacing: 4) {
                if !message.isCurrentUser {
                    Text(message.username)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.secondaryBlue)
                }
                
                Text(message.message)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        message.isCurrentUser ? Color.primaryBlue : Color.gray.opacity(0.2)
                    )
                    .foregroundColor(message.isCurrentUser ? .white : .primary)
                    .cornerRadius(16)
                
                Text(message.timestamp.formatted(date: .omitted, time: .shortened))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            if !message.isCurrentUser {
                Spacer()
            }
        }
    }
}
