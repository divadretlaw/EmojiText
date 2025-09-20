//
//  EmojiText.swift
//  EmojiText
//
//  Created by David Walter on 11.01.23.
//

import SwiftUI
import OSLog

/// A view that displays one or more lines of text with support for custom emojis.
///
/// Custom Emojis are in the format `:emoji:`.
/// Supports local and remote custom emojis.
///
/// Remote emojis are resolved using [Nuke](https://github.com/kean/Nuke)
@MainActor public struct EmojiText: View {
    @Environment(\.font) var font
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    @Environment(\.displayScale) var displayScale
    @Environment(\.colorScheme) var colorScheme
    
    @Environment(\.emojiText.syncEmojiProvider) var syncEmojiProvider
    @Environment(\.emojiText.asyncEmojiProvider) var asyncEmojiProvider
    
    @Environment(\.emojiText.placeholder) var placeholder
    @Environment(\.emojiText.size) var size
    @Environment(\.emojiText.baselineOffset) var baselineOffset
    #if os(watchOS) || os(macOS)
    @Environment(\.emojiText.timer) var timer
    #endif
    @Environment(\.emojiText.animatedMode) var animatedMode
    
    let emojis: [any CustomEmoji]
    let renderer: any EmojiRenderer
    
    var prepend: (() -> Text)?
    var append: (() -> Text)?
    
    var shouldAnimateIfNeeded: Bool = false
    
    @State var renderedEmojis: [String: LoadedEmoji]?
    @State var renderTime: CFTimeInterval = 0
    
    public var body: some View {
        makeContent
            .task(id: hashValue, priority: .high) {
                guard !emojis.isEmpty else {
                    renderedEmojis = [:]
                    return
                }

                // Hash of currently displayed emojis
                let renderedHash = renderedEmojis.hashValue
                var result: [String: LoadedEmoji] = renderedEmojis ?? [:]

                let loader = makeLoader()

                // Load emojis. Will set placeholders for lazy emojis
                result = result.merging(loader.loadEmojis(emojis)) { current, new in
                    if current.hasSameSource(as: new) {
                        if !new.isPlaceholder || current.isPlaceholder {
                            return new
                        } else {
                            return current
                        }
                    } else {
                        return new
                    }
                }
                guard !Task.isCancelled else { return }
                renderedEmojis = result

                // Load lazy emojis if needed (e.g. placeholders were set or source emojis changed)
                if renderedHash != result.hashValue || result.contains(where: \.value.isPlaceholder) {
                    result = result.merging(await loader.loadLazyEmojis(emojis)) { _, new in
                        new
                    }
                    guard !Task.isCancelled else { return }
                    renderedEmojis = result
                }

                guard !Task.isCancelled, shouldAnimateIfNeeded, needsAnimation else { return }

                #if os(iOS) || targetEnvironment(macCatalyst) || os(tvOS) || os(visionOS)
                for await targetTimestamp in CADisplayLink.publish(mode: .common, stopOnLowPowerMode: animatedMode.disabledOnLowPower).targetTimestamps {
                    renderTime = targetTimestamp
                }
                #else
                for await time in timer.values(stopOnLowPowerMode: animatedMode.disabledOnLowPower) {
                    renderTime = time.timeIntervalSinceReferenceDate as CFTimeInterval
                }
                #endif
            }
    }
    
    var makeContent: Text {
        let result: Text
        
        if needsAnimation {
            result = renderer.renderAnimated(emojis: renderedEmojis ?? fallbackEmoji, size: size, at: renderTime)
        } else {
            result = renderer.render(emojis: renderedEmojis ?? fallbackEmoji, size: size)
        }
        
        return [prepend?(), result, append?()]
            .compactMap { $0 }
            .joined()
    }

    func makeLoader() -> EmojiLoader {
        EmojiLoader(placeholder: placeholder, font: EmojiFont.preferredFont(from: font, for: dynamicTypeSize)) { parameter in
            parameter
                .overrideSize(size)
                .overrideBaselineOffset(baselineOffset)
                .displayScale(displayScale)
                .shouldAnimateIfNeeded(shouldAnimateIfNeeded)
        }
        .emojiProvider(syncEmojiProvider: syncEmojiProvider, asyncEmojiProvider: asyncEmojiProvider)
    }

    // MARK: - Initializers
    
    /// Initialize a Markdown formatted ``EmojiText`` with support for custom emojis.
    ///
    /// - Parameters:
    ///     - content: The string that contains the Markdown formatting.
    ///     - interpretedSyntax: The syntax for interpreting a Markdown string. Defaults to `.inlineOnlyPreservingWhitespace`.
    ///     - emojis: The custom emojis to render.
    ///     - shouldOmitSpacesBetweenEmojis: Whether to omit spaces between emojis. Defaults to `true.`
    ///
    /// > Info:
    /// > Consider removing spaces between emojis as this will often drastically reduce
    /// the amount of text concatenations needed to render the emojis.
    /// >
    /// > There is a limit in SwiftUI Text concatenations and if this limit is reached the application will crash.
    public init(
        markdown content: String,
        interpretedSyntax: AttributedString.MarkdownParsingOptions.InterpretedSyntax = .inlineOnlyPreservingWhitespace,
        emojis: [any CustomEmoji],
        shouldOmitSpacesBetweenEmojis: Bool = true
    ) {
        self.renderer = MarkdownEmojiRenderer(string: content, shouldOmitSpacesBetweenEmojis: shouldOmitSpacesBetweenEmojis, interpretedSyntax: interpretedSyntax)
        self.emojis = emojis.filter { content.contains(":\($0.shortcode):") }
    }
    
    /// Initialize a ``EmojiText`` with support for custom emojis.
    ///
    /// - Parameters:
    ///     - content: A string to display without localization.
    ///     - emojis: The custom emojis to render.
    ///     - shouldOmitSpacesBetweenEmojis: Whether to omit spaces between emojis. Defaults to `true.
    ///
    /// > Info:
    /// > Consider removing spaces between emojis as this will often drastically reduce
    /// the amount of text concatenations needed to render the emojis.
    /// >
    /// > There is a limit in SwiftUI Text concatenations and if this limit is reached the application will crash.
    public init(
        verbatim content: String,
        emojis: [any CustomEmoji],
        shouldOmitSpacesBetweenEmojis: Bool = true
    ) {
        self.renderer = VerbatimEmojiRenderer(string: content, shouldOmitSpacesBetweenEmojis: shouldOmitSpacesBetweenEmojis)
        self.emojis = emojis.filter { content.contains(":\($0.shortcode):") }
    }
    
    /// Initialize a ``EmojiText`` with support for custom emojis.
    ///
    /// - Parameters:
    ///     - content: A string value to display without localization.
    ///     - emojis: The custom emojis to render.
    ///     - shouldOmitSpacesBetweenEmojis: Whether to omit spaces between emojis. Defaults to `true.
    ///
    /// > Info:
    /// > Consider removing spaces between emojis as this will often drastically reduce
    /// the amount of text concatenations needed to render the emojis.
    /// >
    /// > There is a limit in SwiftUI Text concatenations and if this limit is reached the application will crash.
    public init<S>(
        _ content: S,
        emojis: [any CustomEmoji],
        shouldOmitSpacesBetweenEmojis: Bool = true
    ) where S: StringProtocol {
        self.init(verbatim: String(content), emojis: emojis, shouldOmitSpacesBetweenEmojis: shouldOmitSpacesBetweenEmojis)
    }

    /// Initialize a ``EmojiText`` with support for custom emojis from an `AttributedString`.
    ///
    /// - Parameters:
    ///     - content: The `AttributedString` to display.
    ///     - emojis: The custom emojis to render.
    ///     - shouldOmitSpacesBetweenEmojis: Whether to omit spaces between emojis. Defaults to `true.
    ///
    /// > Info:
    /// > Consider removing spaces between emojis as this will often drastically reduce
    /// the amount of text concatenations needed to render the emojis.
    /// >
    /// > There is a limit in SwiftUI Text concatenations and if this limit is reached the application will crash.
    public init(
        _ content: AttributedString,
        emojis: [any CustomEmoji],
        shouldOmitSpacesBetweenEmojis: Bool = true
    ) {
        self.renderer = AttributedStringEmojiRenderer(attributedString: content, shouldOmitSpacesBetweenEmojis: shouldOmitSpacesBetweenEmojis)
        self.emojis = emojis
    }

    // MARK: - Modifier
    
    /// Prepend `Text` to the ``EmojiText`` view.
    ///
    /// - Parameter text: Callback generating the text to prepend
    /// - Returns: ``EmojiText`` with some text prepended
    public func prepend(text: @Sendable @escaping () -> Text) -> Self {
        var view = self
        view.prepend = text
        return view
    }
    
    /// Append `Text` to the ``EmojiText`` view.
    ///
    /// - Parameter text: Callback generating the text to append
    /// - Returns: ``EmojiText`` with some text appended
    public func append(text: @Sendable @escaping () -> Text) -> Self {
        var view = self
        view.append = text
        return view
    }
    
    /// Enable animated emoji
    ///
    /// - Parameter value: Enable or disable the animated emoji
    /// - Returns: ``EmojiText`` with animated emoji enabled or disabled.
    public func animated(_ value: Bool = true) -> Self {
        var view = self
        view.shouldAnimateIfNeeded = value
        return view
    }
    
    // MARK: - Helper
    
    // swiftlint:disable:next legacy_hashing
    var hashValue: Int {
        var hasher = Hasher()
        hasher.combine(renderer)
        for emoji in emojis {
            hasher.combine(emoji)
        }
        hasher.combine(shouldAnimateIfNeeded)
        hasher.combine(size)
        hasher.combine(animatedMode)
        hasher.combine(displayScale)
        hasher.combine(colorScheme)
        hasher.combine(dynamicTypeSize)
        return hasher.finalize()
    }
    
    var targetHeight: CGFloat {
        if let emojiSize = size {
            return emojiSize
        } else {
            let font = EmojiFont.preferredFont(from: font, for: dynamicTypeSize)
            return font.pointSize
        }
    }
    
    var needsAnimation: Bool {
        guard let renderedEmojis else { return false }
        
        switch animatedMode {
        case .never:
            return false
        default:
            return renderedEmojis.contains { $1.isAnimated }
        }
    }

    var fallbackEmoji: [String: LoadedEmoji] {
        let loader = makeLoader()
        return loader.loadEmojis(emojis)
    }
}

#if DEBUG
#Preview {
    List {
        Section {
            EmojiText(verbatim: "Hello Emoji :a:", emojis: .emojis)
            EmojiText(verbatim: "Hello iPhone :iphone:", emojis: .emojis)
            EmojiText(verbatim: "Hello :a: :a: Double", emojis: .emojis)
            EmojiText(verbatim: "Hello Wide :wide:", emojis: .emojis)
        } header: {
            Text("Verbatim")
        }
        
        Section {
            EmojiText(markdown: "**Hello** _Emoji_ :a:", emojis: .emojis)
            EmojiText(markdown: "**Hello :a: :a: _Double_**", emojis: .emojis)
        } header: {
            Text("Markdown")
        }
    }
}
#endif
