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
                        showingAnswer: $showingAnswer,
                        onBack: {
                            selectedGuide = nil
                            currentCardIndex = 0
                            showingAnswer = false
                        }
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
    let onBack: () -> Void
    
    var currentCard: Flashcard {
        guide.flashcards[currentIndex]
    }
    
    var body: some View {
        VStack(spacing: 24) {
            HStack {
                Button(action: onBack) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(.primaryBlue)
                    .font(.system(size: 16, weight: .medium))
                }
                
                Spacer()
                
                Text("\(currentIndex + 1) of \(guide.flashcards.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
                .opacity(0)
            }
            .padding(.horizontal)
            
            VStack(spacing: 4) {
                Text(guide.subject)
                    .font(.headline)
                    .foregroundColor(.primaryBlue)
                Text(guide.topic)
                    .font(.subheadline)
                    .foregroundColor(.secondaryBlue)
            }
            
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
                .foregroundColor(currentIndex == 0 ? .gray : .primaryBlue)
                
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
                .foregroundColor(currentIndex == guide.flashcards.count - 1 ? .gray : .primaryBlue)
            }
            .padding()
            
            Spacer()
        }
        .padding()
    }
}
