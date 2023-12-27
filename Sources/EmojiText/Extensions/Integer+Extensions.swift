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
@inlinable func gcd<T>(_ rhs: T, _ lhs: T) -> T where T: Comparable, T: SignedInteger {
    let remainder = abs(rhs) % abs(lhs)
    if remainder != 0 {
        return gcd(abs(lhs), remainder)
    } else {
        return abs(lhs)
    }
}
