// swift-tools-version: 5.9
// Package.swift
// Luminous Cognitive Styles™
// Swift Package Manager configuration for shared code

import PackageDescription

let package = Package(
    name: "LuminousCognitiveStyles",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .watchOS(.v10),
        .visionOS(.v1),
    ],
    products: [
        .library(
            name: "LCSShared",
            targets: ["LCSShared"]
        ),
    ],
    targets: [
        .target(
            name: "LCSShared",
            path: "Shared",
            sources: [
                "Models/CognitiveDimension.swift",
                "Models/Assessment.swift",
                "Models/BookChapter.swift",
                "Views/RadarChartView.swift",
                "Views/DimensionScoreView.swift",
                "Views/CognitiveSignatureView.swift",
                "ViewModels/AssessmentViewModel.swift",
                "Theme/LCSTheme.swift",
                "Utils/Scoring.swift",
            ]
        ),
        .testTarget(
            name: "LCSSharedTests",
            dependencies: ["LCSShared"],
            path: "Tests"
        ),
    ]
)
