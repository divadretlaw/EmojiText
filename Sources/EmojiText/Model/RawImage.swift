//
//  RawImage.swift
//  EmojiText
//
//  Created by David Walter on 23.08.23.
//

import Foundation
import ImageIO
import OSLog

/// A wrapper arround ``EmojiImage`` to support animated images on all platforms.
struct RawImage: Sendable {
    private let _static: Lock<EmojiImage>
    private let _frames: Lock<[EmojiImage]?>
    /// The time interval for displaying an animated image.
    ///
    /// For a non-animated image, the value of this property is 0.0.
    let duration: TimeInterval
    
    init?(frames: [EmojiImage], duration: TimeInterval) {
        guard let image = frames.first else { return nil }
        
        let lock = NSLock()
        self._static = Lock(image, lock: lock)
        self._frames = Lock(frames, lock: lock)
        self.duration = duration
    }
    
    init(image: EmojiImage) {
        let lock = NSLock()
        self._static = Lock(image, lock: lock)
        self._frames = Lock(nil, lock: lock)
        self.duration = 0
    }
    
    init(static data: Data) throws {
        if let image = EmojiImage(data: data) {
            self = RawImage(image: image)
        } else {
            throw EmojiError.invalidData
        }
    }
    
    init(animated data: Data) throws {
        do {
            guard let type = AnimatedImageType(from: data) else {
                throw EmojiError.notAnimated
            }
            
            guard let source = CGImageSourceCreateWithData(data as CFData, nil), source.containsAnimatedKeys(for: type) else {
                throw EmojiError.animatedData
            }
            
            if let image = EmojiImage.animatedImage(from: source, type: type) {
                self = image
            } else {
                throw EmojiError.animatedData
            }
        } catch {
            // In case an error occurs while loading the animated image
            // we fall back to a static image
            if let image = EmojiImage(data: data) {
                self = RawImage(image: image)
            } else {
                Logger.animatedImage.warning("Unable to decode animated image: \(error.localizedDescription).")
                throw EmojiError.staticData
            }
        }
    }
    
    /// A static representation of the animated image
    var `static`: EmojiImage {
        _static.wrappedValue
    }
    
    /// The complete array of image objects that compose the animation of an animated object.
    ///
    /// For a non-animated image, the value of this property is nil.
    var frames: [EmojiImage]? {
        _frames.wrappedValue
    }
}
