//
//  EmojiRenderer.swift
//  EmojiText
//
//  Created by David Walter on 28.01.24.
//

import SwiftUI
import Combine

protocol EmojiRenderer {
    func render(string: String, emojis: [String: RenderedEmoji]) -> Text
    func renderAnimated(string: String, emojis: [String: RenderedEmoji], at time: CFTimeInterval) -> Text
}

extension EmojiRenderer {
    func renderAnimated(string: String, emojis: [String: RenderedEmoji], at time: CFTimeInterval) -> Text {
        render(string: string, emojis: emojis)
    }
}
