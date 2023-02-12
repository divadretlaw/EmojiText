//
//  UIContentSizeCategory+Extensions.swift
//  EmojiText
//
//  Created by David Walter on 11.01.23.
//

import SwiftUI
#if canImport(UIKit)
import UIKit

extension UIContentSizeCategory {
    init(from value: DynamicTypeSize) {
        switch value {
        case .xSmall:
            self = .extraSmall
        case .small:
            self = .small
        case .medium:
            self = .medium
        case .large:
            self = .large
        case .xLarge:
            self = .extraLarge
        case .xxLarge:
            self = .extraExtraLarge
        case .xxxLarge:
            self = .extraExtraExtraLarge
        case .accessibility1:
            self = .accessibilityMedium
        case .accessibility2:
            self = .accessibilityLarge
        case .accessibility3:
            self = .accessibilityExtraLarge
        case .accessibility4:
            self = .accessibilityExtraExtraLarge
        case .accessibility5:
            self = .accessibilityExtraExtraExtraLarge
        @unknown default:
            self = .large
        }
    }
}
#endif
