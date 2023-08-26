//
//  CADisplayLinkPublisher.swift
//  EmojiText
//
//  Created by David Walter on 15.08.23.
//

import SwiftUI

#if os(iOS) || targetEnvironment(macCatalyst) || os(tvOS)
extension CADisplayLink {
    @MainActor
    struct CADisplayLinkPublisher {
        var mode: RunLoop.Mode
        var stopOnLowPowerMode: Bool
        
        init(mode: RunLoop.Mode, stopOnLowPowerMode: Bool) {
            self.mode = mode
            self.stopOnLowPowerMode = stopOnLowPowerMode
        }
        
        var values: AsyncStream<CADisplayLink> {
            AsyncStream { continuation in
                let displayLink = DisplayLink(mode: mode) { displayLink in
                    if stopOnLowPowerMode && ProcessInfo.processInfo.isLowPowerModeEnabled {
                        // Do not yielding information on low-power mode
                    } else {
                        continuation.yield(displayLink)
                    }
                }
                
                continuation.onTermination = { _ in
                    Task { await displayLink.stop() }
                }
            }
        }
    }
    
    @MainActor
    static func publish(mode: RunLoop.Mode, stopOnLowPowerMode: Bool) -> CADisplayLinkPublisher {
        CADisplayLinkPublisher(mode: mode, stopOnLowPowerMode: stopOnLowPowerMode)
    }
}

@MainActor
private final class DisplayLink: NSObject {
    private var displayLink: CADisplayLink!
    private let handler: (CADisplayLink) -> Void
    
    init(mode: RunLoop.Mode, handler: @escaping (CADisplayLink) -> Void) {
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
