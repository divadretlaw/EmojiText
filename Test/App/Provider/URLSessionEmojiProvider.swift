//
//  URLSessionEmojiProvider.swift
//  Test
//
//  Created by David Walter on 13.07.24.
//

import Foundation
import EmojiText

struct URLSessionEmojiProvider: AsyncEmojiProvider {
    private let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    // MARK: - AsyncEmojiProvider
    
    func lazyEmojiCached(emoji: any AsyncCustomEmoji, height: CGFloat?) -> EmojiImage? {
        return nil
    }
    
    func lazyEmojiData(emoji: any AsyncCustomEmoji, height: CGFloat?) async throws -> Data {
        switch emoji {
        case let emoji as RemoteEmoji:
            let (data, _) = try await session.data(from: emoji.url)
            return data
        default:
            throw EmojiProviderError.unsupportedEmoji
        }
    }
}
