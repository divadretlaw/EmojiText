//
//  EmojiText.swift
//  EmojiText
//
//  Created by David Walter on 11.01.23.
//

import SwiftUI
import Nuke
import os

/// Markdown formatted Text with support for custom emojis
///
/// Custom Emojis are in the format `:emoji:`.
/// Supports local and remote custom emojis.
/// Remote emojis are resolved using [Nuke](https://github.com/kean/Nuke)
public struct EmojiText: View {
    @Environment(\.imagePipeline) var imagePipeline
    @Environment(\.placeholderEmoji) var placeholderEmoji
    @Environment(\.font) var font
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    
    @ScaledMetric
    var scaleFactor: CGFloat = 1.0
    
    let rawMarkdown: String
    let emojis: [any CustomEmoji]
    
    var prepend: (() -> Text)?
    var append: (() -> Text)?
    
    @State private var localEmojis = Set<LocalEmoji>()
    
    var logger = Logger()
    
    public var body: some View {
        rendered
            .task {
                // Set placeholders
                self.localEmojis = placeholders()
                
                // Load actual emojis
                self.localEmojis = await loadRemoteEmoji()
            }
    }
    
    var targetSize: CGSize {
        let font = UIFont.preferredFont(from: self.font, for: self.dynamicTypeSize)
        let height = (font.capHeight + abs(font.descender)) * scaleFactor
        return CGSize(width: height, height: height)
    }
    
    func placeholders() -> Set<LocalEmoji> {
        let targetSize = self.targetSize
        
        let placeholders = emojis.compactMap { emoji in
            switch emoji {
            case let remoteEmoji as RemoteEmoji:
                return LocalEmoji.placeholder(for: remoteEmoji.shortcode, image: placeholderEmoji)
                    .resized(targetSize: targetSize)
            case let localEmoji as LocalEmoji:
                return localEmoji.resized(targetSize: targetSize)
            default:
                return nil
            }
        }
        return Set(placeholders)
    }
    
    func loadRemoteEmoji() async -> Set<LocalEmoji> {
        let targetSize = self.targetSize
        
        var loadedEmojis = Set<LocalEmoji>()
        for emoji in emojis {
            switch emoji {
            case let remoteEmoji as RemoteEmoji:
                do {
                    let response = try await imagePipeline.image(for: remoteEmoji.url)
                    let localEmoji = LocalEmoji(shortcode: remoteEmoji.shortcode, image: response.image)
                    loadedEmojis.insert(localEmoji.resized(targetSize: targetSize))
                } catch {
                    logger.error("\(error.localizedDescription)")
                }
            case let localEmoji as LocalEmoji:
                loadedEmojis.insert(localEmoji.resized(targetSize: targetSize))
            default:
                break
            }
        }
        
        return loadedEmojis
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
            markdown = markdown.replacingOccurrences(of: ":\(emoji.shortcode):", with: "\(String.emojiSeparator)\(emoji.shortcode)\(String.emojiSeparator)")
        }
        
        return markdown
    }
    
    var rendered: Text {
        var result = Text(verbatim: "")
        
        if let prepend = self.prepend {
            result = result + prepend()
        }
        
        markdown.split(separator: String.emojiSeparator, omittingEmptySubsequences: true).forEach { substring in
            if let image = localEmojis.first(where: { $0.shortcode == String(substring) }) {
                result = result + Text("\(Image(uiImage: image.image))")
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
        VStack {
            EmojiText(markdown: "Hello World :mastodon: :iphone:",
                      emojis: Self.emojis)
            EmojiText(markdown: "Hello World :test:",
                      emojis: [RemoteEmoji(shortcode: "test", url: URL(string: "about:blank")!)])
        }
    }
}
