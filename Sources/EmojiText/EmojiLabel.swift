//
//  EmojiLabel.swift
//  EmojiText
//
//  Created by David Walter on 10.08.25.
//

#if os(iOS) || targetEnvironment(macCatalyst) || os(tvOS) || os(visionOS)
import UIKit
import SwiftUI

@available(iOS 17.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
open class EmojiLabel: UILabel, EmojiTextPresenter {
    // MARK: Public

    override public var text: String? {
        get {
            switch source {
            case let .string(string):
                return string
            case let .attributedString(string):
                return String(string.characters[...])
            case let .nsAttributedString(string):
                return string.string
            default:
                return nil
            }
        }
        set {
            if let newValue {
                source = .string(newValue)
            } else {
                source = nil
            }
            perform()
        }
    }

    override public var attributedText: NSAttributedString? {
        get {
            switch source {
            case let .string(string):
                return NSAttributedString(string: string)
            case let .attributedString(string):
                return NSAttributedString(string)
            case let .nsAttributedString(string):
                return string
            default:
                return super.attributedText
            }
        }
        set {
            if let newValue {
                source = .nsAttributedString(newValue)
            } else {
                source = nil
            }
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

    var source: EmojiTextSource?
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

        #if !os(watchOS)
        registerForTraitChanges([UITraitDisplayScale.self, UITraitPreferredContentSizeCategory.self], action: #selector(traitsDidChange))
        #endif
    }

    public init() {
        super.init(frame: .zero)

        #if !os(watchOS)
        registerForTraitChanges([UITraitDisplayScale.self, UITraitPreferredContentSizeCategory.self], action: #selector(traitsDidChange))
        #endif
    }

    public required init?(coder: NSCoder) {
        self.emojis = []
        self.shouldOmitSpacesBetweenEmojis = true

        super.init(coder: coder)

        #if !os(watchOS)
        registerForTraitChanges([UITraitDisplayScale.self, UITraitPreferredContentSizeCategory.self], action: #selector(traitsDidChange))
        #endif
    }

    deinit {
        task?.cancel()
    }

    @objc func traitsDidChange() {
        perform()
    }

    // MARK: - EmojiTextPresenter

    var emojiFont: EmojiFont {
        font
    }

    var emojiScale: CGFloat? {
        #if os(visionOS)
        EnvironmentValues().displayScale
        #else
        window?.screen.scale
        #endif
    }

    func draw(_ renderedEmojis: [String: LoadedEmoji]) {
        guard let string = makeString(from: renderedEmojis) else { return }
        if let color = tintColor {
            let result = NSMutableAttributedString(attributedString: string)
            result.enumerateAttribute(.link) { value, range, _ in
                guard value is URL else { return }
                result.addAttribute(.foregroundColor, value: color, range: range)
            }
            super.attributedText = result
        } else {
            super.attributedText = string
        }
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
@available(iOS 17.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
#Preview {
    let label = EmojiLabel()
    label.emojis = .emojis
    label.text = "Hello **World** :iphone:"
    return label
}
#endif
#endif
