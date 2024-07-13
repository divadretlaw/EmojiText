//
//  EmojiProvider.swift
//  EmojiText
//
//  Created by David Walter on 13.07.24.
//

import Foundation

/// A provider loading emoji's in a synchronized way
public protocol SyncEmojiProvider {
    /// Load the sync emoji
    /// - Parameters:
    ///   - emoji: The sync emoji to load.
    ///   - height: The desired height of the emoji.
    /// - Returns: The image representing the emoji or `nil` if the emoji couldn't be loaded.
    func emojiImage(emoji: any SyncCustomEmoji, height: CGFloat?) -> EmojiImage?
}
