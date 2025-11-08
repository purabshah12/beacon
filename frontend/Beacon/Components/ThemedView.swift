//
//  ThemedView.swift
//  Beacon
//
//  Created by Eswar Karavadi on 11/7/25.
//

import SwiftUI

struct ThemedView<Content: View>: View {
    let content: Content
    var backgroundColor: Color = AppColors.background

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    init(backgroundColor: Color, @ViewBuilder content: () -> Content) {
        self.backgroundColor = backgroundColor
        self.content = content()
    }

    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()
            content
        }
    }
}

#Preview {
    ThemedView {
        VStack {
            ThemedText(text: "Sample Content", type: .title)
            ThemedText(text: "This is themed content", type: .body)
        }
        .padding()
    }
}
