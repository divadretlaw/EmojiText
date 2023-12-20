//
//  String+Extensions.swift
//  EmojiText
//
//  Created by David Walter on 11.01.23.
//

import Foundation

extension String {
    static var emojiSeparator: String {
        "<custom_emoji_break/>"
    }
    
    /// Split the text on the inserted emoji separator
    /// - Parameter omittingSpacesBetweenEmojis: Remove any spaces between emojis. Defaults to `true`,
    /// - Returns: The split text with every emoji separated
    ///
    /// Consider removing spaces between emojis as this will often drastically reduce
    /// the amount of text contactenations needed to render the emojis.
    ///
    /// There is a limit in SwiftUI Text concatenations and if this limit is reached the application will crash.
    func splitOnEmoji(omittingSpacesBetweenEmojis: Bool = true) -> [String] {
        let splits: [String]
        if #available(iOS 16, macOS 13, tvOS 16, watchOS 9, *) {
            splits = self
                .split(separator: String.emojiSeparator, omittingEmptySubsequences: true)
                .map { String($0) }
        } else {
            splits = self
                .components(separatedBy: String.emojiSeparator)
        }
        
        if omittingSpacesBetweenEmojis {
            // Remove any spaces between emojis
            // This will often drastically reduce the amount of text contactenations
            // needed when rendering the emojis. If we reach around ~500 or more the render would crash
            return splits.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        } else{
            return splits
        }
    }
}
