//
//  EmojiText+Markdown.swift
//  EmojiText
//
//  Created by David Walter on 26.01.24.
//

import SwiftUI
import OSLog

struct MarkdownEmojiRenderer: EmojiRenderer {
    let shouldOmitSpacesBetweenEmojis: Bool
    let interpretedSyntax: AttributedString.MarkdownParsingOptions.InterpretedSyntax
    
    func render(string: String, emojis: [String: RenderedEmoji]) -> Text {
        renderAnimated(string: string, emojis: emojis, at: 0)
    }
    
    func renderAnimated(string: String, emojis: [String: RenderedEmoji], at time: CFTimeInterval) -> Text {
        let attributedString = renderAttributedString(from: string, with: emojis)
        
        var result = Text(verbatim: "")
        var partialString = AttributedPartialstring()
        
        for run in attributedString.runs {
            if let emoji = run.emoji(from: emojis) {
                // If the run is an emoji we render it as an interpolated image in a Text view
                let text = Text(emoji: emoji, renderTime: time)
                
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
    
    private func renderAttributedString(from string: String, with emojis: [String: RenderedEmoji]) -> AttributedString {
        do {
            var text = string
            
            let options = AttributedString.MarkdownParsingOptions(
                allowsExtendedAttributes: true,
                interpretedSyntax: interpretedSyntax,
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
            text = text.splitOnEmoji(omittingSpacesBetweenEmojis: shouldOmitSpacesBetweenEmojis).joined()
            
            return try AttributedString(markdown: text, options: options)
        } catch {
            Logger.text.error("Unable to parse Markdown, falling back to verbatim string: \(error.localizedDescription)")
            return AttributedString(stringLiteral: string)
        }
    }
}
