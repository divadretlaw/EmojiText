//
//  RemoteEmoji.swift
//  EmojiText
//
//  Created by David Walter on 11.01.23.
//

import Foundation

public struct RemoteEmoji: CustomEmoji {
    public let shortcode: String
    public let url: URL
    
    public init(shortcode: String, url: URL) {
        self.shortcode = shortcode
        self.url = url
    }
    
    // MARK: Identifiable
    
    public var id: String {
        shortcode
    }
    
    // MARK: Hashable
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(shortcode)
    }
}
