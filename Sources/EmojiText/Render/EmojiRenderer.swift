//
//  EmojiRenderer.swift
//  EmojiText
//
//  Created by David Walter on 28.01.24.
//

import SwiftUI
import Combine

protocol EmojiRenderer: Hashable {
    // SwiftUI
    func render(emojis: [String: LoadedEmoji], size: CGFloat?) -> Text
    func renderAnimated(emojis: [String: LoadedEmoji], size: CGFloat?, at time: CFTimeInterval) -> Text
    // AttributedString
    func render(emojis: [String: LoadedEmoji], size: CGFloat?) -> NSAttributedString
}

extension EmojiRenderer {
    func renderAnimated(emojis: [String: LoadedEmoji], size: CGFloat?, at time: CFTimeInterval) -> Text {
        render(emojis: emojis, size: size)
    }
}
