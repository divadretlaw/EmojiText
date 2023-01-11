//
//  RemoteEmoji.swift
//  EmojiText
//
//  Created by David Walter on 11.01.23.
//

import UIKit

/// A custom remote emoji
public struct RemoteEmoji: CustomEmoji {
    /// Shortcode of the emoji
    public let shortcode: String
    /// Remote location of the emoji
    public let url: URL
    
    public init(shortcode: String, url: URL) {
        self.shortcode = shortcode
        self.url = url
    }
}
