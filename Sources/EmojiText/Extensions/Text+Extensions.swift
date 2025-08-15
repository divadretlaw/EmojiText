//
//  Text+Extensions.swift
//  EmojiText
//
//  Created by David Walter on 20.12.23.
//

import SwiftUI

extension Text {
    init?(_ attributedPartialstring: inout AttributedPartialstring) {
        self.init(attributedSubstrings: attributedPartialstring.consume())
    }
    
    init?(attributedSubstrings: [AttributedSubstring]) {
        guard !attributedSubstrings.isEmpty else {
            return nil
        }
        
        let string = attributedSubstrings.reduce(AttributedString()) { partialResult, substring in
            partialResult + substring
        }
        
        self.init(string)
    }
    
    init(repating text: Text, count: Int) {
        self = Array(repeating: text, count: max(count, 1)).joined()
    }

    init(_ emoji: LoadedEmoji, size: CGFloat?, at renderTime: CFTimeInterval) {
        // Surround the image with zero-width spaces to give the emoji a default height
        var text = Text("\u{200B}\(emoji.frame(at: renderTime))\u{200B}")

        if let baselineOffset = emoji.baselineOffset {
            text = text.baselineOffset(baselineOffset)
        }

        if let size {
            text = text.font(.system(size: size))
        }

        self = text.accessibilityLabel(emoji.shortcode)
    }
}

extension [Text] {
    func joined() -> Text {
        guard var result = first else {
            return Text(verbatim: "")
        }
        
        for element in dropFirst() {
            result = Text("\(result)\(element)")
        }
        
        return result
    }
}
