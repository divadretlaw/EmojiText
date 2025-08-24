//
//  EmojiLabelWrapper.swift
//  Test
//
//  Created by David Walter on 24.08.25.
//

import SwiftUI
import EmojiText

#if canImport(UIKit)
struct EmojiLabelWrapper: UIViewRepresentable {
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
            RemoteEmoji(
                shortcode: "never",
                url: URL(string: "https://github.com/divadretlaw/EmojiText/Package.swift")!
            ),
            SFSymbolEmoji(shortcode: "iphone")
        ]
    }

    func makeUIView(context: Context) -> EmojiLabel {
        let view = EmojiLabel()
        view.emojis = emojis
        view.text = "Hello World :a:"
        return view
    }

    func updateUIView(_ uiView: EmojiLabel, context: Context) {
    }
}
#endif
