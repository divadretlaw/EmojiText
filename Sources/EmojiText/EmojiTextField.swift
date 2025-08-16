//
//  EmojiTextField.swift
//  EmojiText
//
//  Created by David Walter on 10.08.25.
//

#if canImport(AppKit)
import AppKit
import SwiftUI

public final class EmojiTextField: NSTextField {
    private var raw: String
    private let emojis: [any CustomEmoji]
    private let renderer: EmojiRenderer

    private var task: Task<Void, Never>?
    private var syncEmojiProvider: SyncEmojiProvider = DefaultSyncEmojiProvider()
    private var asyncEmojiProvider: AsyncEmojiProvider = DefaultAsyncEmojiProvider()

    /// Initialize a ``EmojiTextField`` with support for custom emojis.
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

    /// Initialize a Markdown formatted ``EmojiTextField`` with support for custom emojis.
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

    /// Initialize a ``EmojiTextField`` with support for custom emojis.
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

    init(
        string: String,
        emojis: [any CustomEmoji],
        renderer: EmojiRenderer
    ) {
        self.raw = string
        self.emojis = emojis
        self.renderer = renderer
        super.init(frame: .zero)
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
        isBordered = false
    }

    private func load() {
        guard !emojis.isEmpty else {
            return
        }

        let loader = makeLoader()
        task = Task.detached { [weak self, emojis] in
            guard let self else { return }
            // Hash of currently displayed emojis
            var renderedEmojis: [String: LoadedEmoji] = [:]

            // Load emojis. Will set placeholders for lazy emojis
            renderedEmojis = renderedEmojis.merging(loader.loadEmojis(emojis)) { current, new in
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
            await render(renderedEmojis)
            // Load emojis. Will set placeholders for lazy emojis
            renderedEmojis = renderedEmojis.merging(await loader.loadLazyEmojis(emojis)) { current, new in
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
            await render(renderedEmojis)
        }
    }

    private func render(_ renderedEmojis: [String: LoadedEmoji]) {
        let string: NSAttributedString = renderer.render(
            string: raw,
            emojis: renderedEmojis,
            size: nil
        )
        let result = NSMutableAttributedString(attributedString: string)
        result.enumerateAttribute(.link) { value, range, _ in
            guard value is URL else { return }
            result.addAttribute(.foregroundColor, value: NSColor.controlAccentColor, range: range)
        }
        self.attributedStringValue = result
    }

    func makeLoader() -> EmojiLoader {
        EmojiLoader(placeholder: placeholder, font: font ?? NSFont.preferredFont(forTextStyle: .body)) { parameter in
            parameter
            // overrideSize(size)
            // overrideBaselineOffset(baselineOffset)
                .displayScale(window?.screen?.backingScaleFactor)
        }
        .emojiProvider(syncEmojiProvider: syncEmojiProvider, asyncEmojiProvider: asyncEmojiProvider)
    }

    var placeholder: any CustomEmoji {
        if let image = NSImage(systemName: "square.dashed") {
            return LocalEmoji(shortcode: "placeholder", image: image, color: .placeholderEmoji, renderingMode: .template)
        } else {
            return SFSymbolEmoji(shortcode: "placeholder", symbolRenderingMode: .monochrome, renderingMode: .template)
        }
    }
}

@available(macOS 14.0, *)
#Preview {
    EmojiTextField(markdown: "**Hello** :iphone: _and_ :a:", emojis: .emojis)
}
#endif
