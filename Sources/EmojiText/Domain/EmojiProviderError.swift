//
//  EmojiProviderError.swift
//  EmojiText
//
//  Created by David Walter on 13.07.24.
//

import Foundation

public enum EmojiProviderError: Swift.Error {
    /// Thrown when the fetched data is invalid
    case invalidData
    /// Thrown when an unsupported emojis is trying to be fetched
    case unsupportedEmoji
}
