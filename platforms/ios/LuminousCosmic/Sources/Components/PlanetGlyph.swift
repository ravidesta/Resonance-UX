// PlanetGlyph.swift
// Luminous Cosmic Architecture™
// Planet Symbol Rendering Component

import SwiftUI

// MARK: - Planet Glyph View

struct PlanetGlyphView: View {
    let planet: Planet
    var size: CGFloat = 24
    var showLabel: Bool = false
    var style: GlyphStyle = .standard

    @Environment(\.resonanceTheme) var theme

    enum GlyphStyle {
        case standard
        case highlighted
        case subdued
        case onChart
    }

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                // Glow effect for highlighted style
                if style == .highlighted {
                    Circle()
                        .fill(planet.color.opacity(0.2))
                        .frame(width: size * 1.8, height: size * 1.8)
                        .blur(radius: 8)
                }

                // Background circle for chart placement
                if style == .onChart {
                    Circle()
                        .fill(theme.surface.opacity(0.9))
                        .frame(width: size * 1.4, height: size * 1.4)

                    Circle()
                        .strokeBorder(planet.color.opacity(0.5), lineWidth: 1)
                        .frame(width: size * 1.4, height: size * 1.4)
                }

                // Planet glyph
                Text(planet.glyph)
                    .font(.system(size: glyphFontSize, weight: .regular))
                    .foregroundColor(glyphColor)
                    .shadow(color: planet.color.opacity(0.3), radius: style == .highlighted ? 4 : 0)
            }
            .frame(width: size * 1.5, height: size * 1.5)

            if showLabel {
                Text(planet.name)
                    .font(ResonanceTypography.caption)
                    .foregroundColor(theme.textSecondary)
            }
        }
        .accessibilityLabel("\(planet.name) planet glyph")
    }

    private var glyphFontSize: CGFloat {
        switch style {
        case .standard: return size
        case .highlighted: return size * 1.1
        case .subdued: return size * 0.9
        case .onChart: return size * 0.85
        }
    }

    private var glyphColor: Color {
        switch style {
        case .standard: return planet.color
        case .highlighted: return planet.color
        case .subdued: return theme.textTertiary
        case .onChart: return planet.color
        }
    }
}

// MARK: - Planet Position Badge

struct PlanetPositionBadge: View {
    let position: PlanetaryPosition
    var compact: Bool = false

    @Environment(\.resonanceTheme) var theme

    var body: some View {
        HStack(spacing: ResonanceSpacing.xs) {
            PlanetGlyphView(
                planet: position.planet,
                size: compact ? 16 : 20,
                style: .standard
            )

            VStack(alignment: .leading, spacing: 2) {
                if !compact {
                    Text(position.planet.name)
                        .font(ResonanceTypography.bodySmall)
                        .foregroundColor(theme.textPrimary)
                }

                HStack(spacing: 4) {
                    Text(position.sign.glyph)
                        .font(.system(size: compact ? 12 : 14))

                    Text(formatDegree(position.degreeInSign))
                        .font(ResonanceTypography.caption)
                        .foregroundColor(theme.textSecondary)

                    if position.isRetrograde {
                        Text("R")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(ResonanceColors.fire)
                            .accessibilityLabel("retrograde")
                    }
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(position.formattedPosition)
    }

    private func formatDegree(_ deg: Double) -> String {
        let d = Int(deg)
        let m = Int((deg - Double(d)) * 60)
        return "\(d)\u{00B0}\(String(format: "%02d", m))'"
    }
}

// MARK: - Planet Row

struct PlanetRow: View {
    let position: PlanetaryPosition
    @Environment(\.resonanceTheme) var theme

    var body: some View {
        HStack(spacing: ResonanceSpacing.md) {
            PlanetGlyphView(
                planet: position.planet,
                size: 22,
                style: .highlighted
            )

            VStack(alignment: .leading, spacing: 2) {
                Text(position.planet.name)
                    .font(ResonanceTypography.headlineSmall)
                    .foregroundColor(theme.textPrimary)

                Text("in \(position.sign.name)")
                    .font(ResonanceTypography.bodyMedium)
                    .foregroundColor(theme.textSecondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(position.sign.glyph)
                    .font(.system(size: 18))
                    .foregroundColor(position.sign.color)

                HStack(spacing: 2) {
                    Text(formatDegree(position.degreeInSign))
                        .font(ResonanceTypography.caption)
                        .foregroundColor(theme.textTertiary)

                    if position.isRetrograde {
                        Image(systemName: "arrow.uturn.backward")
                            .font(.system(size: 10))
                            .foregroundColor(ResonanceColors.fire)
                    }
                }
            }
        }
        .padding(.vertical, ResonanceSpacing.xs)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(position.planet.name) in \(position.sign.name), \(position.formattedPosition)")
    }

    private func formatDegree(_ deg: Double) -> String {
        let d = Int(deg)
        let m = Int((deg - Double(d)) * 60)
        return "\(d)\u{00B0}\(String(format: "%02d", m))'"
    }
}

// MARK: - Zodiac Sign Badge

struct ZodiacSignBadge: View {
    let sign: ZodiacSign
    var size: CGFloat = 36
    var showName: Bool = true

    @Environment(\.resonanceTheme) var theme

    var body: some View {
        VStack(spacing: ResonanceSpacing.xxs) {
            ZStack {
                Circle()
                    .fill(sign.element.color.opacity(0.15))
                    .frame(width: size, height: size)

                Circle()
                    .strokeBorder(sign.element.color.opacity(0.3), lineWidth: 1)
                    .frame(width: size, height: size)

                Text(sign.glyph)
                    .font(.system(size: size * 0.5))
                    .foregroundColor(sign.element.color)
            }

            if showName {
                Text(sign.name)
                    .font(ResonanceTypography.caption)
                    .foregroundColor(theme.textSecondary)
            }
        }
        .accessibilityLabel("\(sign.name), \(sign.element.name) sign")
    }
}
