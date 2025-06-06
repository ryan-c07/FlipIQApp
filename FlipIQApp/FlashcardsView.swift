//
//  FlashcardsView.swift
//  FlipIQApp
//
//  Created by _ on 6/5/25.
//
import SwiftUI
import Foundation

struct FlashcardsView: View {
    @EnvironmentObject var dataManager: StudyDataManager
    @State private var selectedGuide: StudyGuide?
    @State private var currentCardIndex = 0
    @State private var showingAnswer = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundGray.ignoresSafeArea()
                
                if let guide = selectedGuide {
                    FlashcardSessionView(
                        guide: guide,
                        currentIndex: $currentCardIndex,
                        showingAnswer: $showingAnswer
                    )
                } else {
                    FlashcardSelectionView(selectedGuide: $selectedGuide)
                }
            }
        }
    }
}

struct FlashcardSelectionView: View {
    @EnvironmentObject var dataManager: StudyDataManager
    @Binding var selectedGuide: StudyGuide?
    
    var body: some View {
        VStack {
            Text("Select Study Guide")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primaryBlue)
                .padding()
            
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(dataManager.studyGuides) { guide in
                        Button(action: { selectedGuide = guide }) {
                            StudyGuideCard(guide: guide)
                        }
                    }
                }
                .padding()
            }
        }
    }
}

struct FlashcardSessionView: View {
    let guide: StudyGuide
    @Binding var currentIndex: Int
    @Binding var showingAnswer: Bool
    
    var currentCard: Flashcard {
        guide.flashcards[currentIndex]
    }
    
    var body: some View {
        VStack(spacing: 24) {
            HStack {
                Text("\(currentIndex + 1) of \(guide.flashcards.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.horizontal)
            
            VStack(spacing: 20) {
                Text(showingAnswer ? "Answer" : "Question")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondaryBlue)
                
                Text(showingAnswer ? currentCard.answer : currentCard.question)
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primaryBlue)
                    .padding()
                    .frame(maxWidth: .infinity, minHeight: 200)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(radius: 4)
            }
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showingAnswer.toggle()
                }
            }
            
            HStack(spacing: 20) {
                Button("Previous") {
                    if currentIndex > 0 {
                        currentIndex -= 1
                        showingAnswer = false
                    }
                }
                .disabled(currentIndex == 0)
                
                Button("Flip Card") {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showingAnswer.toggle()
                    }
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.roundedRectangle)
                .tint(Color.primaryBlue)
                
                Button("Next") {
                    if currentIndex < guide.flashcards.count - 1 {
                        currentIndex += 1
                        showingAnswer = false
                    }
                }
                .disabled(currentIndex == guide.flashcards.count - 1)
            }
            .padding()
        }
        .padding()
    }
}
