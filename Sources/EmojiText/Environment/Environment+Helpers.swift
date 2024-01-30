//
//  Environment+Helpers.swift
//  EmojiText
//
//  Created by David Walter on 04.02.24.
//

import SwiftUI

public extension EmojiTextNamespace where Content: View {
    /// Set the placeholder emoji
    ///
    /// - Parameters:
    ///     - systemName: The SF Symbol code of the emoji
    ///     - symbolRenderingMode: The symbol rendering mode to use for this emoji
    ///     - renderingMode: The mode SwiftUI uses to render this emoji
    func placeholder(systemName: String, symbolRenderingMode: SymbolRenderingMode? = nil, renderingMode: Image.TemplateRenderingMode? = nil) -> some View {
        content.environment(\.emojiText.placeholder, SFSymbolEmoji(shortcode: systemName, symbolRenderingMode: symbolRenderingMode, renderingMode: renderingMode))
    }
    
    /// Set the placeholder emoji
    ///
    /// - Parameters:
    ///     - image: The image to use as placeholder
    ///     - renderingMode: The mode SwiftUI uses to render this emoji
    func placeholder(image: EmojiImage, renderingMode: Image.TemplateRenderingMode? = nil) -> some View {
        content.environment(\.emojiText.placeholder, LocalEmoji(shortcode: "placeholder", image: image, renderingMode: renderingMode))
    }
    
    /// Set the size of the inline custom emojis
    ///
    /// - Parameter size: The size to render the custom emojis in
    ///
    /// While ``EmojiText`` tries to determine the size of the emoji based on the current font and dynamic type size
    /// this only works with the system text styles, this is due to limitations of `SwiftUI.Font`.
    /// In case you use a custom font or want to override the calculation of the emoji size for some other reason
    /// you can provide a emoji size
    func size(_ size: CGFloat?) -> some View {
        content.environment(\.emojiText.size, size)
    }
    
    /// Overrides the baseline for custom emojis
    ///
    /// - Parameter offset: The size to render the custom emojis in
    ///
    /// While ``EmojiText`` tries to determine the baseline offset of the emoji based on the current font and dynamic type size
    /// this only works with the system text styles, this is due to limitations of `SwiftUI.Font`.
    /// In case you use a custom font or want to override the calculation of the emoji baseline offset for some other reason
    /// you can provide a emoji baseline offset
    func baselineOffset(_ offset: CGFloat?) -> some View {
        content.environment(\.emojiText.baselineOffset, offset)
    }
}

// MARK: - Deprecations

public extension View {
    /// Set the placeholder emoji
    ///
    /// - Parameters:
    ///     - systemName: The SF Symbol code of the emoji
    ///     - symbolRenderingMode: The symbol rendering mode to use for this emoji
    ///     - renderingMode: The mode SwiftUI uses to render this emoji
    @available(*, deprecated, renamed: "emojiText.placeholder(systemName:symbolRenderingMode:renderingMode:)")
    func emojiPlaceholder(systemName: String, symbolRenderingMode: SymbolRenderingMode? = nil, renderingMode: Image.TemplateRenderingMode? = nil) -> some View {
        environment(\.emojiText.placeholder, SFSymbolEmoji(shortcode: systemName, symbolRenderingMode: symbolRenderingMode, renderingMode: renderingMode))
    }
    
    /// Set the placeholder emoji
    ///
    /// - Parameters:
    ///     - image: The image to use as placeholder
    ///     - renderingMode: The mode SwiftUI uses to render this emoji
    @available(*, deprecated, renamed: "emojiText.placeholder(systemName:renderingMode:)")
    func emojiPlaceholder(image: EmojiImage, renderingMode: Image.TemplateRenderingMode? = nil) -> some View {
        environment(\.emojiText.placeholder, LocalEmoji(shortcode: "placeholder", image: image, renderingMode: renderingMode))
    }
    
    /// Set the size of the inline custom emojis
    ///
    /// - Parameter size: The size to render the custom emojis in
    ///
    /// While ``EmojiText`` tries to determine the size of the emoji based on the current font and dynamic type size
    /// this only works with the system text styles, this is due to limitations of `SwiftUI.Font`.
    /// In case you use a custom font or want to override the calculation of the emoji size for some other reason
    /// you can provide a emoji size
    @available(*, deprecated, renamed: "emojiText.size(_:)")
    func emojiSize(_ size: CGFloat?) -> some View {
        environment(\.emojiText.size, size)
    }
    
    /// Overrides the baseline for custom emojis
    ///
    /// - Parameter offset: The size to render the custom emojis in
    ///
    /// While ``EmojiText`` tries to determine the baseline offset of the emoji based on the current font and dynamic type size
    /// this only works with the system text styles, this is due to limitations of `SwiftUI.Font`.
    /// In case you use a custom font or want to override the calculation of the emoji baseline offset for some other reason
    /// you can provide a emoji baseline offset
    @available(*, deprecated, renamed: "emojiText.baselineOffset(_:)")
    func emojiBaselineOffset(_ offset: CGFloat?) -> some View {
        environment(\.emojiText.baselineOffset, offset)
    }
}
