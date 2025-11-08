//
//  SearcherScreen.swift
//  Beacon
//
//  Created by Eswar Karavadi on 11/7/25.
//

import SwiftUI

struct SearcherScreen: View {
    let onBack: () -> Void
    let onResultsFound: (SearchResult) -> Void
    
    @State private var searchDescription = ""
    @State private var selectedLocation = ""
    @State private var isSearching = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        ZStack {
            // Gradient background
            AppColors.backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom header
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
                    
                    Text("Find Your Item")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 44, height: 44)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 24)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Description Card
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "text.alignleft")
                                    .foregroundColor(AppColors.primary)
                                Text("Description")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            
                            ZStack(alignment: .topLeading) {
                                if searchDescription.isEmpty {
                                    Text("e.g., red backpack with laptop")
                                        .foregroundColor(AppColors.textTertiary)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 14)
                                        .font(.system(size: 16))
                                }
                                
                                TextEditor(text: $searchDescription)
                                    .frame(minHeight: 120)
                                    .padding(12)
                                    .background(AppColors.surfaceLight)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .foregroundColor(.white)
                                    .font(.system(size: 16))
                                    .scrollContentBackground(.hidden)
                            }
                            
                            // Tip
                            HStack(spacing: 10) {
                                Image(systemName: "sparkles")
                                    .foregroundColor(AppColors.accent)
                                    .font(.system(size: 14))
                                Text("Be specific for better matches")
                                    .font(.system(size: 13))
                                    .foregroundColor(AppColors.textSecondary)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(AppColors.accent.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .padding(20)
                        .glassCard()
                        
                        // Location Card
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "mappin.circle.fill")
                                    .foregroundColor(AppColors.accent)
                                Text("Location")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            
                            Text("Where did you lose it? (optional)")
                                .font(.system(size: 13))
                                .foregroundColor(AppColors.textSecondary)
                            
                            Menu {
                                Button(action: {
                                    selectedLocation = ""
                                }) {
                                    HStack {
                                        Text("Any location")
                                        Spacer()
                                        if selectedLocation.isEmpty {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                                
                                Divider()
                                
                                ForEach(Config.umdBuildings, id: \.self) { building in
                                    Button(action: {
                                        selectedLocation = building
                                    }) {
                                        HStack {
                                            Text(building)
                                            Spacer()
                                            if selectedLocation == building {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(selectedLocation.isEmpty ? "Select location" : selectedLocation)
                                        .foregroundColor(selectedLocation.isEmpty ? AppColors.textTertiary : .white)
                                        .font(.system(size: 16))
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(AppColors.textSecondary)
                                        .font(.system(size: 14))
                                }
                                .padding(16)
                                .background(AppColors.surfaceLight)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                        .padding(20)
                        .glassCard()
                        
                        // Search Button
                        Button(action: performSearch) {
                            Group {
                                if isSearching {
                                    HStack(spacing: 12) {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        Text("Searching...")
                                            .font(.system(size: 18, weight: .semibold))
                                    }
                                } else {
                                    HStack(spacing: 12) {
                                        Image(systemName: "magnifyingglass")
                                            .font(.system(size: 20))
                                        Text("Search for My Item")
                                            .font(.system(size: 18, weight: .semibold))
                                    }
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                searchDescription.isEmpty || isSearching
                                    ? LinearGradient(colors: [AppColors.surfaceLight, AppColors.surfaceLight], startPoint: .leading, endPoint: .trailing)
                                    : AppColors.accentGradient
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(
                                color: !searchDescription.isEmpty && !isSearching ? AppColors.accent.opacity(0.5) : .clear,
                                radius: 20,
                                x: 0,
                                y: 10
                            )
                        }
                        .disabled(searchDescription.isEmpty || isSearching)
                        .padding(.horizontal, 20)
                        
                        // Quick suggestions
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "sparkle")
                                    .foregroundColor(AppColors.primary)
                                Text("Quick Search")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                ForEach(["Wallet", "Keys", "Phone", "Backpack", "Laptop", "AirPods"], id: \.self) { item in
                                    Button(action: {
                                        searchDescription = item.lowercased()
                                    }) {
                                        HStack(spacing: 8) {
                                            Image(systemName: getIconForItem(item))
                                                .foregroundColor(AppColors.primary)
                                                .font(.system(size: 16))
                                            Text(item)
                                                .foregroundColor(.white)
                                                .font(.system(size: 15, weight: .medium))
                                            Spacer()
                                        }
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 14)
                                        .background(AppColors.surfaceLight)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                    }
                                }
                            }
                        }
                        .padding(20)
                        .glassCard()
                    }
                    .padding(.bottom, 32)
                }
            }
        }
        .alert("Search Result", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func getIconForItem(_ item: String) -> String {
        switch item {
        case "Wallet": return "creditcard.fill"
        case "Keys": return "key.fill"
        case "Phone": return "iphone"
        case "Backpack": return "backpack.fill"
        case "Laptop": return "laptopcomputer"
        case "AirPods": return "airpodspro"
        default: return "magnifyingglass"
        }
    }
    
    func performSearch() {
        guard !searchDescription.isEmpty else {
            alertMessage = "Please describe your lost item"
            showAlert = true
            return
        }
        
        isSearching = true
        
        let requestData: [String: Any] = [
            "description": searchDescription.trimmingCharacters(in: .whitespacesAndNewlines),
            "lostLocation": selectedLocation.isEmpty ? "Unknown" : selectedLocation
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestData),
              let url = URL(string: Config.matchEndpoint) else {
            isSearching = false
            alertMessage = "Failed to prepare search request"
            showAlert = true
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isSearching = false
                
                if let error = error {
                    print("Search error: \(error)")
                    alertMessage = "No match found: \(error.localizedDescription)"
                    showAlert = true
                    return
                }
                
                guard let data = data else {
                    alertMessage = "No match found: No data received"
                    showAlert = true
                    return
                }
                
                do {
                    if let response = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        if let bestMatch = response["best_match"] as? String,
                           let confidence = response["confidence"] as? Double,
                           let lostLocation = response["lostLocation"] as? String {
                            
                            let result = SearchResult(
                                imageUrl: bestMatch,
                                confidence: confidence,
                                location: lostLocation,
                                description: searchDescription
                            )
                            onResultsFound(result)
                        } else {
                            alertMessage = "No match found: Unable to parse search results"
                            showAlert = true
                        }
                    } else {
                        alertMessage = "No match found: Invalid response format"
                        showAlert = true
                    }
                } catch {
                    alertMessage = "No match found: \(error.localizedDescription)"
                    showAlert = true
                }
            }
        }.resume()
    }
}

struct SearchResult {
    let imageUrl: String
    let confidence: Double
    let location: String
    let description: String
}

#Preview {
    SearcherScreen(onBack: {}, onResultsFound: { _ in })
}
