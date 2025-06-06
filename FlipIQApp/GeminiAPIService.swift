//
//  GeminiAPIService.swift
//  FlipIQApp
//
//  Created by _ on 6/5/25.
//


import SwiftUI
import Foundation


class GeminiAPIService: ObservableObject {
    private let apiKey = "YOUR_GEMINI_API_KEY"
    
    func generateStudyGuide(subject: String, topic: String) async -> StudyGuide? {
        let sampleFlashcards = [
            Flashcard(question: "What is the main concept of \(topic)?",
                     answer: "This is a comprehensive explanation of \(topic) in \(subject)."),
            Flashcard(question: "How does \(topic) relate to other concepts?",
                     answer: "It connects to various aspects of \(subject) through..."),
            Flashcard(question: "What are the key applications of \(topic)?",
                     answer: "The main applications include practical uses in...")
        ]
        
        let studySessions = generateStudySchedule(for: topic)
        
        return StudyGuide(
            subject: subject,
            topic: topic,
            flashcards: sampleFlashcards,
            createdDate: Date(),
            studySchedule: studySessions
        )
    }
    
    private func generateStudySchedule(for topic: String) -> [StudySession] {
        var sessions: [StudySession] = []
        let calendar = Calendar.current
        
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: i, to: Date()) {
                sessions.append(StudySession(
                    date: date,
                    topic: "Review: \(topic) - Day \(i + 1)",
                    completed: false
                ))
            }
        }
        return sessions
    }
}
