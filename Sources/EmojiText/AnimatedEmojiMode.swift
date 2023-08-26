//
//  AnimatedEmojiMode.swift
//  EmojiText
//
//  Created by David Walter on 26.08.23.
//

import Foundation
import SwiftUI

public enum AnimatedEmojiMode {
    /// Never play animated emoji
    case never
    /// Disable animated emoji when device is in low-power mode
    case disabledOnLowPower
    /// Always play animated emoji
    case always
    
    var disabledOnLowPower: Bool {
        switch self {
        case .never:
            return true
        case .disabledOnLowPower:
            return true
        case .always:
            return false
        }
    }
}
