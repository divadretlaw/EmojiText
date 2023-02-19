//
//  Text+Extensions.swift
//  EmojiText
//
//  Created by David Walter on 19.02.23.
//

import SwiftUI
import OSLog

extension Text {
    static var logger = Logger()
    
    init(markdown string: String) {
        do {
            let options = AttributedString.MarkdownParsingOptions(allowsExtendedAttributes: true,
                                                                  interpretedSyntax: .inlineOnlyPreservingWhitespace)
            self.init(try AttributedString(markdown: string, options: options))
        } catch {
            Logger.text.error("Unable to parse Markdown, falling back to raw string: \(error.localizedDescription)")
            self.init(AttributedString(stringLiteral: string))
        }
    }
}
