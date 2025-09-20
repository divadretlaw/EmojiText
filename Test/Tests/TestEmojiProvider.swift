//
//  TestEmojiProvider.swift
//  SnapshotTests
//
//  Created by David Walter on 02.10.24.
//

import Foundation
import EmojiText

struct TestEmojiProvider: AsyncEmojiProvider {
    init() {
    }
    
    // MARK: - AsyncEmojiProvider
    
    func cachedEmojiImage(emoji: any AsyncCustomEmoji, height: CGFloat?) -> EmojiImage? {
        switch emoji.shortcode {
        case "wide":
            return EmojiImage(named: "wide")
        default:
            return EmojiImage(named: "async")
        }
    }
    
    func fetchEmojiData(emoji: any AsyncCustomEmoji, height: CGFloat?) async throws -> Data {
        EmojiImage(systemName: "exclamationmark.triangle")?.pngData() ?? Data()
    }
}
