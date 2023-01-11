//
//  LocalEmoji.swift
//  EmojiText
//
//  Created by David Walter on 11.01.23.
//

import Foundation
import UIKit

/// A local custom emoji
public struct LocalEmoji: CustomEmoji {
    /// Shortcode of the emoji
    public let shortcode: String
    /// The image representing the emoji
    public let image: UIImage
    
    public init(shortcode: String, image: UIImage) {
        self.shortcode = shortcode
        self.image = image
    }
    
    /// Scale emoji using `font`
    ///
    /// - Parameter font: The `UIFont` used to scale the emoji
    public func image(font: UIFont) -> UIImage {
        return image(height: font.capHeight + abs(font.descender))
    }
    
    /// Scale emoji using height
    ///
    /// - Parameter height: The height of the emoji
    public func image(height: CGFloat) -> UIImage {
        return image.scalePreservingAspectRatio(targetSize: CGSize(width: height, height: height))
    }
}
