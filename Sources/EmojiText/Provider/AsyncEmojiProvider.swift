//
//  AsyncEmojiProvider.swift
//  EmojiText
//
//  Created by David Walter on 12.07.24.
//

import Foundation

/// A provider loading emoji's in a asynchronous way e.g. from a remote url.
public protocol AsyncEmojiProvider: Sendable {
    /// Fetch the async emoji from cache (if applicable)
    /// - Parameters:
    ///   - url: The async emoji to fetch.
    ///   - height: The desired height of the emoji.
    /// - Returns: The image representing the emoji or `nil` if the emoji wasn't cached.
    func lazyEmojiCached(emoji: any AsyncCustomEmoji, height: CGFloat?) -> EmojiImage?
    
    /// Fetch the async emoji and return its image data
    /// - Parameters:
    ///   - emoji: The async emoji to fetch.
    ///   - height: The desired height of the emoji.
    /// - Returns: Image data representation
    /// - Throws: An error if the image could not be fetched
    func lazyEmojiData(emoji: any AsyncCustomEmoji, height: CGFloat?) async throws -> Data
}
