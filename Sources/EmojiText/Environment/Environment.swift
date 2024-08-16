//
//  Environment.swift
//  EmojiText
//
//  Created by David Walter on 11.01.23.
//

import SwiftUI
import Combine

// MARK: - Environment Keys

private struct EmojiPlaceholderKey: EnvironmentKey {
    static var defaultValue: any CustomEmoji {
        #if os(iOS) || targetEnvironment(macCatalyst) || os(tvOS) || os(watchOS) || os(visionOS)
        if let image = UIImage(systemName: "square.dashed") {
            return LocalEmoji(shortcode: "placeholder", image: image, color: .placeholderEmoji, renderingMode: .template)
        }
        #elseif os(macOS)
        if let image = NSImage(systemName: "square.dashed") {
            return LocalEmoji(shortcode: "placeholder", image: image, color: .placeholderEmoji, renderingMode: .template)
        }
        #endif
        
        return SFSymbolEmoji(shortcode: "placeholder", symbolRenderingMode: .monochrome, renderingMode: .template)
    }
}

private struct EmojiSizeKey: EnvironmentKey {
    static var defaultValue: CGFloat? {
        nil
    }
}

private struct EmojiBaselineOffsetKey: EnvironmentKey {
    static var defaultValue: CGFloat? {
        nil
    }
}

private struct EmojiAnimatedModeKey: EnvironmentKey {
    static var defaultValue: AnimatedEmojiMode {
        .disabledOnLowPower
    }
}

private struct SyncEmojiProviderKey: EnvironmentKey {
    static var defaultValue: SyncEmojiProvider {
        DefaultSyncEmojiProvider()
    }
}

private struct AsyncEmojiProviderKey: EnvironmentKey {
    static var defaultValue: AsyncEmojiProvider {
        DefaultAsyncEmojiProvider(pipeline: .shared)
    }
}

#if os(watchOS) || os(macOS)
private struct EmojiTimerKey: EnvironmentKey {
    typealias Value = Publishers.Autoconnect<Timer.TimerPublisher>
    
    static var defaultValue: Publishers.Autoconnect<Timer.TimerPublisher> {
        #if os(watchOS)
        Timer.publish(every: 1 / 24, on: .main, in: .common).autoconnect()
        #else
        Timer.publish(every: 1 / 60, on: .main, in: .common).autoconnect()
        #endif
    }
}
#endif

// MARK: - Environment Values

public extension EmojiTextEnvironmentValues {
    /// The ``SyncEmojiProvider`` used to fetch emoji
    var syncEmojiProvider: SyncEmojiProvider {
        get { self[SyncEmojiProviderKey.self] }
        set { self[SyncEmojiProviderKey.self] = newValue }
    }
    
    /// The ``AsyncEmojiProvider`` used to fetch lazy emoji
    var asyncEmojiProvider: AsyncEmojiProvider {
        get { self[AsyncEmojiProviderKey.self] }
        set { self[AsyncEmojiProviderKey.self] = newValue }
    }
    
    /// The ``AnimatedEmojiMode`` that animated emojis should use
    var animatedMode: AnimatedEmojiMode {
        get { self[EmojiAnimatedModeKey.self] }
        set { self[EmojiAnimatedModeKey.self] = newValue }
    }
}

internal extension EmojiTextEnvironmentValues {
    /// The placeholder emoji to use if the emoji isn't yet loaded.
    var placeholder: any CustomEmoji {
        get { self[EmojiPlaceholderKey.self] }
        set { self[EmojiPlaceholderKey.self] = newValue }
    }
    
    #if os(watchOS) || os(macOS)
    var timer: Publishers.Autoconnect<Timer.TimerPublisher> {
        get { self[EmojiTimerKey.self] }
        set { self[EmojiTimerKey.self] = newValue }
    }
    #endif
    
    /// The size of the inline custom emojis. Set `nil` to automatically determine the size based on the font size.
    var size: CGFloat? {
        get { self[EmojiSizeKey.self] }
        set { self[EmojiSizeKey.self] = newValue }
    }
    
    /// The baseline for custom emojis. Set `nil` to not override the baseline offset and use the default value.
    var baselineOffset: CGFloat? {
        get { self[EmojiBaselineOffsetKey.self] }
        set { self[EmojiBaselineOffsetKey.self] = newValue }
    }
}
