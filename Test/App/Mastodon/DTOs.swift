//
//  Status.swift
//  EmojiTextTest
//
//  Created by David Walter on 14.12.23.
//

import Foundation

struct Status: Codable, Equatable {
    let id: String
    
    let content: String
    let account: Account
    
    let emojis: [Emoji]
}

struct Account: Codable, Equatable {
    let id: String
    
    let username: String
    let displayName: String
    
    let emojis: [Emoji]
}

struct Emoji: Codable, Equatable {
    let shortcode: String
    let url: URL
}
