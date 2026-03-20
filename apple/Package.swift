// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "LuminousIntegralArchitecture",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .watchOS(.v10),
        .tvOS(.v17),
        .visionOS(.v1),
    ],
    products: [
        .library(
            name: "LuminousShared",
            targets: ["LuminousShared"]
        ),
        .library(
            name: "ResonanceDesignSystem",
            targets: ["ResonanceDesignSystem"]
        ),
    ],
    dependencies: [
        // Add external Swift package dependencies here
    ],
    targets: [
        .target(
            name: "LuminousShared",
            dependencies: [],
            path: "Shared/Sources",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
            ]
        ),
        .target(
            name: "ResonanceDesignSystem",
            dependencies: ["LuminousShared"],
            path: "Shared/DesignSystem"
        ),
        .testTarget(
            name: "LuminousSharedTests",
            dependencies: ["LuminousShared"],
            path: "Shared/Tests"
        ),
    ]
)
