//
//  EmojiText.swift
//  EmojiText
//
//  Created by David Walter on 11.01.23.
//

import SwiftUI
import Nuke
import OSLog

/// A view that displays one or more lines of text with support for custom emojis.
///
/// Custom Emojis are in the format `:emoji:`.
/// Supports local and remote custom emojis.
///
/// Remote emojis are resolved using [Nuke](https://github.com/kean/Nuke)
public struct EmojiText: View {
    @Environment(\.font) var font
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    
    @Environment(\.emojiImagePipeline) var imagePipeline
    @Environment(\.emojiPlaceholder) var emojiPlaceholder
    @Environment(\.emojiSize) var emojiSize
    @Environment(\.emojiBaselineOffset) var emojiBaselineOffset
    #if os(watchOS) || os(macOS)
    @Environment(\.emojiTimer) var emojiTimer
    #endif
    @Environment(\.emojiAnimatedMode) var emojiAnimatedMode
    @Environment(\.emojiOmitSpacesBetweenEmojis) var emojiOmitSpacesBetweenEmojis
    
    @ScaledMetric
    var scaleFactor: CGFloat = 1.0
    
    let raw: String
    let isMarkdown: Bool
    let emojis: [any CustomEmoji]
    
    var prepend: (() -> Text)?
    var append: (() -> Text)?
    
    var shouldAnimateIfNeeded: Bool = false
    
    @State private var renderedEmojis: [String: RenderedEmoji]?
    @State private var renderTime: CFTimeInterval = 0
    
    public var body: some View {
        rendered
            .task(id: hashValue, priority: .high) {
                guard !emojis.isEmpty else {
                    renderedEmojis = [:]
                    return
                }
                
                // Hash of currently displayed emojis
                let renderedHash = renderedEmojis.hashValue
                let emojis: [String: RenderedEmoji] = renderedEmojis ?? [:]
                
                // Set placeholders
                renderedEmojis = emojis.merging(loadPlaceholders()) { current, new in
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
                
                // Load actual emojis if needed (e.g. placeholders were set or source emojis changed)
                if renderedHash != emojis.hashValue || emojis.contains(where: \.value.isPlaceholder) {
                    renderedEmojis = emojis.merging(await loadEmojis()) { _, new in
                        new
                    }
                }
                
                guard shouldAnimateIfNeeded, needsAnimation else { return }
                
                #if os(iOS) || targetEnvironment(macCatalyst) || os(tvOS) || os(visionOS)
                for await event in CADisplayLink.publish(mode: .common, stopOnLowPowerMode: emojiAnimatedMode.disabledOnLowPower).values {
                    renderTime = event.targetTimestamp
                }
                #else
                for await time in emojiTimer.values(stopOnLowPowerMode: emojiAnimatedMode.disabledOnLowPower) {
                    renderTime = time.timeIntervalSinceReferenceDate as CFTimeInterval
                }
                #endif
            }
    }
    
    // MARK: - Load Emojis
    
    func loadPlaceholders() -> [String: RenderedEmoji] {
        let targetHeight = self.targetHeight
        
        var placeholders = [String: RenderedEmoji]()
        
        for emoji in emojis {
            switch emoji {
            case let localEmoji as LocalEmoji:
                placeholders[emoji.shortcode] = RenderedEmoji(
                    from: localEmoji,
                    targetHeight: targetHeight
                )
            case let sfSymbolEmoji as SFSymbolEmoji:
                placeholders[emoji.shortcode] = RenderedEmoji(
                    from: sfSymbolEmoji
                )
            default:
                placeholders[emoji.shortcode] = RenderedEmoji(
                    from: emoji,
                    placeholder: emojiPlaceholder,
                    targetHeight: targetHeight
                )
            }
        }
        
        return placeholders
    }
    
    func loadEmojis() async -> [String: RenderedEmoji] {
        let font = EmojiFont.preferredFont(from: self.font, for: self.dynamicTypeSize)
        let baselineOffset = emojiBaselineOffset ?? -(font.pointSize - font.capHeight) / 2
        let targetHeight = self.targetHeight
        
        var renderedEmojis = [String: RenderedEmoji]()
        
        for emoji in emojis {
            do {
                switch emoji {
                case let remoteEmoji as RemoteEmoji:
                    let image: RawImage
                    let request = ImageRequest(
                        url: remoteEmoji.url,
                        processors: [.resize(height: targetHeight)]
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
                case let localEmoji as LocalEmoji:
                    renderedEmojis[emoji.shortcode] = RenderedEmoji(
                        from: localEmoji,
                        animated: shouldAnimateIfNeeded,
                        targetHeight: targetHeight,
                        baselineOffset: baselineOffset
                    )
                case let sfSymbolEmoji as SFSymbolEmoji:
                    renderedEmojis[emoji.shortcode] = RenderedEmoji(
                        from: sfSymbolEmoji
                    )
                default:
                    // Fallback to placeholder emoji
                    Logger.emojiText.warning("Tried to load unknown emoji. Falling back to placeholder emoji")
                    renderedEmojis[emoji.shortcode] = RenderedEmoji(
                        from: emoji,
                        placeholder: emojiPlaceholder,
                        targetHeight: targetHeight
                    )
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
    
    /// Initialize a Markdown formatted ``EmojiText`` with support for custom emojis.
    ///
    /// - Parameters:
    ///     - markdown: Markdown formatted text to render
    ///     - emojis: Array of custom emojis to render
    public init(markdown content: String, emojis: [any CustomEmoji]) {
        self.raw = content
        self.isMarkdown = true
        self.emojis = emojis
    }
    
    /// Initialize a ``EmojiText`` with support for custom emojis.
    ///
    /// - Parameters:
    ///     - verbatim: A string to display without localization.
    ///     - emojis: Array of custom emojis to render
    public init(verbatim content: String, emojis: [any CustomEmoji]) {
        self.raw = content
        self.isMarkdown = false
        self.emojis = emojis
    }
    
    /// Initialize a ``EmojiText`` with support for custom emojis.
    ///
    /// - Parameters:
    ///     - content: A string value to display without localization.
    ///     - emojis: Array of custom emojis to render
    public init<S>(_ content: S, emojis: [any CustomEmoji]) where S: StringProtocol {
        self.raw = String(content)
        self.isMarkdown = false
        self.emojis = emojis
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
        return hasher.finalize()
    }
    
    var targetHeight: CGFloat {
        if let emojiSize = emojiSize {
            return emojiSize
        } else {
            let font = EmojiFont.preferredFont(from: self.font, for: self.dynamicTypeSize)
            return font.pointSize * scaleFactor
        }
    }
    
    private func renderString(with emojis: [String: RenderedEmoji]) -> String {
        var text = raw
        
        for shortcode in emojis.keys {
            text = text.replacingOccurrences(of: ":\(shortcode):", with: "\(String.emojiSeparator)\(shortcode)\(String.emojiSeparator)")
        }
        
        return text
    }
    
    private func renderAttributedString(with emojis: [String: RenderedEmoji]) -> AttributedString {
        do {
            var text = raw
            
            let options = AttributedString.MarkdownParsingOptions(allowsExtendedAttributes: true,
                                                                  interpretedSyntax: .inlineOnlyPreservingWhitespace)
            
            for shortcode in emojis.keys {
                text = text.replacingOccurrences(of: ":\(shortcode):", with: "\(String.emojiSeparator)![\(shortcode)](emoji://\(shortcode))\(String.emojiSeparator)")
            }
            
            text = text.splitOnEmoji(omittingSpacesBetweenEmojis: emojiOmitSpacesBetweenEmojis).joined()
            
            return try AttributedString(markdown: text, options: options)
        } catch {
            Logger.text.error("Unable to parse Markdown, falling back to verbatim string: \(error.localizedDescription)")
            return AttributedString(stringLiteral: raw)
        }
    }
    
    var rendered: Text {
        if isMarkdown {
            return renderedMarkdown
        } else {
            return renderedVerbatim
        }
    }
    
    private var renderedMarkdown: Text {
        let emojis = renderedEmojis ?? loadPlaceholders()
        let attributedString = renderAttributedString(with: emojis)
        
        var result = Text(verbatim: "")
        
        if let prepend = self.prepend {
            result = result + prepend()
        }
        
        for run in attributedString.runs {
            if let emoji = run.emoji(from: emojis) {
                if let baselineOffset = emoji.baselineOffset {
                    result = result + Text("\(emoji.frame(at: renderTime))").baselineOffset(baselineOffset)
                } else {
                    result = result + Text("\(emoji.frame(at: renderTime))")
                }
            } else {
                let part = attributedString[run.range]
                result = result + Text(AttributedString(part))
            }
        }
        
        if let append = self.append {
            result = result + append()
        }
        
        return result
    }
    
    private var renderedVerbatim: Text {
        let emojis = renderedEmojis ?? loadPlaceholders()
        let preRendered = renderString(with: emojis)
        
        var result = Text(verbatim: "")
        
        if let prepend = self.prepend {
            result = result + prepend()
        }
        
        if emojis.isEmpty {
            result = result + Text(verbatim: preRendered)
        } else {
            let splits: [String] = preRendered.splitOnEmoji(omittingSpacesBetweenEmojis: emojiOmitSpacesBetweenEmojis)
            for substring in splits {
                if let image = emojis[substring] {
                    if let baselineOffset = image.baselineOffset {
                        result = result + Text("\(image.frame(at: renderTime))").baselineOffset(baselineOffset)
                    } else {
                        result = result + Text("\(image.frame(at: renderTime))")
                    }
                } else {
                    result = result + Text(verbatim: substring)
                }
            }
        }
        
        if let append = self.append {
            result = result + append()
        }
        
        return result
    }
    
    var needsAnimation: Bool {
        guard let renderedEmojis else { return false }
        
        guard case .never = emojiAnimatedMode else {
            return renderedEmojis.contains { $1.isAnimated }
        }
        return false
    }
}

// swiftlint:disable force_unwrapping
struct EmojiText_Previews: PreviewProvider {
    static var emojis: [any CustomEmoji] {
        [
            RemoteEmoji(shortcode: "mastodon", url: URL(string: "https://files.mastodon.social/custom_emojis/images/000/003/675/original/089aaae26a2abcc1.png")!),
            RemoteEmoji(shortcode: "puppu_purin", url: URL(string: "https://s3.fedibird.com/custom_emojis/images/000/358/023/static/5fe65ba070089507.png")!),
            SFSymbolEmoji(shortcode: "iphone")
        ]
    }
    
    static var animatedEmojis: [any CustomEmoji] {
        [
            RemoteEmoji(shortcode: "gif", url: URL(string: "https://ezgif.com/images/format-demo/butterfly.gif")!)
        ]
    }
    
    static var previews: some View {
        Group {
            List {
                TextEmoji()
                
                MarkdownEmoji()
                
                WideWidthEmoji()
            }
            .previewDisplayName("Default Emoji")
            
            List {
                Section {
                    EmojiText(markdown: "**Animated** *GIF* :gif:",
                              emojis: animatedEmojis)
                    .animated()
                    EmojiText(markdown: "**Never Animated** *GIF* :gif:",
                              emojis: animatedEmojis)
                    .animated()
                    .environment(\.emojiAnimatedMode, .never)
                    
                } header: {
                    Text("Default")
                }
                
                AnimatedEmojiToggle()
            }
            .previewDisplayName("Animated Emoji")
            
            List {
                EmojiTextWithSlider()
            }
            .previewDisplayName("Emoji Size")
        }
        .environment(\.emojiImagePipeline, ImagePipeline { configuration in
            configuration.imageCache = nil
            configuration.dataCache = nil
        })
    }
    
    struct TextEmoji: View {
        var body: some View {
            Section {
                EmojiText(verbatim: "Hello Moon & Stars :moon.stars:",
                          emojis: [SFSymbolEmoji(shortcode: "moon.stars")])
                EmojiText(verbatim: "Hello World :mastodon: with a remote emoji",
                          emojis: emojis)
                EmojiText(verbatim: "Hello World :iphone: with a local emoji",
                          emojis: emojis)
                EmojiText(verbatim: "Hello World :mastodon: with a remote emoji",
                          emojis: emojis)
                .font(.title)
                EmojiText(verbatim: "Large Image as Emoji :large:",
                          emojis: [RemoteEmoji(shortcode: "large", url: URL(string: "https://sample-videos.com/img/Sample-jpg-image-15mb.jpeg")!)])
                EmojiText(verbatim: "Hello World :mastodon: with a custom emoji size",
                          emojis: emojis)
                .emojiSize(34)
                .emojiBaselineOffset(-8.5)
            } header: {
                Text("Text")
            }
        }
    }
    
    struct MarkdownEmoji: View {
        var body: some View {
            Section {
                EmojiText(markdown: "**Hello :mastodon:** the **World :mastodon:**", emojis: emojis)
                EmojiText(markdown: "**Hello :mastodon:** the _World :mastodon:_", emojis: emojis)
                EmojiText(markdown: "**Hello** *World* :mastodon: with a remote emoji",
                          emojis: emojis)
                EmojiText(markdown: "**Hello** *World* :mastodon: :test: with a remote emoji and a fake emoji",
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
    
    struct WideWidthEmoji: View {
        var body: some View {
            Section {
                EmojiText(verbatim: "Hello World :puppu_purin: with a remote emoji.",
                          emojis: emojis)
                EmojiText(verbatim: "Hello World :mastodon: :puppu_purin: with a remote emoji.",
                          emojis: emojis)
                .font(.title)
                EmojiText(verbatim: "Hello World :mastodon: :puppu_purin: with a custom emoji.",
                          emojis: emojis)
                .emojiSize(34)
                .emojiBaselineOffset(-8.5)
                EmojiText(markdown: "**Hello** *World* :puppu_purin: with a remote emoji",
                          emojis: emojis)
            } header: {
                Text("Wide width emoji")
            }
        }
    }
    
    struct EmojiTextWithSlider: View {
        @State private var emojiSize: CGFloat = 20
        
        var body: some View {
            Section {
                EmojiText(verbatim: "Hello World :mastodon: with a remote emoji",
                          emojis: emojis)
                .emojiSize(emojiSize)
                
                Slider(value: $emojiSize, in: 1...50)
            }
        }
    }
    
    struct AnimatedEmojiToggle: View {
        @State private var enableAnimation: Bool = false
        
        var body: some View {
            Section {
                EmojiText(markdown: "**Animated** *GIF* :gif:",
                          emojis: animatedEmojis)
                .animated()
                .environment(\.emojiAnimatedMode, enableAnimation ? .always : .never)
                
                EmojiText(markdown: "**Never Animated** *GIF* :gif:",
                          emojis: animatedEmojis)
                .animated()
                .environment(\.emojiAnimatedMode, .never)
                
                Toggle("Enable animation", isOn: $enableAnimation)
            } header: {
                Text("Toggle")
            }
        }
    }
}
// swiftlint:enable force_unwrapping
