//
//  VerbatimEmojiRenderer.swift
//  EmojiText
//
//  Created by David Walter on 26.01.24.
//

import SwiftUI
import OSLog

struct VerbatimEmojiRenderer: EmojiRenderer {
    let shouldOmitSpacesBetweenEmojis: Bool
    
    func render(string: String, emojis: [String: RenderedEmoji]) -> Text {
        renderAnimated(string: string, emojis: emojis, at: 0)
    }
    
    func renderAnimated(string: String, emojis: [String: RenderedEmoji], at time: CFTimeInterval) -> Text {
        let string = renderString(from: string, with: emojis)
        
        var result = Text(verbatim: "")
        
        let splits = string.splitOnEmoji(omittingSpacesBetweenEmojis: shouldOmitSpacesBetweenEmojis)
        for substring in splits {
            if let emoji = emojis[substring] {
                // If the part is an emoji we render it as an inline image
                let text = EmojiTextRenderer(emoji: emoji).render(at: time)
                result = result + text
            } else {
                // Otherwise we just render the part as String
                result = result + Text(verbatim: substring)
            }
        }
        
        return result
    }
    
    private func renderString(from string: String, with emojis: [String: RenderedEmoji]) -> String {
        var text = string
        
        for shortcode in emojis.keys {
            text = text.replacingOccurrences(of: ":\(shortcode):", with: "\(String.emojiSeparator)\(shortcode)\(String.emojiSeparator)")
        }
        
        return text
    }
}

#if DEBUG
#Preview {
    List {
        EmojiText(
            verbatim: "Hello :a:",
            emojis: .emojis
        )
        EmojiText(
            verbatim: "World :wide:",
            emojis: .emojis
        )
        EmojiText(
            verbatim: "Hello World :test:",
            emojis: .emojis
        )
    }
}
#endif
