//
//  LocalEmoji.swift
//  EmojiText
//
//  Created by David Walter on 11.01.23.
//

import Foundation
import UIKit

public struct LocalEmoji: CustomEmoji {
    public let shortcode: String
    public let image: UIImage
    
    public func image(font: UIFont) -> UIImage {
        return image(height: font.capHeight)
    }
    
    public func image(height: CGFloat) -> UIImage {
        return image.scalePreservingAspectRatio(targetSize: CGSize(width: height, height: height))
    }
}
