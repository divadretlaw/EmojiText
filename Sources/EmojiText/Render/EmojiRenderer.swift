//
//  EmojiRenderer.swift
//  EmojiText
//
//  Created by David Walter on 28.01.24.
//

import SwiftUI
import Combine

protocol EmojiRenderer {
    // SwiftUI
    func render(string: String, emojis: [String: LoadedEmoji], size: CGFloat?) -> Text
    func renderAnimated(string: String, emojis: [String: LoadedEmoji], size: CGFloat?, at time: CFTimeInterval) -> Text
    // AttributedString
    func render(string: String, emojis: [String: LoadedEmoji], size: CGFloat?) -> NSAttributedString
}

extension EmojiRenderer {
    func renderAnimated(string: String, emojis: [String: LoadedEmoji], size: CGFloat?, at time: CFTimeInterval) -> Text {
        render(string: string, emojis: emojis, size: size)
    }
}
