//
//  SplashScreen.swift
//  Beacon
//
//  Created by Eswar Karavadi on 11/7/25.
//

import SwiftUI

struct SplashScreen: View {
    @State private var isAnimating = false
    @State private var pulseAnimation = false
    @State private var showSubtext = false
    
    var body: some View {
        ZStack {
            // Background gradient
            AppColors.backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Animated beacon icon/symbol
                ZStack {
                    // Outer pulsing circles
                    Circle()
                        .stroke(AppColors.primary.opacity(0.3), lineWidth: 3)
                        .frame(width: 120, height: 120)
                        .scaleEffect(pulseAnimation ? 1.3 : 1.0)
                        .opacity(pulseAnimation ? 0 : 1)
                    
                    Circle()
                        .stroke(AppColors.accent.opacity(0.3), lineWidth: 3)
                        .frame(width: 120, height: 120)
                        .scaleEffect(pulseAnimation ? 1.5 : 1.0)
                        .opacity(pulseAnimation ? 0 : 1)
                    
                    // Inner gradient circle
                    Circle()
                        .fill(AppColors.primaryGradient)
                        .frame(width: 100, height: 100)
                        .overlay(
                            // Beacon waves
                            VStack(spacing: 4) {
                                ForEach(0..<3) { index in
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(Color.white)
                                        .frame(width: 40 - CGFloat(index * 8), height: 4)
                                        .opacity(isAnimating ? 1.0 : 0.3)
                                        .animation(
                                            Animation.easeInOut(duration: 0.8)
                                                .repeatForever(autoreverses: true)
                                                .delay(Double(index) * 0.2),
                                            value: isAnimating
                                        )
                                }
                            }
                        )
                        .shadow(color: AppColors.primary.opacity(0.5), radius: 20, x: 0, y: 0)
                }
                .scaleEffect(isAnimating ? 1.0 : 0.8)
                .opacity(isAnimating ? 1.0 : 0.0)
                
                // App name
                Text("Beacon")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.primaryGradient)
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .offset(y: isAnimating ? 0 : 20)
                
                // Tagline
                if showSubtext {
                    Text("Find What Matters")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppColors.textSecondary)
                        .opacity(showSubtext ? 1.0 : 0.0)
                }
            }
        }
        .onAppear {
            // Initial fade in and scale
            withAnimation(.easeOut(duration: 0.8)) {
                isAnimating = true
            }
            
            // Start pulsing animation
            withAnimation(
                Animation.easeInOut(duration: 1.5)
                    .repeatForever(autoreverses: false)
            ) {
                pulseAnimation = true
            }
            
            // Show subtext after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeIn(duration: 0.5)) {
                    showSubtext = true
                }
            }
        }
    }
}

#Preview {
    SplashScreen()
}

