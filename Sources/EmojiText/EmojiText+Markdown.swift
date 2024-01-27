//
//  EmojiText+Markdown.swift
//  EmojiText
//
//  Created by David Walter on 26.01.24.
//

import SwiftUI
import Nuke
import OSLog

extension EmojiText {
    /// Initialize a Markdown formatted ``EmojiText`` with support for custom emojis.
    ///
    /// - Parameters:
    ///     - markdown: The string that contains the Markdown formatting.
    ///      - interpretedSyntax: The syntax for intepreting a Markdown string. Defaults to `.inlineOnlyPreservingWhitespace`.
    ///     - emojis: The custom emojis to render.
    public init(
        markdown content: String,
        interpretedSyntax: AttributedString.MarkdownParsingOptions.InterpretedSyntax = .inlineOnlyPreservingWhitespace,
        emojis: [any CustomEmoji]
    ) {
        self.raw = content
        self.isMarkdown = true
        self.emojis = emojis.filter { content.contains(":\($0.shortcode):") }
    }
    
    var renderedMarkdown: Text {
        let emojis = renderedEmojis ?? loadEmojis()
        let attributedString = renderAttributedString(with: emojis)
        
        var result = Text(verbatim: "")
        var partialString = AttributedPartialstring()
        
        for run in attributedString.runs {
            if let emoji = run.emoji(from: emojis) {
                // If the run is an emoji we render it as an interpolated image in a Text view
                let text = Text(emoji: emoji, renderTime: renderTime)
                
                // If the same emoji is added multiple times in a row the run gets merged into one
                // with their shortcodes joined. Therefore we simply divide distance of the range by
                // the character count of the emojo to calculate how often the emoji needs to be displayed
                let distance = attributedString.distance(from: run.range.lowerBound, to: run.range.upperBound)
                let count = emoji.shortcode.count
                
                if distance == count {
                    // Emoji is only displayed once
                    result = [
                        result,
                        Text(&partialString),
                        text
                    ]
                    .compactMap { $0 }
                    .joined()
                } else {
                    // Emojis is displayed multiple times
                    result = [
                        result,
                        Text(&partialString),
                        Text(repating: text, count: distance / count)
                    ]
                    .compactMap { $0 }
                    .joined()
                }
            } else {
                // Otherwise we just append the run to AttributedPartialstring
                partialString.append(attributedString[run.range])
            }
        }
        
        return [result, Text(&partialString)]
            .compactMap { $0 }
            .joined()
    }
    
    private func renderAttributedString(with emojis: [String: RenderedEmoji]) -> AttributedString {
        do {
            var text = raw
            
            let options = AttributedString.MarkdownParsingOptions(
                allowsExtendedAttributes: true,
                interpretedSyntax: emojiMarkdownInterpretedSyntax,
                failurePolicy: .returnPartiallyParsedIfPossible
            )
            
            for shortcode in emojis.keys {
                // Replace emojis with a Markdown image with a custom URL Scheme
                text = text.replacingOccurrences(
                    of: ":\(shortcode):",
                    // Inject `String.emojiSeparator` in order to be able to remove spaces between emojis
                    with: "\(String.emojiSeparator)![\(shortcode)](\(String.emojiScheme)://\(shortcode))\(String.emojiSeparator)"
                )
            }
            
            // Remove the injected `String.emojiSeparator`
            text = text.splitOnEmoji(omittingSpacesBetweenEmojis: emojiOmitSpacesBetweenEmojis).joined()
            
            return try AttributedString(markdown: text, options: options)
        } catch {
            Logger.text.error("Unable to parse Markdown, falling back to verbatim string: \(error.localizedDescription)")
            return AttributedString(stringLiteral: raw)
        }
    }
}

#if DEBUG
#Preview {
    List {
        Section {
            EmojiText(markdown: "**Hello :mastodon:** the **World :mastodon:**", emojis: EmojiText.emojis)
            EmojiText(markdown: "**Hello :mastodon:** the _World :mastodon:_", emojis: EmojiText.emojis)
            EmojiText(markdown: "**Hello** *World* :mastodon: with a remote emoji",
                      emojis: EmojiText.emojis)
            EmojiText(markdown: "**Hello** *World* :mastodon: :test: with a remote emoji and a fake emoji",
                      emojis: EmojiText.emojis)
            EmojiText(markdown: "**Hello** *World* :mastodon: :iphone: with a remote and a local emoji",
                      emojis: EmojiText.emojis)
            EmojiText(markdown: "**Hello** *World* :test: with a remote emoji that will not respond properly",
                      emojis: [RemoteEmoji(shortcode: "test", url: URL(string: "about:blank")!)])
            EmojiText(markdown: "**Hello** *World* :notAnEmoji: with no emojis",
                      emojis: [])
            
            EmojiText(markdown: "**Hello** *World* :mastodon:",
                      emojis: EmojiText.emojis)
            .prepend {
                Text("Prepended - ")
            }
            .append {
                Text(" - Appended")
            }
        } header: {
            Text("Markdown")
        }
    }
}
#endif
