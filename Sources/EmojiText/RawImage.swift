//
//  RenderedImage.swift
//  EmojiImage
//
//  Created by David Walter on 15.08.23.
//

import SwiftUI

struct RenderedImage: Hashable, Equatable {
    private var systemName: String?
    private var platformImage: EmojiImage?
    private var animationImages: [EmojiImage]?
    private var duration: TimeInterval
    
    init(image: EmojiImage, animated: Bool, targetHeight: CGFloat) {
        self.systemName = nil
        self.platformImage = image.scalePreservingAspectRatio(targetHeight: targetHeight)
        #if os(iOS) || targetEnvironment(macCatalyst) || os(tvOS) || os(watchOS)
        if animated {
            self.animationImages = image.images?.map { $0.scalePreservingAspectRatio(targetHeight: targetHeight) }
        } else {
            self.animationImages = nil
        }
        self.duration = image.duration
        #else
        self.animationImages = nil
        self.duration = 0
        #endif
    }
    
    init(image: RawImage, animated: Bool, targetHeight: CGFloat) {
        self.systemName = nil
        self.platformImage = image.static.scalePreservingAspectRatio(targetHeight: targetHeight)
        if animated {
            self.animationImages = image.frames?.map { $0.scalePreservingAspectRatio(targetHeight: targetHeight) }
        } else {
            self.animationImages = nil
        }
        self.duration = image.duration
    }
    
    init(systemName: String) {
        self.systemName = systemName
        self.platformImage = nil
        self.animationImages = nil
        self.duration = 0
    }
    
    var image: Image {
        if let systemName = systemName {
            return Image(systemName: systemName)
        } else if let image = platformImage {
            return Image(emojiImage: image)
        } else {
            return Image(emojiImage: EmojiImage())
        }
    }
    
    var isAnimated: Bool {
        guard let animationImages = animationImages else { return false }
        return !animationImages.isEmpty && duration > 0
    }
    
    func frame(at time: CFTimeInterval) -> Image {
        guard isAnimated, let rawImages = animationImages else { return image }
        
        let count = TimeInterval(rawImages.count)
        let fps = count / duration
        let totalFps = time * fps
        
        let frame = totalFps.truncatingRemainder(dividingBy: count)
        let index = Int(frame)
        
        return Image(emojiImage: rawImages[index])
    }
    
    // MARK: - Hashable
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(systemName)
        hasher.combine(platformImage)
        hasher.combine(animationImages)
        hasher.combine(duration)
    }
}
