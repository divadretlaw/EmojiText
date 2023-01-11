//
//  EmojiText.swift
//  EmojiText
//
//  Created by David Walter on 11.01.23.
//

import SwiftUI
import Nuke

/// Markdown formatted Text with support for custom emojis
///
/// Custom Emojis are in the format `:emoji:`.
/// Supports local and remote custom emojis.
/// Remote emojis are resolved using [Nuke](https://github.com/kean/Nuke)
public struct EmojiText: View {
    @Environment(\.imagePipeline) var imagePipeline
    @Environment(\.font) var font
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    
    let rawMarkdown: String
    let emojis: [any CustomEmoji]
    
    var prepend: (() -> Text)?
    var append: (() -> Text)?
    
    @State private var localEmojis: [LocalEmoji] = []
    
    public var body: some View {
        rendered
            .task {
                for emoji in emojis {
                    switch emoji {
                    case let remoteEmoji as RemoteEmoji:
                        guard let response = try? await imagePipeline.image(for: remoteEmoji.url) else { break }
                        localEmojis.append(LocalEmoji(shortcode: remoteEmoji.shortcode, image: response.image))
                    case let localEmoji as LocalEmoji:
                        localEmojis.append(localEmoji)
                    default:
                        break
                    }
                }
            }
    }
    
    /// Initialize a Markdown formatted Text with support for custom emojis
    ///
    /// - Parameters:
    ///     - markdown: Markdown formatted text to render
    ///     - emojis: Array of custom emojis to render
    public init(markdown: String, emojis: [any CustomEmoji]) {
        self.rawMarkdown = markdown
        self.emojis = emojis
    }
    
    // MARK: - Modifier
    
    /// Prepend `Text` to the `EmojiText`
    ///
    /// - Parameter text: Callback generating the text to prepend
    /// - Returns: ``EmojiText`` with some text prepended
    public func prepend(text: @escaping () -> Text) -> Self {
        var view = self
        view.prepend = text
        return view
    }
    
    /// Append `Text` to the `EmojiText`
    ///
    /// - Parameter text: Callback generating the text to append
    /// - Returns: ``EmojiText`` with some text appended
    public func append(text: @escaping () -> Text) -> Self {
        var view = self
        view.append = text
        return view
    }
    
    // MARK: - Helper
    
    var markdown: String {
        var markdown = rawMarkdown
        
        for emoji in localEmojis {
            // Use empty markdown image `![]()` as separator
            markdown = markdown.replacingOccurrences(of: ":\(emoji.shortcode):", with: "![]()\(emoji.shortcode)![]()")
        }
        
        return markdown
    }
    
    var rendered: Text {
        var result = Text(verbatim: "")
        
        if let prepend = self.prepend {
            result = result + prepend()
        }
        
        let font = UIFont.preferredFont(from: self.font, for: self.dynamicTypeSize)
        
        markdown.split(separator: "![]()", omittingEmptySubsequences: true).forEach { substring in
            if let image = localEmojis.first(where: { $0.shortcode == String(substring) }) {
                result = result + Text("\(Image(uiImage: image.image(font: font)))")
            } else {
                result = result + Text(attributedString(from: substring))
            }
        }
        
        if let append = self.append {
            result = result + append()
        }
        
        return result
    }
    
    func attributedString(from substring: Substring) -> AttributedString {
        return attributedString(from: String(substring))
    }
        
    func attributedString(from string: String) -> AttributedString {
        do {
            // Add space between hashtags and mentions that follow each other
            let options = AttributedString.MarkdownParsingOptions(allowsExtendedAttributes: true,
                                                                  interpretedSyntax: .inlineOnlyPreservingWhitespace)
            return try AttributedString(markdown: string, options: options)
        } catch {
            return AttributedString(stringLiteral: string)
        }
    }
}

struct EmojiText_Previews: PreviewProvider {
    static var emojis: [any CustomEmoji] {
        [
            RemoteEmoji(shortcode: "mastodon", url: URL(string: "https://files.mastodon.social/custom_emojis/images/000/003/675/original/089aaae26a2abcc1.png")!),
            LocalEmoji(shortcode: "iphone", image: UIImage(systemName: "iphone")!)
        ]
    }
    static var previews: some View {
        EmojiText(markdown: "Hello World :mastodon: :iphone:", emojis: Self.emojis)
    }
}
