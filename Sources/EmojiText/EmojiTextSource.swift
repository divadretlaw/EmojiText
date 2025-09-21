//
//  EmojiTextSource.swift
//  EmojiText
//
//  Created by David Walter on 21.09.25.
//

import Foundation

enum EmojiTextSource {
    case string(String)
    case attributedString(AttributedString)
    case nsAttributedString(NSAttributedString)
}
