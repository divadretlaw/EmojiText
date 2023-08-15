//
//  Typealiases.swift
//  EmojiText
//
//  Created by David Walter on 12.02.23.
//

import Foundation

#if os(iOS) || targetEnvironment(macCatalyst) || os(tvOS) || os(watchOS)
import UIKit

/// Platform indepdendent image alias. Will be `UIImage`.
public typealias EmojiImage = UIImage
typealias EmojiFont = UIFont
#endif

#if os(macOS)
import AppKit

/// Platform indepdendent image alias. Will be `NSImage`.
public typealias EmojiImage = NSImage
typealias EmojiFont = NSFont
#endif
