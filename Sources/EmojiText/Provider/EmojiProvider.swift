//
//  EmojiProvider.swift
//  EmojiText
//
//  Created by David Walter on 12.07.24.
//

import Foundation

public protocol EmojiProvider: Sendable {
    // Data
    
    /// Fetch the remote emoji and return its image data
    /// - Parameters:
    ///   - emoji: The remote emoji to fetch.
    ///   - height: The desired height of the emoji.
    /// - Returns: Image data representation
    /// - Throws: An error if the image could not be fetched
    func emojiData(emoji: any CustomEmoji, height: CGFloat?) async throws -> Data
    
    // EmojiImage
    
    /// Fetch the remote emoji and return its image data
    /// - Parameters:
    ///   - url: The url where to fetch the remote emoji.
    ///   - height: The desired height of the emoji.
    /// - Returns: The fetched image
    /// - Throws: An error if the image could not be fetched
    func emojiImage(emoji: any CustomEmoji, height: CGFloat?) async throws -> EmojiImage
    
    // Cached EmojiImage
    
    /// Fetch the remote emoji from cache (if cached)
    /// - Parameters:
    ///   - url: The url where to fetch the remote emoji.
    ///   - height: The desired height of the emoji.
    /// - Returns: The cached image or `nil`
    func emojiCached(emoji: any CustomEmoji, height: CGFloat?) -> EmojiImage?
}

// MARK: - Default Implementations

public extension EmojiProvider {
    func emojiImage(emoji: any CustomEmoji, height: CGFloat?) async throws -> EmojiImage {
        let data = try await emojiData(emoji: emoji, height: height)
        return EmojiImage(data: data) ?? EmojiImage()
    }
    
    func emojiCached(emoji: any CustomEmoji, height: CGFloat?) -> EmojiImage? {
        nil
    }
}
