//
//  Integer+Extensions.swift
//  EmojiText
//
//  Created by David Walter on 15.08.23.
//

import Foundation

/// Returns the greatest common divisor of the given numbers.
///
/// - Parameters:
///     - x: A signed number.
///     - y: A signed number.
/// - Returns: The greatest common divisor between `x` and `y`.
@inlinable func gcd<T>(_ x: T, _ y: T) -> T where T : Comparable, T: SignedInteger {
    let remainder = abs(x) % abs(y)
    if remainder != 0 {
        return gcd(abs(y), remainder)
    } else {
        return abs(y)
    }
}
