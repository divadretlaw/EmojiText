//
//  UpsideDownEmojiProvider.swift
//  Test
//
//  Created by David Walter on 14.07.24.
//

import Foundation
import EmojiText
#if canImport(UIKit)
import UIKit
#endif

struct UpsideDownEmojiProvider: SyncEmojiProvider {
    func emojiImage(emoji: any SyncCustomEmoji, height: CGFloat?) -> EmojiImage? {
        switch emoji {
        case let emoji as LocalEmoji:
            #if canImport(UIKit)
            return emoji.image.upsideDown()
            #else
            return emoji.image
            #endif
        default:
            return nil
        }
    }
}

#if canImport(UIKit)
private extension UIImage {
    func upsideDown() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        context.translateBy(x: size.width / 2, y: size.height / 2)
        context.scaleBy(x: 1.0, y: -1.0)
        context.translateBy(x: -size.width / 2, y: -size.height / 2)
        
        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}
#endif
