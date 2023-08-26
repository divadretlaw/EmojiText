//
//  RawImage.swift
//  EmojiText
//
//  Created by David Walter on 23.08.23.
//

import Foundation

/// A wrapper arround ``EmojiImage`` to support animated images on all platforms.
struct RawImage {
    /// A static representation of the animated image
    var `static`: EmojiImage
    /// The complete array of image objects that compose the animation of an animated object.
    ///
    /// For a non-animated image, the value of this property is nil.
    var frames: [EmojiImage]?
    /// The time interval for displaying an animated image.
    ///
    /// For a non-animated image, the value of this property is 0.0.
    var duration: TimeInterval
    
    init?(frames: [EmojiImage], duration: TimeInterval) {
        guard let image = frames.first else { return nil }
        
        self.static = image
        self.frames = frames
        self.duration = duration
    }
    
    init(image: EmojiImage) {
        self.static = image
        self.frames = nil
        self.duration = 0
    }
}
