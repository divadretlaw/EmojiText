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
            LocalEmoji(shortcode: "template", image: EmojiImage(named: "Test")!, renderingMode: .template)
        ]
    }
    
    var body: some View {
        EmojiTestView {
            EmojiText(verbatim: "Original :original:", emojis: emojis)
            EmojiText(verbatim: "Template :template:", emojis: emojis)
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
