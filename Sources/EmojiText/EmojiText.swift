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
    
    @ScaledMetric
    var scaleFactor: CGFloat = 1.0
    
    let raw: String
    let isMarkdown: Bool
    let emojis: [any CustomEmoji]
    
    var prepend: (() -> Text)?
    var append: (() -> Text)?
    
    var shouldAnimateIfNeeded: Bool = false
    
    @State private var preRendered: String?
    @State private var renderedEmojis: [String: RenderedEmoji] = [:]
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
                
                // Set placeholders
                renderedEmojis.merge(loadPlaceholders()) { current, new in
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
                if renderedHash != renderedEmojis.hashValue {
                    renderedEmojis.merge(await loadEmojis()) { _, new in
                        new
                    }
                }
                
                guard shouldAnimateIfNeeded, needsAnimation else { return }
                
                #if os(iOS) || targetEnvironment(macCatalyst) || os(tvOS)
                for await event in CADisplayLink.publish(mode: .common, stopOnLowPowerMode: emojiAnimatedMode.disabledOnLowPower).values {
                    renderTime = event.targetTimestamp
                }
                #else
                for await time in emojiTimer.values(stopOnLowPowerMode: emojiAnimatedMode.disabledOnLowPower) {
                    renderTime = time.timeIntervalSinceReferenceDate as CFTimeInterval
                }
                #endif
            }
            .onChange(of: renderedEmojis) { emojis in
                preRendered = preRender(with: emojis)
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
                    targetHeight: targetHeight)
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
                    if shouldAnimateIfNeeded {
                        let (data, _) = try await imagePipeline.data(for: remoteEmoji.url)
                        image = try EmojiImage.from(data: data)
                    } else  {
                        let data = try await imagePipeline.image(for: remoteEmoji.url)
                        image = RawImage(image: data)
                    }
                    renderedEmojis[emoji.shortcode] = RenderedEmoji(
                        from: remoteEmoji,
                        image: image,
                        animated: shouldAnimateIfNeeded,
                        targetHeight: targetHeight,
                        baselineOffset: baselineOffset)
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
            } catch  {
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
    
    func preRender(with emojis: [String: RenderedEmoji]) -> String {
        var text = raw
        
        for shortcode in emojis.keys {
            text = text.replacingOccurrences(of: ":\(shortcode):", with: "\(String.emojiSeparator)\(shortcode)\(String.emojiSeparator)")
        }
        
        return text
    }
    
    var rendered: Text {
        var result = prepend?() ?? Text(verbatim: "")
        
        let preRendered = self.preRendered ?? raw
        
        if renderedEmojis.isEmpty {
            if isMarkdown {
                result = result + Text(markdown: preRendered)
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
                if let image = renderedEmojis[substring] {
                    if let baselineOffset = image.baselineOffset {
                        result = result + Text("\(image.frame(at: renderTime))").baselineOffset(baselineOffset)
                    } else {
                        result = result + Text("\(image.frame(at: renderTime))")
                    }
                } else if isMarkdown {
                    result = result + Text(markdown: substring)
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
        renderedEmojis.contains { $1.isAnimated }
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
        List {
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
            Section {
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
        .environment(\.emojiImagePipeline, ImagePipeline { configuration in
            configuration.imageCache = nil
            configuration.dataCache = nil
        })
        
        List {
            Section {
                EmojiText(markdown: "**Animated** *GIF* :gif:",
                          emojis: animatedEmojis)
                .animated()
            } header: {
                Text("Animated emoji")
            }
        }
    }
}
// swiftlint:enable force_unwrapping
