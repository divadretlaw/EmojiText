//
//  RenderedEmoji.swift
//  EmojiText
//
//  Created by David Walter on 12.02.23.
//

import Foundation
import SwiftUI
import OSLog

/// A rendered custom emoji
struct RenderedEmoji: Hashable, Equatable, Identifiable {
    private let shortcode: String
    let baselineOffset: CGFloat?
    let renderingMode: Image.TemplateRenderingMode?
    let symbolRenderingMode: SymbolRenderingMode?
    
    private let _image: Image
    private let isPlaceholder: Bool
    
    init(from emoji: RemoteEmoji, image: EmojiImage, targetSize: CGSize? = nil, baselineOffset: CGFloat? = nil) {
        self.shortcode = emoji.shortcode
        if let targetSize = targetSize {
            self._image = Image(emojiImage: image.scalePreservingAspectRatio(targetSize: targetSize))
        } else {
            self._image = Image(emojiImage: image)
        }
        self.renderingMode = emoji.renderingMode
        self.baselineOffset = emoji.baselineOffset ?? baselineOffset
        self.symbolRenderingMode = nil
        self.isPlaceholder = false
    }
    
    init(from emoji: LocalEmoji, targetSize: CGSize? = nil, baselineOffset: CGFloat? = nil) {
        self.shortcode = emoji.shortcode
        if let targetSize = targetSize {
            self._image = Image(emojiImage: emoji.image.scalePreservingAspectRatio(targetSize: targetSize))
        } else {
            self._image = Image(emojiImage: emoji.image)
        }
        self.renderingMode = emoji.renderingMode
        self.baselineOffset = emoji.baselineOffset ?? baselineOffset
        self.symbolRenderingMode = nil
        self.isPlaceholder = false
    }
    
    init(from emoji: SFSymbolEmoji) {
        self.shortcode = emoji.shortcode
        self._image = Image(systemName: emoji.shortcode)
        self.renderingMode = emoji.renderingMode
        self.baselineOffset = emoji.baselineOffset
        self.symbolRenderingMode = emoji.symbolRenderingMode
        self.isPlaceholder = false
    }
    
    init(placeholder emoji: any CustomEmoji, targetSize: CGSize) {
        self.isPlaceholder = true
        self.shortcode = "placeholder"
        self.renderingMode = emoji.renderingMode
        self.baselineOffset = emoji.baselineOffset
        self.symbolRenderingMode = emoji.symbolRenderingMode
        
        switch emoji {
        case let localEmoji as LocalEmoji:
            self._image = Image(emojiImage: localEmoji.image.scalePreservingAspectRatio(targetSize: targetSize))
        case let sfSymbolEmoji as SFSymbolEmoji:
            self._image = Image(systemName: sfSymbolEmoji.shortcode)
        default:
            self._image = Image(systemName: SFSymbolEmoji.placeholder.shortcode)
            Logger.emojiText.error("Unsupported CustomEmoji was used as placeholder. Only LocalEmoji and SFSymbolEmoji are supported. This is a bug. Please file a report at https://github.com/divadretlaw/EmojiText")
        }
    }
    
    var image: Image {
        _image.renderingMode(renderingMode).symbolRenderingMode(symbolRenderingMode)
    }
    
    // MARK: Hashable
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(shortcode)
        hasher.combine(isPlaceholder)
    }
    
    // MARK: Equatable
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        guard lhs.shortcode == rhs.shortcode, lhs.isPlaceholder == rhs.isPlaceholder else { return false }
        return lhs.image == rhs.image
    }
    
    // MARK: Identifiable
    
    var id: String { shortcode }
}
