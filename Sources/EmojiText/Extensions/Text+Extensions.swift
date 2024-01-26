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
    
    init(emoji: RenderedEmoji, renderTime: CFTimeInterval) {
        var text = Text("\(emoji.frame(at: renderTime))")
        
        if let baselineOffset = emoji.baselineOffset {
            text = text.baselineOffset(baselineOffset)
        }
        
        self = text
    }
    
    init(repating text: Text, count: Int) {
        self = Array(repeating: text, count: max(count, 1)).joined()
    }
}

extension Array where Element == Text {
    func joined() -> Text {
        guard var result = first else {
            return Text(verbatim: "")
        }
        
        for element in dropFirst() {
            result = result + element
        }
        
        return result
    }
}
