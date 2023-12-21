//
//  EmojiView.swift
//  EmojiTextTest
//
//  Created by David Walter on 23.04.23.
//

import SwiftUI
import EmojiText

struct EmojiTestView<Content>: View where Content: View {
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        List {
            Section {
                sectionContent
            } header: {
                Text("Default")
            }
            
            Section {
                sectionContent
            } header: {
                Text("emojiBaselineOffset = -20")
            }
            .emojiBaselineOffset(-20)
            
            Section {
                sectionContent
            } header: {
                Text("emojiBaselineOffset = 20")
            }
            .emojiBaselineOffset(-20)
            
            Section {
                sectionContent
            } header: {
                Text("emojiSize = 30")
            }
            .emojiSize(30)
            
            Section {
                sectionContent
            } header: {
                Text("emojiSize = 10")
            }
            .emojiSize(10)
        }
    }
    
    @ViewBuilder
    var sectionContent: some View {
        Group {
            content()
        }
        
        Group {
            content()
        }
        .font(.title)
        
        Group {
            content()
        }
        .font(.caption2)
    }
}
