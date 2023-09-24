//
//  CGImageSource+Extensions.swift
//  EmojiText
//
//  Created by David Walter on 23.08.23.
//

import Foundation
import ImageIO

extension CGImageSource {
    func properties(for index: Int, key: CFString) -> [String: Any]? {
        guard let properties = CGImageSourceCopyPropertiesAtIndex(self, index, nil) as? [String: Any] else {
            return nil
        }
        
        return properties[key as String] as? [String: Any]
    }
    
    func delay(for index: Int, type: AnimatedImageType) -> Double {
        guard let properties = properties(for: index, key: type.propertiesKey) else {
            return 0
        }
        
        guard let delayObject: AnyObject = properties[type.unclampedDelayTimeKey as String] as? AnyObject,
              let value = delayObject.doubleValue,
              value > 0 else {
            return (properties[type.delayTimeKey as String] as? AnyObject)?.doubleValue ?? 0
        }
        
        return value
    }
    
    func containsAnimatedKeys(for type: AnimatedImageType) -> Bool {
        guard let properties = properties(for: 0, key: type.propertiesKey) else {
            return false
        }
        
        return properties.keys.contains(type.unclampedDelayTimeKey as String)
        || properties.keys.contains(type.delayTimeKey as String)
    }
}
