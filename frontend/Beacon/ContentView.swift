//
//  ContentView.swift
//  Beacon
//
//  Created by Eswar Karavadi on 11/7/25.
//

import SwiftUI

struct ContentView: View {
    @State private var currentScreen: Screen = .splash
    @State private var searchResults: SearchResult?
    @State private var showSplash = true

    enum Screen {
        case splash
        case home
        case finder
        case searcher
        case results
    }

    var body: some View {
        ZStack {
            switch currentScreen {
            case .splash:
                SplashScreen()
                    .onAppear {
                        // Show splash for 2.5 seconds then transition to home
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                currentScreen = .home
                            }
                        }
                    }
            case .home:
                HomeScreen(onNavigateToFinder: { currentScreen = .finder },
                          onNavigateToSearcher: { currentScreen = .searcher })
            case .finder:
                FinderScreen(onBack: { currentScreen = .home })
            case .searcher:
                SearcherScreen(onBack: { currentScreen = .home },
                              onResultsFound: { results in
                    searchResults = results
                    currentScreen = .results
                })
            case .results:
                ResultScreen(result: searchResults,
                           onBack: { currentScreen = .searcher })
            }
        }
        .animation(.easeInOut, value: currentScreen)
    }
}

#Preview {
    ContentView()
}
