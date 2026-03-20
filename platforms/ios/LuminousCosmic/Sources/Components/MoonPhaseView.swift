// MoonPhaseView.swift
// Luminous Cosmic Architecture™
// Moon Phase Display Component

import SwiftUI

// MARK: - Moon Phase View

struct MoonPhaseView: View {
    let phase: MoonPhase
    var size: CGFloat = 80
    var showDetails: Bool = true

    @Environment(\.resonanceTheme) var theme
    @State private var glow = false

    var body: some View {
        VStack(spacing: ResonanceSpacing.md) {
            ZStack {
                // Outer glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                ResonanceColors.goldLight.opacity(glow ? 0.15 : 0.05),
                                .clear
                            ],
                            center: .center,
                            startRadius: size * 0.3,
                            endRadius: size * 0.8
                        )
                    )
                    .frame(width: size * 1.8, height: size * 1.8)

                // Moon body
                MoonShape(phase: phase, size: size)

                // Surface texture
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                .clear,
                                Color.black.opacity(0.05)
                            ],
                            center: UnitPoint(x: 0.6, y: 0.4),
                            startRadius: size * 0.1,
                            endRadius: size * 0.5
                        )
                    )
                    .frame(width: size, height: size)
            }

            if showDetails {
                VStack(spacing: ResonanceSpacing.xxs) {
                    Text(phase.rawValue)
                        .font(ResonanceTypography.headlineSmall)
                        .foregroundColor(theme.textPrimary)

                    Text(phase.ritual)
                        .font(ResonanceTypography.bodySmall)
                        .foregroundColor(theme.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
            }
        }
        .onAppear {
            withAnimation(ResonanceAnimation.breathe) {
                glow = true
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(phase.rawValue). \(phase.ritual)")
    }
}

// MARK: - Moon Shape

struct MoonShape: View {
    let phase: MoonPhase
    let size: CGFloat

    var body: some View {
        ZStack {
            // Full moon circle (dark side)
            Circle()
                .fill(Color(hex: "2A2A3A").opacity(0.9))
                .frame(width: size, height: size)

            // Illuminated portion
            Canvas { context, canvasSize in
                let center = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)
                let radius = min(canvasSize.width, canvasSize.height) / 2

                let illuminatedPath = moonIlluminationPath(
                    center: center,
                    radius: radius,
                    phase: phase
                )

                context.fill(
                    illuminatedPath,
                    with: .linearGradient(
                        Gradient(colors: [
                            Color(hex: "E8E4D8"),
                            Color(hex: "D4CFC0"),
                            Color(hex: "C8C2B2")
                        ]),
                        startPoint: CGPoint(x: 0, y: 0),
                        endPoint: CGPoint(x: canvasSize.width, y: canvasSize.height)
                    )
                )
            }
            .frame(width: size, height: size)
            .clipShape(Circle())

            // Subtle rim light
            Circle()
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            ResonanceColors.goldLight.opacity(0.4),
                            ResonanceColors.goldLight.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
                .frame(width: size, height: size)
        }
        .shadow(color: ResonanceColors.goldLight.opacity(0.2), radius: 10)
    }

    private func moonIlluminationPath(center: CGPoint, radius: CGFloat, phase: MoonPhase) -> Path {
        var path = Path()
        let illumination = phase.illumination

        switch phase {
        case .newMoon:
            // No illumination
            return path

        case .fullMoon:
            path.addEllipse(in: CGRect(
                x: center.x - radius,
                y: center.y - radius,
                width: radius * 2,
                height: radius * 2
            ))
            return path

        case .waxingCrescent, .waxingGibbous:
            // Right side illuminated
            path.addArc(
                center: center,
                radius: radius,
                startAngle: .degrees(-90),
                endAngle: .degrees(90),
                clockwise: false
            )

            let curveOffset = radius * CGFloat(1 - illumination * 2)
            path.addCurve(
                to: CGPoint(x: center.x, y: center.y - radius),
                control1: CGPoint(x: center.x + curveOffset, y: center.y + radius * 0.55),
                control2: CGPoint(x: center.x + curveOffset, y: center.y - radius * 0.55)
            )
            return path

        case .firstQuarter:
            // Right half illuminated
            path.addArc(
                center: center,
                radius: radius,
                startAngle: .degrees(-90),
                endAngle: .degrees(90),
                clockwise: false
            )
            path.addLine(to: CGPoint(x: center.x, y: center.y - radius))
            return path

        case .waningCrescent, .waningGibbous:
            // Left side illuminated
            path.addArc(
                center: center,
                radius: radius,
                startAngle: .degrees(90),
                endAngle: .degrees(-90),
                clockwise: false
            )

            let curveOffset = radius * CGFloat(1 - illumination * 2)
            path.addCurve(
                to: CGPoint(x: center.x, y: center.y + radius),
                control1: CGPoint(x: center.x - curveOffset, y: center.y - radius * 0.55),
                control2: CGPoint(x: center.x - curveOffset, y: center.y + radius * 0.55)
            )
            return path

        case .lastQuarter:
            // Left half illuminated
            path.addArc(
                center: center,
                radius: radius,
                startAngle: .degrees(90),
                endAngle: .degrees(-90),
                clockwise: false
            )
            path.addLine(to: CGPoint(x: center.x, y: center.y + radius))
            return path
        }
    }
}

// MARK: - Compact Moon Phase

struct MoonPhaseCompact: View {
    let phase: MoonPhase

    @Environment(\.resonanceTheme) var theme

    var body: some View {
        HStack(spacing: ResonanceSpacing.sm) {
            MoonShape(phase: phase, size: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(phase.rawValue)
                    .font(ResonanceTypography.bodySmall)
                    .fontWeight(.medium)
                    .foregroundColor(theme.textPrimary)

                Text(phase.ritual)
                    .font(ResonanceTypography.caption)
                    .foregroundColor(theme.textTertiary)
                    .lineLimit(1)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(phase.rawValue): \(phase.ritual)")
    }
}

// MARK: - Moon Phase Ring

struct MoonPhaseRing: View {
    let currentPhase: MoonPhase
    var size: CGFloat = 200

    @Environment(\.resonanceTheme) var theme

    var body: some View {
        ZStack {
            // Ring track
            Circle()
                .strokeBorder(theme.border, lineWidth: 1)
                .frame(width: size, height: size)

            // Phase indicators around the ring
            ForEach(Array(MoonPhase.allCases.enumerated()), id: \.element.rawValue) { index, phase in
                let angle = Double(index) / Double(MoonPhase.allCases.count) * 360 - 90
                let radians = angle * .pi / 180
                let radius = size / 2 - 15

                MoonShape(phase: phase, size: phase == currentPhase ? 22 : 14)
                    .opacity(phase == currentPhase ? 1.0 : 0.5)
                    .position(
                        x: size / 2 + cos(radians) * radius,
                        y: size / 2 + sin(radians) * radius
                    )
            }

            // Current phase label
            VStack(spacing: 4) {
                Text(currentPhase.rawValue)
                    .font(ResonanceTypography.caption)
                    .foregroundColor(theme.textSecondary)
            }
        }
        .frame(width: size, height: size)
    }
}
