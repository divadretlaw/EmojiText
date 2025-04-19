//
//  ContentView.swift
//  EmojiTextTest
//
//  Created by David Walter on 18.02.23.
//

import SwiftUI
import EmojiText

struct ContentView: View {
    var body: some View {
        #if os(macOS)
        list
        #else
        TabView {
            list
            about
        }
        #endif
    }
    
    var list: some View {
        NavigationStack {
            Form {
                Section {
                    NavigationLink {
                        RemoteEmojiView()
                    } label: {
                        Text("Remote Emoji")
                    }
                    
                    NavigationLink {
                        ChangingRemoteEmojiView()
                    } label: {
                        Text("Changing Remote Emoji")
                    }
                    
                    NavigationLink {
                        SFSymbolEmojiView()
                    } label: {
                        Text("SF Symbol Emoji")
                    }
                    
                    NavigationLink {
                        LocalEmojiView()
                    } label: {
                        Text("Local Emoji")
                    }
                    
                    NavigationLink {
                        AnimatedEmojiView()
                    } label: {
                        Text("Animated Emoji")
                    }
                } header: {
                    Text("Simple")
                }
                
                Section {
                    NavigationLink {
                        MastodonView(statusId: "111773699547425887")
                            .environment(MastodonAPI(host: "https://universeodon.com"))
                    } label: {
                        Text("Test Status")
                    }
                    
                    NavigationLink {
                        MastodonView(statusId: "111572969777556029")
                            .environment(MastodonAPI(host: "https://mastodon.de"))
                    } label: {
                        Text("Lots of Emoji-Test")
                    }
                    
                    NavigationLink {
                        MastodonView(statusId: "111324359951561858")
                            .environment(MastodonAPI(host: "https://tapbots.social"))
                    } label: {
                        Text("Emoji & Link")
                    }
                } header: {
                    Text("Mastodon")
                }
                
                Section {
                    NavigationLink {
                        RemoteEmojiView()
                            .environment(\.emojiText.asyncEmojiProvider, NukeEmojiProvider())
                    } label: {
                        Text("Remote Emoji")
                    }
                    NavigationLink {
                        LocalEmojiView()
                            .environment(\.emojiText.syncEmojiProvider, UpsideDownEmojiProvider())
                    } label: {
                        Text("Local Emoji")
                    }
                } header: {
                    Text("Custom Emoji Provider")
                }
            }
            .navigationTitle("EmojiText")
        }
        .formStyle(.grouped)
        .tag(0)
        .tabItem {
            Label("Emojis", systemImage: "face.smiling")
        }
    }
    
    var about: some View {
        NavigationStack {
            List {
                Text("Testing app for snapshot tests and quick debbugging")
            }
            .navigationTitle("About")
        }
        .tag(1)
        .tabItem {
            Label("About", systemImage: "info.circle")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
