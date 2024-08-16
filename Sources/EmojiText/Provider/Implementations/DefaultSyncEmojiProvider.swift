//
//  DefaultEmojiProvider.swift
//  EmojiText
//
//  Created by David Walter on 14.07.24.
//

import Foundation

struct DefaultSyncEmojiProvider: SyncEmojiProvider {
    // MARK: - SyncEmojiProvider
    
    func emojiImage(emoji: any SyncCustomEmoji, height: CGFloat?) -> EmojiImage? {
        switch emoji {
        case let emoji as LocalEmoji:
            if let color = emoji.color {
                #if os(macOS)
                return emoji.image.withColor(color)
                #else
                return emoji.image.withTintColor(color, renderingMode: .alwaysTemplate)
                #endif
            } else {
                return emoji.image
            }
        default:
            return nil
        }
    }
}
