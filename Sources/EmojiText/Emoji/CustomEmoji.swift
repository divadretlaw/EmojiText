//
//  CustomEmoji.swift
//  EmojiText
//
//  Created by David Walter on 11.01.23.
//

import Foundation
import SwiftUI

/// A custom emoji
public protocol CustomEmoji: Equatable, Hashable, Identifiable {
    /// The ID of the emoji
    var id: String { get }
    /// Shortcode of the emoji
    var shortcode: String { get }
    /// The mode SwiftUI uses to render this emoji
    var renderingMode: Image.TemplateRenderingMode? { get }
    /// The symbol rendering mode to use for this emoji
    var symbolRenderingMode: SymbolRenderingMode? { get }
}

public extension CustomEmoji {
    var id: String { shortcode }
    var renderingMode: Image.TemplateRenderingMode? { nil }
    var symbolRenderingMode: SymbolRenderingMode? { nil }
    
    // MARK: Hashable
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(shortcode)
    }
    
    // MARK: Equatable
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}
