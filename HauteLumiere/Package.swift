// swift-tools-version: 5.9
// Haute Lumière — Premium Wellness & Coaching App
// Platforms: iOS 17+, watchOS 10+, visionOS 1+, macOS 14+

import PackageDescription

let package = Package(
    name: "HauteLumiere",
    platforms: [
        .iOS(.v17),
        .watchOS(.v10),
        .macOS(.v14),
        .visionOS(.v1)
    ],
    products: [
        .library(name: "HauteLumiere", targets: ["HauteLumiere"]),
    ],
    targets: [
        .target(
            name: "HauteLumiere",
            path: "HauteLumiere"
        ),
    ]
)
