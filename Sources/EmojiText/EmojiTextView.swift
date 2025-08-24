//
//  EmojiTextView.swift
//  EmojiText
//
//  Created by David Walter on 10.08.25.
//

#if os(iOS) || targetEnvironment(macCatalyst) || os(tvOS) || os(watchOS) || os(visionOS)
import UIKit

open class EmojiTextView: UITextView, EmojiTextPresenter {
    // MARK: Public

    override public var text: String? {
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
    var emojiPlaceholder: any CustomEmoji = EmojiImage.placeholderEmoji

    // MARK: Rendering

    var task: Task<Void, Never>?

    // MARK: Provider

    var syncEmojiProvider: SyncEmojiProvider = DefaultSyncEmojiProvider()
    var asyncEmojiProvider: AsyncEmojiProvider = DefaultAsyncEmojiProvider()

    // MARK: Init

    public override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)

        setup()
    }

    public init() {
        let textLayoutManager = NSTextLayoutManager()
        let textContainer = NSTextContainer(size: .zero)
        textLayoutManager.textContainer = textContainer
        let textContentStorage = NSTextContentStorage()
        textContentStorage.addTextLayoutManager(textLayoutManager)

        super.init(frame: .zero, textContainer: textLayoutManager.textContainer)

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
    }

    // MARK: - EmojiTextPresenter

    var emojiFont: EmojiFont {
        font ?? UIFont.preferredFont(forTextStyle: .body)
    }

    var emojiScale: CGFloat? {
        window?.screen.scale
    }

    func draw(_ renderedEmojis: [String: LoadedEmoji]) {
        guard let string = makeString(from: renderedEmojis) else { return }
        let result = NSMutableAttributedString(attributedString: string)
        result.enumerateAttribute(.link) { value, range, stop in
            guard value is URL else { return }
            result.addAttribute(.foregroundColor, value: UIColor.tintColor, range: range)
        }
        textStorage.setAttributedString(result)
    }
}
#elseif os(macOS)
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
    var emojiPlaceholder: any CustomEmoji = EmojiImage.placeholderEmoji

    // MARK: Rendering

    var task: Task<Void, Never>?

    // MARK: Provider

    var syncEmojiProvider: SyncEmojiProvider = DefaultSyncEmojiProvider()
    var asyncEmojiProvider: AsyncEmojiProvider = DefaultAsyncEmojiProvider()

    // MARK: Init

    public override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)

        setup()
    }

    public override init(frame: CGRect) {
        let textLayoutManager = NSTextLayoutManager()
        let textContainer = NSTextContainer(size: .zero)
        textLayoutManager.textContainer = textContainer
        let textContentStorage = NSTextContentStorage()
        textContentStorage.addTextLayoutManager(textLayoutManager)

        super.init(frame: frame, textContainer: textLayoutManager.textContainer)

        setup()
    }

    public init() {
        let textLayoutManager = NSTextLayoutManager()
        let textContainer = NSTextContainer(size: .zero)
        textLayoutManager.textContainer = textContainer
        let textContentStorage = NSTextContentStorage()
        textContentStorage.addTextLayoutManager(textLayoutManager)

        super.init(frame: .zero, textContainer: textLayoutManager.textContainer)

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
}
#endif

extension EmojiTextView {
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
@available(iOS 17.0, macOS 14.0, tvOS 17.0, *)
#Preview {
    let view = EmojiTextView()
    view.emojis = .emojis
    view.text = "**Hello** :iphone: _and_ :a:"
    return view
}
#endif
