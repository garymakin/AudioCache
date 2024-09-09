// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "AudioCache",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
        .tvOS(.v16),
    ],
    products: [
        .library(
            name: "AudioCache",
            targets: ["AudioCache"]),
    ],
    targets: [
        .target(
            name: "AudioCache"),
        .testTarget(
            name: "AudioCacheTests",
            dependencies: ["AudioCache"]),
    ]
)
