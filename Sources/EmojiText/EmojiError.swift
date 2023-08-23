//
//  EmojiError.swift
//  EmojiText
//
//  Created by David Walter on 15.08.23.
//

import Foundation

enum EmojiError: Error {
    /// The image data was corrupted.
    case data
    /// An internal error occured.
    case `internal`
    /// The given image type is either not animated or in an unknown format.
    case notAnimated
}
