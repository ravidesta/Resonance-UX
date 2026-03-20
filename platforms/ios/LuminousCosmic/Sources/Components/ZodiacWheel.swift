// ZodiacWheel.swift
// Luminous Cosmic Architecture™
// Reusable Zodiac Wheel Component with SwiftUI Path Drawing

import SwiftUI

// MARK: - Zodiac Wheel

struct ZodiacWheel: View {
    let chart: NatalChart?
    var size: CGFloat = 320
    var showPlanets: Bool = true
    var showHouses: Bool = true
    var showAspects: Bool = true
    var interactive: Bool = false

    @Environment(\.resonanceTheme) var theme
    @State private var selectedPlanet: Planet? = nil
    @State private var rotationAngle: Double = 0
    @State private var revealProgress: CGFloat = 0

    private var center: CGPoint { CGPoint(x: size / 2, y: size / 2) }
    private var outerRadius: CGFloat { size / 2 - 8 }
    private var zodiacRingOuter: CGFloat { outerRadius }
    private var zodiacRingInner: CGFloat { outerRadius - size * 0.1 }
    private var houseRingOuter: CGFloat { zodiacRingInner }
    private var houseRingInner: CGFloat { zodiacRingInner - size * 0.06 }
    private var planetRingRadius: CGFloat { houseRingInner - size * 0.06 }
    private var aspectCircleRadius: CGFloat { planetRingRadius - size * 0.08 }

    var body: some View {
        ZStack {
            Canvas { context, canvasSize in
                let center = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)

                // Draw zodiac ring segments
                drawZodiacRing(context: &context, center: center)

                // Draw house lines
                if showHouses, let chart = chart {
                    drawHouseLines(context: &context, center: center, houses: chart.houses)
                }

                // Draw aspect circle
                if showAspects {
                    drawAspectCircle(context: &context, center: center)
                }

                // Draw aspect lines
                if showAspects, let chart = chart {
                    drawAspectLines(context: &context, center: center, chart: chart)
                }

                // Draw degree markers
                drawDegreeMarkers(context: &context, center: center)
            }
            .frame(width: size, height: size)

            // Planet glyphs overlay (as SwiftUI views for interactivity)
            if showPlanets, let chart = chart {
                ForEach(chart.planets) { position in
                    planetMarker(for: position)
                }
            }

            // Center emblem
            CenterEmblem(size: aspectCircleRadius * 0.6, theme: theme)
                .position(center)
        }
        .frame(width: size, height: size)
        .rotationEffect(.degrees(rotationAngle))
        .onAppear {
            withAnimation(.easeOut(duration: 1.2)) {
                revealProgress = 1.0
            }
        }
        .accessibilityLabel("Natal chart zodiac wheel")
        .accessibilityHint(chart != nil ? "Showing \(chart!.planets.count) planetary positions" : "No chart data")
    }

    // MARK: - Zodiac Ring

    private func drawZodiacRing(context: inout GraphicsContext, center: CGPoint) {
        for sign in ZodiacSign.allCases {
            let startAngle = signStartAngle(sign)
            let endAngle = startAngle + 30

            // Segment background
            var segmentPath = Path()
            segmentPath.addArc(
                center: center,
                radius: zodiacRingOuter,
                startAngle: .degrees(startAngle - 90),
                endAngle: .degrees(endAngle - 90),
                clockwise: false
            )
            segmentPath.addArc(
                center: center,
                radius: zodiacRingInner,
                startAngle: .degrees(endAngle - 90),
                endAngle: .degrees(startAngle - 90),
                clockwise: true
            )
            segmentPath.closeSubpath()

            // Alternate segment colors
            let elementColor = sign.element.color
            let fillOpacity = sign.rawValue % 2 == 0 ? 0.12 : 0.06
            context.fill(
                segmentPath,
                with: .color(elementColor.opacity(fillOpacity * Double(revealProgress)))
            )

            // Segment border
            context.stroke(
                segmentPath,
                with: .color(theme.border.opacity(0.5)),
                lineWidth: 0.5
            )

            // Zodiac glyph
            let midAngle = (startAngle + 15 - 90) * .pi / 180
            let glyphRadius = (zodiacRingOuter + zodiacRingInner) / 2
            let glyphPos = CGPoint(
                x: center.x + cos(midAngle) * glyphRadius,
                y: center.y + sin(midAngle) * glyphRadius
            )

            context.draw(
                Text(sign.glyph)
                    .font(.system(size: size * 0.035))
                    .foregroundColor(elementColor),
                at: glyphPos
            )
        }

        // Outer ring border
        context.stroke(
            Path(ellipseIn: CGRect(
                x: center.x - zodiacRingOuter,
                y: center.y - zodiacRingOuter,
                width: zodiacRingOuter * 2,
                height: zodiacRingOuter * 2
            )),
            with: .color(theme.accent.opacity(0.4)),
            lineWidth: 1.5
        )

        // Inner ring border
        context.stroke(
            Path(ellipseIn: CGRect(
                x: center.x - zodiacRingInner,
                y: center.y - zodiacRingInner,
                width: zodiacRingInner * 2,
                height: zodiacRingInner * 2
            )),
            with: .color(theme.border.opacity(0.6)),
            lineWidth: 1
        )
    }

    // MARK: - House Lines

    private func drawHouseLines(context: inout GraphicsContext, center: CGPoint, houses: [House]) {
        // House ring
        context.stroke(
            Path(ellipseIn: CGRect(
                x: center.x - houseRingInner,
                y: center.y - houseRingInner,
                width: houseRingInner * 2,
                height: houseRingInner * 2
            )),
            with: .color(theme.border.opacity(0.4)),
            lineWidth: 0.5
        )

        for house in houses {
            let angle = (house.cuspDegree - 90) * .pi / 180

            // House cusp line
            var linePath = Path()
            let innerPoint = CGPoint(
                x: center.x + cos(angle) * aspectCircleRadius,
                y: center.y + sin(angle) * aspectCircleRadius
            )
            let outerPoint = CGPoint(
                x: center.x + cos(angle) * zodiacRingInner,
                y: center.y + sin(angle) * zodiacRingInner
            )

            linePath.move(to: innerPoint)
            linePath.addLine(to: outerPoint)

            let isAngular = [1, 4, 7, 10].contains(house.number)
            context.stroke(
                linePath,
                with: .color(theme.isDark
                    ? ResonanceColors.goldPrimary.opacity(isAngular ? 0.5 : 0.2)
                    : ResonanceColors.forestMid.opacity(isAngular ? 0.5 : 0.2)),
                lineWidth: isAngular ? 1.5 : 0.75
            )

            // House number
            let labelAngle = angle + (15 * .pi / 180)
            let labelRadius = (houseRingOuter + houseRingInner) / 2
            let labelPos = CGPoint(
                x: center.x + cos(labelAngle) * labelRadius,
                y: center.y + sin(labelAngle) * labelRadius
            )

            context.draw(
                Text(house.romanNumeral)
                    .font(.system(size: size * 0.022, weight: .medium))
                    .foregroundColor(theme.textTertiary),
                at: labelPos
            )
        }
    }

    // MARK: - Aspect Lines

    private func drawAspectCircle(context: inout GraphicsContext, center: CGPoint) {
        context.stroke(
            Path(ellipseIn: CGRect(
                x: center.x - aspectCircleRadius,
                y: center.y - aspectCircleRadius,
                width: aspectCircleRadius * 2,
                height: aspectCircleRadius * 2
            )),
            with: .color(theme.border.opacity(0.2)),
            lineWidth: 0.5
        )
    }

    private func drawAspectLines(context: inout GraphicsContext, center: CGPoint, chart: NatalChart) {
        for aspect in chart.aspects {
            guard let pos1 = chart.planets.first(where: { $0.planet == aspect.planet1 }),
                  let pos2 = chart.planets.first(where: { $0.planet == aspect.planet2 })
            else { continue }

            let angle1 = (pos1.longitude - 90) * .pi / 180
            let angle2 = (pos2.longitude - 90) * .pi / 180
            let radius = aspectCircleRadius

            let point1 = CGPoint(
                x: center.x + cos(angle1) * radius,
                y: center.y + sin(angle1) * radius
            )
            let point2 = CGPoint(
                x: center.x + cos(angle2) * radius,
                y: center.y + sin(angle2) * radius
            )

            var aspectPath = Path()
            aspectPath.move(to: point1)
            aspectPath.addLine(to: point2)

            let opacity = max(0.15, 0.5 - aspect.orb / 10.0) * Double(revealProgress)

            context.stroke(
                aspectPath,
                with: .color(aspect.type.color.opacity(opacity)),
                style: aspect.type.lineStyle
            )
        }
    }

    // MARK: - Degree Markers

    private func drawDegreeMarkers(context: inout GraphicsContext, center: CGPoint) {
        for degree in 0..<360 {
            let angle = (Double(degree) - 90) * .pi / 180
            let isMajor = degree % 30 == 0
            let isMinor = degree % 10 == 0
            let isTick = degree % 5 == 0

            guard isTick else { continue }

            let outerR = zodiacRingOuter
            let innerR: CGFloat

            if isMajor {
                innerR = zodiacRingOuter - 6
            } else if isMinor {
                innerR = zodiacRingOuter - 4
            } else {
                innerR = zodiacRingOuter - 2.5
            }

            var tickPath = Path()
            tickPath.move(to: CGPoint(
                x: center.x + cos(angle) * outerR,
                y: center.y + sin(angle) * outerR
            ))
            tickPath.addLine(to: CGPoint(
                x: center.x + cos(angle) * innerR,
                y: center.y + sin(angle) * innerR
            ))

            context.stroke(
                tickPath,
                with: .color(theme.accent.opacity(isMajor ? 0.5 : 0.2)),
                lineWidth: isMajor ? 1 : 0.5
            )
        }
    }

    // MARK: - Planet Marker

    @ViewBuilder
    private func planetMarker(for position: PlanetaryPosition) -> some View {
        let angle = (position.longitude - 90) * .pi / 180
        let x = center.x + cos(angle) * planetRingRadius
        let y = center.y + sin(angle) * planetRingRadius

        Button {
            withAnimation(ResonanceAnimation.springBouncy) {
                selectedPlanet = selectedPlanet == position.planet ? nil : position.planet
            }
            ResonanceHaptics.light()
        } label: {
            ZStack {
                if selectedPlanet == position.planet {
                    Circle()
                        .fill(position.planet.color.opacity(0.2))
                        .frame(width: size * 0.08, height: size * 0.08)
                        .blur(radius: 4)
                }

                Circle()
                    .fill(theme.surface.opacity(0.85))
                    .frame(width: size * 0.055, height: size * 0.055)

                Circle()
                    .strokeBorder(position.planet.color.opacity(0.6), lineWidth: 0.75)
                    .frame(width: size * 0.055, height: size * 0.055)

                Text(position.planet.glyph)
                    .font(.system(size: size * 0.028))
                    .foregroundColor(position.planet.color)
            }
        }
        .buttonStyle(.plain)
        .position(x: x, y: y)
        .accessibilityLabel("\(position.planet.name) at \(position.formattedPosition)")
    }

    // MARK: - Helpers

    private func signStartAngle(_ sign: ZodiacSign) -> Double {
        // Offset so that the ascendant (if available) is at 9 o'clock
        let ascOffset = chart?.planets.first(where: { $0.planet == .ascendant })?.longitude ?? 0
        return Double(sign.rawValue) * 30 - ascOffset
    }
}

// MARK: - Center Emblem

struct CenterEmblem: View {
    let size: CGFloat
    let theme: ResonanceTheme

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            theme.surface.opacity(0.9),
                            theme.surfaceElevated.opacity(0.7)
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: size / 2
                    )
                )
                .frame(width: size, height: size)

            Circle()
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            ResonanceColors.goldLight.opacity(0.4),
                            ResonanceColors.goldDark.opacity(0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
                .frame(width: size, height: size)

            // Inner star pattern
            StarPattern(size: size * 0.5)
                .foregroundColor(ResonanceColors.goldPrimary.opacity(0.3))
        }
    }
}

// MARK: - Star Pattern

struct StarPattern: View {
    let size: CGFloat

    var body: some View {
        Canvas { context, canvasSize in
            let center = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)
            let radius = min(canvasSize.width, canvasSize.height) / 2

            // Six-pointed star
            var starPath = Path()
            for i in 0..<6 {
                let angle = Double(i) * 60 - 90
                let rad = angle * .pi / 180
                let point = CGPoint(
                    x: center.x + cos(rad) * radius,
                    y: center.y + sin(rad) * radius
                )

                if i == 0 {
                    starPath.move(to: point)
                } else {
                    starPath.addLine(to: point)
                }
            }
            starPath.closeSubpath()

            context.stroke(starPath, with: .foreground, lineWidth: 0.75)

            // Inner hexagram
            var innerPath = Path()
            for i in 0..<6 {
                let angle = Double(i) * 60 - 60
                let rad = angle * .pi / 180
                let point = CGPoint(
                    x: center.x + cos(rad) * radius,
                    y: center.y + sin(rad) * radius
                )

                if i == 0 {
                    innerPath.move(to: point)
                } else {
                    innerPath.addLine(to: point)
                }
            }
            innerPath.closeSubpath()

            context.stroke(innerPath, with: .foreground, lineWidth: 0.75)
        }
        .frame(width: size, height: size)
    }
}
