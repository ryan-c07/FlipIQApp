//
//  ContentView.swift
//  FlipIQApp
//
//  Created by _ on 6/5/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var dataManager = StudyDataManager()
    @StateObject private var geminiService = GeminiAPIService()
    
    var body: some View {
        TabView {
            StudyGuidesView()
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("Study Guides")
                }
            
            CalendarView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Calendar")
                }
            
            FlashcardsView()
                .tabItem {
                    Image(systemName: "rectangle.stack.fill")
                    Text("Flashcards")
                }
            
            CommunityView()
                .tabItem {
                    Image(systemName: "person.2.fill")
                    Text("Community")
                }
        }
        .accentColor(.primaryBlue)
        .environmentObject(dataManager)
        .environmentObject(geminiService)
    }
}


#Preview {
    ContentView()
}
