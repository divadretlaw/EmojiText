//
//  EmojiLabel.swift
//  EmojiText
//
//  Created by David Walter on 10.08.25.
//

#if canImport(UIKit)
import UIKit

@available(iOS 17.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
public final class EmojiLabel: UILabel, EmojiTextPresenter {
    var raw: String
    let emojis: [any CustomEmoji]
    let renderer: EmojiRenderer

    var task: Task<Void, Never>?

    var targetHeight: CGFloat?
    var baselineOffset: CGFloat?
    var syncEmojiProvider: SyncEmojiProvider = DefaultSyncEmojiProvider()
    var asyncEmojiProvider: AsyncEmojiProvider = DefaultAsyncEmojiProvider()

    /// Initialize a ``EmojiLabel`` with support for custom emojis.
    ///
    /// - Parameters:
    ///     - content: A string to display without localization.
    ///     - emojis: The custom emojis to render.
    ///     - shouldOmitSpacesBetweenEmojis: Whether to omit spaces between emojis. Defaults to `true.
    public convenience init(
        verbatim content: String,
        emojis: [any CustomEmoji],
        shouldOmitSpacesBetweenEmojis: Bool = true
    ) {
        let renderer = VerbatimEmojiRenderer(
            shouldOmitSpacesBetweenEmojis: shouldOmitSpacesBetweenEmojis
        )
        self.init(string: content, emojis: emojis, renderer: renderer)
    }

    /// Initialize a Markdown formatted ``EmojiLabel`` with support for custom emojis.
    ///
    /// - Parameters:
    ///     - content: The string that contains the Markdown formatting.
    ///     - interpretedSyntax: The syntax for interpreting a Markdown string. Defaults to `.inlineOnlyPreservingWhitespace`.
    ///     - emojis: The custom emojis to render.
    ///     - shouldOmitSpacesBetweenEmojis: Whether to omit spaces between emojis. Defaults to `true.`
    public convenience init(
        markdown content: String,
        interpretedSyntax: AttributedString.MarkdownParsingOptions.InterpretedSyntax = .inlineOnlyPreservingWhitespace,
        emojis: [any CustomEmoji],
        shouldOmitSpacesBetweenEmojis: Bool = true
    ) {
        let renderer = MarkdownEmojiRenderer(
            shouldOmitSpacesBetweenEmojis: shouldOmitSpacesBetweenEmojis,
            interpretedSyntax: interpretedSyntax
        )
        self.init(string: content, emojis: emojis, renderer: renderer)
    }

    /// Initialize a ``EmojiLabel`` with support for custom emojis.
    ///
    /// - Parameters:
    ///     - content: A string to display without localization.
    ///     - emojis: The custom emojis to render.
    ///     - shouldOmitSpacesBetweenEmojis: Whether to omit spaces between emojis. Defaults to `true.
    public convenience init<S>(
        _ content: S,
        emojis: [any CustomEmoji],
        shouldOmitSpacesBetweenEmojis: Bool = true
    ) where S: StringProtocol {
        self.init(verbatim: String(content), emojis: emojis, shouldOmitSpacesBetweenEmojis: shouldOmitSpacesBetweenEmojis)
    }

    private init(
        string: String,
        emojis: [any CustomEmoji],
        renderer: EmojiRenderer
    ) {
        self.raw = string
        self.emojis = emojis
        self.renderer = renderer
        super.init(frame: .zero)
        #if !os(watchOS)
        registerForTraitChanges([UITraitDisplayScale.self, UITraitPreferredContentSizeCategory.self], action: #selector(traitsDidChange))
        #endif
        load()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        task?.cancel()
    }

    override public var text: String? {
        get {
            raw
        }
        set {
            raw = newValue ?? ""
            load()
        }
    }

    @objc func traitsDidChange() {
        load()
    }

    func render(_ renderedEmojis: [String: LoadedEmoji]) {
        let string: NSAttributedString = renderer.render(
            string: raw,
            emojis: renderedEmojis,
            size: nil
        )
        if let color = tintColor {
            let result = NSMutableAttributedString(attributedString: string)
            result.enumerateAttribute(.link) { value, range, _ in
                guard value is URL else { return }
                result.addAttribute(.foregroundColor, value: color, range: range)
            }
            self.attributedText = result
        } else {
            self.attributedText = string
        }
    }

    func makeLoader() -> EmojiLoader {
        EmojiLoader(placeholder: placeholder, font: font) { parameter in
            parameter
                .overrideSize(targetHeight)
                .overrideBaselineOffset(baselineOffset)
                .displayScale(window?.screen.scale)
        }
        .emojiProvider(syncEmojiProvider: syncEmojiProvider, asyncEmojiProvider: asyncEmojiProvider)
    }

    private var placeholder: any CustomEmoji {
        if let image = UIImage(systemName: "square.dashed") {
            return LocalEmoji(shortcode: "placeholder", image: image, color: .placeholderEmoji, renderingMode: .template)
        } else {
            return SFSymbolEmoji(shortcode: "placeholder", symbolRenderingMode: .monochrome, renderingMode: .template)
        }
    }

    // MARK: - Modifier

    public func setEmojiProvider(syncEmojiProvider: SyncEmojiProvider, asyncEmojiProvider: AsyncEmojiProvider) {
        self.syncEmojiProvider = syncEmojiProvider
        self.asyncEmojiProvider = asyncEmojiProvider
        // Reload emojis
        load()
    }

    public var overrideSize: CGFloat? {
        get {
            targetHeight
        }
        set {
            self.targetHeight = newValue
            // Reload emojis
            load()
        }
    }

    public var overrideBaselineOffset: CGFloat? {
        get {
            baselineOffset
        }
        set {
            self.baselineOffset = newValue
            // Reload emojis
            load()
        }
    }
}

#if DEBUG
@available(iOS 17.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
#Preview {
    EmojiLabel(markdown: "Hello **World** :a:", emojis: .emojis)
}
#endif
#endif
