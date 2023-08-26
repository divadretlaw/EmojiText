//
//  EmojiImage+Extensions.swift
//  EmojiImage
//
//  Created by David Walter on 14.08.23.
//

import Foundation
import ImageIO
import OSLog

extension EmojiImage {
    static func from(data: Data) throws -> RawImage {
        do {
            guard let type = AnimatedImageType(from: data) else {
                throw EmojiError.notAnimated
            }
            
            guard let source = CGImageSourceCreateWithData(data as CFData, nil), source.containsAnimatedKeys(for: type) else {
                throw EmojiError.animatedData
            }
            
            if let image = animatedImage(from: source, type: type) {
                return image
            } else {
                throw EmojiError.animatedData
            }
        } catch {
            // In case an error occurs while loading the animated image
            // we fall back to a static image
            if let image = EmojiImage(data: data) {
                return RawImage(image: image)
            } else {
                Logger.animatedImage.warning("Unable to decode animated image: \(error.localizedDescription).")
                throw EmojiError.staticData
            }
        }
    }
}
