//
//  AsyncEmojiProvider.swift
//  EmojiText
//
//  Created by David Walter on 12.07.24.
//

import Foundation
import OSLog

/// A provider loading emoji's in a asynchronous way e.g. from a remote url.
///
/// > Note:
/// > The default implementation of ``AsyncEmojiProvider/cachedEmojiImage(emoji:height:)-1t879`` calls
/// > ``AsyncEmojiProvider/cachedEmojiData(emoji:height:)-4j1xz`` so you only have to provider one implementation.
public protocol AsyncEmojiProvider: Sendable {
    /// Fetch the async emoji from cache (if applicable)
    /// - Parameters:
    ///   - url: The async emoji to fetch.
    ///   - height: The desired height of the emoji.
    /// - Returns: The data representing the emoji or `nil` if the emoji wasn't cached.
    func cachedEmojiData(emoji: any AsyncCustomEmoji, height: CGFloat?) -> Data?

    /// Fetch the async emoji from cache (if applicable)
    /// - Parameters:
    ///   - url: The async emoji to fetch.
    ///   - height: The desired height of the emoji.
    /// - Returns: The image representing the emoji or `nil` if the emoji wasn't cached.
    func cachedEmojiImage(emoji: any AsyncCustomEmoji, height: CGFloat?) -> EmojiImage?

    /// Fetch the async emoji and return its image data
    /// - Parameters:
    ///   - emoji: The async emoji to fetch.
    ///   - height: The desired height of the emoji.
    /// - Returns: Image data representation
    /// - Throws: An error if the image could not be fetched
    func fetchEmojiData(emoji: any AsyncCustomEmoji, height: CGFloat?) async throws -> Data

    @available(*, deprecated, renamed: "cachedEmojiImage(emoji:height:)")
    func lazyEmojiCached(emoji: any AsyncCustomEmoji, height: CGFloat?) -> EmojiImage?
    @available(*, deprecated, renamed: "fetchEmojiData(emoji:height:)")
    func lazyEmojiData(emoji: any AsyncCustomEmoji, height: CGFloat?) async throws -> Data
}

public extension AsyncEmojiProvider {
    func cachedEmojiData(emoji: any AsyncCustomEmoji, height: CGFloat?) -> Data? {
        nil
    }

    func cachedEmojiImage(emoji: any AsyncCustomEmoji, height: CGFloat?) -> EmojiImage? {
        if let data = cachedEmojiData(emoji: emoji, height: height) {
            return EmojiImage(data: data)
        } else if let image = lazyEmojiCached(emoji: emoji, height: height) {
            Logger.emojiText.error("Loaded image from 'lazyEmojiCached(emoji:height:)' which is deprecated. Please switch to new implementations.")
            return image
        } else {
            return nil
        }
    }
}

// MARK: - Deprecations

public extension AsyncEmojiProvider {
    func lazyEmojiCached(emoji: any AsyncCustomEmoji, height: CGFloat?) -> EmojiImage? {
        nil
    }

    func lazyEmojiData(emoji: any AsyncCustomEmoji, height: CGFloat?) async throws -> Data {
        throw EmojiProviderError.unsupportedEmoji
    }

    func fetchEmojiData(emoji: any AsyncCustomEmoji, height: CGFloat?) async throws -> Data {
        defer {
            Logger.emojiText.error("Fetched data from 'lazyEmojiData(emoji:height:)' which is deprecated. Please switch to new implementations.")
        }
        return try await lazyEmojiData(emoji: emoji, height: height)
    }
}
