//
//  EmojiTextRenderer.swift
//  EmojiText
//
//  Created by David Walter on 01.02.24.
//

import Foundation
import SwiftUI

struct EmojiTextRenderer {
    let emoji: RenderedEmoji
    
    func render(_ size: CGFloat?, at renderTime: CFTimeInterval) -> Text {
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
}
