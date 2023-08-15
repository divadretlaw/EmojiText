//
//  Integer+Extensions.swift
//  EmojiText
//
//  Created by David Walter on 15.08.23.
//

import Foundation

@inlinable public func gcd<T>(_ a: T, _ b: T) -> T where T : Comparable, T: SignedInteger {
    let remainder = abs(a) % abs(b)
    if remainder != 0 {
        return gcd(abs(b), remainder)
    } else {
        return abs(b)
    }
}
