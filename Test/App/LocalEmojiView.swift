//
//  LocalEmojiView.swift
//  EmojiTextTest
//
//  Created by David Walter on 04.02.24.
//

import SwiftUI
import EmojiText

struct LocalEmojiView: View {
    var emojis: [any CustomEmoji] {
        [
            LocalEmoji(shortcode: "original", image: EmojiImage(named: "Test")!),
            LocalEmoji(shortcode: "template", image: EmojiImage(named: "Test")!, renderingMode: .template),
            LocalEmoji(shortcode: "color", image: EmojiImage(named: "Test")!, color: .systemBlue)
        ]
    }
    
    var body: some View {
        EmojiTestView {
            EmojiText(verbatim: "Original :original:", emojis: emojis)
            EmojiText(verbatim: "Template :template:", emojis: emojis)
            EmojiText(verbatim: "Color :color:", emojis: emojis)
        }
        .navigationTitle("Local Emoji")
    }
}

struct LocalEmojiView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            LocalEmojiView()
        }
    }
}
