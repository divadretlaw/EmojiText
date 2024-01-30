//
//  EmojiTextNamespace.swift
//  EmojiText
//
//  Created by David Walter on 30.01.24.
//

import SwiftUI

public extension View {
    /// The ``EmojiText`` namespace
    var emojiText: EmojiTextNamespace<Self> {
        EmojiTextNamespace(self)
    }
}

/// ``EmojiText`` namespace
public struct EmojiTextNamespace<Content> {
    /// The content of the namespace
    public let content: Content
    
    /// Create a new ``EmojiText`` namespace
    /// - Parameter content: The content of the namespace
    public init(_ content: Content) {
        self.content = content
    }
}
