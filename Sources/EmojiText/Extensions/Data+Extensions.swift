//
//  Data+Extensions.swift
//  EmojiText
//
//  Created by David Walter on 14.08.23.
//

import Foundation

extension Data {
    func readBytes(count: Int) -> [UInt8] {
        var bytes = [UInt8](repeating: 0, count: count)
        self.copyBytes(to: &bytes, count: count)
        return bytes
    }
}
