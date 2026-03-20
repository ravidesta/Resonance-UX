// DimensionCard.swift
// Luminous Cognitive Styles™ — iOS
// Card showing dimension info with score visualization and interpretation

import SwiftUI

struct DimensionCard: View {
    let dimension: CognitiveDimension
    let score: Double
    var isExpanded: Bool = false
    var onTap: (() -> Void)? = nil

    @State private var animatedScore: Double = 0

    var body: some View {
        VStack(alignment: .leading, spacing: LCSTheme.Spacing.md) {
            // Header
            HStack(spacing: LCSTheme.Spacing.sm) {
                // Color indicator
                RoundedRectangle(cornerRadius: 3)
                    .fill(dimension.color)
                    .frame(width: 4, height: 40)

                VStack(alignment: .leading, spacing: 2) {
                    Text(dimension.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(LCSTheme.textPrimary)

                    HStack(spacing: LCSTheme.Spacing.xs) {
                        Text(dimension.lowPole)
                            .font(.caption2)
                            .foregroundColor(LCSTheme.textTertiary)
                        Image(systemName: "arrow.left.arrow.right")
                            .font(.system(size: 8))
                            .foregroundColor(LCSTheme.textTertiary)
                        Text(dimension.highPole)
                            .font(.caption2)
                            .foregroundColor(LCSTheme.textTertiary)
                    }
                }

                Spacer()

                // Score badge
                ZStack {
                    Circle()
                        .fill(dimension.color.opacity(0.15))
                        .frame(width: 44, height: 44)

                    Circle()
                        .trim(from: 0, to: CGFloat(animatedScore / 10.0))
                        .stroke(dimension.color, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        .frame(width: 44, height: 44)
                        .rotationEffect(.degrees(-90))

                    Text(ScoreFormatter.formatted(score))
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundColor(dimension.color)
                }
            }

            // Score bar
            DimensionScoreView(
                dimension: dimension,
                score: score,
                showInterpretation: false,
                animated: true
            )

            // Pole indicator
            HStack {
                Text(ScoreFormatter.poleLabel(dimension: dimension, score: score))
                    .font(.caption.weight(.semibold))
                    .foregroundColor(dimension.color)
                    .padding(.horizontal, LCSTheme.Spacing.sm)
                    .padding(.vertical, LCSTheme.Spacing.xs)
                    .background(
                        Capsule()
                            .fill(dimension.color.opacity(0.12))
                    )

                Spacer()

                if onTap != nil {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(LCSTheme.textTertiary)
                }
            }

            // Expanded interpretation
            if isExpanded {
                VStack(alignment: .leading, spacing: LCSTheme.Spacing.sm) {
                    Divider().background(Color.white.opacity(0.1))

                    Text(dimension.interpretation(for: score))
                        .font(.subheadline)
                        .foregroundColor(LCSTheme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)

                    // Home territory indicator
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Home Territory")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(LCSTheme.textTertiary)

                        HStack(spacing: 4) {
                            let homeRange = homeTerritory
                            Text("\(ScoreFormatter.formatted(homeRange.lowerBound)) - \(ScoreFormatter.formatted(homeRange.upperBound))")
                                .font(.caption.monospacedDigit())
                                .foregroundColor(dimension.color)

                            Spacer()

                            Text("Adaptive Range")
                                .font(.caption.weight(.semibold))
                                .foregroundColor(LCSTheme.textTertiary)

                            let adaptRange = adaptiveRange
                            Text("\(ScoreFormatter.formatted(adaptRange.lowerBound)) - \(ScoreFormatter.formatted(adaptRange.upperBound))")
                                .font(.caption.monospacedDigit())
                                .foregroundColor(dimension.color.opacity(0.7))
                        }
                    }

                    Text(dimension.description)
                        .font(.caption)
                        .foregroundColor(LCSTheme.textTertiary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .lcsCard()
        .onTapGesture {
            onTap?()
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animatedScore = score
            }
        }
    }

    private var homeTerritory: ClosedRange<Double> {
        let lower = max(1.0, score - 1.0)
        let upper = min(10.0, score + 1.0)
        return lower...upper
    }

    private var adaptiveRange: ClosedRange<Double> {
        let lower = max(1.0, score - 2.5)
        let upper = min(10.0, score + 2.5)
        return lower...upper
    }
}

// MARK: - Mini Dimension Card (for grids)

struct MiniDimensionCard: View {
    let dimension: CognitiveDimension
    let score: Double

    var body: some View {
        VStack(spacing: LCSTheme.Spacing.sm) {
            Image(systemName: dimension.icon)
                .font(.system(size: 20))
                .foregroundColor(dimension.color)

            Text(dimension.shortName)
                .font(.caption.weight(.semibold))
                .foregroundColor(LCSTheme.textPrimary)

            Text(ScoreFormatter.formatted(score))
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundColor(dimension.color)

            Text(ScoreFormatter.poleLabel(dimension: dimension, score: score))
                .font(.system(size: 9))
                .foregroundColor(LCSTheme.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, LCSTheme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: LCSTheme.Radius.md)
                .fill(LCSTheme.darkSurface.opacity(0.7))
                .overlay(
                    RoundedRectangle(cornerRadius: LCSTheme.Radius.md)
                        .stroke(dimension.color.opacity(0.15), lineWidth: 1)
                )
        )
    }
}
