//
//  PreviewWideWidth.swift
//  EmojiText
//
//  Created by David Walter on 26.01.24.
//

import SwiftUI

#if DEBUG
#Preview {
    List {
        Section {
            EmojiText(
                verbatim: "Hello World :puppu_purin: with a remote emoji.",
                emojis: EmojiText.emojis
            )
            EmojiText(
                verbatim: "Hello World :mastodon: :puppu_purin: with a remote emoji.",
                emojis: EmojiText.emojis
            )
            .font(.title)
            EmojiText(
                verbatim: "Hello World :mastodon: :puppu_purin: with a custom emoji.",
                emojis: EmojiText.emojis
            )
            .emojiText.size(34)
            .emojiText.baselineOffset(-8.5)
        } header: {
            Text("Verbatim")
        }
        
        Section {
            EmojiText(
                markdown: "**Hello** *World* :puppu_purin: with a remote emoji",
                emojis: EmojiText.emojis
            )
        } header: {
            Text("Markdown")
        }
    }
}
#endif
