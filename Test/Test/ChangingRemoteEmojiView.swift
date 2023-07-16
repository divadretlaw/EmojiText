//
//  ChangingRemoteEmojiView.swift
//  EmojiTextTest
//
//  Created by David Walter on 16.07.23.
//

import SwiftUI
import EmojiText

struct ChangingRemoteEmojiView: View {
    @State private var emojis: [any CustomEmoji] = {
        [
            RemoteEmoji(shortcode: "custom", url: URL(string: "https://dummyimage.com/64x64/00f/fff&text=A")!)
        ]
    }()
    
    var body: some View {
        List {
            Section {
                EmojiText(verbatim: "Custom Emoji :custom:", emojis: emojis)
            }
            
            Section {
                Button {
                    self.emojis = [
                        RemoteEmoji(shortcode: "custom", url: URL(string: "https://dummyimage.com/64x64/00f/fff&text=A")!)
                    ]
                } label: {
                    Text("Set A")
                }
                
                Button {
                    self.emojis = [
                        RemoteEmoji(shortcode: "custom", url: URL(string: "https://dummyimage.com/64x64/f00/000&text=B")!)
                    ]
                } label: {
                    Text("Set B")
                }
            }
        }
        .navigationTitle("Changing Remote Emoji")
    }
}

struct ChangingRemoteEmojiView_Previews: PreviewProvider {
    static var previews: some View {
        ChangingRemoteEmojiView()
    }
}
