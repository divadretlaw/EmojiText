//
//  AttributedStringEmojiRenderer.swift
//  EmojiText
//
//  Created by Łukasz Rutkowski on 19/09/2025.
//

import Foundation
import SwiftUI

struct AttributedStringEmojiRenderer: EmojiRenderer {
    let attributedString: AttributedString
    let shouldOmitSpacesBetweenEmojis: Bool

    init(attributedString: AttributedString, shouldOmitSpacesBetweenEmojis: Bool) {
        self.attributedString = attributedString
        self.shouldOmitSpacesBetweenEmojis = shouldOmitSpacesBetweenEmojis
    }

    init(attributedString: NSAttributedString, shouldOmitSpacesBetweenEmojis: Bool) {
        self.attributedString = AttributedString(attributedString)
        self.shouldOmitSpacesBetweenEmojis = shouldOmitSpacesBetweenEmojis
    }

    // MARK: SwiftUI

    func render(emojis: [String: LoadedEmoji], size: CGFloat?) -> Text {
        renderAnimated(emojis: emojis, size: size, at: 0)
    }

    func renderAnimated(emojis: [String: LoadedEmoji], size: CGFloat?, at time: CFTimeInterval) -> Text {
        let attributedString = renderAttributedString(with: emojis)

        var result = Text(verbatim: "")
        var partialString = AttributedPartialstring()

        for run in attributedString.runs {
            if let emoji = run.attributes[EmojiAttribute.self] {
                // If the run is an emoji we render it as an interpolated image in a Text view
                let text = Text(emoji, size: size, at: time)

                // If the same emoji is added multiple times in a row the run gets merged into one
                // with their shortcodes joined. Therefore we simply divide distance of the range by
                // the character count of the emoji to calculate how often the emoji needs to be displayed
                let distance = attributedString.distance(from: run.range.lowerBound, to: run.range.upperBound)
                let count = emoji.shortcode.count + 2 // leading and trailing ':'

                if distance == count {
                    // Emoji is only displayed once
                    result = [
                        result,
                        Text(&partialString),
                        text
                    ]
                    .compactMap { $0 }
                    .joined()
                } else {
                    // Emojis is displayed multiple times
                    result = [
                        result,
                        Text(&partialString),
                        Text(repating: text, count: distance / count)
                    ]
                    .compactMap { $0 }
                    .joined()
                }
            } else {
                // Otherwise we just append the run to AttributedPartialstring
                partialString.append(attributedString[run.range])
            }
        }

        return [result, Text(&partialString)]
            .compactMap { $0 }
            .joined()
    }

    private func renderAttributedString(with emojis: [String: LoadedEmoji]) -> AttributedString {
        var string = attributedString
        for (shortcode, emoji) in emojis {
            for range in attributedString.ranges(of: ":\(shortcode):") {
                string[range].emoji = emoji
            }
        }
        if shouldOmitSpacesBetweenEmojis, string.runs.count > 2 {
            string.removeWhitespaceBetweenEmojis()
        }
        return string
    }

    // MARK: - UIKit & AppKit

    func render(emojis: [String: LoadedEmoji], size: CGFloat?) -> NSAttributedString {
        let attributedString = renderAttributedString(with: emojis)
        let result = NSMutableAttributedString()
        for run in attributedString.runs {
            if let emoji = run.attributes[EmojiAttribute.self] {
                // If the run is an emoji we render it as an interpolated image in an NSAttributedString
                result.append(NSAttributedString(emoji, size: size))
            } else {
                // Otherwise we just append the run to NSAttributedString
                let string = AttributedString(attributedString[run.range])
                result.append(NSAttributedString(string))
            }
        }
        return result
    }
}

// MARK: - Attributes

private extension AttributeScopes {
    struct EmojiAttributes: AttributeScope {
        let emoji: EmojiAttribute
    }

    var emoji: EmojiAttributes.Type { EmojiAttributes.self }
}

private enum EmojiAttribute: AttributedStringKey {
    typealias Value = LoadedEmoji
    static let name = "Emoji"
}

private extension AttributeDynamicLookup {
    subscript<T: AttributedStringKey>(dynamicMember keyPath: KeyPath<AttributeScopes.EmojiAttributes, T>) -> T {
        self[T.self]
    }
}

private extension AttributedString.Runs.Run {
    var isEmoji: Bool {
        attributes[EmojiAttribute.self] != nil
    }
}

private extension AttributedString {
    func ranges(of string: String) -> [Range<Index>] {
        let plainText = String(characters)
        var ranges: [Range<Index>] = []
        var searchRange = plainText.startIndex..<plainText.endIndex
        while let range = plainText.range(of: string, range: searchRange) {
            if
                let startIndex = Index(range.lowerBound, within: self),
                let endIndex = Index(range.upperBound, within: self) {
                ranges.append(startIndex..<endIndex)
            }

            searchRange = range.upperBound..<searchRange.upperBound
        }
        return ranges
    }

    mutating func removeWhitespaceBetweenEmojis() {
        var indicesToRemove: [AttributedString.Runs.Index] = []
        var index = runs.startIndex
        while index < runs.endIndex {
            guard runs[index].isEmoji else {
                index = runs.index(after: index)
                continue
            }
            index = runs.index(after: index)
            var potentialIndicesToRemove: [Runs.Index] = []
            while index < runs.endIndex && self[runs[index].range].isWhitespaceExcludingNewline {
                potentialIndicesToRemove.append(index)
                index = runs.index(after: index)
            }
            if index < runs.endIndex && runs[index].isEmoji {
                indicesToRemove.append(contentsOf: potentialIndicesToRemove)
            }
        }
        for index in indicesToRemove.reversed() {
            removeSubrange(runs[index].range)
        }
    }
}

private extension AttributedSubstring {
    var isWhitespaceExcludingNewline: Bool {
        characters.allSatisfy { character in
            character.isWhitespace && !character.isNewline
        }
    }
}

#if DEBUG
#Preview {
    let hello = AttributedString("Hello", attributes: AttributeContainer().font(.body.bold()))
    return List {
        EmojiText(
            hello + AttributedString(" :a:"),
            emojis: .emojis
        )
        EmojiText(
            hello + AttributedString(" World :wide:"),
            emojis: .emojis
        )
        EmojiText(
            hello + AttributedString(" World :test:"),
            emojis: .emojis
        )
        EmojiText(
            hello + AttributedString(" World :a: :wide: :a: :wide:"),
            emojis: .emojis
        )
        EmojiText(
            hello + AttributedString(" World :a::a::a:"),
            emojis: .emojis
        )
        EmojiText(
            hello + AttributedString(" World :a: :a:   :a:"),
            emojis: .emojis
        )
        EmojiText(
            hello + AttributedString(" World :a: :a:   :a:"),
            emojis: .emojis,
            shouldOmitSpacesBetweenEmojis: false
        )
        EmojiText(
            AttributedString(":a: :a: ") + AttributedString(" ", attributes: AttributeContainer().font(.body.bold())) + AttributedString(" :a:"),
            emojis: .emojis
        )
        EmojiText(
            AttributedString(":a:   \n   :a:"),
            emojis: .emojis
        )
    }
}
#endif
