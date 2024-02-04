//
//  Typealiases.swift
//  EmojiText
//
//  Created by David Walter on 12.02.23.
//

import Foundation

#if os(iOS) || targetEnvironment(macCatalyst) || os(tvOS) || os(watchOS) || os(visionOS)
import UIKit

/// Platform indepdendent image alias. Will be `UIImage`.
public typealias EmojiImage = UIImage
typealias EmojiFont = UIFont
public typealias EmojiColor = UIColor

extension EmojiColor {
    static var placeholderEmoji: EmojiColor {
        #if os(watchOS)
        .gray
        #else
        .placeholderText
        #endif
    }
}
#endif

#if os(macOS)
import AppKit

/// Platform indepdendent image alias. Will be `NSImage`.
public typealias EmojiImage = NSImage
typealias EmojiFont = NSFont
public typealias EmojiColor = NSColor

extension EmojiColor {
    static var placeholderEmoji: EmojiColor {
        .placeholderTextColor
    }
}
#endif
