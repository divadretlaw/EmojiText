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
    
    @State private var isAnimating = true
    
    var body: some View {
        EmojiTestView {
            EmojiText(verbatim: "WebP :webp:", emojis: emojis)
                .animated(isAnimating)
            EmojiText(verbatim: "APNG :apng:", emojis: emojis)
                .animated(isAnimating)
            EmojiText(verbatim: "GIF :gif:", emojis: emojis)
                .animated(isAnimating)
        }
        .navigationTitle("Animated Emoji")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    isAnimating.toggle()
                } label: {
                    if isAnimating {
                        Image(systemName: "pause")
                    } else {
                        Image(systemName: "play")
                    }
                }

            }
        }
    }
}

struct AnimatedEmojiView_Previews: PreviewProvider {
    static var previews: some View {
        AnimatedEmojiView()
    }
}
