//
//  String+Extensions.swift
//  EmojiText
//
//  Created by David Walter on 11.01.23.
//

import Foundation

extension String {
    static var emojiScheme: String {
        "custom-emoji"
    }
    
    static var emojiSeparator: String {
        "<custom_emoji_break/>"
    }
    
    /// Split the text on the injected emoji separator
    ///
    /// - Parameter omittingSpacesBetweenEmojis: Remove any spaces between emojis. Defaults to `true`,
    /// - Returns: The split text with every emoji separated
    func splitOnEmoji(omittingSpacesBetweenEmojis: Bool = true) -> [String] {
        let splits: [String]
        if #available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *) {
            splits = self
                .split(separator: String.emojiSeparator, omittingEmptySubsequences: true)
                .map { String($0) }
        } else {
            splits = components(separatedBy: String.emojiSeparator)
                .filter { !$0.isEmpty }
        }
        
        if omittingSpacesBetweenEmojis {
            // Remove any spaces between emojis
            // This will often drastically reduce the amount of text contactenations
            // needed when rendering the emojis. If we reach around ~500 or more the render would crash
            return splits.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        } else {
            return splits
        }
    }
}
