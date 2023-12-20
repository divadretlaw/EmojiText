//
//  Text+Extensions.swift
//  EmojiText
//
//  Created by David Walter on 20.12.23.
//

import SwiftUI

extension Array where Element == Text {
    func joined() -> Text {
        guard let first = first else { return Text(verbatim: "") }
        var result = first
        for element in dropFirst() {
            result = result + element
        }
        return result
    }
}
