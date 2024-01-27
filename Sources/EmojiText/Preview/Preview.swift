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
                shortcode: "mastodon",
                url: URL(string: "https://files.mastodon.social/custom_emojis/images/000/003/675/original/089aaae26a2abcc1.png")!
            ),
            RemoteEmoji(
                shortcode: "puppu_purin",
                url: URL(string: "https://s3.fedibird.com/custom_emojis/images/000/358/023/static/5fe65ba070089507.png")!
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

struct Preview<Content>: View where Content: View {
    var content: Content
    
    var body: some View {
        List {
            content
            
            Section {
                
            }
        }
    }
}
// swiftlint:enable force_unwrapping
#endif
