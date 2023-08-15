//
//  AnimatedEmojiView.swift
//  EmojiTextTest
//
//  Created by David Walter on 15.08.23.
//

import SwiftUI
import EmojiText

struct AnimatedEmojiView: View {
    var emojis: [any CustomEmoji] {
        [
            RemoteEmoji(shortcode: "webp", url: URL(string: "https://ezgif.com/images/format-demo/butterfly-small.webp")!),
            RemoteEmoji(shortcode: "apng", url: URL(string: "https://ezgif.com/images/format-demo/butterfly.png")!),
            RemoteEmoji(shortcode: "gif", url: URL(string: "https://ezgif.com/images/format-demo/butterfly.gif")!)
        ]
    }
    
    var body: some View {
        EmojiTestView {
            EmojiText(verbatim: "WebP :webp:", emojis: emojis)
                .animated()
            EmojiText(verbatim: "APNG :apng:", emojis: emojis)
                .animated()
            EmojiText(verbatim: "GIF :gif:", emojis: emojis)
                .animated()
        }
        .navigationTitle("Animated Emoji")
    }
}

struct AnimatedEmojiView_Previews: PreviewProvider {
    static var previews: some View {
        AnimatedEmojiView()
    }
}
