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
    
    let raw: String
    let emojis: [any CustomEmoji]
    let renderer: EmojiRenderer
    
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
                var emojis: [String: LoadedEmoji] = renderedEmojis ?? [:]
                
                // Load emojis. Will set placeholders for lazy emojis
                emojis = emojis.merging(loadEmojis()) { current, new in
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
                renderedEmojis = emojis
                
                // Load lazy emojis if needed (e.g. placeholders were set or source emojis changed)
                if renderedHash != emojis.hashValue || emojis.contains(where: \.value.isPlaceholder) {
                    emojis = emojis.merging(await loadLazyEmojis()) { _, new in
                        new
                    }
                    renderedEmojis = emojis
                }
                
                guard shouldAnimateIfNeeded, needsAnimation else { return }
                
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
            result = renderer.renderAnimated(string: raw, emojis: renderedEmojis ?? loadEmojis(), size: size, at: renderTime)
        } else {
            result = renderer.render(string: raw, emojis: renderedEmojis ?? loadEmojis(), size: size)
        }
        
        return [prepend?(), result, append?()]
            .compactMap { $0 }
            .joined()
    }

    // MARK: - Load Emojis
    
    func loadEmojis() -> [String: LoadedEmoji] {
        let font = EmojiFont.preferredFont(from: font, for: dynamicTypeSize)
        let baselineOffset = baselineOffset ?? -(font.pointSize - font.capHeight) / 2
        
        var renderedEmojis = [String: LoadedEmoji]()
        
        for emoji in emojis {
            switch emoji {
            case let sfSymbolEmoji as SFSymbolEmoji:
                // SF Symbol emoji don't require a placeholder as they can be loaded instantly
                renderedEmojis[emoji.shortcode] = LoadedEmoji(
                    from: sfSymbolEmoji
                )
            case let emoji as any SyncCustomEmoji:
                if let image = syncEmojiProvider.emojiImage(emoji: emoji, height: targetHeight) {
                    renderedEmojis[emoji.shortcode] = LoadedEmoji(
                        from: emoji,
                        image: RawImage(image: image),
                        animated: shouldAnimateIfNeeded,
                        targetHeight: targetHeight,
                        baselineOffset: baselineOffset
                    )
                } else {
                    // Sync emoji wasn't loaded and a placeholder will be used instead
                    renderedEmojis[emoji.shortcode] = LoadedEmoji(
                        from: emoji,
                        placeholder: placeholder,
                        targetHeight: targetHeight,
                        baselineOffset: baselineOffset
                    )
                }
            case let emoji as any AsyncCustomEmoji:
                // Try to load remote emoji from cache
                let resizeHeight = targetHeight * displayScale
                if let image = asyncEmojiProvider.cachedEmojiImage(emoji: emoji, height: resizeHeight) {
                    renderedEmojis[emoji.shortcode] = LoadedEmoji(
                        from: emoji,
                        image: RawImage(image: image),
                        animated: shouldAnimateIfNeeded,
                        targetHeight: targetHeight,
                        baselineOffset: baselineOffset
                    )
                } else {
                    // Async emoji wasn't found in cache and a placeholder will be used instead
                    renderedEmojis[emoji.shortcode] = LoadedEmoji(
                        from: emoji,
                        placeholder: placeholder,
                        targetHeight: targetHeight,
                        baselineOffset: baselineOffset
                    )
                }
            default:
                // Set a placeholder for all other emoji
                renderedEmojis[emoji.shortcode] = LoadedEmoji(
                    from: emoji,
                    placeholder: placeholder,
                    targetHeight: targetHeight,
                    baselineOffset: baselineOffset
                )
            }
        }
        
        return renderedEmojis
    }
    
    func loadLazyEmojis() async -> [String: LoadedEmoji] {
        let font = EmojiFont.preferredFont(from: font, for: dynamicTypeSize)
        let baselineOffset = baselineOffset ?? -(font.pointSize - font.capHeight) / 2
        let resizeHeight = targetHeight * displayScale
        
        return await withTaskGroup(of: LoadedEmoji?.self, returning: [String: LoadedEmoji].self) { [asyncEmojiProvider, targetHeight, shouldAnimateIfNeeded] group in
            for emoji in emojis {
                switch emoji {
                case let emoji as any AsyncCustomEmoji:
                    _ = group.addTaskUnlessCancelled {
                        do {
                            let image: RawImage
                            let data = try await asyncEmojiProvider.fetchEmojiData(emoji: emoji, height: resizeHeight)
                            if shouldAnimateIfNeeded {
                                image = try RawImage(animated: data)
                            } else {
                                image = try RawImage(static: data)
                            }
                            return LoadedEmoji(
                                from: emoji,
                                image: image,
                                animated: shouldAnimateIfNeeded,
                                targetHeight: targetHeight,
                                baselineOffset: baselineOffset
                            )
                        } catch {
                            Logger.emojiText.error("Unable to load '\(type(of: emoji))' with code '\(emoji.shortcode)': \(error.localizedDescription)")
                            return nil
                        }
                    }
                default:
                    continue
                }
            }
            // Collect TaskGroup results
            var result: [String: LoadedEmoji] = [:]
            for await emoji in group {
                if let emoji {
                    result[emoji.shortcode] = emoji
                }
            }
            return result
        }
    }
    
    // MARK: - Initializers
    
    /// Initialize a Markdown formatted ``EmojiText`` with support for custom emojis.
    ///
    /// - Parameters:
    ///     - content: The string that contains the Markdown formatting.
    ///     - interpretedSyntax: The syntax for intepreting a Markdown string. Defaults to `.inlineOnlyPreservingWhitespace`.
    ///     - emojis: The custom emojis to render.
    ///     - shouldOmitSpacesBetweenEmojis: Whether to omit spaces between emojis. Defaults to `true.`
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
        self.renderer = MarkdownEmojiRenderer(shouldOmitSpacesBetweenEmojis: shouldOmitSpacesBetweenEmojis, interpretedSyntax: interpretedSyntax)
        self.raw = content
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
    /// the amount of text contactenations needed to render the emojis.
    /// >
    /// > There is a limit in SwiftUI Text concatenations and if this limit is reached the application will crash.
    public init(
        verbatim content: String,
        emojis: [any CustomEmoji],
        shouldOmitSpacesBetweenEmojis: Bool = true
    ) {
        self.renderer = VerbatimEmojiRenderer(shouldOmitSpacesBetweenEmojis: shouldOmitSpacesBetweenEmojis)
        self.raw = content
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
        hasher.combine(raw)
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
