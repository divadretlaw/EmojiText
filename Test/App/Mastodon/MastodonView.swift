//
//  MastodonView.swift
//  EmojiTextTest
//
//  Created by David Walter on 14.12.23.
//

import SwiftUI
import EmojiText
import Nuke

struct MastodonView: View {
    @Environment(MastodonAPI.self) private var api
    var statusId: String
    
    init(
        statusId: String
    ) {
        self.statusId = statusId
    }
    
    @State private var instanceEmojis: [Emoji] = []
    @State private var status: Status?
    @State private var uuid = UUID()
    
    @Environment(\.displayScale) private var displayScale
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    var body: some View {
        Form {
            if let status {
                VStack(alignment: .leading) {
                    EmojiText(markdown: "\(status.account.displayName)", emojis: status.customEmojis + customEmojis)
                        .font(.largeTitle)
                        .foregroundStyle(.primary)
                        .id(uuid)
                    Text("@\(status.account.username)")
                        .font(.title)
                        .foregroundStyle(.secondary)
                }
                EmojiText(markdown: status.text, emojis: status.customEmojis)
                    .animated()
                    .id(uuid)
            } else {
                ProgressView()
            }
            
            Section {
                LabeledContent("Display Scale", value: displayScale.description)
                
                Button {
                    uuid = UUID()
                } label: {
                    Text("Force re-render")
                }

            } header: {
                Text("Debug")
            }
        }
        .formStyle(.grouped)
        .animation(.default, value: status)
        .navigationTitle("Mastodon")
        .task {
            do {
                self.instanceEmojis = try await api.loadCustomEmoji()
                self.status = try await api.loadStatus(id: statusId)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    var customEmojis: [any CustomEmoji] {
        instanceEmojis.map { emoji in
            RemoteEmoji(shortcode: emoji.shortcode, url: emoji.url)
        }
    }
}

extension Status {
    var text: String {
        content
            .replacingOccurrences(of: "<p>", with: "")
            .replacingOccurrences(of: "</p>", with: "")
            .replacingOccurrences(of: "<strong>", with: "**")
            .replacingOccurrences(of: "</strong>", with: "**")
    }
    
    var customEmojis: [any CustomEmoji] {
        self.emojis.map { emoji in
            RemoteEmoji(shortcode: emoji.shortcode, url: emoji.url)
        }
    }
}

struct MastodonView_Previews: PreviewProvider {
    static var previews: some View {
        MastodonView(statusId: "111773699547425887")
            .environment(MastodonAPI(host: "https://universeodon.com"))
    }
}
