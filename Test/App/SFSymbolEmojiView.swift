//
//  SFSymbolEmojiView.swift
//  EmojiTextTest
//
//  Created by David Walter on 23.04.23.
//

import SwiftUI
import EmojiText

struct SFSymbolEmojiView: View {
    var emojis: [any CustomEmoji] {
        [
            SFSymbolEmoji(shortcode: "iphone"),
            SFSymbolEmoji(shortcode: "person.fill.badge.plus", symbolRenderingMode: .multicolor)
        ]
    }
    
    var body: some View {
        EmojiTestView {
            EmojiText(verbatim: "iPhone :iphone:", emojis: emojis)
            EmojiText(verbatim: "Person :person.fill.badge.plus:", emojis: emojis)
        }
        .navigationTitle("SF Symbol Emoji")
    }
}

struct SFSymbolEmojiView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SFSymbolEmojiView()
        }
    }
}
