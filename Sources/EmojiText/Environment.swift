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
}
