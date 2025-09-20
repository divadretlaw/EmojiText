//
//  MarkdownEmojiRenderer.swift
//  EmojiText
//
//  Created by David Walter on 26.01.24.
//

import SwiftUI
import Markdown
import OSLog

struct MarkdownEmojiRenderer: EmojiRenderer {
    let string: String
    let font: EmojiFont?
    let shouldOmitSpacesBetweenEmojis: Bool
    let interpretedSyntax: AttributedString.MarkdownParsingOptions.InterpretedSyntax
    private let formatterOptions: MarkupFormatter.Options

    init(
        string: String,
        font: EmojiFont? = nil,
        shouldOmitSpacesBetweenEmojis: Bool,
        interpretedSyntax: AttributedString.MarkdownParsingOptions.InterpretedSyntax
    ) {
        self.string = string
        self.font = font
        self.shouldOmitSpacesBetweenEmojis = shouldOmitSpacesBetweenEmojis
        self.interpretedSyntax = interpretedSyntax

        self.formatterOptions = MarkupFormatter.Options(
            unorderedListMarker: .star,
            orderedListNumerals: .incrementing(start: 1)
        )
    }

    func formatMarkdown(_ string: String, emojis: [String: LoadedEmoji]) -> String {
        // We need to replace \\ with \\\\ otherwise the Markdown parser
        // will interpret the previously escaped characters when rendering
        // them in AttributedString
        let escapedString = string.replacingOccurrences(of: "\\", with: "\\\\")
        let originalDocument = Document(parsing: escapedString)
        var emojiReplacer = MarkdownEmojiReplacer(emojis: emojis)
        let emojiDocument = emojiReplacer.visitDocument(originalDocument) ?? originalDocument

        return emojiDocument.format(options: formatterOptions)
            .splitOnEmoji(omittingSpacesBetweenEmojis: shouldOmitSpacesBetweenEmojis)
            .joined()
    }

    // MARK: - SwiftUI

    func render(emojis: [String: LoadedEmoji], size: CGFloat?) -> SwiftUI.Text {
        renderAnimated(emojis: emojis, size: size, at: 0)
    }

    func renderAnimated(emojis: [String: LoadedEmoji], size: CGFloat?, at time: CFTimeInterval) -> SwiftUI.Text {
        let attributedString = renderAttributedString(from: string, with: emojis)
        
        var result = Text(verbatim: "")
        var partialString = AttributedPartialstring()
        
        for run in attributedString.runs {
            if let emoji = run.emoji(from: emojis) {
                // If the run is an emoji we render it as an interpolated image in a Text view
                let text = Text(emoji, size: size, at: time)

                // If the same emoji is added multiple times in a row the run gets merged into one
                // with their shortcodes joined. Therefore we simply divide distance of the range by
                // the character count of the emojo to calculate how often the emoji needs to be displayed
                let distance = attributedString.distance(from: run.range.lowerBound, to: run.range.upperBound)
                let count = emoji.shortcode.count
                
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

    private func renderAttributedString(from string: String, with emojis: [String: LoadedEmoji]) -> AttributedString {
        do {
            let options = AttributedString.MarkdownParsingOptions(
                allowsExtendedAttributes: true,
                interpretedSyntax: interpretedSyntax,
                failurePolicy: .returnPartiallyParsedIfPossible
            )

            let markdown = formatMarkdown(string, emojis: emojis)
            return try AttributedString(markdown: markdown, options: options)
        } catch {
            Logger.text.error("Unable to parse Markdown, falling back to verbatim string: \(error.localizedDescription)")
            return AttributedString(stringLiteral: string)
        }
    }

    // MARK: - UIKit & AppKit

    func render(emojis: [String: LoadedEmoji], size: CGFloat?) -> NSAttributedString {
        let markdown = formatMarkdown(string, emojis: emojis)
        var renderer = MarkdownEmojiVisitor(
            emojis: emojis,
            font: font ?? EmojiFont.preferredFont(forTextStyle: .body),
            interpretedSyntax: interpretedSyntax
        )
        return renderer.parseAndVisit(markdown)
    }

    // MARK: - Hashable & Equatable

    static func == (lhs: Self, rhs: Self) -> Bool {
        guard
            lhs.string == rhs.string,
            lhs.font == rhs.font,
            lhs.shouldOmitSpacesBetweenEmojis == rhs.shouldOmitSpacesBetweenEmojis,
            lhs.interpretedSyntax == rhs.interpretedSyntax
        else {
            return false
        }
        return true
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(string)
        hasher.combine(font)
        hasher.combine(shouldOmitSpacesBetweenEmojis)
        hasher.combine(interpretedSyntax)
    }
}

#if DEBUG
#Preview {
    List {
        EmojiText(
            markdown: "Hello :a:",
            emojis: .emojis
        )
        EmojiText(
            markdown: "Hello [:a:](https://github.com)",
            emojis: .emojis
        )
        EmojiText(
            markdown: """
            Hello :a:
            
            ```
            EmojiText(markdown: "Hello :a:", emojis: .emojis)
            ```
            
            World :wide:
            """,
            emojis: .emojis
        )
        EmojiText(
            markdown: """
            # Hello :a:
            ## Hello :a:
            ### Hello :a:
            **Hello :a:**
            *Hello :a:*
            _Hello :a:_
            `Hello :a:`
            
            * Hello :a:
            * Hello :wide:
              
            1. Hello :a:
            2. Hello :wide:
            """,
            emojis: .emojis
        )
    }
}
#endif
