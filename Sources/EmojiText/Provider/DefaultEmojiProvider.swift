//
//  DefaultEmojiProvider.swift
//  EmojiText
//
//  Created by David Walter on 13.07.24.
//

import Foundation

struct DefaultEmojiProvider: RemoteEmojiProvider {
    private let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    // MARK: - RemoteEmojiProvider
    
    func emojiData(emoji: RemoteEmoji, height: CGFloat?) async throws -> Data {
        let (data, _) = try await session.data(from: emoji.url)
        return data
    }
    
    #if os(iOS) || targetEnvironment(macCatalyst) || os(tvOS) || os(watchOS) || os(visionOS)
    func emojiImage(emoji: RemoteEmoji, height: CGFloat?) async throws -> EmojiImage {
        let (data, _) = try await session.data(from: emoji.url)
        guard let image = EmojiImage(data: data) else {
            throw EmojiProviderError.invalidData
        }
        guard let preparedImage = await image.byPreparingForDisplay() else {
            return image
        }
        return preparedImage
    }
    #endif
}
