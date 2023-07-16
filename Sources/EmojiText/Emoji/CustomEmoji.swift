//
//  CustomEmoji.swift
//  EmojiText
//
//  Created by David Walter on 11.01.23.
//

import Foundation
import SwiftUI

/// A custom emoji
public protocol CustomEmoji: Hashable, Equatable, Identifiable {
    /// The ID of the emoji
    var id: String { get }
    /// Shortcode of the emoji
    var shortcode: String { get }
    /// The mode SwiftUI uses to render this emoji
    var renderingMode: Image.TemplateRenderingMode? { get }
    /// The symbol rendering mode to use for this emoji
    var symbolRenderingMode: SymbolRenderingMode? { get }
    /// The symbols baseline offset
    var baselineOffset: CGFloat? { get }
}

// MARK: - Default Implementations

// swiftlint:disable missing_docs
public extension CustomEmoji {
    var renderingMode: Image.TemplateRenderingMode? { nil }
    var symbolRenderingMode: SymbolRenderingMode? { nil }
    var baselineOffset: CGFloat? { nil }
    
    // MARK: Hashable
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(shortcode)
    }
    
    // MARK: Equatable
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
    
    // MARK: Identifiable
    
    var id: String { shortcode }
}
// swiftlint:enable missing_docs
