//
//  EmojiText.swift
//  EmojiText
//
//  Created by David Walter on 11.01.23.
//

import SwiftUI
import Nuke
import OSLog

// swiftlint:disable file_length type_body_length

/// A view that displays one or more lines of text with support for custom emojis.
///
/// Custom Emojis are in the format `:emoji:`.
/// Supports local and remote custom emojis.
///
/// Remote emojis are resolved using [Nuke](https://github.com/kean/Nuke)
public struct EmojiText: View {
    @Environment(\.font) var font
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    @Environment(\.displayScale) var displayScale
    
    @Environment(\.emojiImagePipeline) var imagePipeline
    @Environment(\.emojiPlaceholder) var emojiPlaceholder
    @Environment(\.emojiSize) var emojiSize
    @Environment(\.emojiBaselineOffset) var emojiBaselineOffset
    #if os(watchOS) || os(macOS)
    @Environment(\.emojiTimer) var emojiTimer
    #endif
    @Environment(\.emojiAnimatedMode) var emojiAnimatedMode
    @Environment(\.emojiOmitSpacesBetweenEmojis) var emojiOmitSpacesBetweenEmojis
    @Environment(\.emojiMarkdownInterpretedSyntax) var emojiMarkdownInterpretedSyntax
    
    @ScaledMetric
    var scaleFactor: CGFloat = 1.0
    
    let raw: String
    let isMarkdown: Bool
    let emojis: [any CustomEmoji]
    
    var prepend: (() -> Text)?
    var append: (() -> Text)?
    
    var shouldAnimateIfNeeded: Bool = false
    
    @State var renderedEmojis: [String: RenderedEmoji]?
    @State var renderTime: CFTimeInterval = 0
    
    public var body: some View {
        rendered
            .task(id: hashValue, priority: .high) {
                guard !emojis.isEmpty else {
                    renderedEmojis = [:]
                    return
                }
                
                // Hash of currently displayed emojis
                let renderedHash = renderedEmojis.hashValue
                var emojis: [String: RenderedEmoji] = renderedEmojis ?? [:]
                
                // Set placeholders
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
                self.renderedEmojis = emojis
                
                // Load actual emojis if needed (e.g. placeholders were set or source emojis changed)
                if renderedHash != emojis.hashValue || emojis.contains(where: \.value.isPlaceholder) {
                    emojis = emojis.merging(await loadRemoteEmojis()) { _, new in
                        return new
                    }
                    self.renderedEmojis = emojis
                }
                
                guard shouldAnimateIfNeeded, needsAnimation else { return }
                
                #if os(iOS) || targetEnvironment(macCatalyst) || os(tvOS) || os(visionOS)
                for await targetTimestamp in CADisplayLink.publish(mode: .common, stopOnLowPowerMode: emojiAnimatedMode.disabledOnLowPower).values.map(\.targetTimestamp) {
                    renderTime = targetTimestamp
                }
                #else
                for await time in emojiTimer.values(stopOnLowPowerMode: emojiAnimatedMode.disabledOnLowPower) {
                    renderTime = time.timeIntervalSinceReferenceDate as CFTimeInterval
                }
                #endif
            }
    }
    
    // MARK: - Load Emojis
    
    func loadEmojis() -> [String: RenderedEmoji] {
        let font = EmojiFont.preferredFont(from: font, for: dynamicTypeSize)
        let baselineOffset = emojiBaselineOffset ?? -(font.pointSize - font.capHeight) / 2
        
        var renderedEmojis = [String: RenderedEmoji]()
        
        for emoji in emojis {
            switch emoji {
            case let localEmoji as LocalEmoji:
                // Local emoji don't require a placeholder as they can be loaded instantly
                renderedEmojis[emoji.shortcode] = RenderedEmoji(
                    from: localEmoji,
                    targetHeight: targetHeight,
                    baselineOffset: baselineOffset
                )
            case let sfSymbolEmoji as SFSymbolEmoji:
                // SF Symbol emoji don't require a placeholder as they can be loaded instantly
                renderedEmojis[emoji.shortcode] = RenderedEmoji(
                    from: sfSymbolEmoji
                )
            default:
                // Set a placeholder for all other emoji
                renderedEmojis[emoji.shortcode] = RenderedEmoji(
                    from: emoji,
                    placeholder: emojiPlaceholder,
                    targetHeight: targetHeight,
                    baselineOffset: baselineOffset
                )
            }
        }
        
        return renderedEmojis
    }
    
    func loadRemoteEmojis() async -> [String: RenderedEmoji] {
        let font = EmojiFont.preferredFont(from: font, for: dynamicTypeSize)
        let baselineOffset = emojiBaselineOffset ?? -(font.pointSize - font.capHeight) / 2
        
        var renderedEmojis = [String: RenderedEmoji]()
        
        for emoji in emojis {
            do {
                switch emoji {
                case let remoteEmoji as RemoteEmoji:
                    let image: RawImage
                    let request = ImageRequest(
                        url: remoteEmoji.url,
                        processors: [.resize(height: targetHeight * displayScale)]
                    )
                    if shouldAnimateIfNeeded {
                        let (data, _) = try await imagePipeline.data(for: request)
                        image = try RawImage(data: data)
                    } else {
                        let data = try await imagePipeline.image(for: request)
                        image = RawImage(image: data)
                    }
                    renderedEmojis[emoji.shortcode] = RenderedEmoji(
                        from: remoteEmoji,
                        image: image,
                        animated: shouldAnimateIfNeeded,
                        targetHeight: targetHeight,
                        baselineOffset: baselineOffset
                    )
                default:
                    continue
                }
            } catch is CancellationError {
                return [:]
            } catch {
                Logger.emojiText.error("Unable to load custom emoji \(emoji.shortcode): \(error.localizedDescription)")
            }
        }
        
        return renderedEmojis
    }
    
    // MARK: - Initializers
    
    /// Initialize a ``EmojiText`` with support for custom emojis.
    ///
    /// - Parameters:
    ///     - content: A string value to display without localization.
    ///     - emojis: The custom emojis to render.
    public init<S>(_ content: S, emojis: [any CustomEmoji]) where S: StringProtocol {
        self.raw = String(content)
        self.isMarkdown = false
        self.emojis = emojis.filter { content.contains(":\($0.shortcode):") }
    }
    
    // MARK: - Modifier
    
    /// Prepend `Text` to the ``EmojiText`` view.
    ///
    /// - Parameter text: Callback generating the text to prepend
    /// - Returns: ``EmojiText`` with some text prepended
    public func prepend(text: @escaping () -> Text) -> Self {
        var view = self
        view.prepend = text
        return view
    }
    
    /// Append `Text` to the ``EmojiText`` view.
    ///
    /// - Parameter text: Callback generating the text to append
    /// - Returns: ``EmojiText`` with some text appended
    public func append(text: @escaping () -> Text) -> Self {
        var view = self
        view.append = text
        return view
    }
    
    // MARK: - Modifier
    
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
        hasher.combine(emojiSize)
        hasher.combine(emojiAnimatedMode)
        hasher.combine(displayScale)
        return hasher.finalize()
    }
    
    var targetHeight: CGFloat {
        if let emojiSize = emojiSize {
            return emojiSize
        } else {
            let font = EmojiFont.preferredFont(from: font, for: dynamicTypeSize)
            return font.pointSize * scaleFactor
        }
    }
    
    var needsAnimation: Bool {
        guard let renderedEmojis else { return false }
        
        guard case .never = emojiAnimatedMode else {
            return renderedEmojis.contains { $1.isAnimated }
        }
        return false
    }
    
    // MARK: - Render
    
    var rendered: Text {
        let result: Text
        
        if isMarkdown {
            result = renderedMarkdown
        } else {
            result = renderedVerbatim
        }
        
        return [prepend?(), result, append?()]
            .compactMap { $0 }
            .joined()
    }
}

#if DEBUG
#Preview {
    List {
        EmojiText(verbatim: "Hello World :mastodon:", emojis: EmojiText.emojis)
        EmojiText(verbatim: "Hello iPhone :iphone:", emojis: EmojiText.emojis)
        EmojiText(markdown: "**Hello** _World_ :mastodon:", emojis: EmojiText.emojis)
    }
}
#endif
