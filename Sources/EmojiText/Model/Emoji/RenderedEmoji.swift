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
struct RenderedEmoji: Hashable, Equatable, Identifiable, Sendable {
    let shortcode: String
    let baselineOffset: CGFloat?
    let renderingMode: Image.TemplateRenderingMode?
    let symbolRenderingMode: SymbolRenderingMode?
    
    private let rawImage: RenderedImage
    private let sourceHash: Int
    private let placeholderId: UUID?
    
    init(from emoji: any CustomEmoji, image: RawImage, animated: Bool = false, targetHeight: CGFloat, baselineOffset: CGFloat? = nil) {
        self.shortcode = emoji.shortcode
        self.rawImage = RenderedImage(image: image, animated: animated, targetHeight: targetHeight)
        self.renderingMode = emoji.renderingMode
        self.baselineOffset = emoji.baselineOffset ?? baselineOffset
        self.symbolRenderingMode = nil
        self.placeholderId = nil
        // The source hash is the cominbed value of the emoji & target height
        var hasher = Hasher()
        hasher.combine(emoji)
        hasher.combine(targetHeight)
        self.sourceHash = hasher.finalize()
    }
    
    init(from emoji: LocalEmoji, animated: Bool = false, targetHeight: CGFloat, baselineOffset: CGFloat? = nil) {
        self.shortcode = emoji.shortcode
        self.rawImage = RenderedImage(image: emoji.image.withColor(emoji.color), animated: animated, targetHeight: targetHeight)
        self.renderingMode = emoji.renderingMode
        self.baselineOffset = emoji.baselineOffset ?? baselineOffset
        self.symbolRenderingMode = nil
        self.placeholderId = nil
        // The source hash is the cominbed value of the emoji & target height
        var hasher = Hasher()
        hasher.combine(emoji)
        hasher.combine(targetHeight)
        self.sourceHash = hasher.finalize()
    }
    
    init(from emoji: SFSymbolEmoji) {
        self.shortcode = emoji.shortcode
        self.rawImage = RenderedImage(systemName: emoji.shortcode)
        self.renderingMode = emoji.renderingMode
        self.baselineOffset = emoji.baselineOffset
        self.symbolRenderingMode = emoji.symbolRenderingMode
        self.placeholderId = nil
        self.sourceHash = emoji.hashValue
    }
    
    init(from emoji: any CustomEmoji, placeholder: any CustomEmoji, animated: Bool = false, targetHeight: CGFloat, baselineOffset: CGFloat? = nil) {
        self.shortcode = emoji.shortcode
        self.renderingMode = emoji.renderingMode
        self.baselineOffset = emoji.baselineOffset ?? baselineOffset
        self.symbolRenderingMode = emoji.symbolRenderingMode
        self.placeholderId = UUID()
        // The source hash is the cominbed value of the emoji & target height
        var hasher = Hasher()
        hasher.combine(emoji)
        hasher.combine(targetHeight)
        self.sourceHash = hasher.finalize()
        
        switch placeholder {
        case let localEmoji as LocalEmoji:
            self.rawImage = RenderedImage(image: localEmoji.image.withColor(localEmoji.color), animated: animated, targetHeight: targetHeight)
        case let sfSymbolEmoji as SFSymbolEmoji:
            self.rawImage = RenderedImage(systemName: sfSymbolEmoji.shortcode)
        default:
            self.rawImage = RenderedImage(systemName: SFSymbolEmoji.fallback.shortcode)
            Logger.emojiText.error("Unsupported CustomEmoji was used as placeholder. Only LocalEmoji and SFSymbolEmoji are supported. This is a bug. Please file a report at https://github.com/divadretlaw/EmojiText")
        }
    }
    
    var isPlaceholder: Bool {
        placeholderId != nil
    }
    
    var isAnimated: Bool {
        rawImage.isAnimated
    }
    
    var image: Image {
        rawImage.image
            .renderingMode(renderingMode)
            .symbolRenderingMode(symbolRenderingMode)
    }
    
    func frame(at time: CFTimeInterval) -> Image {
        rawImage.frame(at: time)
            .renderingMode(renderingMode)
            .symbolRenderingMode(symbolRenderingMode)
    }
    
    func hasSameSource(as value: RenderedEmoji) -> Bool {
        sourceHash == value.sourceHash
    }
    
    // MARK: - Hashable
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(shortcode)
        hasher.combine(placeholderId)
        hasher.combine(sourceHash)
    }
    
    // MARK: - Equatable
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        guard lhs.shortcode == rhs.shortcode,
              lhs.isPlaceholder == rhs.isPlaceholder else { return false }
        return lhs.rawImage == rhs.rawImage
    }
    
    // MARK: - Identifiable
    
    var id: String { shortcode }
}
