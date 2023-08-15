//
//  AnimatedImageType.swift
//  EmojiImage
//
//  Created by David Walter on 15.08.23.
//

import Foundation
import ImageIO

enum AnimatedImageType: CaseIterable, Sendable {
    case gif
    case apng
    case webp
    
    init?(from data: Data) {
        let magicType = Self.allCases.first {
            let magicBytes = $0.magicBytes
            return data.readBytes(count: magicBytes.count) == magicBytes
        }
        guard let type = magicType else { return nil }
        self = type
    }
    
    var magicBytes: [UInt8] {
        switch self {
        case .gif:
            return [0x47, 0x49, 0x46]
        case .apng:
            return [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]
        case .webp:
            return [0x52, 0x49, 0x46, 0x46]
        }
    }
    
    var propertiesKey: CFString {
        switch self {
        case .gif:
            return kCGImagePropertyGIFDictionary
        case .apng:
            return kCGImagePropertyPNGDictionary
        case .webp:
            return kCGImagePropertyWebPDictionary
        }
    }
    
    var checkKey: CFString {
        switch self {
        case .gif:
            return kCGImagePropertyGIFLoopCount
        case .apng:
            return kCGImagePropertyGIFLoopCount
        case .webp:
            return kCGImagePropertyGIFLoopCount
        }
    }
    
    var delayTimeKey: CFString {
        switch self {
        case .gif:
            return kCGImagePropertyGIFDelayTime
        case .apng:
            return kCGImagePropertyAPNGDelayTime
        case .webp:
            return kCGImagePropertyWebPDelayTime
        }
    }
    
    var unclampedDelayTimeKey: CFString {
        switch self {
        case .gif:
            return kCGImagePropertyGIFUnclampedDelayTime
        case .apng:
            return kCGImagePropertyAPNGUnclampedDelayTime
        case .webp:
            return kCGImagePropertyWebPUnclampedDelayTime
        }
    }
}
