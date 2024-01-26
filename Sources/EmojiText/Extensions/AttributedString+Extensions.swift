//
//  AttributedString+Extensions.swift
//  EmojiText
//
//  Created by David Walter on 20.12.23.
//

import SwiftUI

extension AttributedString {
    func distance(from start: AttributedString.Index, to end: AttributedString.Index) -> Int {
        characters.distance(from: start, to: end)
    }
}

extension AttributedString.Runs.Element {
    func emoji(from values: [String: RenderedEmoji]) -> RenderedEmoji? {
        guard let imageURL = attributes[AttributeScopes.FoundationAttributes.ImageURLAttribute.self] else { return nil }
        guard imageURL.scheme == String.emojiScheme else { return nil }
        if #available(iOS 16, macOS 13, tvOS 16, watchOS 9, *) {
            guard let host = imageURL.host(percentEncoded: false) else { return nil }
            return values[host]
        } else {
            guard let host = imageURL.host else { return nil }
            return values[host]
        }
    }
}
