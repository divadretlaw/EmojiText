//
//  NSAttributedString+Extensions.swift
//  EmojiText
//
//  Created by David Walter on 15.08.25.
//

import Foundation
import SwiftUI

extension NSAttributedString {
    var range: NSRange {
        NSRange(location: 0, length: length)
    }

    convenience init(_ emoji: LoadedEmoji, size: CGFloat?) {
        let attachment = NSTextAttachment()
        attachment.image = emoji.emojiImage

        let text = NSMutableAttributedString()
        text.append(NSAttributedString("\u{200B}"))
        text.append(NSAttributedString(attachment: attachment))
        text.append(NSAttributedString("\u{200B}"))

        if let baselineOffset = emoji.baselineOffset {
            text.addAttribute(.baselineOffset, value: baselineOffset)
        }

        if let size {
            text.addAttribute(.font, value: EmojiFont.systemFont(ofSize: size))
        }

        self.init(attributedString: text)
    }
}

extension NSMutableAttributedString {
    func addAttribute(_ name: NSAttributedString.Key, value: Any) {
        addAttribute(name, value: value, range: range)
    }

    func addAttributes(_ attributes: [NSAttributedString.Key: Any]) {
        addAttributes(attributes, range: range)
    }

    func enumerateAttribute(_ attrName: NSAttributedString.Key, options opts: NSAttributedString.EnumerationOptions = [], using block: (Any?, NSRange, UnsafeMutablePointer<ObjCBool>) -> Void) {
        enumerateAttribute(attrName, in: range, options: opts, using: block)
    }
}
