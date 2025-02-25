//
//  CADisplayLinkPublisher.swift
//  EmojiText
//
//  Created by David Walter on 15.08.23.
//

import SwiftUI

#if os(iOS) || targetEnvironment(macCatalyst) || os(tvOS) || os(visionOS)
extension CADisplayLink {
    struct CADisplayLinkPublisher {
        let mode: RunLoop.Mode
        let stopOnLowPowerMode: Bool
        
        init(mode: RunLoop.Mode, stopOnLowPowerMode: Bool) {
            self.mode = mode
            self.stopOnLowPowerMode = stopOnLowPowerMode
        }
        
        var targetTimestamps: AsyncStream<CFTimeInterval> {
            AsyncStream { continuation in
                let displayLink = DisplayLink(mode: mode) { displayLink in
                    if stopOnLowPowerMode, ProcessInfo.processInfo.isLowPowerModeEnabled {
                        // Do not yield information on low-power mode
                    } else {
                        continuation.yield(displayLink.targetTimestamp)
                    }
                }
                
                continuation.onTermination = { _ in
                    displayLink.stop()
                }
            }
        }
    }
    
    static func publish(mode: RunLoop.Mode, stopOnLowPowerMode: Bool) -> CADisplayLinkPublisher {
        CADisplayLinkPublisher(mode: mode, stopOnLowPowerMode: stopOnLowPowerMode)
    }
}

private final class DisplayLink: NSObject, @unchecked Sendable {
    private var displayLink: CADisplayLink!
    private let handler: (CADisplayLink) -> Void
    
    init(mode: RunLoop.Mode, handler: @Sendable @escaping (CADisplayLink) -> Void) {
        self.handler = handler
        super.init()
        
        displayLink = CADisplayLink(target: self, selector: #selector(handle(displayLink:)))
        displayLink.add(to: .main, forMode: mode)
    }
    
    func stop() {
        displayLink.invalidate()
    }
    
    @objc func handle(displayLink: CADisplayLink) {
        handler(displayLink)
    }
}
#endif
