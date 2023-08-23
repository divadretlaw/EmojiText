//
//  CGImageSource+Extensions.swift
//  EmojiText
//
//  Created by David Walter on 23.08.23.
//

import Foundation
import ImageIO

extension CGImageSource {
    func properties(for index: Int, key: CFString) -> CFDictionary? {
        guard let properties = CGImageSourceCopyPropertiesAtIndex(self, index, nil) else {
            return nil
        }
        
        let key = Unmanaged.passUnretained(key).toOpaque()
        return unsafeBitCast(CFDictionaryGetValue(properties, key), to: CFDictionary.self)
    }
    
    func delay(for index: Int, type: AnimatedImageType) -> Double {
        guard let properties = properties(for: index, key: type.propertiesKey) else {
            return 0
        }
        
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
        guard let properties = properties(for: 0, key: type.propertiesKey) else {
            return false
        }
        
        let unclampedDelayTimeKey = Unmanaged.passUnretained(type.unclampedDelayTimeKey).toOpaque()
        let delayTimeKey = Unmanaged.passUnretained(type.delayTimeKey).toOpaque()
        
        return CFDictionaryContainsKey(properties, unclampedDelayTimeKey)
        || CFDictionaryContainsKey(properties, delayTimeKey)
    }
}
