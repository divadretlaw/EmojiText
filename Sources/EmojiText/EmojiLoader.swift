//
//  EmojiLoader.swift
//  EmojiText
//
//  Created by David Walter on 10.08.25.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif
#if canImport(AppKit)
import AppKit
#endif
import OSLog

struct EmojiLoader: Sendable {
    struct Parameter: Sendable {
        private(set) var placeholder: any CustomEmoji
        private(set) var targetHeight: CGFloat
        private(set) var baselineOffset: CGFloat
        private(set) var displayScale: CGFloat
        private(set) var shouldAnimateIfNeeded: Bool

        init(placeholder: any CustomEmoji, targetHeight: CGFloat, baselineOffset: CGFloat) {
            self.placeholder = placeholder
            self.targetHeight = targetHeight
            self.baselineOffset = baselineOffset
            self.displayScale = 1.0
            self.shouldAnimateIfNeeded = false
        }

        init(
            placeholder: any CustomEmoji,
            font: EmojiFont
        ) {
            self.placeholder = placeholder
            self.targetHeight = font.pointSize
            self.baselineOffset = -(font.pointSize - font.capHeight) / 2
            self.displayScale = 1.0
            self.shouldAnimateIfNeeded = false
        }

        var resizeHeight: CGFloat {
            targetHeight * displayScale
        }

        func overrideSize(_ value: CGFloat?) -> Self {
            var parameter = self
            parameter.targetHeight = value ?? targetHeight
            return parameter
        }

        func overrideBaselineOffset(_ value: CGFloat?) -> Self {
            var parameter = self
            parameter.baselineOffset = value ?? baselineOffset
            return parameter
        }

        func displayScale(_ value: CGFloat?) -> Self {
            var parameter = self
            parameter.displayScale = value ?? displayScale
            return parameter
        }

        func shouldAnimateIfNeeded(_ value: Bool) -> Self {
            var parameter = self
            parameter.shouldAnimateIfNeeded = value
            return parameter
        }
    }

    let parameter: Parameter

    private var syncEmojiProvider: SyncEmojiProvider
    private var asyncEmojiProvider: AsyncEmojiProvider

    init(
        parameter: Parameter
    ) {
        self.parameter = parameter
        self.syncEmojiProvider = DefaultSyncEmojiProvider()
        self.asyncEmojiProvider = DefaultAsyncEmojiProvider()
    }

    init(
        placeholder: any CustomEmoji,
        font: EmojiFont,
        builder: (Parameter) -> Parameter
    ) {
        let parameter = Parameter(placeholder: placeholder, font: font)
        self.parameter = builder(parameter)
        self.syncEmojiProvider = DefaultSyncEmojiProvider()
        self.asyncEmojiProvider = DefaultAsyncEmojiProvider()
    }

    func loadEmojis(_ emojis: [any CustomEmoji]) -> [String: LoadedEmoji] {
        var renderedEmojis = [String: LoadedEmoji]()

        for emoji in emojis {
            guard !Task.isCancelled else { return [:] }
            switch emoji {
            case let sfSymbolEmoji as SFSymbolEmoji:
                // SF Symbol emoji don't require a placeholder as they can be loaded instantly
                renderedEmojis[emoji.shortcode] = LoadedEmoji(
                    from: sfSymbolEmoji
                )
            case let emoji as any SyncCustomEmoji:
                if let image = syncEmojiProvider.emojiImage(emoji: emoji, height: parameter.targetHeight) {
                    renderedEmojis[emoji.shortcode] = LoadedEmoji(
                        from: emoji,
                        image: RawImage(image: image),
                        animated: parameter.shouldAnimateIfNeeded,
                        targetHeight: parameter.targetHeight,
                        baselineOffset: parameter.baselineOffset
                    )
                } else {
                    // Sync emoji wasn't loaded and a placeholder will be used instead
                    renderedEmojis[emoji.shortcode] = LoadedEmoji(
                        from: emoji,
                        placeholder: parameter.placeholder,
                        targetHeight: parameter.targetHeight,
                        baselineOffset: parameter.baselineOffset
                    )
                }
            case let emoji as any AsyncCustomEmoji:
                // Try to load remote emoji from cache
                if let image = asyncEmojiProvider.cachedEmojiImage(emoji: emoji, height: parameter.resizeHeight) {
                    renderedEmojis[emoji.shortcode] = LoadedEmoji(
                        from: emoji,
                        image: RawImage(image: image),
                        animated: false,
                        targetHeight: parameter.targetHeight,
                        baselineOffset: parameter.baselineOffset
                    )
                } else {
                    // Async emoji wasn't found in cache and a placeholder will be used instead
                    renderedEmojis[emoji.shortcode] = LoadedEmoji(
                        from: emoji,
                        placeholder: parameter.placeholder,
                        targetHeight: parameter.targetHeight,
                        baselineOffset: parameter.baselineOffset
                    )
                }
            default:
                // Set a placeholder for all other emoji
                renderedEmojis[emoji.shortcode] = LoadedEmoji(
                    from: emoji,
                    placeholder: parameter.placeholder,
                    targetHeight: parameter.targetHeight,
                    baselineOffset: parameter.baselineOffset
                )
            }
        }

        return renderedEmojis
    }

    func loadLazyEmojis(_ emojis: [any CustomEmoji]) async -> [String: LoadedEmoji] {
        await withTaskGroup(of: LoadedEmoji?.self, returning: [String: LoadedEmoji].self) { [asyncEmojiProvider, parameter] group in
            for emoji in emojis {
                guard !Task.isCancelled else { return [:] }
                switch emoji {
                case let emoji as any AsyncCustomEmoji:
                    _ = group.addTaskUnlessCancelled {
                        do {
                            let image: RawImage
                            let data = try await asyncEmojiProvider.fetchEmojiData(emoji: emoji, height: parameter.resizeHeight)
                            if parameter.shouldAnimateIfNeeded {
                                image = try RawImage(animated: data)
                            } else {
                                image = try RawImage(static: data)
                            }
                            return LoadedEmoji(
                                from: emoji,
                                image: image,
                                animated: parameter.shouldAnimateIfNeeded,
                                targetHeight: parameter.targetHeight,
                                baselineOffset: parameter.baselineOffset
                            )
                        } catch {
                            Logger.emojiText.error("Unable to load '\(type(of: emoji))' with code '\(emoji.shortcode)': \(error.localizedDescription)")
                            return nil
                        }
                    }
                default:
                    continue
                }
            }
            // Collect TaskGroup results
            var result: [String: LoadedEmoji] = [:]
            for await emoji in group {
                if let emoji {
                    result[emoji.shortcode] = emoji
                }
            }
            return result
        }
    }

    // MARK: - Modifier

    func emojiProvider(syncEmojiProvider: SyncEmojiProvider, asyncEmojiProvider: AsyncEmojiProvider) -> Self {
        var loader = self
        loader.syncEmojiProvider = syncEmojiProvider
        loader.asyncEmojiProvider = asyncEmojiProvider
        return loader
    }
}
