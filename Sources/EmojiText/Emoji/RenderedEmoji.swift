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
    let shortcode: String
    let baselineOffset: CGFloat?
    let renderingMode: Image.TemplateRenderingMode?
    let symbolRenderingMode: SymbolRenderingMode?
    
    private let _image: Image
    private let sourceHash: Int
    private let placeholderId: UUID?
    
    init(from emoji: RemoteEmoji, image: EmojiImage, targetHeight: CGFloat, baselineOffset: CGFloat? = nil) {
        self.shortcode = emoji.shortcode
        self._image = Image(emojiImage: image.scalePreservingAspectRatio(targetHeight: targetHeight))
        self.renderingMode = emoji.renderingMode
        self.baselineOffset = emoji.baselineOffset ?? baselineOffset
        self.symbolRenderingMode = nil
        self.placeholderId = nil
        self.sourceHash = emoji.hashValue
    }
    
    init(from emoji: LocalEmoji, targetHeight: CGFloat, baselineOffset: CGFloat? = nil) {
        self.shortcode = emoji.shortcode
        self._image = Image(emojiImage: emoji.image.scalePreservingAspectRatio(targetHeight: targetHeight))
        self.renderingMode = emoji.renderingMode
        self.baselineOffset = emoji.baselineOffset ?? baselineOffset
        self.symbolRenderingMode = nil
        self.placeholderId = nil
        self.sourceHash = emoji.hashValue
    }
    
    init(from emoji: SFSymbolEmoji) {
        self.shortcode = emoji.shortcode
        self._image = Image(systemName: emoji.shortcode)
        self.renderingMode = emoji.renderingMode
        self.baselineOffset = emoji.baselineOffset
        self.symbolRenderingMode = emoji.symbolRenderingMode
        self.placeholderId = nil
        self.sourceHash = emoji.hashValue
    }
    
    init(placeholder emoji: any CustomEmoji, targetHeight: CGFloat) {
        self.placeholderId = UUID()
        self.shortcode = "placeholder"
        self.renderingMode = emoji.renderingMode
        self.baselineOffset = emoji.baselineOffset
        self.symbolRenderingMode = emoji.symbolRenderingMode
        self.sourceHash = emoji.hashValue
        
        switch emoji {
        case let localEmoji as LocalEmoji:
            self._image = Image(emojiImage: localEmoji.image.scalePreservingAspectRatio(targetHeight: targetHeight))
        case let sfSymbolEmoji as SFSymbolEmoji:
            self._image = Image(systemName: sfSymbolEmoji.shortcode)
        default:
            self._image = Image(systemName: SFSymbolEmoji.placeholder.shortcode)
            Logger.emojiText.error("Unsupported CustomEmoji was used as placeholder. Only LocalEmoji and SFSymbolEmoji are supported. This is a bug. Please file a report at https://github.com/divadretlaw/EmojiText")
        }
    }
    
    var isPlaceholder: Bool {
        placeholderId != nil
    }
    
    var image: Image {
        _image.renderingMode(renderingMode).symbolRenderingMode(symbolRenderingMode)
    }
    
    func hasSameSource(as value: RenderedEmoji) -> Bool {
        sourceHash == value.sourceHash
    }
    
    // MARK: - Hashable
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(shortcode)
        hasher.combine(baselineOffset)
        hasher.combine(renderingMode)
        hasher.combine(placeholderId)
        hasher.combine(sourceHash)
    }
    
    // MARK: - Equatable
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        guard lhs.shortcode == rhs.shortcode,
              lhs.baselineOffset == rhs.baselineOffset,
              lhs.renderingMode == rhs.renderingMode,
              lhs.sourceHash == rhs.sourceHash,
              lhs.isPlaceholder == rhs.isPlaceholder else { return false }
        return lhs.image == rhs.image
    }
    
    // MARK: - Identifiable
    
    var id: String { shortcode }
}
