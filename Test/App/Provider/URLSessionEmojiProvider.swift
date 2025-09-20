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
    
    func cachedEmojiImage(emoji: any AsyncCustomEmoji, height: CGFloat?) -> EmojiImage? {
        return nil
    }
    
    func fetchEmojiData(emoji: any AsyncCustomEmoji, height: CGFloat?) async throws -> Data {
        switch emoji {
        case let emoji as RemoteEmoji:
            let (data, _) = try await session.data(from: emoji.url)
            return data
        default:
            throw EmojiProviderError.unsupportedEmoji
        }
    }
}
