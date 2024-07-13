//
//  DefaultEmojiProvider.swift
//  EmojiText
//
//  Created by David Walter on 13.07.24.
//

import Foundation
import Nuke

struct DefaultAsyncEmojiProvider: AsyncEmojiProvider {
    private let pipeline: ImagePipeline
    
    init(pipeline: ImagePipeline) {
        self.pipeline = pipeline
    }
    
    // MARK: - AsyncEmojiProvider
    
    func lazyEmojiCached(emoji: any AsyncCustomEmoji, height: CGFloat?) -> EmojiImage? {
        switch emoji {
        case let emoji as RemoteEmoji:
            let request = request(for: emoji, height: height)
            guard let container = pipeline.cache[request] else { return nil }
            return container.image
        default:
            return nil
        }
    }
    
    func lazyEmojiCached(emoji: RemoteEmoji, height: CGFloat?) -> EmojiImage? {
        let request = request(for: emoji, height: height)
        guard let container = pipeline.cache[request] else { return nil }
        return container.image
    }
    
    func lazyEmojiData(emoji: any AsyncCustomEmoji, height: CGFloat?) async throws -> Data {
        switch emoji {
        case let emoji as RemoteEmoji:
            let request = request(for: emoji, height: height)
            let (data, _) = try await pipeline.data(for: request)
            return data
        default:
            throw EmojiProviderError.unsupportedEmoji
        }
    }
    
    // MARK: - Helper
    
    private func request(for emoji: RemoteEmoji, height: CGFloat?) -> ImageRequest {
        if let height {
            ImageRequest(url: emoji.url, processors: [.resize(height: height)])
        } else {
            ImageRequest(url: emoji.url)
        }
    }
}
