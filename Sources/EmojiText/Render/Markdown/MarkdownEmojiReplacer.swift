//
//  MarkdownEmojiReplacer.swift
//  EmojiText
//
//  Created by David Walter on 30.01.24.
//

import Foundation
import Markdown

struct MarkdownEmojiReplacer: MarkupRewriter {
    let emojis: [String: LoadedEmoji]
    
    mutating func visitText(_ text: Text) -> Markup? {
        var string = text.string
        for shortcode in emojis.keys {
            // Replace emojis with a Markdown image with a custom URL Scheme
            string = string.replacingOccurrences(
                of: ":\(shortcode):",
                // Inject `String.emojiSeparator` in order to be able to remove spaces between emojis
                with: "\(String.emojiSeparator)![\(shortcode)](\(String.emojiScheme)://\(shortcode))\(String.emojiSeparator)"
            )
        }
        return Markdown.Text(string)
    }
    
    // MARK: - Workarounds
    
    /// `AttributedString` would simply add the language as part of the code block, therefore we remove it
    mutating func visitCodeBlock(_ codeBlock: CodeBlock) -> Markup? {
        CodeBlock(language: nil, codeBlock.code)
    }
}
