// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EmojiText",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15),
        .watchOS(.v9)
    ],
    products: [
        .library(
            name: "EmojiText",
            targets: ["EmojiText"]
        ),
    ],
    dependencies: [
         .package(url: "https://github.com/kean/Nuke", from: "12.0.0")
    ],
    targets: [
        .target(
            name: "EmojiText",
            dependencies: [
                .product(name: "Nuke", package: "Nuke")
            ]
        ),
    ]
)
