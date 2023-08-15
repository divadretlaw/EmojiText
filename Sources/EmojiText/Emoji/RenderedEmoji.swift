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
    
    private let rawImage: EmojiImage
    private let rawImages: [EmojiImage]?
    private let duration: TimeInterval
    private let sourceHash: Int
    private let placeholderId: UUID?
    
    init(from emoji: RemoteEmoji, image: EmojiImage, animated: Bool = false, targetHeight: CGFloat, baselineOffset: CGFloat? = nil) {
        self.shortcode = emoji.shortcode
        self.duration = image.duration
        self.rawImage = image.scalePreservingAspectRatio(targetHeight: targetHeight)
        if animated {
            self.rawImages = image.images?.map { $0.scalePreservingAspectRatio(targetHeight: targetHeight) }
        } else {
            self.rawImages = nil
        }
        self.renderingMode = emoji.renderingMode
        self.baselineOffset = emoji.baselineOffset ?? baselineOffset
        self.symbolRenderingMode = nil
        self.placeholderId = nil
        self.sourceHash = emoji.hashValue
    }
    
    init(from emoji: LocalEmoji, animated: Bool = false, targetHeight: CGFloat, baselineOffset: CGFloat? = nil) {
        self.shortcode = emoji.shortcode
        self.duration = emoji.image.duration
        self.rawImage = emoji.image.scalePreservingAspectRatio(targetHeight: targetHeight)
        if animated {
            self.rawImages = emoji.image.images?.map { $0.scalePreservingAspectRatio(targetHeight: targetHeight) }
        } else {
            self.rawImages = nil
        }
        self.renderingMode = emoji.renderingMode
        self.baselineOffset = emoji.baselineOffset ?? baselineOffset
        self.symbolRenderingMode = nil
        self.placeholderId = nil
        self.sourceHash = emoji.hashValue
    }
    
    init(from emoji: SFSymbolEmoji) {
        self.shortcode = emoji.shortcode
        self.duration = 0
        self.rawImage = EmojiImage(systemName: emoji.shortcode) ?? EmojiImage()
        self.rawImages = nil
        self.renderingMode = emoji.renderingMode
        self.baselineOffset = emoji.baselineOffset
        self.symbolRenderingMode = emoji.symbolRenderingMode
        self.placeholderId = nil
        self.sourceHash = emoji.hashValue
    }
    
    init(from emoji: any CustomEmoji, placeholder: any CustomEmoji, animated: Bool = false, targetHeight: CGFloat) {
        self.shortcode = "placeholder"
        self.duration = 0
        self.renderingMode = emoji.renderingMode
        self.baselineOffset = emoji.baselineOffset
        self.symbolRenderingMode = emoji.symbolRenderingMode
        self.placeholderId = UUID()
        self.sourceHash = emoji.hashValue
        
        switch placeholder {
        case let localEmoji as LocalEmoji:
            self.rawImage = localEmoji.image.scalePreservingAspectRatio(targetHeight: targetHeight)
            if animated {
                self.rawImages = [localEmoji.image.scalePreservingAspectRatio(targetHeight: targetHeight)]
            } else {
                self.rawImages = nil
            }
        case let sfSymbolEmoji as SFSymbolEmoji:
            self.rawImage = EmojiImage.from(emoji: sfSymbolEmoji)
            self.rawImages = nil
        default:
            self.rawImage = EmojiImage.from(emoji: .placeholder)
            self.rawImages = nil
            Logger.emojiText.error("Unsupported CustomEmoji was used as placeholder. Only LocalEmoji and SFSymbolEmoji are supported. This is a bug. Please file a report at https://github.com/divadretlaw/EmojiText")
        }
    }
    
    var isAnimated: Bool {
        guard let rawImages = rawImages else { return false }
        return !rawImages.isEmpty && duration > 0
    }
    
    var isPlaceholder: Bool {
        placeholderId != nil
    }
    
    var image: Image {
        Image(emojiImage: rawImage)
            .renderingMode(renderingMode)
            .symbolRenderingMode(symbolRenderingMode)
    }
    
    func frame(at date: Date) -> Image {
        guard isAnimated, let rawImages = rawImages else { return image }
        
        let count = TimeInterval(rawImages.count)
        let fps = count / duration
        let totalFps = date.timeIntervalSinceReferenceDate * fps
        
        let frame = totalFps.truncatingRemainder(dividingBy: count)
        let index = Int(frame)
        
        return Image(emojiImage: rawImages[index])
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
        return lhs.image == rhs.image
    }
    
    // MARK: - Identifiable
    
    var id: String { shortcode }
}
