// WatchChartGlanceView.swift
// Luminous Cosmic Architecture™ — watchOS Chart Glance
// Simplified natal chart showing Sun, Moon, Rising with glyphs

import SwiftUI

struct WatchChartGlanceView: View {
    @EnvironmentObject var watchState: WatchState
    @State private var rotateWheel: Bool = false

    var body: some View {
        VStack(spacing: WatchTheme.Spacing.lg) {
            // Mini zodiac wheel
            ZStack {
                // Outer zodiac ring
                Circle()
                    .strokeBorder(WatchTheme.Colors.surfaceAccent, lineWidth: 2)
                    .frame(width: 90, height: 90)

                // Zodiac glyphs around the wheel
                ForEach(0..<12) { i in
                    let angle = Angle.degrees(Double(i) * 30 - 90)
                    let pos = pointOnCircle(radius: 45, angle: angle)

                    Text(WatchZodiacGlyph.all[i].glyph)
                        .font(.system(size: 8))
                        .foregroundStyle(
                            isHighlightedSign(WatchZodiacGlyph.all[i].name)
                                ? WatchTheme.Colors.gold
                                : WatchTheme.Colors.textTertiary
                        )
                        .offset(x: pos.x, y: pos.y)
                }

                // Inner circle
                Circle()
                    .fill(WatchTheme.Colors.surface)
                    .frame(width: 52, height: 52)
                    .overlay(
                        Circle()
                            .strokeBorder(WatchTheme.Colors.gold.opacity(0.2), lineWidth: 0.5)
                    )

                // Center sparkle
                Image(systemName: "sparkle")
                    .font(.system(size: 10, weight: .light))
                    .foregroundStyle(WatchTheme.Colors.gold.opacity(0.6))
                    .rotationEffect(.degrees(rotateWheel ? 360 : 0))

                // Planet markers on the wheel
                planetMarker(sign: watchState.sunSign, symbol: "\u{2609}", color: WatchTheme.Colors.goldLight)
                planetMarker(sign: watchState.moonSign, symbol: "\u{263D}", color: WatchTheme.Colors.textPrimary)
                planetMarker(sign: watchState.risingSign, symbol: "AC", color: WatchTheme.Colors.gold)
            }
            .frame(width: 100, height: 100)

            // Big Three
            VStack(spacing: WatchTheme.Spacing.md) {
                bigThreeRow(label: "Sun", sign: watchState.sunSign, glyph: "\u{2609}")
                bigThreeRow(label: "Moon", sign: watchState.moonSign, glyph: "\u{263D}")
                bigThreeRow(label: "Rising", sign: watchState.risingSign, glyph: "AC")
            }
        }
        .background(WatchTheme.Colors.background)
        .onAppear {
            withAnimation(.linear(duration: 60).repeatForever(autoreverses: false)) {
                rotateWheel = true
            }
        }
    }

    // MARK: - Big Three Row

    private func bigThreeRow(label: String, sign: String, glyph: String) -> some View {
        HStack(spacing: WatchTheme.Spacing.md) {
            ZStack {
                Circle()
                    .fill(WatchTheme.Colors.surfaceAccent)
                    .frame(width: 24, height: 24)

                Text(glyph)
                    .font(.system(size: 10))
                    .foregroundStyle(WatchTheme.Colors.gold)
            }

            VStack(alignment: .leading, spacing: 0) {
                Text(label)
                    .font(WatchTheme.Typography.caption2)
                    .foregroundStyle(WatchTheme.Colors.textTertiary)

                Text(sign)
                    .font(WatchTheme.Typography.headline)
                    .foregroundStyle(WatchTheme.Colors.textPrimary)
            }

            Spacer()

            Text(WatchZodiacGlyph.glyph(for: sign))
                .font(.system(size: 14))
                .foregroundStyle(WatchTheme.Colors.gold.opacity(0.7))
        }
        .padding(.horizontal, WatchTheme.Spacing.xl)
    }

    // MARK: - Planet Marker

    private func planetMarker(sign: String, symbol: String, color: Color) -> some View {
        let signIndex = WatchZodiacGlyph.all.firstIndex(where: { $0.name == sign }) ?? 0
        let angle = Angle.degrees(Double(signIndex) * 30 + 15 - 90)
        let pos = pointOnCircle(radius: 33, angle: angle)

        return ZStack {
            Circle()
                .fill(WatchTheme.Colors.surface)
                .frame(width: 14, height: 14)
                .overlay(
                    Circle()
                        .strokeBorder(color, lineWidth: 1)
                )

            Text(symbol)
                .font(.system(size: 6, weight: .bold))
                .foregroundStyle(color)
        }
        .offset(x: pos.x, y: pos.y)
    }

    // MARK: - Helpers

    private func isHighlightedSign(_ sign: String) -> Bool {
        sign == watchState.sunSign || sign == watchState.moonSign || sign == watchState.risingSign
    }

    private func pointOnCircle(radius: CGFloat, angle: Angle) -> CGPoint {
        CGPoint(
            x: radius * CGFloat(cos(angle.radians)),
            y: radius * CGFloat(sin(angle.radians))
        )
    }
}
