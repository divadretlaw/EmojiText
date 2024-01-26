//
//  MastodonAPI.swift
//  EmojiTextTest
//
//  Created by David Walter on 14.12.23.
//

import Foundation
import Observation

@Observable
final class MastodonAPI {
    private let baseURL: URL
    private let decoder: JSONDecoder
    
    init(host: String) {
        baseURL = URL(string: host)!
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.decoder = decoder
    }
    
    func loadStatus(id: String) async throws -> Status {
        let url = URL(string: "api/v1/statuses/\(id)", relativeTo: baseURL)!
        let (data, _) = try await URLSession.shared.data(from: url)
        let status = try decoder.decode(Status.self, from: data)
        return status
    }
    
    func loadCustomEmoji() async throws -> [Emoji] {
        let url = URL(string: "/api/v1/custom_emojis", relativeTo: baseURL)!
        let (data, _) = try await URLSession.shared.data(from: url)
        let status = try decoder.decode([Emoji].self, from: data)
        return status
    }
}
