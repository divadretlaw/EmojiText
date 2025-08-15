//
//  UIEmojiText.swift
//  EmojiText
//
//  Created by David Walter on 10.08.25.
//

#if canImport(UIKit)
import UIKit
import SwiftUI

@available(iOS 17.0, tvOS 17.0, watchOS 10.0, *)
@MainActor public final class UIEmojiLabel: UILabel {
    private var raw: String
    private let emojis: [any CustomEmoji]
    private let renderer: EmojiRenderer

    private var task: Task<Void, Never>?
    private var syncEmojiProvider: SyncEmojiProvider = DefaultSyncEmojiProvider()
    private var asyncEmojiProvider: AsyncEmojiProvider = DefaultAsyncEmojiProvider()

    /// Initialize a ``UIEmojiLabel`` with support for custom emojis.
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

    /// Initialize a Markdown formatted ``UIEmojiLabel`` with support for custom emojis.
    ///
    /// - Parameters:
    ///     - content: The string that contains the Markdown formatting.
    ///     - interpretedSyntax: The syntax for intepreting a Markdown string. Defaults to `.inlineOnlyPreservingWhitespace`.
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

    /// Initialize a ``UIEmojiLabel`` with support for custom emojis.
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
        #if !os(watchOS)
        registerForTraitChanges([UITraitDisplayScale.self, UITraitPreferredContentSizeCategory.self], action: #selector(load))
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

    @objc private func load() {
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
            // .overrideSize(size)
            // .overrideBaselineOffset(baselineOffset)
                .displayScale(window?.screen.scale)
        }
        .emojiProvider(syncEmojiProvider: syncEmojiProvider, asyncEmojiProvider: asyncEmojiProvider)
    }

    var placeholder: any CustomEmoji {
        if let image = UIImage(systemName: "square.dashed") {
            return LocalEmoji(shortcode: "placeholder", image: image, color: .placeholderEmoji, renderingMode: .template)
        } else {
            return SFSymbolEmoji(shortcode: "placeholder", symbolRenderingMode: .monochrome, renderingMode: .template)
        }
    }
}

#if DEBUG
@available(iOS 17.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
private struct UIPreview: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        UIEmojiLabel(markdown: "Hello **World** :a:", emojis: .emojis)
    }

    func updateUIView(_ uiView: UIView, context: Context) {
    }
}

@available(iOS 17.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
#Preview {
    UIPreview()
}
#endif
#endif
