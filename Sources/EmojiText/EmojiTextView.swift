//
//  EmojiTextView.swift
//  EmojiText
//
//  Created by David Walter on 10.08.25.
//

#if canImport(AppKit)
import AppKit

public final class EmojiTextView: NSTextView, EmojiTextPresenter {
    var raw: String
    let emojis: [any CustomEmoji]
    let renderer: EmojiRenderer

    var task: Task<Void, Never>?

    var targetHeight: CGFloat?
    var baselineOffset: CGFloat?
    var syncEmojiProvider: SyncEmojiProvider = DefaultSyncEmojiProvider()
    var asyncEmojiProvider: AsyncEmojiProvider = DefaultAsyncEmojiProvider()

    /// Initialize a ``EmojiTextView`` with support for custom emojis.
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

    /// Initialize a Markdown formatted ``EmojiTextView`` with support for custom emojis.
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

    /// Initialize a ``EmojiTextView`` with support for custom emojis.
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

        // Create text container
        let textContainer = NSTextContainer()
        // Create layout manager using the text container
        let layoutManager = NSLayoutManager()
        layoutManager.addTextContainer(textContainer)
        // Create text storage using the layout manager
        let textStorage = NSTextStorage()
        textStorage.addLayoutManager(layoutManager)

        super.init(frame: .zero, textContainer: textContainer)

        setup()
        load()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        task?.cancel()
    }

    private func setup() {
        isEditable = false
        backgroundColor = .clear
        drawsBackground = false
    }

    func render(_ renderedEmojis: [String: LoadedEmoji]) {
        guard let textStorage else {
            return
        }

        let string: NSAttributedString = renderer.render(
            string: raw,
            emojis: renderedEmojis,
            size: nil
        )
        let result = NSMutableAttributedString(attributedString: string)
        result.enumerateAttribute(.link) { value, range, stop in
            guard value is URL else { return }
            result.addAttribute(.foregroundColor, value: NSColor.controlAccentColor, range: range)
        }
        textStorage.setAttributedString(result)
    }

    func makeLoader() -> EmojiLoader {
        EmojiLoader(placeholder: placeholder, font: font ?? NSFont.preferredFont(forTextStyle: .body)) { parameter in
            parameter
                .overrideSize(targetHeight)
                .overrideBaselineOffset(baselineOffset)
                .displayScale(window?.screen?.backingScaleFactor)
        }
        .emojiProvider(syncEmojiProvider: syncEmojiProvider, asyncEmojiProvider: asyncEmojiProvider)
    }

    private var placeholder: any CustomEmoji {
        if let image = NSImage(systemName: "square.dashed") {
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
import SwiftUI

private struct NSPreview: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        EmojiTextView(markdown: "**Hello** :iphone: _and_ :a:", emojis: .emojis)
    }

    func updateNSView(_ nsView: NSView, context: Context) {
    }
}

#Preview {
    NSPreview()
        .padding()
}
#endif
#endif
