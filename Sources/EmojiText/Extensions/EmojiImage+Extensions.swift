//
//  EmojiImage+Extensions.swift
//  EmojiImage
//
//  Created by David Walter on 14.08.23.
//

import Foundation
import ImageIO

extension EmojiImage {
    static func from(data: Data) throws -> EmojiImage {
        #if os(iOS) || targetEnvironment(macCatalyst) || os(tvOS) || os(watchOS)
        do {
            guard let type = AnimatedImageType(from: data) else {
                throw EmojiError.unknownAnimatedImageType
            }
            
            guard let source = CGImageSourceCreateWithData(data as CFData, nil), source.containsAnimatedKeys(for: type) else {
                throw EmojiError.internal
            }
            
            if let image = UIImage.animatedImage(from: source, type: type) {
                return image
            } else {
                throw EmojiError.internal
            }
        } catch {
            if let image = EmojiImage(data: data) {
                return image
            } else {
                throw EmojiError.data
            }
        }
        #else
        if let image = EmojiImage(data: data) {
            return image
        } else {
            throw EmojiError.data
        }
        #endif
    }
    
    private static func fallback(data: Data) throws -> EmojiImage {
        return EmojiImage(data: data)!
    }
}

#if canImport(UIKit)
import UIKit

extension UIImage {
    static func animatedImage(from source: CGImageSource, type: AnimatedImageType) -> UIImage? {
        let count = CGImageSourceGetCount(source)
        var images: [CGImage] = []
        var delays: [Int] = []
        
        for i in 0..<count {
            if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
                images.append(image)
            }
            
            let delayInSeconds = max(source.delay(for: i, type: type), 0.1)
            delays.append(Int(delayInSeconds * 1000.0))
        }
        
        let duration = delays.reduce(0) { partialResult, value in
            return partialResult + value
        }
        
        let divisor = delays.reduce(0) { gcd($0, $1) }
        var frames = [UIImage]()
        
        for index in 0..<count {
            let frame = UIImage(cgImage: images[index])
            let frameCount = delays[index] / divisor
            
            for _ in 0..<frameCount {
                frames.append(frame)
            }
        }
        
        let animation = UIImage.animatedImage(with: frames,
                                              duration: TimeInterval(duration) / 1000.0)
        
        return animation
    }
}

extension CGImageSource {
    func properties(for index: Int, key: CFString) -> CFDictionary! {
        let cfProperties = CGImageSourceCopyPropertiesAtIndex(self, index, nil)
        let key = Unmanaged.passUnretained(key).toOpaque()
        return unsafeBitCast(CFDictionaryGetValue(cfProperties, key), to: CFDictionary.self)
    }
    
    func delay(for index: Int, type: AnimatedImageType) -> Double {
        let properties = self.properties(for: index, key: type.propertiesKey)
        
        let unclampedDelayTimeKey = Unmanaged.passUnretained(type.unclampedDelayTimeKey).toOpaque()
        var delayObject: AnyObject = unsafeBitCast(CFDictionaryGetValue(properties, unclampedDelayTimeKey),
                                                   to: AnyObject.self)
        
        if let value = delayObject.doubleValue, value > 0 {
            return value
        } else {
            let delayTimeKey = Unmanaged.passUnretained(type.delayTimeKey).toOpaque()
            delayObject = unsafeBitCast(CFDictionaryGetValue(properties, delayTimeKey),
                                        to: AnyObject.self)
            return delayObject.doubleValue ?? 0
        }
    }
    
    func containsAnimatedKeys(for type: AnimatedImageType) -> Bool {
        let properties = self.properties(for: 0, key: type.propertiesKey)
        
        let unclampedDelayTimeKey = Unmanaged.passUnretained(type.unclampedDelayTimeKey).toOpaque()
        let delayTimeKey = Unmanaged.passUnretained(type.delayTimeKey).toOpaque()
        guard properties != nil, CFDictionaryContainsKey(properties, unclampedDelayTimeKey), CFDictionaryContainsKey(properties, delayTimeKey) else {
            return false
        }
        return true
    }
}
#endif
