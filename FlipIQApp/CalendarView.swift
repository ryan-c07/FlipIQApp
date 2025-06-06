//
//  CalendarView.swift
//  FlipIQApp
//
//  Created by _ on 6/5/25.
//


import SwiftUI
import Foundation

struct CalendarView: View {
    @EnvironmentObject var dataManager: StudyDataManager
    @State private var selectedDate = Date()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundGray.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    HStack {
                        Button(action: { changeMonth(-1) }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.white)
                                .font(.title2)
                        }
                        
                        Spacer()
                        
                        Text(monthYearString(from: selectedDate))
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button(action: { changeMonth(1) }) {
                            Image(systemName: "chevron.right")
                                .foregroundColor(.white)
                                .font(.title2)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.primaryBlue)
                    )
                    .padding(.horizontal)
                    .padding(.top)
                    
                    VStack(spacing: 8) {
                        HStack {
                            ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { day in
                                Text(day)
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.secondaryBlue)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .padding(.horizontal)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                            ForEach(generateCalendarDays(), id: \.self) { date in
                                CalendarDayView(date: date, selectedDate: $selectedDate)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.black)
                    )
                    .padding()
                    
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(getStudySessionsFor(date: selectedDate), id: \.id) { session in
                                StudySessionCard(session: session)
                            }
                        }
                        .padding()
                    }
                    
                    Spacer()
                }
            }
            .navigationTitle("Study Calendar")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func changeMonth(_ direction: Int) {
        if let newDate = Calendar.current.date(byAdding: .month, value: direction, to: selectedDate) {
            selectedDate = newDate
        }
    }
    
    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date).uppercased()
    }
    
    private func generateCalendarDays() -> [Date] {
        let calendar = Calendar.current
        let startOfMonth = calendar.dateInterval(of: .month, for: selectedDate)?.start ?? selectedDate
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: startOfMonth)?.start ?? startOfMonth
        
        var days: [Date] = []
        for i in 0..<42 { 
            if let day = calendar.date(byAdding: .day, value: i, to: startOfWeek) {
                days.append(day)
            }
        }
        return days
    }
    
    private func getStudySessionsFor(date: Date) -> [StudySession] {
        let calendar = Calendar.current
        return dataManager.studyGuides.flatMap { guide in
            guide.studySchedule.filter { session in
                calendar.isDate(session.date, inSameDayAs: date)
            }
        }
    }
}

struct CalendarDayView: View {
    let date: Date
    @Binding var selectedDate: Date
    
    var body: some View {
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        let isToday = calendar.isDateInToday(date)
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let isCurrentMonth = calendar.isDate(date, equalTo: selectedDate, toGranularity: .month)
        
        Button(action: { selectedDate = date }) {
            Text("\(day)")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(isCurrentMonth ? .white : .gray)
                .frame(width: 32, height: 32)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? Color.primaryBlue : Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(isToday ? Color.lightBlue : Color.clear, lineWidth: 2)
                        )
                )
        }
    }
}

struct StudySessionCard: View {
    let session: StudySession
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(session.topic)
                    .font(.headline)
                    .foregroundColor(.primaryBlue)
                Text(session.date.formatted(date: .omitted, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Image(systemName: session.completed ? "checkmark.circle.fill" : "circle")
                .foregroundColor(session.completed ? .green : .gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
}
