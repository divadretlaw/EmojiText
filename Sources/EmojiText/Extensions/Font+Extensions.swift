//
//  Font+Extensions.swift
//  EmojiText
//
//  Created by David Walter on 11.01.23.
//

import SwiftUI

#if os(iOS) || targetEnvironment(macCatalyst) || os(tvOS)
import UIKit

extension UIFont {
    static func preferredFont(from font: Font?, compatibleWith traitCollection: UITraitCollection? = nil) -> UIFont {
        guard let font = font else {
            return UIFont.preferredFont(forTextStyle: .body)
        }
        
        switch font {
        case .largeTitle:
            #if os(tvOS)
            return UIFont.preferredFont(forTextStyle: .title1, compatibleWith: traitCollection)
            #else
            return UIFont.preferredFont(forTextStyle: .largeTitle, compatibleWith: traitCollection)
            #endif
        case .title:
            return UIFont.preferredFont(forTextStyle: .title1, compatibleWith: traitCollection)
        case .title2:
            return UIFont.preferredFont(forTextStyle: .title2, compatibleWith: traitCollection)
        case .title3:
            return UIFont.preferredFont(forTextStyle: .title3, compatibleWith: traitCollection)
        case .headline:
            return UIFont.preferredFont(forTextStyle: .headline, compatibleWith: traitCollection)
        case .subheadline:
            return UIFont.preferredFont(forTextStyle: .subheadline, compatibleWith: traitCollection)
        case .callout:
            return UIFont.preferredFont(forTextStyle: .callout, compatibleWith: traitCollection)
        case .caption:
            return UIFont.preferredFont(forTextStyle: .caption1, compatibleWith: traitCollection)
        case .caption2:
            return UIFont.preferredFont(forTextStyle: .caption2, compatibleWith: traitCollection)
        case .footnote:
            return UIFont.preferredFont(forTextStyle: .footnote, compatibleWith: traitCollection)
        case .body:
            fallthrough
        default:
            return UIFont.preferredFont(forTextStyle: .body, compatibleWith: traitCollection)
        }
    }
    
    static func preferredFont(from font: Font?, for dynamicTypeSize: DynamicTypeSize) -> UIFont {
        let traitCollection = UITraitCollection(preferredContentSizeCategory: UIContentSizeCategory(from: dynamicTypeSize))
        return UIFont.preferredFont(from: font, compatibleWith: traitCollection)
    }
}
#endif

#if os(watchOS)
import UIKit

extension UIFont {
    static func preferredFont(from font: Font?) -> UIFont {
        guard let font = font else {
            return UIFont.preferredFont(forTextStyle: .body)
        }
        
        switch font {
        case .largeTitle:
            return UIFont.preferredFont(forTextStyle: .largeTitle)
        case .title:
            return UIFont.preferredFont(forTextStyle: .title1)
        case .title2:
            return UIFont.preferredFont(forTextStyle: .title2)
        case .title3:
            return UIFont.preferredFont(forTextStyle: .title3)
        case .headline:
            return UIFont.preferredFont(forTextStyle: .headline)
        case .subheadline:
            return UIFont.preferredFont(forTextStyle: .subheadline)
        case .callout:
            return UIFont.preferredFont(forTextStyle: .callout)
        case .caption:
            return UIFont.preferredFont(forTextStyle: .caption1)
        case .caption2:
            return UIFont.preferredFont(forTextStyle: .caption2)
        case .footnote:
            return UIFont.preferredFont(forTextStyle: .footnote)
        case .body:
            fallthrough
        default:
            return UIFont.preferredFont(forTextStyle: .body)
        }
    }
    
    static func preferredFont(from font: Font?, for dynamicTypeSize: DynamicTypeSize) -> UIFont {
        UIFont.preferredFont(from: font)
    }
}
#endif

#if os(macOS)
import AppKit

extension NSFont {
    static func preferredFont(from font: Font?, for dynamicTypeSize: DynamicTypeSize) -> NSFont {
        guard let font = font else {
            return NSFont.preferredFont(forTextStyle: .body)
        }
        
        switch font {
        case .largeTitle:
            return NSFont.preferredFont(forTextStyle: .largeTitle)
        case .title:
            return NSFont.preferredFont(forTextStyle: .title1)
        case .title2:
            return NSFont.preferredFont(forTextStyle: .title2)
        case .title3:
            return NSFont.preferredFont(forTextStyle: .title3)
        case .headline:
            return NSFont.preferredFont(forTextStyle: .headline)
        case .subheadline:
            return NSFont.preferredFont(forTextStyle: .subheadline)
        case .callout:
            return NSFont.preferredFont(forTextStyle: .callout)
        case .caption:
            return NSFont.preferredFont(forTextStyle: .caption1)
        case .caption2:
            return NSFont.preferredFont(forTextStyle: .caption2)
        case .footnote:
            return NSFont.preferredFont(forTextStyle: .footnote)
        case .body:
            fallthrough
        default:
            return NSFont.preferredFont(forTextStyle: .body)
        }
    }
}
#endif
