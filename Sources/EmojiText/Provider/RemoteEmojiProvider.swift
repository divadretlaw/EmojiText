//
//  RemoteEmojiProvider.swift
//  EmojiText
//
//  Created by David Walter on 12.07.24.
//

import Foundation

public protocol RemoteEmojiProvider: EmojiProvider {
    // Data
    
    /// Fetch the remote emoji and return its image data
    /// - Parameters:
    ///   - emoji: The remote emoji to fetch.
    ///   - height: The desired height of the emoji.
    /// - Returns: Image data representation
    /// - Throws: An error if the image could not be fetched
    func emojiData(emoji: RemoteEmoji, height: CGFloat?) async throws -> Data
    
    // EmojiImage
    
    /// Fetch the remote emoji and return its image data
    /// - Parameters:
    ///   - url: The url where to fetch the remote emoji.
    ///   - height: The desired height of the emoji.
    /// - Returns: The fetched image
    /// - Throws: An error if the image could not be fetched
    func emojiImage(emoji: RemoteEmoji, height: CGFloat?) async throws -> EmojiImage
    
    // Cached EmojiImage
    
    /// Fetch the remote emoji from cache (if cached)
    /// - Parameters:
    ///   - url: The url where to fetch the remote emoji.
    ///   - height: The desired height of the emoji.
    /// - Returns: The cached image or `nil`
    func emojiCached(emoji: RemoteEmoji, height: CGFloat?) -> EmojiImage?
}

// MARK: - Default Implementations

public extension RemoteEmojiProvider {
    func emojiImage(emoji: RemoteEmoji, height: CGFloat?) async throws -> EmojiImage {
        let data = try await emojiData(emoji: emoji, height: height)
        return EmojiImage(data: data) ?? EmojiImage()
    }
    
    func emojiCached(emoji: RemoteEmoji, height: CGFloat?) -> EmojiImage? {
        nil
    }
}

// MARK: - EmojiProvider

public extension RemoteEmojiProvider {
    func emojiData(emoji: any CustomEmoji, height: CGFloat?) async throws -> Data {
        switch emoji {
        case let emoji as RemoteEmoji:
            try await emojiData(emoji: emoji, height: height)
        default:
            throw EmojiProviderError.unsupportedEmoji
        }
    }
    
    func emojiCached(emoji: any CustomEmoji, height: CGFloat?) -> EmojiImage? {
        switch emoji {
        case let emoji as RemoteEmoji:
            emojiCached(emoji: emoji, height: height)
        default:
            nil
        }
    }
}
