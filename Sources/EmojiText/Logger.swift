//
//  Logger.swift
//  EmojiText
//
//  Created by David Walter on 19.02.23.
//

import Foundation
import OSLog

extension Logger {
    static var text = Logger(subsystem: "at.davidwalter.EmojiText", category: "Text")
    static var emojiText = Logger(subsystem: "at.davidwalter.EmojiText", category: "EmojiText")
    static var animatedImage = Logger(subsystem: "at.davidwalter.EmojiText", category: "Animated Image")
}
