// RadarChartView.swift
// Luminous Cognitive Styles™
// Custom radar/spider chart for visualizing cognitive profiles

import SwiftUI

struct RadarChartView: View {
    let profile: CognitiveProfile
    var showLabels: Bool = true
    var showAdaptiveRange: Bool = true
    var animated: Bool = true
    var size: CGFloat = 280

    @State private var animationProgress: Double = 0

    private let dimensions = CognitiveDimension.allCases
    private let maxScore: Double = 10.0
    private let rings = 5

    var body: some View {
        ZStack {
            // Background rings
            ForEach(1...rings, id: \.self) { ring in
                RadarPolygon(
                    sides: dimensions.count,
                    scale: CGFloat(ring) / CGFloat(rings)
                )
                .stroke(Color.white.opacity(ring == rings ? 0.2 : 0.08), lineWidth: ring == rings ? 1.0 : 0.5)
            }

            // Axis lines
            ForEach(0..<dimensions.count, id: \.self) { index in
                let angle = angleFor(index: index)
                Path { path in
                    path.move(to: CGPoint(x: 0, y: 0))
                    path.addLine(to: pointOnCircle(angle: angle, radius: size / 2))
                }
                .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
            }

            // Adaptive range (outer fill)
            if showAdaptiveRange {
                let adaptiveScores = dimensions.map { dim -> CGFloat in
                    let range = profile.adaptiveRange(for: dim)
                    return CGFloat(range.upperBound / maxScore)
                }
                RadarDataPolygon(values: adaptiveScores, animationProgress: animated ? animationProgress : 1.0)
                    .fill(Color.white.opacity(0.05))
                    .frame(width: size, height: size)

                RadarDataPolygon(values: adaptiveScores, animationProgress: animated ? animationProgress : 1.0)
                    .stroke(Color.white.opacity(0.15), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                    .frame(width: size, height: size)
            }

            // Home territory fill
            let homeScores = dimensions.map { dim -> CGFloat in
                CGFloat(profile.score(for: dim) / maxScore)
            }

            RadarDataPolygon(values: homeScores, animationProgress: animated ? animationProgress : 1.0)
                .fill(
                    AngularGradient(
                        colors: dimensions.map { $0.color.opacity(0.3) } + [dimensions.first!.color.opacity(0.3)],
                        center: .center
                    )
                )
                .frame(width: size, height: size)

            RadarDataPolygon(values: homeScores, animationProgress: animated ? animationProgress : 1.0)
                .stroke(
                    AngularGradient(
                        colors: dimensions.map { $0.color } + [dimensions.first!.color],
                        center: .center
                    ),
                    lineWidth: 2
                )
                .frame(width: size, height: size)

            // Score dots
            ForEach(0..<dimensions.count, id: \.self) { index in
                let dimension = dimensions[index]
                let score = profile.score(for: dimension)
                let normalizedScore = score / maxScore
                let angle = angleFor(index: index) - .pi / 2
                let radius = (size / 2) * CGFloat(normalizedScore) * CGFloat(animated ? animationProgress : 1.0)
                let x = cos(angle) * radius
                let y = sin(angle) * radius

                Circle()
                    .fill(dimension.color)
                    .frame(width: 8, height: 8)
                    .shadow(color: dimension.color.opacity(0.6), radius: 4)
                    .offset(x: x, y: y)
            }

            // Labels
            if showLabels {
                ForEach(0..<dimensions.count, id: \.self) { index in
                    let dimension = dimensions[index]
                    let angle = angleFor(index: index) - .pi / 2
                    let labelRadius = (size / 2) + 32
                    let x = cos(angle) * labelRadius
                    let y = sin(angle) * labelRadius

                    VStack(spacing: 1) {
                        Text(dimension.shortName)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(dimension.color)
                        Text(ScoreFormatter.formatted(profile.score(for: dimension)))
                            .font(.system(size: 9, weight: .medium, design: .monospaced))
                            .foregroundColor(LCSTheme.textSecondary)
                    }
                    .offset(x: x, y: y)
                }
            }
        }
        .frame(width: size + (showLabels ? 120 : 0), height: size + (showLabels ? 100 : 0))
        .onAppear {
            if animated {
                withAnimation(.easeOut(duration: 1.2).delay(0.3)) {
                    animationProgress = 1.0
                }
            }
        }
    }

    private func angleFor(index: Int) -> CGFloat {
        let fraction = CGFloat(index) / CGFloat(dimensions.count)
        return fraction * 2 * .pi
    }

    private func pointOnCircle(angle: CGFloat, radius: CGFloat) -> CGPoint {
        let adjusted = angle - .pi / 2
        return CGPoint(x: cos(adjusted) * radius, y: sin(adjusted) * radius)
    }
}

// MARK: - Radar Polygon Shape (regular polygon for grid)

struct RadarPolygon: Shape {
    let sides: Int
    let scale: CGFloat

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2 * scale
        var path = Path()

        for i in 0..<sides {
            let angle = (CGFloat(i) / CGFloat(sides)) * 2 * .pi - .pi / 2
            let point = CGPoint(
                x: center.x + cos(angle) * radius,
                y: center.y + sin(angle) * radius
            )
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.closeSubpath()
        return path
    }
}

// MARK: - Radar Data Polygon (for actual data values)

struct RadarDataPolygon: Shape {
    let values: [CGFloat]
    var animationProgress: Double

    var animatableData: Double {
        get { animationProgress }
        set { animationProgress = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let maxRadius = min(rect.width, rect.height) / 2
        var path = Path()

        for i in 0..<values.count {
            let angle = (CGFloat(i) / CGFloat(values.count)) * 2 * .pi - .pi / 2
            let radius = maxRadius * values[i] * CGFloat(animationProgress)
            let point = CGPoint(
                x: center.x + cos(angle) * radius,
                y: center.y + sin(angle) * radius
            )
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.closeSubpath()
        return path
    }
}

// MARK: - Compact Radar (for watchOS / widgets)

struct CompactRadarChartView: View {
    let profile: CognitiveProfile
    var size: CGFloat = 80

    private let dimensions = CognitiveDimension.allCases

    var body: some View {
        ZStack {
            RadarPolygon(sides: dimensions.count, scale: 1.0)
                .stroke(Color.white.opacity(0.15), lineWidth: 0.5)
                .frame(width: size, height: size)

            let scores = dimensions.map { CGFloat(profile.score(for: $0) / 10.0) }
            RadarDataPolygon(values: scores, animationProgress: 1.0)
                .fill(
                    AngularGradient(
                        colors: dimensions.map { $0.color.opacity(0.35) } + [dimensions.first!.color.opacity(0.35)],
                        center: .center
                    )
                )
                .frame(width: size, height: size)

            RadarDataPolygon(values: scores, animationProgress: 1.0)
                .stroke(
                    AngularGradient(
                        colors: dimensions.map { $0.color } + [dimensions.first!.color],
                        center: .center
                    ),
                    lineWidth: 1.5
                )
                .frame(width: size, height: size)
        }
        .frame(width: size, height: size)
    }
}
