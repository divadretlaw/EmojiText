//
//  Set+Extensions.swift
//  EmojiText
//
//  Created by David Walter on 11.01.23.
//

import Foundation

extension Set {
    mutating func replace(_ member: Element) {
        if self.contains(member) {
            self.remove(member)
        }
        self.insert(member)
    }
}
