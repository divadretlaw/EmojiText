//
//  Logger.swift
//  EmojiText
//
//  Created by David Walter on 19.02.23.
//

import Foundation
import OSLog

extension Logger {
    static let text = Logger(subsystem: "at.davidwalter.EmojiText", category: "Text")
    static let emojiText = Logger(subsystem: "at.davidwalter.EmojiText", category: "EmojiText")
    static let animatedImage = Logger(subsystem: "at.davidwalter.EmojiText", category: "Animated Image")
}
