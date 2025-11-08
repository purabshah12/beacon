//
//  ExternalLink.swift
//  Beacon
//
//  Created by Eswar Karavadi on 11/7/25.
//

import SwiftUI

struct ExternalLink: View {
    let title: String
    let url: URL
    var iconName: String = "arrow.up.right"

    var body: some View {
        Button(action: {
            UIApplication.shared.open(url)
        }) {
            HStack {
                ThemedText(text: title, type: .link)
                Image(systemName: iconName)
                    .foregroundColor(AppColors.accent)
                    .font(.system(size: 14))
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(AppColors.surface)
            .cornerRadius(6)
        }
    }
}

#Preview {
    ThemedView {
        ExternalLink(
            title: "Open in Maps",
            url: URL(string: "https://maps.apple.com/?ll=38.9869,-76.9426")!
        )
        .padding()
    }
}
