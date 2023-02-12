//
//  Image+Extensions.swift
//  EmojiText
//
//  Created by David Walter on 11.01.23.
//

import SwiftUI

extension Image {
    init(emojiImage: EmojiImage) {
        #if os(iOS) || targetEnvironment(macCatalyst) || os(tvOS) || os(watchOS)
        self.init(uiImage: emojiImage)
        #else
        self.init(nsImage: emojiImage)
        #endif
    }
}

#if os(iOS) || targetEnvironment(macCatalyst) || os(tvOS) || os(watchOS)
import UIKit

extension UIImage {
    func scalePreservingAspectRatio(targetSize: CGSize) -> UIImage {
        // Determine the scale factor that preserves aspect ratio
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        
        let scaleFactor = min(widthRatio, heightRatio)
        
        // Compute the new image size that preserves aspect ratio
        let scaledImageSize = CGSize(
            width: size.width * scaleFactor,
            height: size.height * scaleFactor
        )
        
        #if os(watchOS)
        UIGraphicsBeginImageContextWithOptions(scaledImageSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        
        // Draw and return the resized UIImage
        self.draw(in: CGRect(
            origin: .zero,
            size: scaledImageSize
        ))

        return UIGraphicsGetImageFromCurrentImageContext() ?? self
        #else
        // Draw and return the resized UIImage
        let renderer = UIGraphicsImageRenderer(
            size: scaledImageSize
        )
        
        let scaledImage = renderer.image { _ in
            self.draw(in: CGRect(
                origin: .zero,
                size: scaledImageSize
            ))
        }
        
        return scaledImage
        #endif
    }
}
#endif

#if os(macOS)
import AppKit

extension NSImage {
    convenience init?(systemName: String) {
        self.init(systemSymbolName: systemName, accessibilityDescription: systemName)
    }
    
    func scalePreservingAspectRatio(targetSize: CGSize) -> NSImage {
        // Determine the scale factor that preserves aspect ratio
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        
        let scaleFactor = min(widthRatio, heightRatio)
        
        // Compute the new image size that preserves aspect ratio
        let scaledImageSize = CGSize(
            width: size.width * scaleFactor,
            height: size.height * scaleFactor
        )
        
        let scaledImage = NSImage(size: targetSize, flipped: false) { rect in
            self.draw(in: rect)
            return true
        }
        
        return scaledImage
    }
}
#endif
