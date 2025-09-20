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
    @Test func test_Empty() {
        let view = EmojiText(verbatim: "", emojis: [])
        assertSnapshot(of: view, as: .image(layout: .fixed(width: 100, height: 100)))
    }
    
    @Test func test_No_Emoji() {
        let view = EmojiText(verbatim: "Hello World", emojis: [])
        assertSnapshot(of: view, as: .image)
    }
    
    @Test func test_Async() {
        let view = EmojiText(verbatim: "Hello Async :async:", emojis: [Emojis.async])
            .environment(\.emojiText.asyncEmojiProvider, TestEmojiProvider())
        assertSnapshot(of: view, as: .image)
    }
    
    @Test func test_Async_Verbatim_Double() {
        let view = EmojiText(verbatim: "Hello Async :async: :async:", emojis: [Emojis.async])
            .environment(\.emojiText.asyncEmojiProvider, TestEmojiProvider())
        assertSnapshot(of: view, as: .image)
    }
    
    @Test func test_Async_Markdown_Double() {
        let view = EmojiText(markdown: "Hello Async :async: :async:", emojis: [Emojis.async])
            .environment(\.emojiText.asyncEmojiProvider, TestEmojiProvider())
        assertSnapshot(of: view, as: .image)
    }
    
    @Test func test_Async_Scaled() {
        let view = EmojiText(verbatim: "Hello Async :async:", emojis: [Emojis.async])
            .environment(\.emojiText.asyncEmojiProvider, TestEmojiProvider())
            .font(.largeTitle)
        assertSnapshot(of: view, as: .image)
    }
    
    @Test func test_Async_Custom_Scaled() {
        let view = EmojiText(verbatim: "Hello Async :async:", emojis: [Emojis.async])
            .environment(\.emojiText.asyncEmojiProvider, TestEmojiProvider())
            .emojiText.size(30)
        assertSnapshot(of: view, as: .image)
    }
    
    @Test func test_Async_Offset() {
        let view = EmojiText(verbatim: "Hello Async :async: and :async_offset:", emojis: [Emojis.async, Emojis.asyncWithOffset])
            .environment(\.emojiText.asyncEmojiProvider, TestEmojiProvider())
        assertSnapshot(of: view, as: .image)
    }
    
    @Test func test_Async_Offset_Positive() {
        let view = EmojiText(verbatim: "Hello Async :async:", emojis: [Emojis.async])
            .environment(\.emojiText.asyncEmojiProvider, TestEmojiProvider())
            .emojiText.baselineOffset(8)
        assertSnapshot(of: view, as: .image)
    }
    
    @Test func test_Async_Offset_Negative() {
        let view = EmojiText(verbatim: "Hello Async :async:", emojis: [Emojis.async])
            .environment(\.emojiText.asyncEmojiProvider, TestEmojiProvider())
            .emojiText.baselineOffset(-8)
        assertSnapshot(of: view, as: .image)
    }
    
    @MainActor
    func test_Async_Markdown() {
        let view = EmojiText(markdown: "**Hello** _Async_ :async:", emojis: [Emojis.async])
            .environment(\.emojiText.asyncEmojiProvider, TestEmojiProvider())
        assertSnapshot(of: view, as: .image)
    }
    
    @Test func test_iPhone() {
        let view = EmojiText(verbatim: "SF Symbol for iPhone: :iphone:", emojis: [Emojis.iPhone])
        assertSnapshot(of: view, as: .image)
    }
    
    @Test func test_iPhone_Scaled() {
        let view = EmojiText(verbatim: "SF Symbol for iPhone: :iphone:", emojis: [Emojis.iPhone])
            .font(.largeTitle)
        assertSnapshot(of: view, as: .image)
    }
    
    @Test func test_iPhone_RenderingMode() {
        let view = EmojiText(verbatim: "SF Symbol for iPhone: :iphone:", emojis: [Emojis.iPhone(renderingMode: .template)])
        assertSnapshot(of: view, as: .image)
    }
    
    @Test func test_Multiple() {
        let view = EmojiText(verbatim: "Hello :face.smiling: how are you? :face.dashed:", emojis: Emojis.multiple)
            .environment(\.emojiText.asyncEmojiProvider, TestEmojiProvider())
        assertSnapshot(of: view, as: .image)
    }
    
    @Test func test_Prepend_Append() {
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
    
    @Test func test_Wide() {
        let view = EmojiText(verbatim: "Hello Wide :wide:", emojis: [Emojis.wide])
            .environment(\.emojiText.asyncEmojiProvider, TestEmojiProvider())
        assertSnapshot(of: view, as: .image)
    }
    
    @Test func test_Wide_Custom_Scaled() {
        let view = EmojiText(verbatim: "Hello Wide :wide:", emojis: [Emojis.wide])
            .environment(\.emojiText.asyncEmojiProvider, TestEmojiProvider())
            .emojiText.size(30)
        assertSnapshot(of: view, as: .image)
    }
    
    @Test func test_EmojiInMarkdown() {
        let view = EmojiText(markdown: "**Hello :async:** _Async :async:_ :async:", emojis: [Emojis.async])
            .environment(\.emojiText.asyncEmojiProvider, TestEmojiProvider())
        assertSnapshot(of: view, as: .image)
    }
    
    @Test func test_EmojiInMarkdownNested() {
        let view = EmojiText(markdown: "**Hello :async: _World_** with `code` and Mi**x***e*d", emojis: [Emojis.async])
            .environment(\.emojiText.asyncEmojiProvider, TestEmojiProvider())
        assertSnapshot(of: view, as: .image(precision: 0.99, perceptualPrecision: 0.98))
    }
    
    @Test func test_Markdown_InlineOnlyPreservingWhitespace() {
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
    
    @Test func test_Markdown_Full() {
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
