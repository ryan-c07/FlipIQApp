//
//  StudyGuidesView.swift
//  FlipIQApp
//
//  Created by _ on 6/5/25.
//


import SwiftUI
import Foundation



struct StudyGuidesView: View {
    @EnvironmentObject var dataManager: StudyDataManager
    @EnvironmentObject var geminiService: GeminiAPIService
    @State private var showingCreateGuide = false
    @State private var selectedSubject = ""
    @State private var selectedTopic = ""
    @State private var isGenerating = false
    
    let subjects = ["Mathematics", "Science", "History", "Literature", "Computer Science", "Psychology"]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundGray.ignoresSafeArea()
                
                VStack {
                    HStack {
                        Text("FlipIQ")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(Color.primaryBlue)
                        Spacer()
                        Button(action: { showingCreateGuide = true }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(Color.primaryBlue)
                        }
                    }
                    .padding(.horizontal)
                    
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(dataManager.studyGuides) { guide in
                                StudyGuideCard(guide: guide)
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .sheet(isPresented: $showingCreateGuide) {
            CreateStudyGuideView(
                selectedSubject: $selectedSubject,
                selectedTopic: $selectedTopic,
                isGenerating: $isGenerating,
                subjects: subjects
            )
        }
    }
}

struct StudyGuideCard: View {
    let guide: StudyGuide
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    Text(guide.subject)
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(guide.topic)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                }
                Spacer()
                Text("\(guide.flashcards.count) cards")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Text("Created: \(guide.createdDate.formatted(date: .abbreviated, time: .omitted))")
                .font(.caption2)
                .foregroundColor(.white.opacity(0.7))
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.primaryBlue, Color.secondaryBlue],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
    }
}

struct CreateStudyGuideView: View {
    @Binding var selectedSubject: String
    @Binding var selectedTopic: String
    @Binding var isGenerating: Bool
    let subjects: [String]
    
    @EnvironmentObject var dataManager: StudyDataManager
    @EnvironmentObject var geminiService: GeminiAPIService
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundGray.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Text("Create Study Guide")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color.primaryBlue)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Select Subject")
                            .font(.headline)
                            .foregroundColor(Color.secondaryBlue)
                        
                        Picker("Subject", selection: $selectedSubject) {
                            ForEach(subjects, id: \.self) { subject in
                                Text(subject).tag(subject)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Enter Topic")
                            .font(.headline)
                            .foregroundColor(Color.secondaryBlue)
                        
                        TextField("e.g., Derivatives in Calculus", text: $selectedTopic)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                    }
                    
                    Button(action: generateStudyGuide) {
                        HStack {
                            if isGenerating {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            }
                            Text(isGenerating ? "Generating..." : "Generate Study Guide")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.primaryBlue)
                        .cornerRadius(12)
                    }
                    .disabled(selectedSubject.isEmpty || selectedTopic.isEmpty || isGenerating)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() }
            )
        }
    }
    
    private func generateStudyGuide() {
        isGenerating = true
        
        Task {
            if let guide = await geminiService.generateStudyGuide(
                subject: selectedSubject,
                topic: selectedTopic
            ) {
                await MainActor.run {
                    dataManager.addStudyGuide(guide)
                    isGenerating = false
                    dismiss()
                }
            }
        }
    }
}
