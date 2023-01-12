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
    
    var isPlaceholder = false
    
    public init(shortcode: String, image: UIImage) {
        self.shortcode = shortcode
        self.image = image
    }
    
    static func placeholder(for shortcode: String, image: UIImage? = nil) -> Self {
        var placeholder = LocalEmoji(shortcode: shortcode, image: image ?? UIImage(systemName: "square.dashed") ?? UIImage())
        placeholder.isPlaceholder = true
        return placeholder
    }
    
    func resized(targetSize: CGSize) -> Self {
        let image = image.scalePreservingAspectRatio(targetSize: targetSize)
        return LocalEmoji(shortcode: shortcode, image: image)
    }
    
    // MARK: Hashable
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(shortcode)
        hasher.combine(image)
        hasher.combine(isPlaceholder)
    }
    
    // MARK: Equatable
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        guard lhs.shortcode == rhs.shortcode, lhs.isPlaceholder == rhs.isPlaceholder else { return false }
        return lhs.image == rhs.image
    }
}
