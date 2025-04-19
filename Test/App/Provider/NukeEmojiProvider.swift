//
//  NukeEmojiProvider.swift
//  Test
//
//  Created by David Walter on 19.04.25.
//

import Foundation
import EmojiText
import Nuke

struct NukeEmojiProvider: AsyncEmojiProvider {
    private let pipeline: ImagePipeline

    init(pipeline: ImagePipeline = .shared) {
        self.pipeline = pipeline
    }

    // MARK: - AsyncEmojiProvider

    func cachedEmojiData(emoji: any AsyncCustomEmoji, height: CGFloat?) -> EmojiImage? {
        switch emoji {
        case let emoji as RemoteEmoji:
            let request = request(for: emoji, height: height)
            guard let container = pipeline.cache[request] else { return nil }
            return container.image
        default:
            return nil
        }
    }

    func fetchEmojiData(emoji: any AsyncCustomEmoji, height: CGFloat?) async throws -> Data {
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
