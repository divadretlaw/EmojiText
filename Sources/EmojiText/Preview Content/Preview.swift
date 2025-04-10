//
//  Preview.swift
//  EmojiText
//
//  Created by David Walter on 26.01.24.
//

import SwiftUI

#if DEBUG
// swiftlint:disable force_unwrapping
extension [CustomEmoji] {
    static var emojis: [any CustomEmoji] {
        let remote = [
            RemoteEmoji(
                shortcode: "a",
                url: URL(string: "https://dummyimage.com/64x64/0A6FFF/fff&text=A")
            ),
            RemoteEmoji(
                shortcode: "wide",
                url: URL(string: "https://dummyimage.com/256x64/DE3A3B/fff&text=wide")
            )
        ]
        .compactMap { $0 }
        let local = [
            SFSymbolEmoji(shortcode: "iphone")
        ]
        return remote + local
    }
    
    static var animatedEmojis: [any CustomEmoji] {
        [
            RemoteEmoji(
                shortcode: "gif",
                url: URL(string: "https://ezgif.com/images/format-demo/butterfly.gif")!
            )
        ]
        .compactMap { $0 }
    }
}
// swiftlint:enable force_unwrapping
#endif
