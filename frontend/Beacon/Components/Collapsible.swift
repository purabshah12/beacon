//
//  Collapsible.swift
//  Beacon
//
//  Created by Eswar Karavadi on 11/7/25.
//

import SwiftUI

struct Collapsible<Content: View>: View {
    let title: String
    let content: Content
    @State private var isExpanded = false

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    ThemedText(text: title, type: .subtitle)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(AppColors.textSecondary)
                        .font(.system(size: 14))
                }
                .padding()
                .background(AppColors.surface)
                .cornerRadius(8)
            }

            if isExpanded {
                content
                    .padding(.horizontal)
                    .padding(.bottom)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(AppColors.surface.opacity(0.5))
        .cornerRadius(8)
    }
}

#Preview {
    ThemedView {
        Collapsible(title: "Additional Details") {
            VStack(alignment: .leading, spacing: 10) {
                ThemedText(text: "Location: McKeldin Library", type: .body)
                ThemedText(text: "Time: 2 hours ago", type: .body)
                ThemedText(text: "Description: Black wallet found on table", type: .body)
            }
        }
        .padding()
    }
}
