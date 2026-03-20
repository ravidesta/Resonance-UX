// ComplicationView.swift
// Luminous Cognitive Styles™ — watchOS
// Watch complication showing primary dimension (circular, modular, graphic styles)

import SwiftUI
import WidgetKit

// MARK: - Complication Entry

struct CognitiveComplicationEntry: TimelineEntry {
    let date: Date
    let profileTypeName: String
    let topDimension: CognitiveDimension
    let topScore: Double
    let allScores: [CognitiveDimension: Double]

    static var placeholder: CognitiveComplicationEntry {
        CognitiveComplicationEntry(
            date: Date(),
            profileTypeName: "The Visionary",
            topDimension: .perceptualMode,
            topScore: 7.5,
            allScores: Dictionary(
                uniqueKeysWithValues: CognitiveDimension.allCases.map { ($0, 5.0) }
            )
        )
    }
}

// MARK: - Circular Complication

struct CircularComplicationView: View {
    let entry: CognitiveComplicationEntry

    var body: some View {
        ZStack {
            // Background arc showing score
            Circle()
                .trim(from: 0, to: CGFloat(entry.topScore / 10.0))
                .stroke(entry.topDimension.color, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .rotationEffect(.degrees(-90))

            VStack(spacing: 0) {
                Text(entry.topDimension.abbreviation)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(entry.topDimension.color)

                Text(String(format: "%.0f", entry.topScore))
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
        }
    }
}

// MARK: - Modular Complication (Rectangular)

struct ModularComplicationView: View {
    let entry: CognitiveComplicationEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 4) {
                Image(systemName: "sparkles")
                    .font(.system(size: 9))
                    .foregroundColor(LCSTheme.goldAccent)
                Text("LCS")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(LCSTheme.goldAccent)
            }

            Text(entry.profileTypeName)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white)
                .lineLimit(1)

            HStack(spacing: 3) {
                ForEach(CognitiveDimension.allCases.prefix(5)) { dim in
                    let score = entry.allScores[dim] ?? 5.0
                    RoundedRectangle(cornerRadius: 1)
                        .fill(dim.color.opacity(0.7))
                        .frame(width: max(2, CGFloat(score / 10.0) * 16), height: 4)
                }
            }
        }
    }
}

// MARK: - Graphic Complication (Corner/Inline)

struct GraphicComplicationView: View {
    let entry: CognitiveComplicationEntry

    var body: some View {
        HStack(spacing: 4) {
            // Mini radar shape
            ZStack {
                let scores = CognitiveDimension.allCases.map {
                    CGFloat((entry.allScores[$0] ?? 5.0) / 10.0)
                }
                RadarDataPolygon(values: scores, animationProgress: 1.0)
                    .fill(
                        AngularGradient(
                            colors: CognitiveDimension.allCases.map { $0.color.opacity(0.4) }
                                + [CognitiveDimension.allCases.first!.color.opacity(0.4)],
                            center: .center
                        )
                    )
                    .frame(width: 20, height: 20)

                RadarDataPolygon(values: scores, animationProgress: 1.0)
                    .stroke(
                        AngularGradient(
                            colors: CognitiveDimension.allCases.map { $0.color }
                                + [CognitiveDimension.allCases.first!.color],
                            center: .center
                        ),
                        lineWidth: 1
                    )
                    .frame(width: 20, height: 20)
            }

            Text(entry.topDimension.abbreviation)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(entry.topDimension.color)

            Text(String(format: "%.0f", entry.topScore))
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundColor(.white)
        }
    }
}

// MARK: - Complication Preview Container

struct ComplicationPreviewsView: View {
    let entry = CognitiveComplicationEntry.placeholder

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Complication Styles")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)

                // Circular
                VStack(spacing: 4) {
                    Text("Circular")
                        .font(.system(size: 9))
                        .foregroundColor(.white.opacity(0.5))
                    CircularComplicationView(entry: entry)
                        .frame(width: 50, height: 50)
                }

                // Modular
                VStack(spacing: 4) {
                    Text("Modular")
                        .font(.system(size: 9))
                        .foregroundColor(.white.opacity(0.5))
                    ModularComplicationView(entry: entry)
                        .frame(height: 40)
                }

                // Graphic
                VStack(spacing: 4) {
                    Text("Graphic")
                        .font(.system(size: 9))
                        .foregroundColor(.white.opacity(0.5))
                    GraphicComplicationView(entry: entry)
                }
            }
            .padding()
        }
        .containerBackground(LCSTheme.deepNavy.gradient, for: .navigation)
    }
}
