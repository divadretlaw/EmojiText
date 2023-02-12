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
    
    let raw: String
    let isMarkdown: Bool
    let emojis: [any CustomEmoji]
    
    var prepend: (() -> Text)?
    var append: (() -> Text)?
    
    @State private var localEmojis = Set<LocalEmoji>()
    
    var logger = Logger()
    
    public var body: some View {
        rendered
            .task {
                guard !emojis.isEmpty else { return }
                
                // Set placeholders
                self.localEmojis = placeholders()
                
                // Load actual emojis
                self.localEmojis = await loadRemoteEmoji()
            }
    }
    
    var targetSize: CGSize {
        let font = EmojiFont.preferredFont(from: self.font, for: self.dynamicTypeSize)
        let height = font.capHeight * scaleFactor
        return CGSize(width: height, height: height)
    }
    
    func placeholders() -> Set<LocalEmoji> {
        let targetSize = self.targetSize
        
        let placeholders = emojis
            .compactMap { emoji in
                switch emoji {
                case let remoteEmoji as RemoteEmoji:
                    return LocalEmoji.placeholder(for: remoteEmoji.shortcode, image: placeholderEmoji)
                case let localEmoji as LocalEmoji:
                    return localEmoji
                default:
                    return nil
                }
            }
            .map { $0.resized(targetSize: targetSize) }
        
        return Set(placeholders)
    }
    
    func loadRemoteEmoji() async -> Set<LocalEmoji> {
        let targetSize = self.targetSize
        
        var loadedEmojis = [LocalEmoji]()
        for emoji in emojis {
            switch emoji {
            case let remoteEmoji as RemoteEmoji:
                do {
                    let response = try await imagePipeline.image(for: remoteEmoji.url)
                    let localEmoji = LocalEmoji(shortcode: remoteEmoji.shortcode, image: response.image)
                    loadedEmojis.append(localEmoji)
                } catch {
                    logger.error("\(error.localizedDescription)")
                }
            case let localEmoji as LocalEmoji:
                loadedEmojis.append(localEmoji)
            default:
                break
            }
        }
        
        return Set(loadedEmojis.map { $0.resized(targetSize: targetSize) })
    }
    
    /// Initialize a Markdown formatted Text with support for custom emojis
    ///
    /// - Parameters:
    ///     - markdown: Markdown formatted text to render
    ///     - emojis: Array of custom emojis to render
    public init(markdown: String, emojis: [any CustomEmoji]) {
        self.raw = markdown
        self.isMarkdown = true
        self.emojis = emojis
    }
    
    /// Initialize a ``EmojiText`` with support for custom emojis
    ///
    /// - Parameters:
    ///     - verbatim: A string to display without localization.
    ///     - emojis: Array of custom emojis to render
    public init(verbatim: String, emojis: [any CustomEmoji]) {
        self.raw = verbatim
        self.isMarkdown = false
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
    
    var preRendered: String {
        var text = raw
        
        for emoji in localEmojis {
            text = text.replacingOccurrences(of: ":\(emoji.shortcode):", with: "\(String.emojiSeparator)\(emoji.shortcode)\(String.emojiSeparator)")
        }
        
        return text
    }
    
    var rendered: Text {
        var result = prepend?() ?? Text(verbatim: "")
        
        if localEmojis.isEmpty {
            if isMarkdown {
                result = result + Text(attributedString(from: preRendered))
            } else {
                result = result + Text(verbatim: preRendered)
            }
        } else {
            let splits: [String]
            if #available(iOS 16, macOS 13, tvOS 16, *) {
                splits = preRendered
                    .split(separator: String.emojiSeparator, omittingEmptySubsequences: true)
                    .map { String($0) }
            } else {
                splits = preRendered
                    .components(separatedBy: String.emojiSeparator)
            }
            splits.forEach { substring in
                if let image = localEmojis.first(where: { $0.shortcode == substring }) {
                    result = result + Text("\(Image(emojiImage: image.image))")
                } else if isMarkdown {
                    result = result + Text(attributedString(from: substring))
                } else {
                    result = result + Text(verbatim: String(substring))
                }
            }
        }
        
        if let append = self.append {
            result = result + append()
        }
        
        return result
    }
    
    func attributedString(from string: String) -> AttributedString {
        do {
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
            LocalEmoji(shortcode: "iphone", image: EmojiImage(systemName: "iphone")!)
        ]
    }
    
    static var previews: some View {
        List {
            Section {
                EmojiText(verbatim: "Hello World :mastodon: with only a remote emoji",
                          emojis: emojis)
                EmojiText(verbatim: "Hello World :mastodon: with only a remote emoji",
                          emojis: emojis)
                .font(.title)
            } header: {
                Text("Text")
            }
            
            Section {
                EmojiText(markdown: "**Hello** *World* :mastodon: with only a remote emoji",
                          emojis: emojis)
                EmojiText(markdown: "**Hello** *World* :mastodon: with only a remote emoji and a fake emoji :test:",
                          emojis: emojis)
                EmojiText(markdown: "**Hello** *World* :mastodon: :iphone: with a remote and a local emoji",
                          emojis: emojis)
                EmojiText(markdown: "**Hello** *World* :test: with a remote emoji that will not respond properly",
                          emojis: [RemoteEmoji(shortcode: "test", url: URL(string: "about:blank")!)])
                EmojiText(markdown: "**Hello** *World* :notAnEmoji: with no emojis",
                          emojis: [])
                
                EmojiText(markdown: "**Hello** *World* :mastodon:",
                          emojis: emojis)
                .prepend {
                    Text("Prepended - ")
                }
                .append {
                    Text(" - Appended")
                }
            } header: {
                Text("Markdown")
            }
        }
    }
}
