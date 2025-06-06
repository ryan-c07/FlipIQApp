//
//  StudyDataManager.swift
//  FlipIQApp
//
//  Created by _ on 6/5/25.
//


import SwiftUI
import Foundation


class StudyDataManager: ObservableObject {
    @Published var studyGuides: [StudyGuide] = []
    @Published var chatMessages: [ChatMessage] = []
    
    init() {
        loadSampleData()
    }
    
    func addStudyGuide(_ guide: StudyGuide) {
        studyGuides.append(guide)
    }
    
    func addChatMessage(_ message: ChatMessage) {
        chatMessages.append(message)
    }
    
    private func loadSampleData() {
        chatMessages = [
            ChatMessage(username: "Sarah", message: "Anyone studying for the calculus exam?",
                       timestamp: Date().addingTimeInterval(-3600), isCurrentUser: false),
            ChatMessage(username: "Mike", message: "Yes! I'm struggling with derivatives",
                       timestamp: Date().addingTimeInterval(-1800), isCurrentUser: false),
            ChatMessage(username: "You", message: "I found some great flashcards on limits",
                       timestamp: Date().addingTimeInterval(-900), isCurrentUser: true)
        ]
    }
}
