//
//  CustomEmoji.swift
//  EmojiText
//
//  Created by David Walter on 11.01.23.
//

/// A custom emoji
public protocol CustomEmoji: Equatable, Hashable, Identifiable {
    /// The ID of the emoji
    var id: String { get }
    /// Shortcode of the emoji
    var shortcode: String { get }
}

public extension CustomEmoji {
    var id: String { shortcode }
    
    // MARK: Hashable
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(shortcode)
    }
    
    // MARK: Equatable
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.shortcode == rhs.shortcode
    }
}
