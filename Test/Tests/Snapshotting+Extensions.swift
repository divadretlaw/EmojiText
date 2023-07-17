//
//  Snapshotting+Extensions.swift
//  Tests
//
//  Created by David Walter on 18.02.23.
//

import Foundation
import SnapshotTesting
import SwiftUI
import GraphicsRenderer

#if os(iOS) || targetEnvironment(macCatalyst) || os(tvOS)
extension Snapshotting where Value: View, Format == UIImage {
    static func rendered(size: CGSize, delay: UInt64 = 0) -> Snapshotting {
        SimplySnapshotting
            .image
            .pullback { @MainActor view in
                let bounds = CGRect(origin: .zero, size: size)
                guard let windowScene = UIApplication.shared.windowScenes.first else {
                    return UIImage()
                }
                let window = UIWindow(windowScene: windowScene)
                window.rootViewController = UIHostingController(rootView: view)
                window.frame.size = size
                window.makeKeyAndVisible()
                try? await Task.sleep(nanoseconds: delay * NSEC_PER_SEC)
                let renderer = ImageRenderer(bounds: bounds)
                return renderer.image { _ in
                    window.drawHierarchy(in: bounds, afterScreenUpdates: true)
                }
            }
    }
}

extension UIApplication {
    var keyWindow: UIWindow? {
        windowScenes
            .flatMap { $0.windows }
            .first(where: \.isKeyWindow)
    }
    
    var windowScenes: [UIWindowScene] {
        connectedScenes
            .compactMap { $0 as? UIWindowScene }
    }
}
#elseif os(macOS)
extension Snapshotting where Value: View, Format == NSImage {
    static func rendered(size: CGSize, delay: UInt64 = 0) -> Snapshotting {
        SimplySnapshotting
            .image
            .pullback { @MainActor view in
                let bounds = NSRect(origin: .zero, size: size)
                let hostingView = NSHostingView(rootView: view)
                let window = NSWindow(contentRect: bounds, styleMask: .borderless, backing: .buffered, defer: true)
                window.contentView = hostingView
                try? await Task.sleep(nanoseconds: delay * NSEC_PER_SEC)
                let renderer = ImageRenderer(bounds: bounds)
                return renderer.image { _ in
                    hostingView.draw(bounds)
                }
            }
    }
}
#endif
