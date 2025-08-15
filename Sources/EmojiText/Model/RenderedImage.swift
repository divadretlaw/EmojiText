//
//  RenderedImage.swift
//  EmojiText
//
//  Created by David Walter on 15.08.23.
//

import SwiftUI

struct RenderedImage: Hashable, Equatable, @unchecked Sendable {
    private let systemName: String?
    private let platformImage: EmojiImage?
    private let animationImages: [EmojiImage]?
    private let duration: TimeInterval
    
    init(image: EmojiImage, animated: Bool, targetHeight: CGFloat) {
        self.systemName = nil
        self.platformImage = image.scalePreservingAspectRatio(targetHeight: targetHeight)
        #if os(iOS) || targetEnvironment(macCatalyst) || os(tvOS) || os(watchOS) || os(visionOS)
        if animated {
            self.animationImages = image.images?.map { $0.scalePreservingAspectRatio(targetHeight: targetHeight) }
        } else {
            self.animationImages = nil
        }
        self.duration = image.duration
        #else
        // No support for animated images on this platform
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

    var emojiImage: EmojiImage {
        if let systemName = systemName {
            return EmojiImage(systemName: systemName) ?? EmojiImage()
        } else if let image = platformImage {
            return image
        } else {
            return EmojiImage()
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
