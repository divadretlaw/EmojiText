//
//  ContentView.swift
//  Test
//
//  Created by David Walter on 18.02.23.
//

import SwiftUI
import EmojiText

struct ContentView: View {
    var body: some View {
        TabView {
            NavigationStack {
                List {
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
                        AnimatedEmojiView()
                    } label: {
                        Text("Animated Emoji")
                    }
                }
                .navigationTitle("EmojiText")
            }
            .tag(0)
            .tabItem {
                Label("Emojis", systemImage: "face.smiling")
            }
            
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
