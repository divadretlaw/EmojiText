//
//  UIFont+Extensions.swift
//  EmojiText
//
//  Created by David Walter on 11.01.23.
//

import SwiftUI
import UIKit

extension UIFont {
    static func preferredFont(from font: Font?, compatibleWith traitCollection: UITraitCollection? = nil) -> UIFont {
        guard let font = font else {
            return UIFont.preferredFont(forTextStyle: .body)
        }
        
        switch font {
        case .largeTitle:
            return UIFont.preferredFont(forTextStyle: .largeTitle, compatibleWith: traitCollection)
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
