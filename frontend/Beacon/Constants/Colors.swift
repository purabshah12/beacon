//
//  Colors.swift
//  Beacon
//
//  Created by Eswar Karavadi on 11/7/25.
//

import SwiftUI

struct AppColors {
    // Gradient colors - Modern purple/blue theme
    static let gradientStart = Color(hex: "#667eea")
    static let gradientEnd = Color(hex: "#764ba2")
    static let accentGradientStart = Color(hex: "#f093fb")
    static let accentGradientEnd = Color(hex: "#f5576c")
    
    // Base colors
    static let background = Color(hex: "#0a0a0f")
    static let surface = Color(hex: "#1a1a24")
    static let surfaceLight = Color(hex: "#252536")
    
    // Text colors
    static let textPrimary = Color.white
    static let textSecondary = Color(hex: "#a0a0b8")
    static let textTertiary = Color(hex: "#6b6b85")
    
    // Accent colors
    static let primary = Color(hex: "#667eea")
    static let accent = Color(hex: "#f093fb")
    static let success = Color(hex: "#4ade80")
    static let error = Color(hex: "#f87171")
    static let warning = Color(hex: "#fbbf24")
    
    // Gradients
    static let primaryGradient = LinearGradient(
        colors: [gradientStart, gradientEnd],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let accentGradient = LinearGradient(
        colors: [accentGradientStart, accentGradientEnd],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let backgroundGradient = LinearGradient(
        colors: [Color(hex: "#0a0a0f"), Color(hex: "#1a1a24")],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let glassEffect = Color.white.opacity(0.1)
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// Glassmorphism card modifier
struct GlassCard: ViewModifier {
    var cornerRadius: CGFloat = 20
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(AppColors.glassEffect)
                    .background(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(AppColors.surface)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
    }
}

extension View {
    func glassCard(cornerRadius: CGFloat = 20) -> some View {
        modifier(GlassCard(cornerRadius: cornerRadius))
    }
}
