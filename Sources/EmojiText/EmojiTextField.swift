//
//  EmojiTextField.swift
//  EmojiText
//
//  Created by David Walter on 10.08.25.
//

#if canImport(AppKit)
import AppKit

open class EmojiTextField: NSTextField, EmojiTextPresenter {
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

    override open var stringValue: String {
        get {
            text ?? super.stringValue
        }
        set {
            text = newValue
        }
    }

    override open var font: NSFont? {
        didSet {
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
    var emojiPlaceholder: any CustomEmoji = EmojiImage.placeholderEmoji

    // MARK: Rendering

    var task: Task<Void, Never>?

    // MARK: Provider

    var syncEmojiProvider: SyncEmojiProvider = DefaultSyncEmojiProvider()
    var asyncEmojiProvider: AsyncEmojiProvider = DefaultAsyncEmojiProvider()

    // MARK: Init

    override public init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    public init() {
        super.init(frame: .zero)

        setup()
    }

    public required init?(coder: NSCoder) {
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
        isBordered = false
    }

    // MARK: - EmojiTextPresenter

    var emojiFont: EmojiFont {
        font ?? NSFont.preferredFont(forTextStyle: .body)
    }

    var emojiScale: CGFloat? {
        window?.screen?.backingScaleFactor
    }

    func draw(_ renderedEmojis: [String: LoadedEmoji]) {
        guard let string = makeString(from: renderedEmojis) else { return }
        let result = NSMutableAttributedString(attributedString: string)
        result.enumerateAttribute(.link) { value, range, _ in
            guard value is URL else { return }
            result.addAttribute(.foregroundColor, value: NSColor.controlAccentColor, range: range)
        }
        self.attributedStringValue = result
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

    public var placeholder: (any CustomEmoji)! {
        get {
            emojiPlaceholder
        }
        set {
            self.emojiPlaceholder = newValue ?? EmojiImage.placeholderEmoji

            // Reload emojis
            perform()
        }
    }
}

#if DEBUG
@available(macOS 14.0, *)
#Preview {
    let textField = EmojiTextField()
    textField.emojis = .emojis
    textField.text = "Hello **World** :a:"
    return textField
}
#endif
#endif
