// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "HighlightSwift",
    platforms: [
        .iOS(.v15),
        .tvOS(.v15),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "HighlightSwift",
            targets: ["HighlightSwift"]),
    ],
    dependencies: [
        .package(url: "https://github.com/nicklockwood/LRUCache.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "HighlightSwift",
            dependencies: [
                .product(name: "LRUCache", package: "LRUCache")
            ],
            resources: [.process("HighlightJS")]),
        .testTarget(
            name: "HighlightSwiftTests",
            dependencies: ["HighlightSwift"]),
    ]
)
