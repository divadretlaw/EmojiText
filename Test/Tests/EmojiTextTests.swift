//
//  EmojiTextTests.swift
//  Tests
//
//  Created by David Walter on 18.02.23.
//

import XCTest
import EmojiText
import SnapshotTesting
import SwiftUI

final class EmojiTextTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        isRecording = false
    }
    
    func test_Empty() async throws {
        let view = EmojiText(verbatim: "", emojis: [])
        await assertSnapshot(matching: view, as: .rendered(size: CGSize(width: 300, height: 100)))
    }
    
    func test_No_Emoji() async throws {
        let view = EmojiText(verbatim: "Hello World", emojis: [])
        await assertSnapshot(matching: view, as: .rendered(size: CGSize(width: 300, height: 100)))
    }
    
    func test_Mastodon() async throws {
        let view = EmojiText(verbatim: "Hello Mastodon :mastodon:", emojis: [Emojis.mastodon])
        await assertSnapshot(matching: view, as: .rendered(size: CGSize(width: 300, height: 100), delay: 2))
    }
    
    func test_Mastodon_Scaled() async throws {
        let view = EmojiText(verbatim: "Hello Mastodon :mastodon:", emojis: [Emojis.mastodon])
            .font(.largeTitle)
        await assertSnapshot(matching: view, as: .rendered(size: CGSize(width: 300, height: 100), delay: 2))
    }
    
    func test_Mastodon_Custom_Scaled() async throws {
        let view = EmojiText(verbatim: "Hello Mastodon :mastodon:", emojis: [Emojis.mastodon])
            .emojiSize(30)
        await assertSnapshot(matching: view, as: .rendered(size: CGSize(width: 300, height: 100), delay: 2))
    }
    
    func test_Mastodon_Offset() async throws {
        let view = EmojiText(verbatim: "Hello Mastodon :mastodon: and :mastodon_offset:", emojis: [Emojis.mastodon, Emojis.mastodonWithOffset])
        await assertSnapshot(matching: view, as: .rendered(size: CGSize(width: 300, height: 100), delay: 2))
    }
    
    func test_Mastodon_Offset_Positive() async throws {
        let view = EmojiText(verbatim: "Hello Mastodon :mastodon:", emojis: [Emojis.mastodon])
            .emojiBaselineOffset(8)
        await assertSnapshot(matching: view, as: .rendered(size: CGSize(width: 300, height: 100), delay: 2))
    }
    
    func test_Mastodon_Offset_Negative() async throws {
        let view = EmojiText(verbatim: "Hello Mastodon :mastodon:", emojis: [Emojis.mastodon])
            .emojiBaselineOffset(-8)
        await assertSnapshot(matching: view, as: .rendered(size: CGSize(width: 300, height: 100), delay: 2))
    }
    
    func test_Mastodon_Markdown() async throws {
        let view = EmojiText(markdown: "**Hello** _Mastodon_ :mastodon:", emojis: [Emojis.mastodon])
        await assertSnapshot(matching: view, as: .rendered(size: CGSize(width: 300, height: 100), delay: 2))
    }
    
    func test_iPhone() async throws {
        let view = EmojiText(verbatim: "SF Symbol for iPhone: :iphone:", emojis: [Emojis.iPhone])
        await assertSnapshot(matching: view, as: .rendered(size: CGSize(width: 300, height: 100), delay: 1))
    }
    
    func test_iPhone_Scaled() async throws {
        let view = EmojiText(verbatim: "SF Symbol for iPhone: :iphone:", emojis: [Emojis.iPhone])
            .font(.largeTitle)
        await assertSnapshot(matching: view, as: .rendered(size: CGSize(width: 400, height: 100), delay: 1))
    }
    
    func test_iPhone_RenderingMode() async throws {
        let view = EmojiText(verbatim: "SF Symbol for iPhone: :iphone:", emojis: [Emojis.iPhone(renderingMode: .template)])
        await assertSnapshot(matching: view, as: .rendered(size: CGSize(width: 300, height: 100), delay: 1))
    }
    
    func test_Multiple() async throws {
        let view = EmojiText(verbatim: "Hello :face.smiling: how are you? :face.dashed:", emojis: Emojis.multiple)
        await assertSnapshot(matching: view, as: .rendered(size: CGSize(width: 300, height: 100), delay: 1))
    }
    
    func test_Prepend_Append() async throws {
        let view = EmojiText(verbatim: "Hello :face.smiling: how are you? :face.dashed:", emojis: Emojis.multiple)
            .prepend {
                Text("Prepended - ")
            }
            .append {
                Text(" - Appended")
            }
        await assertSnapshot(matching: view, as: .rendered(size: CGSize(width: 400, height: 100), delay: 1))
    }
    
    func test_Wide() async throws {
        let view = EmojiText(verbatim: "Hello Wide :wide:", emojis: [Emojis.wide])
        await assertSnapshot(matching: view, as: .rendered(size: CGSize(width: 300, height: 100), delay: 2))
    }
    
    func test_Wide_Custom_Scaled() async throws {
        let view = EmojiText(verbatim: "Hello Wide :wide:", emojis: [Emojis.wide])
            .emojiSize(30)
        await assertSnapshot(matching: view, as: .rendered(size: CGSize(width: 300, height: 100), delay: 2))
    }
}
