// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EmojiText",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15),
        .watchOS(.v8),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "EmojiText",
            targets: ["EmojiText"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/kean/Nuke", from: "12.8.0"),
        .package(url: "https://github.com/swiftlang/swift-markdown", from: "0.5.0")
    ],
    targets: [
        .target(
            name: "EmojiText",
            dependencies: [
                .product(name: "Nuke", package: "Nuke"),
                .product(name: "Markdown", package: "swift-markdown")
            ]
        )
    ]
)
