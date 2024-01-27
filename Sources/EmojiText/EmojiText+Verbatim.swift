//
//  EmojiText+Verbatim.swift
//  EmojiText
//
//  Created by David Walter on 26.01.24.
//

import SwiftUI
import Nuke
import OSLog

extension EmojiText {
    /// Initialize a ``EmojiText`` with support for custom emojis.
    ///
    /// - Parameters:
    ///     - verbatim: A string to display without localization.
    ///     - emojis: The custom emojis to render.
    public init(verbatim content: String, emojis: [any CustomEmoji]) {
        self.raw = content
        self.isMarkdown = false
        self.emojis = emojis.filter { content.contains(":\($0.shortcode):") }
    }
    
    var renderedVerbatim: Text {
        let emojis = renderedEmojis ?? loadEmojis()
        let string = renderString(with: emojis)
        
        var result = Text(verbatim: "")
        
        let splits = string.splitOnEmoji(omittingSpacesBetweenEmojis: emojiOmitSpacesBetweenEmojis)
        for substring in splits {
            if let image = emojis[substring] {
                // If the part is an emoji we render it as an inline image
                if let baselineOffset = image.baselineOffset {
                    result = result + Text("\(image.frame(at: renderTime))").baselineOffset(baselineOffset)
                } else {
                    result = result + Text("\(image.frame(at: renderTime))")
                }
            } else {
                // Otherwise we just render the part as String
                result = result + Text(verbatim: substring)
            }
        }
        
        return result
    }
    
    private func renderString(with emojis: [String: RenderedEmoji]) -> String {
        var text = raw
        
        for shortcode in emojis.keys {
            text = text.replacingOccurrences(of: ":\(shortcode):", with: "\(String.emojiSeparator)\(shortcode)\(String.emojiSeparator)")
        }
        
        return text
    }
}

#if DEBUG
#Preview {
    List {
        Section {
            EmojiText(
                verbatim: "Hello Moon & Stars :moon.stars:",
                emojis: [SFSymbolEmoji(shortcode: "moon.stars")]
            )
            EmojiText(
                verbatim: "Hello World :mastodon: with a remote emoji",
                emojis: EmojiText.emojis
            )
            EmojiText(
                verbatim: "Hello World :iphone: with a local emoji",
                emojis: EmojiText.emojis
            )
            EmojiText(
                verbatim: "Hello World :mastodon: with a remote emoji",
                emojis: EmojiText.emojis
            )
            .font(.title)
            EmojiText(
                verbatim: "Large Image as Emoji :large:",
                emojis: [RemoteEmoji(
                    shortcode: "large",
                    url: URL(
                        string: "https://sample-videos.com/img/Sample-jpg-image-15mb.jpeg"
                    )!
                )]
            )
            EmojiText(
                verbatim: "Hello World :mastodon: with a custom emoji size",
                emojis: EmojiText.emojis
            )
            .emojiSize(34)
            .emojiBaselineOffset(-8.5)
        } header: {
            Text("Text")
        }
    }
}
#endif
