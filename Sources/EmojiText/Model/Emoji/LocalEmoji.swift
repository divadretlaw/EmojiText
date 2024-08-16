//
//  LocalEmoji.swift
//  EmojiText
//
//  Created by David Walter on 11.01.23.
//

import Foundation
import SwiftUI

/// A custom local emoji
public struct LocalEmoji: SyncCustomEmoji {
    /// Shortcode of the emoji
    public let shortcode: String
    /// The image representing the emoji
    public let image: EmojiImage
    /// The color to render the emoji with
    ///
    /// Set `nil` if you don't want to override the color.
    public let color: EmojiColor?
    /// The mode SwiftUI uses to render this emoji
    public let renderingMode: Image.TemplateRenderingMode?
    /// The emoji baseline offset
    public let baselineOffset: CGFloat?
    
    /// Initialize a local custom emoji
    ///
    /// - Parameters:
    ///     - shortcode: The shortcode of the emoji
    ///     - image: The image containing the emoji
    ///     - color: Override the color to render the emoji with
    ///     - renderingMode: The mode SwiftUI uses to render this emoji
    ///     - baselineOffset: The baseline offset to use when rendering this emoji
    public init(shortcode: String, image: EmojiImage, color: EmojiColor? = nil, renderingMode: Image.TemplateRenderingMode? = nil, baselineOffset: CGFloat? = nil) {
        self.shortcode = shortcode
        self.image = image
        self.renderingMode = renderingMode
        self.baselineOffset = baselineOffset
        self.color = color
    }
    
    // MARK: - Hashable
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(shortcode)
        hasher.combine(image)
        hasher.combine(renderingMode)
        hasher.combine(baselineOffset)
        hasher.combine(color)
    }
    
    // MARK: - Equatable
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        guard lhs.shortcode == rhs.shortcode else { return false }
        return lhs.image == rhs.image
    }
}
