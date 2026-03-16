// swift-tools-version: 5.9
// Resonance UX GitHub Backup — Swift Package
// Multiplatform: macOS, iOS, iPadOS, visionOS, watchOS

import PackageDescription

let package = Package(
    name: "ResonanceBackup",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
        .watchOS(.v10),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "ResonanceBackup",
            targets: ["ResonanceBackup"]
        ),
    ],
    targets: [
        .target(
            name: "ResonanceBackup",
            path: "Shared"
        ),
    ]
)
