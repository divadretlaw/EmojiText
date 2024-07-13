//
//  NukeEmojiProvider.swift
//  NukeEmojiText
//
//  Created by David Walter on 13.07.24.
//

import Foundation
import EmojiText
import Nuke

struct NukeEmojiProvider: RemoteEmojiProvider {
    private let pipeline: ImagePipeline
    
    init(pipeline: ImagePipeline) {
        self.pipeline = pipeline
    }
    
    // MARK: - EmojiProvider
    
    func emojiData(emoji: RemoteEmoji, height: CGFloat?) async throws -> Data {
        let request = request(for: emoji, height: height)
        let (data, _) = try await pipeline.data(for: request)
        return data
    }
    
    func emojiImage(emoji: RemoteEmoji, height: CGFloat?) async throws -> EmojiImage {
        let request = request(for: emoji, height: height)
        return try await pipeline.image(for: request)
    }
    
    func emojiCached(emoji: RemoteEmoji, height: CGFloat?) -> EmojiImage? {
        let request = request(for: emoji, height: height)
        guard let container = pipeline.cache[request] else { return nil }
        return container.image
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
