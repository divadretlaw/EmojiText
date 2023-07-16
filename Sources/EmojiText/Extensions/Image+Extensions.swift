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
    func scalePreservingAspectRatio(targetHeight: CGFloat) -> UIImage {
        let scaleFactor = targetHeight / size.height
        
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
        
        return renderer.image { _ in
            self.draw(in: CGRect(
                origin: .zero,
                size: scaledImageSize
            ))
        }
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
    
    func scalePreservingAspectRatio(targetHeight: CGFloat) -> NSImage {
        let scaleFactor = targetHeight / size.height
        
        // Compute the new image size that preserves aspect ratio
        let scaledImageSize = CGSize(
            width: size.width * scaleFactor,
            height: size.height * scaleFactor
        )
        
        return NSImage(size: scaledImageSize, flipped: false) { rect in
            self.draw(in: rect)
            return true
        }
    }
}
#endif
