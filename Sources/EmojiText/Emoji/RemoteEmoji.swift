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
    
    /// Initialize a remote emoji
    ///
    /// - Parameters:
    ///     - shortcode: The shortcode of the emoji
    ///     - url: The remote location of the emoji
    ///     - renderingMode: The mode SwiftUI uses to render this emoji
    public init(shortcode: String, url: URL, renderingMode: Image.TemplateRenderingMode? = nil) {
        self.shortcode = shortcode
        self.url = url
        self.renderingMode = renderingMode
    }
    
    // MARK: Hashable
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(shortcode)
        hasher.combine(url)
    }
    
    // MARK: Equatable
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        guard lhs.shortcode == rhs.shortcode else { return false }
        return lhs.url == rhs.url
    }
}
