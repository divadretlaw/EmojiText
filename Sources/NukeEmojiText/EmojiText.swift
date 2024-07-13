//
//  EmojiText.swift
//  NukeEmojiText
//
//  Created by David Walter on 13.07.24.
//

import SwiftUI
@_exported import EmojiText
import Nuke

/// A view that displays one or more lines of text with support for custom emojis.
///
/// Custom Emojis are in the format `:emoji:`.
/// Supports local and remote custom emojis.
///
/// Remote emojis are resolved using [Nuke](https://github.com/kean/Nuke)
@MainActor public struct EmojiText: View {
    private var pipeline: ImagePipeline = .shared
    private var content: CoreEmojiText
    
    public var body: some View {
        content
            .environment(\.emojiText.emojiProvider, NukeEmojiProvider(pipeline: pipeline))
    }
    
    // MARK: - Initializers
    
    /// Initialize a Markdown formatted ``EmojiText`` with support for custom emojis.
    ///
    /// - Parameters:
    ///     - markdown: The string that contains the Markdown formatting.
    ///     - interpretedSyntax: The syntax for intepreting a Markdown string. Defaults to `.inlineOnlyPreservingWhitespace`.
    ///     - emojis: The custom emojis to render.
    ///     - shoulOmitSpacesBetweenEmojis: Whether to omit spaces between emojis. Defaults to `true.`
    ///
    /// > Info:
    /// > Consider removing spaces between emojis as this will often drastically reduce
    /// the amount of text contactenations needed to render the emojis.
    /// >
    /// > There is a limit in SwiftUI Text concatenations and if this limit is reached the application will crash.
    public init(
        markdown content: String,
        interpretedSyntax: AttributedString.MarkdownParsingOptions.InterpretedSyntax = .inlineOnlyPreservingWhitespace,
        emojis: [any CustomEmoji],
        shouldOmitSpacesBetweenEmojis: Bool = true
    ) {
        self.content = CoreEmojiText(
            markdown: content,
            interpretedSyntax: interpretedSyntax,
            emojis: emojis,
            shouldOmitSpacesBetweenEmojis: shouldOmitSpacesBetweenEmojis
        )
    }
    
    /// Initialize a ``EmojiText`` with support for custom emojis.
    ///
    /// - Parameters:
    ///     - verbatim: A string to display without localization.
    ///     - emojis: The custom emojis to render.
    ///     - shoulOmitSpacesBetweenEmojis: Whether to omit spaces between emojis. Defaults to `true.
    ///
    /// > Info:
    /// > Consider removing spaces between emojis as this will often drastically reduce
    /// the amount of text contactenations needed to render the emojis.
    /// >
    /// > There is a limit in SwiftUI Text concatenations and if this limit is reached the application will crash.
    public init(
        verbatim content: String,
        emojis: [any CustomEmoji],
        shouldOmitSpacesBetweenEmojis: Bool = true
    ) {
        self.content = CoreEmojiText(
            verbatim: content,
            emojis: emojis,
            shouldOmitSpacesBetweenEmojis: shouldOmitSpacesBetweenEmojis
        )
    }
    
    /// Initialize a ``EmojiText`` with support for custom emojis.
    ///
    /// - Parameters:
    ///     - content: A string value to display without localization.
    ///     - emojis: The custom emojis to render.
    ///
    /// > Info:
    /// > Consider removing spaces between emojis as this will often drastically reduce
    /// the amount of text contactenations needed to render the emojis.
    /// >
    /// > There is a limit in SwiftUI Text concatenations and if this limit is reached the application will crash.
    public init<S>(
        _ content: S,
        emojis: [any CustomEmoji],
        shouldOmitSpacesBetweenEmojis: Bool = true
    ) where S: StringProtocol {
        self.init(verbatim: String(content), emojis: emojis, shouldOmitSpacesBetweenEmojis: shouldOmitSpacesBetweenEmojis)
    }
    
    // MARK: - Modifier
    
    /// Changes the underlying pipeline used for image loading.
    public func pipeline(_ pipeline: ImagePipeline) -> Self {
        var view = self
        view.pipeline = pipeline
        return view
    }
    
    /// Prepend `Text` to the ``EmojiText`` view.
    ///
    /// - Parameter text: Callback generating the text to prepend
    /// - Returns: ``EmojiText`` with some text prepended
    public func prepend(text: @escaping () -> Text) -> Self {
        var view = self
        view.content = view.content.prepend(text: text)
        return view
    }
    
    /// Append `Text` to the ``EmojiText`` view.
    ///
    /// - Parameter text: Callback generating the text to append
    /// - Returns: ``EmojiText`` with some text appended
    public func append(text: @escaping () -> Text) -> Self {
        var view = self
        view.content = view.content.append(text: text)
        return view
    }
    
    /// Enable animated emoji
    ///
    /// - Parameter value: Enable or disable the animated emoji
    /// - Returns: ``EmojiText`` with animated emoji enabled or disabled.
    public func animated(_ value: Bool = true) -> Self {
        var view = self
        view.content = view.content.animated(value)
        return view
    }
    
}
