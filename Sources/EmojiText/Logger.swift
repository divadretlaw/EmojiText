//
//  Logger.swift
//  EmojiText
//
//  Created by David Walter on 19.02.23.
//

import Foundation
import OSLog

extension Logger {
    #if swift(>=5.10) && compiler(<6.0)
    nonisolated(unsafe) static let text = Logger(subsystem: "at.davidwalter.EmojiText", category: "Text")
    nonisolated(unsafe) static let emojiText = Logger(subsystem: "at.davidwalter.EmojiText", category: "EmojiText")
    nonisolated(unsafe) static let animatedImage = Logger(subsystem: "at.davidwalter.EmojiText", category: "Animated Image")
    #else
    static let text = Logger(subsystem: "at.davidwalter.EmojiText", category: "Text")
    static let emojiText = Logger(subsystem: "at.davidwalter.EmojiText", category: "EmojiText")
    static let animatedImage = Logger(subsystem: "at.davidwalter.EmojiText", category: "Animated Image")
    #endif
}
