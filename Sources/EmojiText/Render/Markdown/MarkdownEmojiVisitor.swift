//
//  MarkdownEmojiVisitor.swift
//  EmojiText
//
//  Created by David Walter on 15.08.25.
//

import Foundation
import Markdown
#if canImport(UIKit)
import UIKit
#endif
#if canImport(AppKit)
import AppKit
#endif

struct MarkdownEmojiVisitor: MarkupVisitor {
    private let emojis: [String: LoadedEmoji]
    private let font: EmojiFont
    private let interpretedSyntax: AttributedString.MarkdownParsingOptions.InterpretedSyntax

    init(
        emojis: [String: LoadedEmoji],
        font: EmojiFont,
        interpretedSyntax: AttributedString.MarkdownParsingOptions.InterpretedSyntax = .inlineOnlyPreservingWhitespace
    ) {
        self.emojis = emojis
        self.font = font
        self.interpretedSyntax = interpretedSyntax
    }

    private var basePointSize: CGFloat {
        font.pointSize
    }

    mutating func parseAndVisit(_ string: String) -> NSAttributedString {
        let document = Document(parsing: string)
        return visit(document)
    }

    // MARK: - MarkupVisitor

    mutating func defaultVisit(_ markup: any Markup) -> NSAttributedString {
        let result = NSMutableAttributedString()
        for child in markup.children {
            result.append(visit(child))
        }
        return result
    }

    mutating func visitHeading(_ heading: Markdown.Heading) -> NSAttributedString {
        let result = NSMutableAttributedString()

        switch interpretedSyntax {
        case .inlineOnly, .inlineOnlyPreservingWhitespace:
            result.append(NSAttributedString(string: Array(repeating: "#", count: heading.level).joined(), attributes: [.font: font]))
            result.append(NSAttributedString(string: " ", attributes: [.font: font]))
        default:
            break
        }

        for child in heading.children {
            result.append(visit(child))
        }

        if let childCount = heading.parent?.childCount {
            if heading.indexInParent < childCount - 1 {
                result.append(NSAttributedString(string: "\n\n", attributes: [.font: font]))
            }
        }

        return result
    }

    mutating func visitParagraph(_ paragraph: Markdown.Paragraph) -> NSAttributedString {
        let result = NSMutableAttributedString()

        for child in paragraph.children {
            result.append(visit(child))
        }

        if let childCount = paragraph.parent?.childCount {
            if paragraph.indexInParent < childCount - 1 {
                result.append(NSAttributedString(string: "\n\n", attributes: [.font: font]))
            }
        }

        return result
    }

    mutating func visitInlineCode(_ inlineCode: Markdown.InlineCode) -> NSAttributedString {
        NSAttributedString(string: inlineCode.code, attributes: [.font: EmojiFont.monospacedSystemFont(ofSize: basePointSize, weight: .regular)])
    }

    mutating func visitEmphasis(_ emphasis: Emphasis) -> NSAttributedString {
        let result = NSMutableAttributedString()

        for child in emphasis.children {
            result.append(visit(child))
        }

        result.enumerateAttribute(.font) { value, _, _ in
            guard let font = value as? EmojiFont else { return }
            #if os(iOS) || targetEnvironment(macCatalyst) || os(tvOS) || os(watchOS) || os(visionOS)
            let newFont = font.with(traits: .traitItalic)
            #elseif os(macOS)
            let newFont = font.with(traits: .italic)
            #endif
            result.addAttribute(.font, value: newFont)
        }

        return result
    }

    mutating func visitImage(_ image: Markdown.Image) -> NSAttributedString {
        if let emoji = image.emoji(from: emojis) {
            return NSAttributedString(emoji, size: nil)
        } else {
            let result = NSMutableAttributedString()

            for child in image.children {
                result.append(visit(child))
            }

            return result
        }
    }

    mutating func visitLink(_ link: Markdown.Link) -> NSAttributedString {
        let result = NSMutableAttributedString()

        for child in link.children {
            result.append(visit(child))
        }

        let url: URL? = if let destination = link.destination {
            URL(string: destination)
        } else {
            nil
        }

        if let url {
            result.addAttribute(.link, value: url)
        }

        return result
    }

    mutating func visitStrong(_ strong: Markdown.Strong) -> NSAttributedString {
        let result = NSMutableAttributedString()

        for child in strong.children {
            result.append(visit(child))
        }

        result.enumerateAttribute(.font) { value, range, _ in
            guard let font = value as? EmojiFont else { return }
            #if os(iOS) || targetEnvironment(macCatalyst) || os(tvOS) || os(watchOS) || os(visionOS)
            let newFont = font.with(traits: .traitBold)
            #elseif os(macOS)
            let newFont = font.with(traits: .bold)
            #endif
            result.addAttribute(.font, value: newFont, range: range)
        }

        return result
    }

    mutating func visitText(_ text: Markdown.Text) -> NSAttributedString {
        NSAttributedString(string: text.plainText, attributes: [.font: EmojiFont.systemFont(ofSize: basePointSize, weight: .regular)])
    }

    mutating func visitStrikethrough(_ strikethrough: Strikethrough) -> NSAttributedString {
        let result = NSMutableAttributedString()

        for child in strikethrough.children {
            result.append(visit(child))
        }

        result.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue)

        return result
    }
}

private extension Markdown.Image {
    func emoji(from values: [String: LoadedEmoji]) -> LoadedEmoji? {
        guard let source, let imageURL = URL(string: source) else { return nil }
        guard imageURL.scheme == String.emojiScheme else { return nil }
        if #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
            guard let host = imageURL.host(percentEncoded: false) else { return nil }
            return values[host]
        } else {
            guard let host = imageURL.host else { return nil }
            return values[host]
        }
    }
}
