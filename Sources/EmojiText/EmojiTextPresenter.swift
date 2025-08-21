//
//  EmojiTextPresenter.swift
//  EmojiText
//
//  Created by David Walter on 21.08.25.
//

import Foundation

@MainActor protocol EmojiTextPresenter: AnyObject, Sendable {
    var raw: String { get set }
    var emojis: [any CustomEmoji] { get }
    var renderer: EmojiRenderer { get }

    /// Loading task
    var task: Task<Void, Never>? { get set }

    var targetHeight: CGFloat? { get set }
    var baselineOffset: CGFloat? { get set }
    var syncEmojiProvider: SyncEmojiProvider { get set }
    var asyncEmojiProvider: AsyncEmojiProvider { get set }

    /// Reload emojis
    func load()
    /// Render emojis
    func render(_ renderedEmojis: [String: LoadedEmoji])
    /// Create an ``EmojiLoader``
    func makeLoader() -> EmojiLoader
}

extension EmojiTextPresenter {
    func load() {
        guard !emojis.isEmpty else {
            return render([:])
        }

        let loader = makeLoader()
        task?.cancel()
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
            await self.render(renderedEmojis)
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
            await self.render(renderedEmojis)
        }
    }
}
