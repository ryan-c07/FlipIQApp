//
//  GeminiAPIService.swift
//  FlipIQApp
//
//  Created by _ on 6/5/25.
//


import SwiftUI
import Foundation


struct GeminiRequest: Codable {
    let contents: [GeminiContent]
    let generationConfig: GeminiGenerationConfig
}

struct GeminiContent: Codable {
    let parts: [GeminiPart]
}

struct GeminiPart: Codable {
    let text: String
}

struct GeminiGenerationConfig: Codable {
    let temperature: Double
    let topK: Int
    let topP: Double
    let maxOutputTokens: Int
}

struct GeminiResponse: Codable {
    let candidates: [GeminiCandidate]
}

struct GeminiCandidate: Codable {
    let content: GeminiContent
}

struct GeminiError: Codable {
    let error: GeminiErrorDetail
}

struct GeminiErrorDetail: Codable {
    let code: Int
    let message: String
    let status: String
}

class GeminiAPIService: ObservableObject {
    private let apiKey = "YOUR_API_KEY_HERE" // Replace with your actual API key
    private let baseURL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent"
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func generateStudyGuide(subject: String, topic: String) async -> StudyGuide? {
        await MainActor.run { isLoading = true }
        defer { Task { await MainActor.run { isLoading = false } } }
        
        do {
            let flashcards = await generateFlashcards(subject: subject, topic: topic)
            
            let studySessions = generateStudySchedule(for: topic)
            
            return StudyGuide(
                subject: subject,
                topic: topic,
                flashcards: flashcards,
                createdDate: Date(),
                studySchedule: studySessions
            )
        } catch {
            await MainActor.run {
                errorMessage = "Failed to generate study guide: \(error.localizedDescription)"
            }
            return nil
        }
    }
    
    private func generateFlashcards(subject: String, topic: String) async -> [Flashcard] {
        let prompt = """
        Create 10 educational flashcards for the topic "\(topic)" in the subject "\(subject)".
        
        Format your response as a JSON array where each flashcard has exactly these fields:
        - "question": A clear, specific question about the topic
        - "answer": A comprehensive but concise answer
        
        Make the questions progressively more challenging, covering:
        1. Basic definitions and concepts
        2. How concepts relate to each other
        3. Practical applications
        4. Critical thinking questions
        5. Problem-solving scenarios
        
        Ensure answers are educational, accurate, and appropriate for studying.
        
        Return only the JSON array, no additional text or formatting.
        
        Example format:
        [
            {
                "question": "What is the definition of [concept]?",
                "answer": "A detailed explanation of the concept..."
            }
        ]
        """
        
        do {
            let response = try await callGeminiAPI(prompt: prompt)
            return parseFlashcardsFromResponse(response) ?? generateFallbackFlashcards(subject: subject, topic: topic)
        } catch {
            print("Error generating flashcards: \(error)")
            return generateFallbackFlashcards(subject: subject, topic: topic)
        }
    }
    
    private func callGeminiAPI(prompt: String) async throws -> String {
        guard !apiKey.isEmpty && apiKey != "YOUR_GEMINI_API_KEY" else {
            throw GeminiAPIError.invalidAPIKey
        }
        
        let url = URL(string: "\(baseURL)?key=\(apiKey)")!
        
        let request = GeminiRequest(
            contents: [
                GeminiContent(parts: [GeminiPart(text: prompt)])
            ],
            generationConfig: GeminiGenerationConfig(
                temperature: 0.7,
                topK: 40,
                topP: 0.95,
                maxOutputTokens: 2048
            )
        )
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(request)
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        if let httpResponse = response as? HTTPURLResponse {
            guard 200...299 ~= httpResponse.statusCode else {
                if let errorData = try? JSONDecoder().decode(GeminiError.self, from: data) {
                    throw GeminiAPIError.apiError(errorData.error.message)
                } else {
                    throw GeminiAPIError.httpError(httpResponse.statusCode)
                }
            }
        }
        
        let geminiResponse = try JSONDecoder().decode(GeminiResponse.self, from: data)
        
        guard let firstCandidate = geminiResponse.candidates.first,
              let firstPart = firstCandidate.content.parts.first else {
            throw GeminiAPIError.invalidResponse
        }
        
        return firstPart.text
    }
    
    private func parseFlashcardsFromResponse(_ response: String) -> [Flashcard]? {
        let cleanedResponse = response
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let data = cleanedResponse.data(using: .utf8) else {
            print("Failed to convert response to data")
            return nil
        }
        
        do {
            let flashcardData = try JSONDecoder().decode([[String: String]].self, from: data)
            
            let flashcards = flashcardData.compactMap { dict -> Flashcard? in
                guard let question = dict["question"],
                      let answer = dict["answer"],
                      !question.isEmpty,
                      !answer.isEmpty else {
                    return nil
                }
                
                return Flashcard(question: question, answer: answer)
            }
            
            return flashcards.isEmpty ? nil : flashcards
            
        } catch {
            print("JSON parsing error: \(error)")
            print("Response was: \(cleanedResponse)")
            return nil
        }
    }
    
    private func generateFallbackFlashcards(subject: String, topic: String) -> [Flashcard] {
        return [
            Flashcard(
                question: "What is the main concept of \(topic) in \(subject)?",
                answer: "This is a fundamental concept in \(subject) that involves understanding \(topic) and its key principles."
            ),
            Flashcard(
                question: "How does \(topic) relate to other concepts in \(subject)?",
                answer: "\(topic) connects to various other concepts in \(subject) through shared principles and applications."
            ),
            Flashcard(
                question: "What are the practical applications of \(topic)?",
                answer: "\(topic) has several real-world applications including problem-solving scenarios and practical implementations."
            ),
            Flashcard(
                question: "What are the key components or elements of \(topic)?",
                answer: "The main components of \(topic) include several interconnected elements that work together to form the complete concept."
            ),
            Flashcard(
                question: "How would you explain \(topic) to someone new to \(subject)?",
                answer: "I would explain \(topic) by starting with the basic definition and building up to more complex applications and examples."
            )
        ]
    }
    
    private func generateStudySchedule(for topic: String) -> [StudySession] {
        var sessions: [StudySession] = []
        let calendar = Calendar.current
        
        let scheduleItems = [
            "Introduction and Overview",
            "Core Concepts",
            "Detailed Study",
            "Practice Problems",
            "Review and Reinforcement",
            "Advanced Applications",
            "Final Review and Testing"
        ]
        
        for (index, item) in scheduleItems.enumerated() {
            if let date = calendar.date(byAdding: .day, value: index, to: Date()) {
                sessions.append(StudySession(
                    date: date,
                    topic: "\(topic): \(item)",
                    completed: false
                ))
            }
        }
        
        return sessions
    }
}

enum GeminiAPIError: LocalizedError {
    case invalidAPIKey
    case invalidResponse
    case apiError(String)
    case httpError(Int)
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .invalidAPIKey:
            return "Invalid API key. Please check your Gemini API key."
        case .invalidResponse:
            return "Invalid response from Gemini API."
        case .apiError(let message):
            return "API Error: \(message)"
        case .httpError(let code):
            return "HTTP Error: \(code)"
        case .networkError:
            return "Network connection error."
        }
    }
}
