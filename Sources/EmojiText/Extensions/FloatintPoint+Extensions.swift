//
//  FloatingPoint+Extensions.swift
//  EmojiText
//
//  Created by David Walter on 14.12.23.
//

import Foundation

extension FloatingPoint {
    func isAlmostEqual(
        to other: Self,
        tolerance: Self = Self.ulpOfOne.squareRoot()
    ) -> Bool {
        guard self.isFinite, other.isFinite else {
            return false
        }
        
        let scale = max(abs(self), abs(other), .leastNormalMagnitude)
        return abs(self - other) < scale * tolerance
    }
}
