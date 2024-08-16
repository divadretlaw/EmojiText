//
//  Lock.swift
//  EmojiText
//
//  Created by David Walter on 16.08.24.
//

import Foundation

final class Lock<T>: @unchecked Sendable {
    private var _value: T
    private let lock: NSLocking
    
    init(_ image: T, lock: NSLocking = NSLock()) {
        self._value = image
        self.lock = lock
    }
    
    var wrappedValue: T {
        get {
            lock.withLock { _value }
        }
        set {
            lock.withLock { _value = newValue }
        }
    }
}
