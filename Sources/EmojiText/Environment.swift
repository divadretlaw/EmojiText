//
//  Environment.swift
//  EmojiText
//
//  Created by David Walter on 11.01.23.
//

import SwiftUI
import Nuke

struct ImagePipelineKey: EnvironmentKey {
    static var defaultValue: ImagePipeline { .shared }
}

struct PlaceholderEmojiKey: EnvironmentKey {
    static var defaultValue: any CustomEmoji {
        SFSymbolEmoji.placeholder
    }
}

struct EmojiSizeKey: EnvironmentKey {
    static var defaultValue: CGFloat? {
        nil
    }
}

public extension EnvironmentValues {
    @available(*, deprecated, renamed: "emojiImagePipeline")
    var imagePipeline: ImagePipeline {
        get {
            self[ImagePipelineKey.self]
        }
        set {
            self[ImagePipelineKey.self] = newValue
        }
    }
    
    var emojiImagePipeline: ImagePipeline {
        get {
            self[ImagePipelineKey.self]
        }
        set {
            self[ImagePipelineKey.self] = newValue
        }
    }
    
    var emojiSize: CGFloat? {
        get {
            self[EmojiSizeKey.self]
        }
        set {
            self[EmojiSizeKey.self] = newValue
        }
    }
}

internal extension EnvironmentValues {
    var placeholderEmoji: any CustomEmoji {
        get {
            self[PlaceholderEmojiKey.self]
        }
        set {
            self[PlaceholderEmojiKey.self] = newValue
        }
    }
}

public extension View {
    /// Set the placeholder emoji
    ///
    /// - Parameters:
    ///     - systemName: The SF Symbol code of the emoji
    ///     - symbolRenderingMode: The symbol rendering mode to use for this emoji
    ///     - renderingMode: The mode SwiftUI uses to render this emoji
    func placeholderEmoji(systemName: String, symbolRenderingMode: SymbolRenderingMode? = nil, renderingMode: Image.TemplateRenderingMode? = nil) -> some View {
        environment(\.placeholderEmoji, SFSymbolEmoji(shortcode: systemName, symbolRenderingMode: symbolRenderingMode, renderingMode: renderingMode))
    }
    
    /// Set the placeholder emoji
    ///
    /// - Parameters:
    ///     - image: The image to use as placeholder
    ///     - renderingMode: The mode SwiftUI uses to render this emoji
    func placeholderEmoji(image: EmojiImage, renderingMode: Image.TemplateRenderingMode? = nil) -> some View {
        environment(\.placeholderEmoji, LocalEmoji(shortcode: "placeholder", image: image, renderingMode: renderingMode))
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
}
