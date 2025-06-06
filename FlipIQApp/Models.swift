//
//  Models.swift
//  FlipIQApp
//
//  Created by _ on 6/5/25.
//

import SwiftUI
import Foundation

struct StudyGuide: Identifiable, Codable {
    let id = UUID()
    let subject: String
    let topic: String
    let flashcards: [Flashcard]
    let createdDate: Date
    let studySchedule: [StudySession]
}

struct Flashcard: Identifiable, Codable {
    let id = UUID()
    let question: String
    let answer: String
    var isFlipped: Bool = false
}

struct StudySession: Identifiable, Codable {
    let id = UUID()
    let date: Date
    let topic: String
    let completed: Bool
}

struct ChatMessage: Identifiable, Codable {
    let id = UUID()
    let username: String
    let message: String
    let timestamp: Date
    let isCurrentUser: Bool
}
