//
//  EmojiTextView.swift
//  EmojiText
//
//  Created by David Walter on 10.08.25.
//

#if canImport(AppKit)
import AppKit

open class EmojiTextView: NSTextView, EmojiTextPresenter {
    // MARK: Public

    public var text: String? {
        get {
            raw
        }
        set {
            raw = newValue
            perform()
        }
    }

    /// Whether to omit spaces between emojis. Defaults to `true.
    public var shouldOmitSpacesBetweenEmojis: Bool = true {
        didSet {
            perform()
        }
    }

    /// The emojis that can be displayed
    public var emojis: [any CustomEmoji] = [] {
        didSet {
            perform()
        }
    }

    /// The syntax for interpreting a Markdown string.
    ///
    /// If `nil` the text will not be interpreted as Markdown
    public var interpretedSyntax: AttributedString.MarkdownParsingOptions.InterpretedSyntax? = .inlineOnlyPreservingWhitespace {
        didSet {
            perform()
        }
    }

    // MARK: Internal

    var raw: String?
    var emojiTargetHeight: CGFloat?
    var emojiBaselineOffset: CGFloat?

    // MARK: Rendering

    var task: Task<Void, Never>?

    // MARK: Provider

    var syncEmojiProvider: SyncEmojiProvider = DefaultSyncEmojiProvider()
    var asyncEmojiProvider: AsyncEmojiProvider = DefaultAsyncEmojiProvider()

    // MARK: Init

    public override init(frame: CGRect) {
        // Create text container
        let textContainer = NSTextContainer()
        // Create layout manager using the text container
        let layoutManager = NSLayoutManager()
        layoutManager.addTextContainer(textContainer)
        // Create text storage using the layout manager
        let textStorage = NSTextStorage()
        textStorage.addLayoutManager(layoutManager)

        super.init(frame: frame, textContainer: textContainer)

        setup()
    }

    public init() {
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
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)

        setup()
    }

    deinit {
        task?.cancel()
    }

    private func setup() {
        isEditable = false
        backgroundColor = .clear
        drawsBackground = false
    }

    // MARK: - EmojiTextPresenter

    var emojiPlaceholder: any CustomEmoji {
        if let image = NSImage(systemName: "square.dashed") {
            return LocalEmoji(shortcode: "placeholder", image: image, color: .placeholderEmoji, renderingMode: .template)
        } else {
            return SFSymbolEmoji(shortcode: "placeholder", symbolRenderingMode: .monochrome, renderingMode: .template)
        }
    }

    var emojiFont: EmojiFont {
        font ?? NSFont.preferredFont(forTextStyle: .body)
    }

    var emojiScale: CGFloat? {
        window?.screen?.backingScaleFactor
    }

    func draw(_ renderedEmojis: [String: LoadedEmoji]) {
        guard let textStorage, let string = makeString(from: renderedEmojis) else { return }
        let result = NSMutableAttributedString(attributedString: string)
        result.enumerateAttribute(.link) { value, range, stop in
            guard value is URL else { return }
            result.addAttribute(.foregroundColor, value: NSColor.controlAccentColor, range: range)
        }
        textStorage.setAttributedString(result)
    }

    // MARK: - Modifier

    public func setEmojiProvider(syncEmojiProvider: SyncEmojiProvider, asyncEmojiProvider: AsyncEmojiProvider) {
        self.syncEmojiProvider = syncEmojiProvider
        self.asyncEmojiProvider = asyncEmojiProvider
        // Reload emojis
        perform()
    }

    public var overrideSize: CGFloat? {
        get {
            emojiTargetHeight
        }
        set {
            self.emojiTargetHeight = newValue
            // Reload emojis
            perform()
        }
    }

    public var overrideBaselineOffset: CGFloat? {
        get {
            emojiBaselineOffset
        }
        set {
            self.emojiBaselineOffset = newValue
            // Reload emojis
            perform()
        }
    }
}

#if DEBUG
import SwiftUI

private struct NSPreview: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = EmojiTextView()
        view.emojis = .emojis
        view.text = "**Hello** :iphone: _and_ :a:"
        return view
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
