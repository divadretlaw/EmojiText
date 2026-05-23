//
//  EmojiTextTests.swift
//  Tests
//
//  Created by David Walter on 18.02.23.
//

import Testing
@preconcurrency import SnapshotTesting
@testable import EmojiText
import SwiftUI

@MainActor struct EmojiTextTests {
    @Test func `empty`() {
        let view = EmojiText(verbatim: "", emojis: [])
        assertSnapshot(of: view, as: .image(layout: .fixed(width: 100, height: 100)))
    }
    
    @Test func `no emoji`() {
        let view = EmojiText(verbatim: "Hello World", emojis: [])
        assertSnapshot(of: view, as: .image)
    }
    
    @Test func `async`() {
        let view = EmojiText(verbatim: "Hello Async :async:", emojis: [Emojis.async])
            .environment(\.emojiText.asyncEmojiProvider, TestEmojiProvider())
        assertSnapshot(of: view, as: .image)
    }
    
    @Test func `async verbatim double`() {
        let view = EmojiText(verbatim: "Hello Async :async: :async:", emojis: [Emojis.async])
            .environment(\.emojiText.asyncEmojiProvider, TestEmojiProvider())
        assertSnapshot(of: view, as: .image)
    }
    
    @Test func `async markdown double`() {
        let view = EmojiText(markdown: "Hello Async :async: :async:", emojis: [Emojis.async])
            .environment(\.emojiText.asyncEmojiProvider, TestEmojiProvider())
        assertSnapshot(of: view, as: .image)
    }
    
    @Test func `async scaled`() {
        let view = EmojiText(verbatim: "Hello Async :async:", emojis: [Emojis.async])
            .environment(\.emojiText.asyncEmojiProvider, TestEmojiProvider())
            .font(.largeTitle)
        assertSnapshot(of: view, as: .image)
    }
    
    @Test func `async custom scaled`() {
        let view = EmojiText(verbatim: "Hello Async :async:", emojis: [Emojis.async])
            .environment(\.emojiText.asyncEmojiProvider, TestEmojiProvider())
            .emojiText.size(30)
        assertSnapshot(of: view, as: .image)
    }
    
    @Test func `async offset`() {
        let view = EmojiText(verbatim: "Hello Async :async: and :async_offset:", emojis: [Emojis.async, Emojis.asyncWithOffset])
            .environment(\.emojiText.asyncEmojiProvider, TestEmojiProvider())
        assertSnapshot(of: view, as: .image)
    }
    
    @Test func `async offset positive`() {
        let view = EmojiText(verbatim: "Hello Async :async:", emojis: [Emojis.async])
            .environment(\.emojiText.asyncEmojiProvider, TestEmojiProvider())
            .emojiText.baselineOffset(8)
        assertSnapshot(of: view, as: .image)
    }
    
    @Test func `async offset negative`() {
        let view = EmojiText(verbatim: "Hello Async :async:", emojis: [Emojis.async])
            .environment(\.emojiText.asyncEmojiProvider, TestEmojiProvider())
            .emojiText.baselineOffset(-8)
        assertSnapshot(of: view, as: .image)
    }
    
    @MainActor
    func `async markdownn`() {
        let view = EmojiText(markdown: "**Hello** _Async_ :async:", emojis: [Emojis.async])
            .environment(\.emojiText.asyncEmojiProvider, TestEmojiProvider())
        assertSnapshot(of: view, as: .image)
    }
    
    @Test func `sync`() {
        let view = EmojiText(verbatim: "SF Symbol for iPhone: :iphone:", emojis: [Emojis.iPhone])
        assertSnapshot(of: view, as: .image)
    }
    
    @Test func `sync scaled`() {
        let view = EmojiText(verbatim: "SF Symbol for iPhone: :iphone:", emojis: [Emojis.iPhone])
            .font(.largeTitle)
        assertSnapshot(of: view, as: .image)
    }
    
    @Test func `sync rendering mode`() {
        let view = EmojiText(verbatim: "SF Symbol for iPhone: :iphone:", emojis: [Emojis.iPhone(renderingMode: .template)])
        assertSnapshot(of: view, as: .image)
    }
    
    @Test func `sync multiple`() {
        let view = EmojiText(verbatim: "Hello :face.smiling: how are you? :face.dashed:", emojis: Emojis.multiple)
            .environment(\.emojiText.asyncEmojiProvider, TestEmojiProvider())
        assertSnapshot(of: view, as: .image)
    }
    
    @Test func `prepend/append`() {
        let view = EmojiText(verbatim: "Hello :face.smiling: how are you? :face.dashed:", emojis: Emojis.multiple)
            .prepend {
                Text("Prepended - ")
            }
            .append {
                Text(" - Appended")
            }
            .environment(\.emojiText.asyncEmojiProvider, TestEmojiProvider())
        assertSnapshot(of: view, as: .image)
    }
    
    @Test func `wide`() {
        let view = EmojiText(verbatim: "Hello Wide :wide:", emojis: [Emojis.wide])
            .environment(\.emojiText.asyncEmojiProvider, TestEmojiProvider())
        assertSnapshot(of: view, as: .image)
    }
    
    @Test func `wide custom scaled`() {
        let view = EmojiText(verbatim: "Hello Wide :wide:", emojis: [Emojis.wide])
            .environment(\.emojiText.asyncEmojiProvider, TestEmojiProvider())
            .emojiText.size(30)
        assertSnapshot(of: view, as: .image)
    }
    
    @Test func `emoji in markdown`() {
        let view = EmojiText(markdown: "**Hello :async:** _Async :async:_ :async:", emojis: [Emojis.async])
            .environment(\.emojiText.asyncEmojiProvider, TestEmojiProvider())
        assertSnapshot(of: view, as: .image)
    }
    
    @Test func `emoji in markdown nested`() {
        let view = EmojiText(markdown: "**Hello :async: _World_** with `code` and Mi**x***e*d", emojis: [Emojis.async])
            .environment(\.emojiText.asyncEmojiProvider, TestEmojiProvider())
        assertSnapshot(of: view, as: .image(precision: 0.99, perceptualPrecision: 0.98))
    }
    
    @Test func `markdown inline only preserving whitespace`() {
        let markdown = """
        # Title 1
        
        ## Title 2
        
        ### Title 3
        
        **Bold**
        
        *Italic*
        
        1. List
        2. List
        
        * List
        * List
        
        `inline code`
        
        ```swift
        code block
        ```
        
        > quote
        """
        let view = EmojiText(markdown: markdown, interpretedSyntax: .inlineOnlyPreservingWhitespace, emojis: [])
        assertSnapshot(of: view, as: .image(precision: 0.99, perceptualPrecision: 0.98))
    }
    
    @Test func `markdown full`() {
        let markdown = """
        # Title 1
        
        ## Title 2
        
        ### Title 3
        
        **Bold**
        
        *Italic*
        
        1. List
        2. List
        
        * List
        * List
        
        `inline code`
        
        ```swift
        code block
        ```
        
        > quote
        """
        let view = EmojiText(markdown: markdown, interpretedSyntax: .full, emojis: [])
        assertSnapshot(of: view, as: .image(precision: 0.99, perceptualPrecision: 0.98))
    }
}
