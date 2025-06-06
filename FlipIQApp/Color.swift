//
//  Color.swift
//  FlipIQApp
//
//  Created by _ on 6/5/25.
//


import SwiftUI
import Foundation

extension Color {
    static let primaryBlue = Color(red: 0.25, green: 0.35, blue: 0.75)
    static let secondaryBlue = Color(red: 0.15, green: 0.25, blue: 0.65)
    static let lightBlue = Color(red: 0.35, green: 0.45, blue: 0.85)
    static let backgroundGray = Color(red: 0.95, green: 0.95, blue: 0.92)
}

extension ShapeStyle where Self == LinearGradient {
    static var primaryBlueGradient: LinearGradient {
        LinearGradient(
            colors: [Color.primaryBlue, Color.secondaryBlue],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
