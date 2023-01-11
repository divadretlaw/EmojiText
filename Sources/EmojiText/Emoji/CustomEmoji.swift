//
//  CustomEmoji.swift
//  EmojiText
//
//  Created by David Walter on 11.01.23.
//

public protocol CustomEmoji: Equatable, Hashable, Identifiable {
    var id: String { get }
    var shortcode: String { get }
}

public extension CustomEmoji {
    var id: String { shortcode }
}
