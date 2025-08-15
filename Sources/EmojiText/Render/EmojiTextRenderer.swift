//
//  EmojiTextRenderer.swift
//  EmojiText
//
//  Created by David Walter on 01.02.24.
//

import Foundation
import SwiftUI

struct EmojiTextRenderer {
    let emoji: LoadedEmoji
    
    func text(_ size: CGFloat?, at renderTime: CFTimeInterval) -> Text {
        // Surround the image with zero-width spaces to give the emoji a default height
        var text = Text("\u{200B}\(emoji.frame(at: renderTime))\u{200B}")

        if let baselineOffset = emoji.baselineOffset {
            text = text.baselineOffset(baselineOffset)
        }
        
        if let size {
            text = text.font(.system(size: size))
        }
        
        return text.accessibilityLabel(emoji.shortcode)
    }

    func attributedString(_ size: CGFloat?) -> NSAttributedString {
        let attachment = NSTextAttachment()
        attachment.image = emoji.emojiImage

        let text = NSMutableAttributedString()
        text.append(NSAttributedString("\u{200B}"))
        text.append(NSAttributedString(attachment: attachment))
        text.append(NSAttributedString("\u{200B}"))

        return text
    }
}
