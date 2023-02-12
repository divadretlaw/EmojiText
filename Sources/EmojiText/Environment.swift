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
    static var defaultValue: EmojiImage? { nil }
}

public extension EnvironmentValues {
    var imagePipeline: ImagePipeline {
        get {
            self[ImagePipelineKey.self]
        }
        set {
            self[ImagePipelineKey.self] = newValue
        }
    }
    
    var placeholderEmoji: EmojiImage? {
        get {
            self[PlaceholderEmojiKey.self]
        }
        set {
            self[PlaceholderEmojiKey.self] = newValue
        }
    }
}
