//
//  EmojiTextPresenter.swift
//  EmojiText
//
//  Created by David Walter on 21.08.25.
//

import Foundation

/// A view that can present emojis
@MainActor protocol EmojiTextPresenter: AnyObject, Sendable {
    var raw: String? { get set }
    var interpretedSyntax: AttributedString.MarkdownParsingOptions.InterpretedSyntax? { get set }
    var emojis: [any CustomEmoji] { get }
    var shouldOmitSpacesBetweenEmojis: Bool { get set }

    /// Loading task
    var task: Task<Void, Never>? { get set }

    var emojiPlaceholder: any CustomEmoji { get }
    var emojiFont: EmojiFont { get }
    var emojiTargetHeight: CGFloat? { get }
    var emojiBaselineOffset: CGFloat? { get }
    var emojiScale: CGFloat? { get }
    var syncEmojiProvider: SyncEmojiProvider { get set }
    var asyncEmojiProvider: AsyncEmojiProvider { get set }

    /// Load/Reload emojis
    func perform()
    /// Draw the emojis
    func draw(_ string: [String: LoadedEmoji])
    /// Create an ``EmojiLoader``
    func makeLoader() -> EmojiLoader
}

extension EmojiTextPresenter {
    func makeLoader() -> EmojiLoader {
        EmojiLoader(
            placeholder: emojiPlaceholder,
            font: emojiFont
        ) { parameter in
            parameter
                .overrideSize(emojiTargetHeight)
                .overrideBaselineOffset(emojiBaselineOffset)
                .displayScale(emojiScale)
        }
        .emojiProvider(syncEmojiProvider: syncEmojiProvider, asyncEmojiProvider: asyncEmojiProvider)
    }

    func perform() {
        task?.cancel()
        guard !emojis.isEmpty else {
            return draw([:])
        }

        let loader = makeLoader()
        task = Task.detached { [weak self, emojis] in
            guard let self, !Task.isCancelled else { return }
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
            guard !Task.isCancelled else { return }
            await self.draw(renderedEmojis)
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
            guard !Task.isCancelled else { return }
            await self.draw(renderedEmojis)
        }
    }

    /// Helper to create `NSAttributedString` from emojis
    func makeString(from emojis: [String: LoadedEmoji]) -> NSAttributedString? {
        guard let raw else { return nil }
        let renderer: EmojiRenderer = if let interpretedSyntax {
            MarkdownEmojiRenderer(
                font: emojiFont,
                shouldOmitSpacesBetweenEmojis: shouldOmitSpacesBetweenEmojis,
                interpretedSyntax: interpretedSyntax
            )
        } else {
            VerbatimEmojiRenderer(
                shouldOmitSpacesBetweenEmojis: shouldOmitSpacesBetweenEmojis
            )
        }
        return renderer.render(
            string: raw,
            emojis: emojis,
            size: emojiTargetHeight
        )
    }
}
