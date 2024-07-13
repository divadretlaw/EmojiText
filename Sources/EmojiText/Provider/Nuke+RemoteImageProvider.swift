//
//  NukeRemoteImagerProvider.swift
//  EmojiText
//
//  Created by David Walter on 12.07.24.
//

import Foundation
import Nuke

extension ImagePipeline: RemoteEmojiProvider {
    // MARK: - EmojiProvider
    
    public func emojiData(emoji: RemoteEmoji, height: CGFloat?) async throws -> Data {
        let request = request(for: emoji, height: height)
        let (data, _) = try await data(for: request)
        return data
    }
    
    public func emojiImage(emoji: RemoteEmoji, height: CGFloat?) async throws -> EmojiImage {
        let request = request(for: emoji, height: height)
        return try await image(for: request)
    }
    
    public func emojiCached(emoji: RemoteEmoji, height: CGFloat?) -> EmojiImage? {
        let request = request(for: emoji, height: height)
        guard let container = cache[request] else { return nil }
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
