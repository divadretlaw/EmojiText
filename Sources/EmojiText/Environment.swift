//
//  Environment.swift
//  EmojiText
//
//  Created by David Walter on 11.01.23.
//

import SwiftUI
import Nuke
import Combine

struct EmojiImagePipelineKey: EnvironmentKey {
    static var defaultValue: ImagePipeline { .shared }
}

struct EmojiPlaceholderKey: EnvironmentKey {
    static var defaultValue: any CustomEmoji {
        SFSymbolEmoji.placeholder
    }
}

struct EmojiSizeKey: EnvironmentKey {
    static var defaultValue: CGFloat? {
        nil
    }
}

struct EmojiBaselineOffsetKey: EnvironmentKey {
    static var defaultValue: CGFloat? {
        nil
    }
}

struct EmojiAnimatedModeKey: EnvironmentKey {
    static var defaultValue: AnimatedEmojiMode {
        .disabledOnLowPower
    }
}

#if os(watchOS) || os(macOS)
struct EmojiTimerKey: EnvironmentKey {
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

public extension EnvironmentValues {
    /// The image pipeline used to fetch remote emojis.
    var emojiImagePipeline: ImagePipeline {
        get {
            self[EmojiImagePipelineKey.self]
        }
        set {
            self[EmojiImagePipelineKey.self] = newValue
        }
    }
    
    /// The size of the inline custom emojis. Set `nil` to automatically determine the size based on the font size.
    var emojiSize: CGFloat? {
        get {
            self[EmojiSizeKey.self]
        }
        set {
            self[EmojiSizeKey.self] = newValue
        }
    }
    
    /// The baseline for custom emojis. Set `nil` to not override the baseline offset and use the default value.
    var emojiBaselineOffset: CGFloat? {
        get {
            self[EmojiBaselineOffsetKey.self]
        }
        set {
            self[EmojiBaselineOffsetKey.self] = newValue
        }
    }
    
    var emojiAnimatedMode: AnimatedEmojiMode {
        get {
            self[EmojiAnimatedModeKey.self]
        }
        set {
            self[EmojiAnimatedModeKey.self] = newValue
        }
    }
}

internal extension EnvironmentValues {
    var emojiPlaceholder: any CustomEmoji {
        get {
            self[EmojiPlaceholderKey.self]
        }
        set {
            self[EmojiPlaceholderKey.self] = newValue
        }
    }
    
    @available(*, deprecated, renamed: "emojiPlaceholder")
    var placeholderEmoji: any CustomEmoji {
        get {
            self[EmojiPlaceholderKey.self]
        }
        set {
            self[EmojiPlaceholderKey.self] = newValue
        }
    }
    
    #if os(watchOS) || os(macOS)
    var emojiTimer: Publishers.Autoconnect<Timer.TimerPublisher> {
        get {
            self[EmojiTimerKey.self]
        }
        set {
            self[EmojiTimerKey.self] = newValue
        }
    }
    #endif
}

public extension View {
    /// Set the placeholder emoji
    ///
    /// - Parameters:
    ///     - systemName: The SF Symbol code of the emoji
    ///     - symbolRenderingMode: The symbol rendering mode to use for this emoji
    ///     - renderingMode: The mode SwiftUI uses to render this emoji
    func emojiPlaceholder(systemName: String, symbolRenderingMode: SymbolRenderingMode? = nil, renderingMode: Image.TemplateRenderingMode? = nil) -> some View {
        environment(\.emojiPlaceholder, SFSymbolEmoji(shortcode: systemName, symbolRenderingMode: symbolRenderingMode, renderingMode: renderingMode))
    }
    
    /// Set the placeholder emoji
    ///
    /// - Parameters:
    ///     - image: The image to use as placeholder
    ///     - renderingMode: The mode SwiftUI uses to render this emoji
    func emojiPlaceholder(image: EmojiImage, renderingMode: Image.TemplateRenderingMode? = nil) -> some View {
        environment(\.emojiPlaceholder, LocalEmoji(shortcode: "placeholder", image: image, renderingMode: renderingMode))
    }
    
    /// Set the placeholder emoji
    ///
    /// - Parameters:
    ///     - systemName: The SF Symbol code of the emoji
    ///     - symbolRenderingMode: The symbol rendering mode to use for this emoji
    ///     - renderingMode: The mode SwiftUI uses to render this emoji
    @available(*, deprecated, renamed: "emojiPlaceholder(systemName:symbolRenderingMode:renderingMode:)")
    func placeholderEmoji(systemName: String, symbolRenderingMode: SymbolRenderingMode? = nil, renderingMode: Image.TemplateRenderingMode? = nil) -> some View {
        emojiPlaceholder(systemName: systemName, symbolRenderingMode: symbolRenderingMode, renderingMode: renderingMode)
    }
    
    /// Set the placeholder emoji
    ///
    /// - Parameters:
    ///     - image: The image to use as placeholder
    ///     - renderingMode: The mode SwiftUI uses to render this emoji
    @available(*, deprecated, renamed: "emojiPlaceholder(image:renderingMode:)")
    func placeholderEmoji(image: EmojiImage, renderingMode: Image.TemplateRenderingMode? = nil) -> some View {
        emojiPlaceholder(image: image, renderingMode: renderingMode)
    }
    
    /// Set the size of the inline custom emojis
    ///
    /// - Parameter size: The size to render the custom emojis in
    ///
    /// While ``EmojiText`` tries to determine the size of the emoji based on the current font and dynamic type size
    /// this only works with the system text styles, this is due to limitations of `SwiftUI.Font`.
    /// In case you use a custom font or want to override the calculation of the emoji size for some other reason
    /// you can provide a emoji size
    func emojiSize(_ size: CGFloat?) -> some View {
        environment(\.emojiSize, size)
    }
    
    /// Overrides the baseline for custom emojis
    ///
    /// - Parameter offset: The size to render the custom emojis in
    ///
    /// While ``EmojiText`` tries to determine the baseline offset of the emoji based on the current font and dynamic type size
    /// this only works with the system text styles, this is due to limitations of `SwiftUI.Font`.
    /// In case you use a custom font or want to override the calculation of the emoji baseline offset for some other reason
    /// you can provide a emoji baseline offset
    func emojiBaselineOffset(_ offset: CGFloat?) -> some View {
        environment(\.emojiBaselineOffset, offset)
    }
}
