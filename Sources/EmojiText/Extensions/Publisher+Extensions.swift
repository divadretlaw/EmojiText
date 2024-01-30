//
//  Publisher+Extensions.swift
//  EmojiText
//
//  Created by David Walter on 26.08.23.
//

import Foundation
import Combine

extension Publisher where Failure == Never {
    func values(stopOnLowPowerMode: Bool) -> AsyncPublisher<AnyPublisher<Output, Never>> {
        filter { _ in
            if stopOnLowPowerMode && ProcessInfo.processInfo.isLowPowerModeEnabled {
                return false
            } else {
                return true
            }
        }
        .eraseToAnyPublisher()
        .values
    }
}
