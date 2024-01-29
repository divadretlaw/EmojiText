//
//  EmojiText+Preview.swift
//  EmojiText
//
//  Created by David Walter on 26.01.24.
//

import SwiftUI

#if DEBUG
// swiftlint:disable force_unwrapping
extension EmojiText {
    static var emojis: [any CustomEmoji] {
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
    
    static var animatedEmojis: [any CustomEmoji] {
        [
            RemoteEmoji(
                shortcode: "gif",
                url: URL(string: "https://ezgif.com/images/format-demo/butterfly.gif")!
            )
        ]
    }
}
// swiftlint:enable force_unwrapping
#endif
