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
            RemoteEmoji(shortcode: "mastodon", url: URL(string: "https://files.mastodon.social/custom_emojis/images/000/003/675/original/089aaae26a2abcc1.png")!),
            RemoteEmoji(shortcode: "wide", url: URL(string: "https://s3.fedibird.com/custom_emojis/images/000/358/023/static/5fe65ba070089507.png")!)
        ]
    }
    
    var body: some View {
        EmojiTestView {
            EmojiText(verbatim: "Mastodon :mastodon:", emojis: emojis)
            EmojiText(verbatim: "Wide :wide:", emojis: emojis)
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
