//
//  ResultScreen.swift
//  Beacon
//
//  Created by Eswar Karavadi on 11/7/25.
//

import SwiftUI
import MapKit

struct ResultScreen: View {
    let result: SearchResult?
    let onBack: () -> Void
    @State private var image: UIImage?
    @State private var isLoadingImage = true

    var body: some View {
        ZStack {
            // Gradient background
            AppColors.backgroundGradient
                .ignoresSafeArea()
            
            if let result = result {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Custom header with back button
                        HStack {
                            Button(action: onBack) {
                                ZStack {
                                    Circle()
                                        .fill(AppColors.glassEffect)
                                        .frame(width: 44, height: 44)
                                    
                                    Image(systemName: "arrow.left")
                                        .foregroundColor(.white)
                                        .font(.system(size: 18, weight: .semibold))
                                }
                            }
                            
                            Spacer()
                            
                            Text("Match Found!")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Circle()
                                .fill(Color.clear)
                                .frame(width: 44, height: 44)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        
                        // Confidence Score Card
                        VStack(spacing: 20) {
                            ZStack {
                                Circle()
                                    .stroke(AppColors.surfaceLight, lineWidth: 12)
                                    .frame(width: 140, height: 140)
                                
                                Circle()
                                    .trim(from: 0, to: result.confidence)
                                    .stroke(AppColors.accentGradient, lineWidth: 12)
                                    .frame(width: 140, height: 140)
                                    .rotationEffect(.degrees(-90))
                                
                                VStack(spacing: 4) {
                                    Text("\(Int(result.confidence * 100))%")
                                        .font(.system(size: 38, weight: .bold))
                                        .foregroundColor(.white)
                                    Text("Match")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(AppColors.textSecondary)
                                }
                            }
                            .shadow(color: AppColors.accent.opacity(0.3), radius: 20)
                            
                            Text(getConfidenceText(result.confidence))
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(getConfidenceColor(result.confidence))
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(getConfidenceColor(result.confidence).opacity(0.2))
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                        }
                        .padding(.vertical, 20)
                        .frame(maxWidth: .infinity)
                        .glassCard()
                        .padding(.horizontal, 20)
                        
                        // Image Card
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "photo.fill")
                                    .foregroundColor(AppColors.primary)
                                Text("Found Item")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            
                            if isLoadingImage {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(AppColors.surfaceLight)
                                        .frame(height: 280)
                                    
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: AppColors.primary))
                                }
                            } else if let image = image {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 280)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(AppColors.primaryGradient, lineWidth: 2)
                                    )
                            } else {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(AppColors.surfaceLight)
                                        .frame(height: 280)
                                    
                                    VStack(spacing: 12) {
                                        Image(systemName: "photo.slash")
                                            .font(.system(size: 40))
                                            .foregroundColor(AppColors.textTertiary)
                                        Text("Image unavailable")
                                            .foregroundColor(AppColors.textSecondary)
                                    }
                                }
                            }
                        }
                        .padding(20)
                        .glassCard()
                        .padding(.horizontal, 20)
                        
                        // Location Card
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "mappin.circle.fill")
                                    .foregroundColor(AppColors.accent)
                                Text("Location")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            
                            HStack {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Found at")
                                        .font(.system(size: 13))
                                        .foregroundColor(AppColors.textSecondary)
                                    Text(result.location)
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    if let url = getMapURL(for: result.location) {
                                        UIApplication.shared.open(url)
                                    }
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "map.fill")
                                        Text("View")
                                    }
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 18)
                                    .padding(.vertical, 10)
                                    .background(AppColors.accentGradient)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                            }
                        }
                        .padding(20)
                        .glassCard()
                        .padding(.horizontal, 20)
                        
                        // Search Query Card
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "text.bubble.fill")
                                    .foregroundColor(AppColors.primary)
                                Text("Your Search")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            
                            Text("\"\(result.description)\"")
                                .font(.system(size: 15))
                                .foregroundColor(AppColors.textSecondary)
                                .italic()
                                .lineSpacing(4)
                        }
                        .padding(20)
                        .glassCard()
                        .padding(.horizontal, 20)
                        
                        // Action Buttons
                        VStack(spacing: 12) {
                            Button(action: {
                                if let phoneURL = URL(string: "tel://3014051000") {
                                    UIApplication.shared.open(phoneURL)
                                }
                            }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "phone.fill")
                                        .font(.system(size: 18))
                                    Text("Contact Lost & Found")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(AppColors.primaryGradient)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .shadow(color: AppColors.primary.opacity(0.4), radius: 15, x: 0, y: 8)
                            }
                            
                            Button(action: {
                                let email = "lostandfound@umd.edu"
                                if let emailURL = URL(string: "mailto:\(email)?subject=Lost Item Inquiry&body=I found a potential match for my lost item: \(result.description)") {
                                    UIApplication.shared.open(emailURL)
                                }
                            }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "envelope.fill")
                                        .font(.system(size: 18))
                                    Text("Send Email")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(AppColors.surfaceLight)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 32)
                    }
                }
            } else {
                // No results state
                VStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .fill(AppColors.primaryGradient)
                            .frame(width: 140, height: 140)
                            .blur(radius: 40)
                            .opacity(0.5)
                        
                        Circle()
                            .fill(AppColors.surfaceLight)
                            .frame(width: 120, height: 120)
                        
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 50))
                            .foregroundColor(AppColors.textSecondary)
                    }
                    
                    VStack(spacing: 12) {
                        Text("No Match Found")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Try searching with different keywords")
                            .font(.system(size: 15))
                            .foregroundColor(AppColors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    Button(action: onBack) {
                        HStack(spacing: 12) {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Search Again")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 16)
                        .background(AppColors.primaryGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .shadow(color: AppColors.primary.opacity(0.4), radius: 15, x: 0, y: 8)
                    }
                }
                .padding(.horizontal, 40)
            }
        }
        .onAppear {
            loadImage()
        }
    }

    private func loadImage() {
        guard let result = result,
              let url = URL(string: result.imageUrl) else {
            isLoadingImage = false
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                isLoadingImage = false
                if let data = data, let loadedImage = UIImage(data: data) {
                    image = loadedImage
                }
            }
        }.resume()
    }

    private func getConfidenceColor(_ confidence: Double) -> Color {
        if confidence >= 0.8 {
            return AppColors.success
        } else if confidence >= 0.6 {
            return AppColors.warning
        } else {
            return AppColors.error
        }
    }
    
    private func getConfidenceText(_ confidence: Double) -> String {
        if confidence >= 0.8 {
            return "Excellent Match!"
        } else if confidence >= 0.6 {
            return "Good Match"
        } else {
            return "Possible Match"
        }
    }

    private func getMapURL(for location: String) -> URL? {
        let umdLat = 38.9869
        let umdLng = -76.9426
        let query = location.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? location
        let appleMapsURL = "https://maps.apple.com/?q=\(query)&ll=\(umdLat),\(umdLng)"
        return URL(string: appleMapsURL)
    }
}

#Preview {
    let sampleResult = SearchResult(
        imageUrl: "https://example.com/image.jpg",
        confidence: 0.85,
        location: "McKeldin Library",
        description: "black leather wallet"
    )
    ResultScreen(result: sampleResult, onBack: {})
}
