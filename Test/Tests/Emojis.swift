//
//  Emojis.swift
//  Tests
//
//  Created by David Walter on 18.02.23.
//

import Foundation
import EmojiText
import SwiftUI

enum Emojis {
    static var async: RemoteEmoji {
        RemoteEmoji(shortcode: "async", url: URL(string: "https://dummyimage.com/64x64/0A6FFF/fff&text=A")!)
    }
    
    static var asyncWithOffset: RemoteEmoji {
        RemoteEmoji(shortcode: "async_offset", url: URL(string: "https://dummyimage.com/64x64/0A6FFF/fff&text=A")!, baselineOffset: -8)
    }
    
    static var iPhone: SFSymbolEmoji {
        SFSymbolEmoji(shortcode: "iphone")
    }
    
    static func iPhone(renderingMode: Image.TemplateRenderingMode? = nil) -> SFSymbolEmoji {
        SFSymbolEmoji(shortcode: "iphone", renderingMode: renderingMode)
    }
    
    static var multiple: [any CustomEmoji] {
        [
            SFSymbolEmoji(shortcode: "face.smiling"),
            SFSymbolEmoji(shortcode: "face.dashed")
        ]
    }
    
    static var wide: RemoteEmoji {
        RemoteEmoji(shortcode: "wide", url: URL(string: "https://dummyimage.com/256x64/DE3A3B/fff&text=wide")!)
    }
}
