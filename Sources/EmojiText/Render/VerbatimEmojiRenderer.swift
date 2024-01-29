//
//  EmojiText+Verbatim.swift
//  EmojiText
//
//  Created by David Walter on 26.01.24.
//

import SwiftUI
import OSLog

struct VerbatimEmojiRenderer: EmojiRenderer {
    let shouldOmitSpacesBetweenEmojis: Bool
    
    func renderString(from string: String, with emojis: [String: RenderedEmoji]) -> String {
        var text = string
        
        for shortcode in emojis.keys {
            text = text.replacingOccurrences(of: ":\(shortcode):", with: "\(String.emojiSeparator)\(shortcode)\(String.emojiSeparator)")
        }
        
        return text
    }
    
    func render(string: String, emojis: [String: RenderedEmoji]) -> Text {
        renderAnimated(string: string, emojis: emojis, at: 0)
    }
    
    func renderAnimated(string: String, emojis: [String: RenderedEmoji], at time: CFTimeInterval) -> Text {
        let string = renderString(from: string, with: emojis)
        
        var result = Text(verbatim: "")
        
        let splits = string.splitOnEmoji(omittingSpacesBetweenEmojis: shouldOmitSpacesBetweenEmojis)
        for substring in splits {
            if let image = emojis[substring] {
                // If the part is an emoji we render it as an inline image
                if let baselineOffset = image.baselineOffset {
                    result = result + Text("\(image.frame(at: time))").baselineOffset(baselineOffset)
                } else {
                    result = result + Text("\(image.frame(at: time))")
                }
            } else {
                // Otherwise we just render the part as String
                result = result + Text(verbatim: substring)
            }
        }
        
        return result
    }
}
