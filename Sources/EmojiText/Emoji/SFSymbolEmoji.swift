//
//  SFSymbolEmoji.swift
//  EmojiText
//
//  Created by David Walter on 12.02.23.
//

import Foundation
import SwiftUI

/// A custom emoji from SF Symbols
public struct SFSymbolEmoji: CustomEmoji {
    /// Shortcode of the SF Symbol
    public let shortcode: String
    /// The mode SwiftUI uses to render this emoji
    public let renderingMode: Image.TemplateRenderingMode?
    /// The symbol rendering mode to use for this emoji
    public let symbolRenderingMode: SymbolRenderingMode?
    
    /// Initialize a SF Symbol custom emoji
    ///
    /// - Parameters:
    ///     - shortcode: The SF Symbol code of the emoji
    ///     - symbolRenderingMode: The symbol rendering mode to use for this emoji
    ///     - renderingMode: The mode SwiftUI uses to render this emoji
    public init(shortcode: String, symbolRenderingMode: SymbolRenderingMode? = nil, renderingMode: Image.TemplateRenderingMode? = nil) {
        self.shortcode = shortcode
        self.symbolRenderingMode = symbolRenderingMode
        self.renderingMode = renderingMode
    }
    
    static var placeholder: Self {
        SFSymbolEmoji(shortcode: "square.dashed", symbolRenderingMode: .monochrome, renderingMode: .template)
    }
    
    // MARK: Hashable
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(shortcode)
        hasher.combine(renderingMode)
    }
}

extension EmojiImage {
    static func from(emoji: SFSymbolEmoji) -> EmojiImage {
        EmojiImage(systemName: emoji.shortcode)
        ?? EmojiImage(systemName: SFSymbolEmoji.placeholder.shortcode)
        ?? EmojiImage()
    }
}
