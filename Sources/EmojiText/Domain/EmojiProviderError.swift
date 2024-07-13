//
//  EmojiProviderError.swift
//  EmojiText
//
//  Created by David Walter on 13.07.24.
//

import Foundation

enum EmojiProviderError: Swift.Error {
    /// Throw this error when an unsupported emojis is trying to be fetched
    case unsupportedEmoji
}
