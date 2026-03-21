// swift-tools-version: 6.0
// Resonance — Design for the Exhale
//
// Shared design system library for all Apple platforms.

import PackageDescription

let package = Package(
    name: "ResonanceApp",
    platforms: [
        .iOS(.v18),
        .macOS(.v15),
        .watchOS(.v11),
        .visionOS(.v2),
    ],
    products: [
        .library(
            name: "ResonanceDesignSystem",
            targets: ["ResonanceDesignSystem"]
        ),
    ],
    targets: [
        .target(
            name: "ResonanceDesignSystem",
            path: "Shared/DesignSystem"
        ),
    ]
)
