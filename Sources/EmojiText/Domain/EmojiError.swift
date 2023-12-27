//
//  EmojiError.swift
//  EmojiText
//
//  Created by David Walter on 15.08.23.
//

import Foundation

/// Internal errors for loading images
internal enum EmojiError: LocalizedError {
    /// The static fallback data was corrupted.
    case staticData
    /// The animated image data was corrupted.
    case animatedData
    /// The given image type is either not animated or in an unknown format.
    case notAnimated
    
    var errorDescription: String? {
        switch self {
        case .staticData:
            return "The static fallback image could not be read"
        case .animatedData:
            return "The animated image data could not be read"
        case .notAnimated:
            return "The provided image is not animated or in an unknown format"
        }
    }
}
