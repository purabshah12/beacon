//
//  ThemedText.swift
//  Beacon
//
//  Created by Eswar Karavadi on 11/7/25.
//

import SwiftUI

enum TextType {
    case title
    case subtitle
    case body
    case caption
    case link
}

struct ThemedText: View {
    let text: String
    let type: TextType
    var color: Color? = nil

    private var font: Font {
        switch type {
        case .title:
            return .largeTitle
        case .subtitle:
            return .title2
        case .body:
            return .body
        case .caption:
            return .caption
        case .link:
            return .body
        }
    }

    private var textColor: Color {
        if let color = color {
            return color
        }
        switch type {
        case .title, .subtitle, .body, .caption:
            return AppColors.textPrimary
        case .link:
            return AppColors.accent
        }
    }

    var body: some View {
        Text(text)
            .font(font)
            .foregroundColor(textColor)
            .fontWeight(type == .title ? .bold : .regular)
    }
}

#Preview {
    VStack(spacing: 20) {
        ThemedText(text: "Lost & Found", type: .title)
        ThemedText(text: "Find your lost items", type: .subtitle)
        ThemedText(text: "This is regular body text", type: .body)
        ThemedText(text: "Small caption text", type: .caption)
        ThemedText(text: "Click here", type: .link)
    }
    .padding()
    .background(AppColors.background)
}
