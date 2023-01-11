// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EmojiText",
    platforms: [.iOS(.v16)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "EmojiText",
            targets: ["EmojiText"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
         .package(url: "https://gitlab.com/mflint/HTML2Markdown", from: "1.0.0"),
         .package(url: "https://github.com/kean/Nuke", from: "11.5.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "EmojiText",
            dependencies: [
                .product(name: "HTML2Markdown", package: "HTML2Markdown"),
                .product(name: "Nuke", package: "Nuke")
            ]),
    ]
)
