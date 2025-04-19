//
//  DefaultEmojiProvider.swift
//  EmojiText
//
//  Created by David Walter on 13.07.24.
//

import Foundation

public struct DefaultAsyncEmojiProvider: AsyncEmojiProvider {
    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    // MARK: - AsyncEmojiProvider

    public func cachedEmojiData(emoji: any AsyncCustomEmoji, height: CGFloat?) -> Data? {
        guard let cache = session.configuration.urlCache else { return nil }
        switch emoji {
        case let emoji as RemoteEmoji:
            let request = URLRequest(url: emoji.url)
            guard let response = cache.cachedResponse(for: request) else { return nil }
            return response.data
        default:
            return nil
        }
    }

    public func fetchEmojiData(emoji: any AsyncCustomEmoji, height: CGFloat?) async throws -> Data {
        switch emoji {
        case let emoji as RemoteEmoji:
            let (data, _) = try await session.data(from: emoji.url)
            return data
        default:
            throw EmojiProviderError.unsupportedEmoji
        }
    }
}
