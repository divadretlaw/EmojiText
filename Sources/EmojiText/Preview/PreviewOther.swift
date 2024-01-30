//
//  PreviewOther.swift
//  EmojiText
//
//  Created by David Walter on 26.01.24.
//

import SwiftUI

#if DEBUG
#Preview("Animated") {
    AnimatedEmoji()
}
    
private struct AnimatedEmoji: View {
    @State private var enableAnimation = false
    
    var body: some View {
        List {
            Section {
                EmojiText(
                    markdown: "**Animated** *GIF* :gif:",
                    emojis: EmojiText.animatedEmojis
                )
                .animated()
                EmojiText(
                    markdown: "**Never Animated** *GIF* :gif:",
                    emojis: EmojiText.animatedEmojis
                )
                .animated()
                .environment(\.emojiText.animatedMode, .never)
            } header: {
                Text("Default")
            }
            
            Section {
                EmojiText(
                    markdown: "**Animated** *GIF* :gif:",
                    emojis: EmojiText.animatedEmojis
                )
                .animated()
                .environment(\.emojiText.animatedMode, enableAnimation ? .always : .never)
                
                EmojiText(
                    markdown: "**Never Animated** *GIF* :gif:",
                    emojis: EmojiText.animatedEmojis
                )
                .animated()
                .environment(\.emojiText.animatedMode, .never)
                
                Toggle("Enable animation", isOn: $enableAnimation)
            } header: {
                Text("Toggle")
            }
        }
    }
}

#Preview("Variable size") {
    EmojiTextWithSlider()
}

private struct EmojiTextWithSlider: View {
    @State private var size: CGFloat = 20
    
    var body: some View {
        List {
            Section {
                EmojiText(
                    verbatim: "Hello World :mastodon: with a remote emoji",
                    emojis: EmojiText.emojis
                )
                .emojiText.size(size)
                
                Slider(value: $size, in: 1...50)
            }
        }
    }
}
#endif
