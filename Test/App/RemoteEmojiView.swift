//
//  RemoteEmoji.swift
//  EmojiTextTest
//
//  Created by David Walter on 23.04.23.
//

import SwiftUI
import EmojiText

struct RemoteEmojiView: View {
    var emojis: [any CustomEmoji] {
        [
            RemoteEmoji(
                shortcode: "a",
                url: URL(string: "https://dummyimage.com/64x64/0A6FFF/fff&text=A")!
            ),
            RemoteEmoji(
                shortcode: "wide",
                url: URL(string: "https://dummyimage.com/256x64/DE3A3B/fff&text=wide")!
            ),
            SFSymbolEmoji(shortcode: "iphone")
        ]
    }
    
    var body: some View {
        EmojiTestView {
            EmojiText(verbatim: "Hello Emoji :a:", emojis: emojis)
            EmojiText(verbatim: "Hello Wide :wide:", emojis: emojis)
        }
        .navigationTitle("Remote Emoji")
    }
}

struct RemoteEmojiView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            RemoteEmojiView()
        }
    }
}
