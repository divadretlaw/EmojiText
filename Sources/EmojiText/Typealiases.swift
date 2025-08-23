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
public typealias EmojiFont = UIFont
/// Platform indepdendent color alias. Will be `UIColor`.
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
#elseif os(macOS)
import AppKit

/// Platform indepdendent image alias. Will be `NSImage`.
public typealias EmojiImage = NSImage
public typealias EmojiFont = NSFont
/// Platform indepdendent color alias. Will be `NSColor`.
public typealias EmojiColor = NSColor

extension EmojiColor {
    static var placeholderEmoji: EmojiColor {
        .placeholderTextColor
    }
}
#else
#error("Unsupported platform")
#endif
