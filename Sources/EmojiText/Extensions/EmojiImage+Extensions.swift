//
//  EmojiImage+Extensions.swift
//  EmojiImage
//
//  Created by David Walter on 14.08.23.
//

import Foundation
import ImageIO

extension EmojiImage {
    static func from(data: Data) throws -> EmojiImage {
        do {
            guard let type = AnimatedImageType(from: data) else {
                throw EmojiError.notAnimated
            }
            
            guard let source = CGImageSourceCreateWithData(data as CFData, nil), source.containsAnimatedKeys(for: type) else {
                throw EmojiError.internal
            }
            
            if let image = animatedImage(from: source, type: type) {
                return image
            } else {
                throw EmojiError.internal
            }
        } catch {
            // In case an error occurs while loading the animated image
            // we fall back to a static image
            if let image = EmojiImage(data: data) {
                return image
            } else {
                throw EmojiError.data
            }
        }
    }
}
