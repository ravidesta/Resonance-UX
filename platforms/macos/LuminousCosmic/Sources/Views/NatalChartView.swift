// NatalChartView.swift
// Luminous Cosmic Architecture™ — macOS Natal Chart
// Full-screen zodiac wheel with houses, planets, and aspect lines

import SwiftUI

struct NatalChartView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedPlanet: PlanetPlacement?
    @State private var showAspects: Bool = true
    @State private var animateChart: Bool = false
    @State private var rotationAngle: Double = 0

    var body: some View {
        HSplitView {
            // Chart canvas
            chartArea
                .frame(minWidth: 500)

            // Detail panel
            detailPanel
                .frame(width: 280)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.2)) {
                animateChart = true
            }
        }
    }

    // MARK: - Chart Area

    private var chartArea: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height) - 80
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)

            ZStack {
                Canvas { context, canvasSize in
                    let mid = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)
                    let outerRadius = size / 2
                    let zodiacInner = outerRadius * 0.82
                    let houseOuter = zodiacInner
                    let houseInner = outerRadius * 0.35
                    let planetRing = outerRadius * 0.68

                    // Outer ring
                    drawRing(context: context, center: mid, outerR: outerRadius, innerR: zodiacInner,
                             color: appState.isNightMode ? ResonanceMacTheme.Colors.forestMid : ResonanceMacTheme.Colors.forestLight)

                    // Zodiac sign divisions and glyphs
                    for i in 0..<12 {
                        let angle = Angle.degrees(Double(i) * 30 - 90 + rotationAngle)
                        let midAngle = Angle.degrees(Double(i) * 30 + 15 - 90 + rotationAngle)

                        // Division lines
                        let lineStart = pointOnCircle(center: mid, radius: zodiacInner, angle: angle)
                        let lineEnd = pointOnCircle(center: mid, radius: outerRadius, angle: angle)
                        var linePath = Path()
                        linePath.move(to: lineStart)
                        linePath.addLine(to: lineEnd)
                        context.stroke(linePath, with: .color(ResonanceMacTheme.Colors.gold.opacity(0.4)), lineWidth: 0.5)

                        // Zodiac glyphs
                        let glyphPos = pointOnCircle(center: mid, radius: (outerRadius + zodiacInner) / 2, angle: midAngle)
                        let glyph = ZodiacGlyph.all[i].glyph
                        context.draw(
                            Text(glyph)
                                .font(.system(size: 14, weight: .light))
                                .foregroundColor(ResonanceMacTheme.Colors.goldLight),
                            at: glyphPos
                        )
                    }

                    // House divisions
                    for i in 0..<12 {
                        let houseAngle = Angle.degrees(sampleHouseCusps[i] - 90 + rotationAngle)
                        let start = pointOnCircle(center: mid, radius: houseInner, angle: houseAngle)
                        let end = pointOnCircle(center: mid, radius: houseOuter, angle: houseAngle)
                        var housePath = Path()
                        housePath.move(to: start)
                        housePath.addLine(to: end)

                        let lineWidth: CGFloat = (i == 0 || i == 3 || i == 6 || i == 9) ? 1.5 : 0.5
                        let opacity: Double = (i == 0 || i == 3 || i == 6 || i == 9) ? 0.6 : 0.25
                        context.stroke(housePath, with: .color(ResonanceMacTheme.Colors.mutedGreen.opacity(opacity)), lineWidth: lineWidth)

                        // House numbers
                        let nextCusp = sampleHouseCusps[(i + 1) % 12]
                        let currentCusp = sampleHouseCusps[i]
                        var midDeg = (currentCusp + nextCusp) / 2
                        if nextCusp < currentCusp { midDeg = (currentCusp + nextCusp + 360) / 2 }
                        let numAngle = Angle.degrees(midDeg - 90 + rotationAngle)
                        let numPos = pointOnCircle(center: mid, radius: houseInner + 14, angle: numAngle)
                        context.draw(
                            Text("\(i + 1)")
                                .font(.system(size: 9, weight: .regular))
                                .foregroundColor(ResonanceMacTheme.Colors.mutedGreenLight.opacity(0.6)),
                            at: numPos
                        )
                    }

                    // Inner circle
                    let innerCirclePath = Path(ellipseIn: CGRect(
                        x: mid.x - houseInner, y: mid.y - houseInner,
                        width: houseInner * 2, height: houseInner * 2
                    ))
                    context.stroke(innerCirclePath, with: .color(ResonanceMacTheme.Colors.gold.opacity(0.2)), lineWidth: 0.5)

                    // Aspect lines
                    if showAspects {
                        drawAspectLines(context: context, center: mid, radius: planetRing * 0.9)
                    }

                    // Planet ring circle
                    let planetCircle = Path(ellipseIn: CGRect(
                        x: mid.x - planetRing, y: mid.y - planetRing,
                        width: planetRing * 2, height: planetRing * 2
                    ))
                    context.stroke(planetCircle, with: .color(ResonanceMacTheme.Colors.gold.opacity(0.1)), lineWidth: 0.5)
                }
                .opacity(animateChart ? 1 : 0)
                .scaleEffect(animateChart ? 1 : 0.9)

                // Planet markers (as SwiftUI views for interactivity)
                ForEach(samplePlanetPlacements) { planet in
                    let angle = Angle.degrees(planet.degree - 90 + rotationAngle)
                    let radius = (size / 2) * 0.68
                    let pos = pointOnCircle(center: center, radius: radius, angle: angle)

                    PlanetMarker(planet: planet, isSelected: selectedPlanet?.id == planet.id)
                        .position(pos)
                        .onTapGesture {
                            withAnimation(ResonanceMacTheme.Animation.spring) {
                                selectedPlanet = planet
                            }
                        }
                }
                .opacity(animateChart ? 1 : 0)
            }
        }
    }

    // MARK: - Detail Panel

    private var detailPanel: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: ResonanceMacTheme.Spacing.lg) {
                Text("Chart Details")
                    .font(ResonanceMacTheme.Typography.title2)
                    .foregroundStyle(
                        appState.isNightMode
                            ? ResonanceMacTheme.Colors.cream
                            : ResonanceMacTheme.Colors.forestDeep
                    )

                // Controls
                VStack(spacing: ResonanceMacTheme.Spacing.sm) {
                    Toggle("Show Aspects", isOn: $showAspects)
                        .font(ResonanceMacTheme.Typography.body)
                        .tint(ResonanceMacTheme.Colors.gold)

                    HStack {
                        Text("Rotate")
                            .font(ResonanceMacTheme.Typography.caption)
                            .foregroundStyle(ResonanceMacTheme.Colors.mutedGreen)
                        Slider(value: $rotationAngle, in: 0...360)
                            .tint(ResonanceMacTheme.Colors.gold)
                    }
                }
                .padding()
                .glassmorphism(isNightMode: appState.isNightMode)

                // Selected planet detail
                if let planet = selectedPlanet {
                    selectedPlanetDetail(planet)
                }

                // Planet list
                VStack(alignment: .leading, spacing: ResonanceMacTheme.Spacing.sm) {
                    Text("Placements")
                        .font(ResonanceMacTheme.Typography.headline)
                        .foregroundStyle(
                            appState.isNightMode
                                ? ResonanceMacTheme.Colors.cream
                                : ResonanceMacTheme.Colors.forestDeep
                        )

                    ForEach(samplePlanetPlacements) { planet in
                        Button(action: {
                            withAnimation(ResonanceMacTheme.Animation.spring) {
                                selectedPlanet = planet
                            }
                        }) {
                            HStack {
                                Text(planet.glyph)
                                    .font(.system(size: 16))
                                    .frame(width: 24)

                                Text(planet.name)
                                    .font(ResonanceMacTheme.Typography.body)
                                    .foregroundStyle(
                                        appState.isNightMode
                                            ? ResonanceMacTheme.Colors.cream
                                            : ResonanceMacTheme.Colors.forestDeep
                                    )

                                Spacer()

                                Text(planet.signName)
                                    .font(ResonanceMacTheme.Typography.caption)
                                    .foregroundStyle(ResonanceMacTheme.Colors.gold)

                                Text(planet.formattedDegree)
                                    .font(ResonanceMacTheme.Typography.data)
                                    .foregroundStyle(ResonanceMacTheme.Colors.mutedGreen)
                            }
                            .padding(.vertical, 4)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
                .glassmorphism(isNightMode: appState.isNightMode)
            }
            .padding(ResonanceMacTheme.Spacing.md)
        }
        .background(
            appState.isNightMode
                ? ResonanceMacTheme.Colors.nightBackground.opacity(0.3)
                : ResonanceMacTheme.Colors.creamWarm.opacity(0.5)
        )
    }

    private func selectedPlanetDetail(_ planet: PlanetPlacement) -> some View {
        VStack(alignment: .leading, spacing: ResonanceMacTheme.Spacing.sm) {
            HStack {
                Text(planet.glyph)
                    .font(.system(size: 24))
                Text(planet.name)
                    .font(ResonanceMacTheme.Typography.title3)
                    .foregroundStyle(
                        appState.isNightMode
                            ? ResonanceMacTheme.Colors.cream
                            : ResonanceMacTheme.Colors.forestDeep
                    )
            }

            HStack {
                Label(planet.signName, systemImage: "sparkle")
                    .font(ResonanceMacTheme.Typography.callout)
                    .foregroundStyle(ResonanceMacTheme.Colors.gold)

                Text("\u{2022}")
                    .foregroundStyle(ResonanceMacTheme.Colors.mutedGreenLight)

                Text("House \(planet.house)")
                    .font(ResonanceMacTheme.Typography.callout)
                    .foregroundStyle(ResonanceMacTheme.Colors.mutedGreen)
            }

            Text(planet.interpretation)
                .font(ResonanceMacTheme.Typography.body)
                .foregroundStyle(ResonanceMacTheme.Colors.mutedGreen)
                .lineSpacing(4)
        }
        .padding()
        .glassmorphism(isNightMode: appState.isNightMode)
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
    }

    // MARK: - Drawing Helpers

    private func pointOnCircle(center: CGPoint, radius: CGFloat, angle: Angle) -> CGPoint {
        CGPoint(
            x: center.x + radius * CGFloat(cos(angle.radians)),
            y: center.y + radius * CGFloat(sin(angle.radians))
        )
    }

    private func drawRing(context: GraphicsContext, center: CGPoint, outerR: CGFloat, innerR: CGFloat, color: Color) {
        var outerPath = Path()
        outerPath.addArc(center: center, radius: outerR, startAngle: .zero, endAngle: .degrees(360), clockwise: false)
        context.fill(outerPath, with: .color(color.opacity(0.15)))
        context.stroke(outerPath, with: .color(ResonanceMacTheme.Colors.gold.opacity(0.3)), lineWidth: 1)

        var innerPath = Path()
        innerPath.addArc(center: center, radius: innerR, startAngle: .zero, endAngle: .degrees(360), clockwise: false)
        context.stroke(innerPath, with: .color(ResonanceMacTheme.Colors.gold.opacity(0.2)), lineWidth: 0.5)
    }

    private func drawAspectLines(context: GraphicsContext, center: CGPoint, radius: CGFloat) {
        let aspects: [(Int, Int, Color, CGFloat)] = [
            (0, 4, .red.opacity(0.25), 1.0),       // Sun opposite Neptune
            (1, 3, .blue.opacity(0.25), 0.8),       // Moon trine Mars
            (2, 5, .green.opacity(0.25), 0.8),      // Mercury sextile Jupiter
            (0, 7, .purple.opacity(0.2), 0.6),      // Sun square Uranus
            (3, 6, .orange.opacity(0.2), 0.6),      // Mars conjunct Saturn
        ]

        let planets = samplePlanetPlacements
        for (i, j, color, width) in aspects {
            guard i < planets.count, j < planets.count else { continue }
            let angle1 = Angle.degrees(planets[i].degree - 90 + rotationAngle)
            let angle2 = Angle.degrees(planets[j].degree - 90 + rotationAngle)
            let p1 = pointOnCircle(center: center, radius: radius, angle: angle1)
            let p2 = pointOnCircle(center: center, radius: radius, angle: angle2)

            var path = Path()
            path.move(to: p1)
            path.addLine(to: p2)
            context.stroke(path, with: .color(color), style: StrokeStyle(lineWidth: width, dash: [4, 3]))
        }
    }

    // MARK: - Sample Data

    private var sampleHouseCusps: [Double] {
        [0, 30, 60, 90, 120, 150, 180, 210, 240, 270, 300, 330]
    }

    private var samplePlanetPlacements: [PlanetPlacement] {
        [
            PlanetPlacement(name: "Sun", glyph: PlanetGlyph.sun, degree: 350, signName: "Pisces", house: 10, interpretation: "Your core identity seeks transcendence and compassion. In the 10th house, your public life radiates spiritual depth."),
            PlanetPlacement(name: "Moon", glyph: PlanetGlyph.moon, degree: 215, signName: "Scorpio", house: 5, interpretation: "Emotional depth runs through your creative expression. You feel most alive when exploring hidden truths."),
            PlanetPlacement(name: "Mercury", glyph: PlanetGlyph.mercury, degree: 338, signName: "Pisces", house: 10, interpretation: "Your mind flows with intuition and imagination, communicating through feeling rather than logic."),
            PlanetPlacement(name: "Venus", glyph: PlanetGlyph.venus, degree: 15, signName: "Aries", house: 11, interpretation: "Love is passionate, direct, and pioneering. You attract through bold authenticity."),
            PlanetPlacement(name: "Mars", glyph: PlanetGlyph.mars, degree: 142, signName: "Leo", house: 3, interpretation: "Your drive expresses dramatically. Communication is passionate and warm."),
            PlanetPlacement(name: "Jupiter", glyph: PlanetGlyph.jupiter, degree: 68, signName: "Gemini", house: 1, interpretation: "Expansion through knowledge and versatility. Your presence is curious and communicative."),
            PlanetPlacement(name: "Saturn", glyph: PlanetGlyph.saturn, degree: 148, signName: "Leo", house: 3, interpretation: "Discipline in creative self-expression. Learning to structure your natural warmth."),
            PlanetPlacement(name: "Uranus", glyph: PlanetGlyph.uranus, degree: 82, signName: "Gemini", house: 1, interpretation: "Revolutionary thinking defines your identity. You break patterns through ideas."),
            PlanetPlacement(name: "Neptune", glyph: PlanetGlyph.neptune, degree: 170, signName: "Virgo", house: 4, interpretation: "Spiritual foundations in practical service. Home is a sanctuary of healing."),
            PlanetPlacement(name: "Pluto", glyph: PlanetGlyph.pluto, degree: 128, signName: "Leo", house: 3, interpretation: "Transformative power through creative communication and self-expression."),
        ]
    }
}

// MARK: - Planet Placement Model

struct PlanetPlacement: Identifiable {
    let id = UUID()
    let name: String
    let glyph: String
    let degree: Double
    let signName: String
    let house: Int
    let interpretation: String

    var formattedDegree: String {
        let signDegree = Int(degree) % 30
        return "\(signDegree)\u{00B0}"
    }
}

// MARK: - Planet Marker View

struct PlanetMarker: View {
    let planet: PlanetPlacement
    let isSelected: Bool

    var body: some View {
        ZStack {
            if isSelected {
                Circle()
                    .fill(ResonanceMacTheme.Colors.gold.opacity(0.2))
                    .frame(width: 36, height: 36)

                Circle()
                    .strokeBorder(ResonanceMacTheme.Colors.gold, lineWidth: 1.5)
                    .frame(width: 36, height: 36)
            }

            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            ResonanceMacTheme.Colors.forestLight,
                            ResonanceMacTheme.Colors.forestDeep
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 12
                    )
                )
                .frame(width: 24, height: 24)
                .overlay(
                    Circle()
                        .strokeBorder(ResonanceMacTheme.Colors.gold.opacity(0.6), lineWidth: 1)
                )

            Text(planet.glyph)
                .font(.system(size: 12, weight: .light))
                .foregroundStyle(ResonanceMacTheme.Colors.goldLight)
        }
        .scaleEffect(isSelected ? 1.15 : 1.0)
        .animation(ResonanceMacTheme.Animation.spring, value: isSelected)
    }
}
