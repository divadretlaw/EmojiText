//
//  RemoteEmoji.swift
//  EmojiText
//
//  Created by David Walter on 11.01.23.
//

import Foundation
import SwiftUI

/// A custom remote emoji
public struct RemoteEmoji: CustomEmoji {
    /// Shortcode of the emoji
    public let shortcode: String
    /// Remote location of the emoji
    public let url: URL
    /// The mode SwiftUI uses to render this emoji
    public let renderingMode: Image.TemplateRenderingMode?
    public let baselineOffset: CGFloat?

    /// Size for wide width emoji.
    public let size: CGSize?
    
    /// Initialize a remote emoji
    ///
    /// - Parameters:
    ///     - shortcode: The shortcode of the emoji
    ///     - url: The remote location of the emoji
    ///     - renderingMode: The mode SwiftUI uses to render this emoji
    ///     - baselineOffset: The baseline offset to use when rendering this emoji
    public init(shortcode: String, url: URL, renderingMode: Image.TemplateRenderingMode? = nil, baselineOffset: CGFloat? = nil, size: CGSize? = nil) {
        self.shortcode = shortcode
        self.url = url
        self.renderingMode = renderingMode
        self.baselineOffset = baselineOffset
        self.size = size
    }
    
    // MARK: Hashable
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(shortcode)
        hasher.combine(url)
        hasher.combine(renderingMode)
        hasher.combine(baselineOffset)
        hasher.combine(size?.width)
        hasher.combine(size?.height)
    }
    
    // MARK: Equatable
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        guard lhs.shortcode == rhs.shortcode else { return false }
        return lhs.url == rhs.url
    }
}
