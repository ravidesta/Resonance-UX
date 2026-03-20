// DimensionScoreView.swift
// Luminous Cognitive Styles™
// Horizontal bar visualization for a single dimension score

import SwiftUI

struct DimensionScoreView: View {
    let dimension: CognitiveDimension
    let score: Double
    var showInterpretation: Bool = false
    var animated: Bool = true

    @State private var animatedScore: Double = 0

    private var displayScore: Double {
        animated ? animatedScore : score
    }

    var body: some View {
        VStack(alignment: .leading, spacing: LCSTheme.Spacing.sm) {
            // Header
            HStack {
                Image(systemName: dimension.icon)
                    .font(.system(size: 14))
                    .foregroundColor(dimension.color)

                Text(dimension.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(LCSTheme.textPrimary)

                Spacer()

                Text(ScoreFormatter.formatted(score))
                    .font(.system(.subheadline, design: .monospaced).weight(.bold))
                    .foregroundColor(dimension.color)
            }

            // Bar
            ZStack(alignment: .leading) {
                // Track
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white.opacity(0.08))
                    .frame(height: 8)

                // Fill
                GeometryReader { geo in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [dimension.color.opacity(0.5), dimension.color],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * CGFloat(ScoreFormatter.percentPosition(displayScore)), height: 8)
                        .shadow(color: dimension.color.opacity(0.4), radius: 4, x: 0, y: 0)
                }
                .frame(height: 8)

                // Indicator dot
                GeometryReader { geo in
                    let xPos = geo.size.width * CGFloat(ScoreFormatter.percentPosition(displayScore))
                    Circle()
                        .fill(dimension.color)
                        .frame(width: 14, height: 14)
                        .shadow(color: dimension.color.opacity(0.6), radius: 6)
                        .offset(x: xPos - 7, y: -3)
                }
                .frame(height: 8)
            }

            // Pole labels
            HStack {
                Text(dimension.lowPole)
                    .font(.caption2)
                    .foregroundColor(LCSTheme.textTertiary)
                Spacer()
                Text(dimension.highPole)
                    .font(.caption2)
                    .foregroundColor(LCSTheme.textTertiary)
            }

            // Interpretation
            if showInterpretation {
                Text(dimension.interpretation(for: score))
                    .font(.caption)
                    .foregroundColor(LCSTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, LCSTheme.Spacing.xs)
            }
        }
        .onAppear {
            if animated {
                withAnimation(.easeOut(duration: 0.8).delay(Double(dimension.rawValue) * 0.1)) {
                    animatedScore = score
                }
            }
        }
    }
}

// MARK: - Compact Score View (for lists)

struct CompactDimensionScoreView: View {
    let dimension: CognitiveDimension
    let score: Double

    var body: some View {
        HStack(spacing: LCSTheme.Spacing.sm) {
            Circle()
                .fill(dimension.color)
                .frame(width: 8, height: 8)

            Text(dimension.shortName)
                .font(.caption.weight(.medium))
                .foregroundColor(LCSTheme.textSecondary)
                .frame(width: 70, alignment: .leading)

            // Mini bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.white.opacity(0.06))

                    RoundedRectangle(cornerRadius: 2)
                        .fill(dimension.color.opacity(0.7))
                        .frame(width: geo.size.width * CGFloat(ScoreFormatter.percentPosition(score)))
                }
            }
            .frame(height: 4)

            Text(ScoreFormatter.formatted(score))
                .font(.system(.caption2, design: .monospaced))
                .foregroundColor(dimension.color)
                .frame(width: 30, alignment: .trailing)
        }
        .frame(height: 20)
    }
}
