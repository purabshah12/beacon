//
//  HomeScreen.swift
//  Beacon
//
//  Created by Eswar Karavadi on 11/7/25.
//

import SwiftUI

struct HomeScreen: View {
    let onNavigateToFinder: () -> Void
    let onNavigateToSearcher: () -> Void
    
    @State private var animateGradient = false

    var body: some View {
        ZStack {
            // Animated gradient background
            AppColors.backgroundGradient
                .ignoresSafeArea()
            
            // Floating orbs for depth
            GeometryReader { geometry in
                ZStack {
                    Circle()
                        .fill(AppColors.gradientStart.opacity(0.3))
                        .frame(width: 200, height: 200)
                        .blur(radius: 60)
                        .offset(x: -50, y: -100)
                    
                    Circle()
                        .fill(AppColors.gradientEnd.opacity(0.2))
                        .frame(width: 250, height: 250)
                        .blur(radius: 80)
                        .offset(x: geometry.size.width - 100, y: geometry.size.height - 150)
                }
            }
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header with stats
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Text("🏅")
                                .font(.system(size: 32))
                            Text("Welcome, Eswar!")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        Text("You've reunited 2 Terps this month 🎉")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.top, 60)
                    
                    // Mini challenges section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("🎯")
                                .font(.system(size: 20))
                            Text("Today's Missions")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 24)
                        
                        VStack(spacing: 12) {
                            // Challenge 1
                            ChallengeCard(
                                icon: "checkmark.seal.fill",
                                title: "Help match 3 new found items today",
                                progress: 0,
                                total: 3,
                                color: AppColors.success
                            )
                            
                            // Challenge 2
                            ChallengeCard(
                                icon: "location.fill",
                                title: "Check top matches near ESJ",
                                progress: 0,
                                total: 1,
                                color: AppColors.accent
                            )
                        }
                        .padding(.horizontal, 24)
                    }
                    
                    // Quick action buttons - MAIN FUNCTIONALITY
                    VStack(spacing: 20) {
                        // Found something button - HERO
                        Button(action: onNavigateToFinder) {
                            VStack(spacing: 12) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 32))
                                    Spacer()
                                    Image(systemName: "arrow.right.circle.fill")
                                        .font(.system(size: 24))
                                        .opacity(0.8)
                                }
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Found Something?")
                                        .font(.system(size: 24, weight: .bold))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    Text("Help reunite a Terp with their lost item")
                                        .font(.system(size: 14, weight: .medium))
                                        .opacity(0.9)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                            .foregroundColor(.white)
                            .padding(24)
                            .background(
                                ZStack {
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(AppColors.primaryGradient)
                                    
                                    // Glow effect
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(AppColors.primary.opacity(0.3))
                                        .blur(radius: 20)
                                        .offset(y: 10)
                                }
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .shadow(color: AppColors.primary.opacity(0.6), radius: 25, x: 0, y: 12)
                        }
                        
                        // Lost something button - SECONDARY HERO
                        Button(action: onNavigateToSearcher) {
                            VStack(spacing: 12) {
                                HStack {
                                    Image(systemName: "magnifyingglass.circle.fill")
                                        .font(.system(size: 32))
                                    Spacer()
                                    Image(systemName: "arrow.right.circle.fill")
                                        .font(.system(size: 24))
                                        .opacity(0.8)
                                }
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Lost Something?")
                                        .font(.system(size: 24, weight: .bold))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    Text("Search our database to find your item")
                                        .font(.system(size: 14, weight: .medium))
                                        .opacity(0.9)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                            .foregroundColor(.white)
                            .padding(24)
                            .background(
                                ZStack {
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(
                                            LinearGradient(
                                                colors: [AppColors.accentGradientStart, AppColors.accentGradientEnd],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                    
                                    // Glow effect
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(AppColors.accent.opacity(0.3))
                                        .blur(radius: 20)
                                        .offset(y: 10)
                                }
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .shadow(color: AppColors.accent.opacity(0.6), radius: 25, x: 0, y: 12)
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    // Leaderboard ranking
                    VStack(spacing: 16) {
                        HStack {
                            Text("🏆")
                                .font(.system(size: 20))
                            Text("Your Ranking")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 24)
                        
                        // Ranking card
                        HStack(spacing: 20) {
                            // Rank badge
                            ZStack {
                                Circle()
                                    .fill(AppColors.primaryGradient)
                                    .frame(width: 70, height: 70)
                                
                                VStack(spacing: 2) {
                                    Text("#5")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(.white)
                                    Text("rank")
                                        .font(.system(size: 10, weight: .medium))
                                        .foregroundColor(.white.opacity(0.8))
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("You're the 5th top user!")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                                
                                HStack(spacing: 4) {
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 14))
                                        .foregroundColor(AppColors.warning)
                                    Text("48 points")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(AppColors.textSecondary)
                                }
                                
                                Text("12 points to rank #4")
                                    .font(.system(size: 13))
                                    .foregroundColor(AppColors.textTertiary)
                            }
                            
                            Spacer()
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(AppColors.glassEffect)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(AppColors.surface)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(
                                            LinearGradient(
                                                colors: [AppColors.warning.opacity(0.5), AppColors.accent.opacity(0.3)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 2
                                        )
                                )
                        )
                        .padding(.horizontal, 24)
                    }
                    .padding(.bottom, 40)
                }
            }
        }
    }
}

// Challenge card component
struct ChallengeCard: View {
    let icon: String
    let title: String
    let progress: Int
    let total: Int
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
                .frame(width: 40, height: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white)
                
                HStack(spacing: 8) {
                    ProgressView(value: Double(progress), total: Double(total))
                        .tint(color)
                        .frame(maxWidth: 120)
                    
                    Text("\(progress)/\(total)")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AppColors.glassEffect)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(AppColors.surface)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

#Preview {
    HomeScreen(onNavigateToFinder: {}, onNavigateToSearcher: {})
}
