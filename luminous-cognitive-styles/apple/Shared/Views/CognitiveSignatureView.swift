// CognitiveSignatureView.swift
// Luminous Cognitive Styles™
// Full results view showing radar chart and dimensional analysis

import SwiftUI

struct CognitiveSignatureView: View {
    let profile: CognitiveProfile
    var onShare: (() -> Void)? = nil

    @State private var selectedDimension: CognitiveDimension? = nil
    @State private var showFullInterpretation = false

    var body: some View {
        ScrollView {
            VStack(spacing: LCSTheme.Spacing.xl) {
                // Profile Type Header
                VStack(spacing: LCSTheme.Spacing.sm) {
                    Text("Your Cognitive Signature")
                        .font(.caption.weight(.semibold))
                        .textCase(.uppercase)
                        .tracking(2)
                        .foregroundColor(LCSTheme.goldAccent)

                    Text(profile.profileTypeName)
                        .font(.system(size: 28, weight: .bold, design: .serif))
                        .foregroundColor(LCSTheme.textPrimary)
                        .multilineTextAlignment(.center)

                    Text(profile.profileSummary)
                        .font(.subheadline)
                        .foregroundColor(LCSTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, LCSTheme.Spacing.lg)

                // Radar Chart
                RadarChartView(profile: profile)
                    .padding(.vertical, LCSTheme.Spacing.md)

                // Assessment info
                HStack(spacing: LCSTheme.Spacing.lg) {
                    Label(profile.assessmentType.rawValue, systemImage: "checkmark.seal")
                        .font(.caption)
                        .foregroundColor(LCSTheme.textTertiary)

                    Label(profile.createdAt.formatted(date: .abbreviated, time: .shortened), systemImage: "calendar")
                        .font(.caption)
                        .foregroundColor(LCSTheme.textTertiary)
                }

                // Dimension Scores
                VStack(spacing: LCSTheme.Spacing.md) {
                    HStack {
                        Text("Dimensional Analysis")
                            .font(.headline)
                            .foregroundColor(LCSTheme.textPrimary)
                        Spacer()
                        Button {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showFullInterpretation.toggle()
                            }
                        } label: {
                            Text(showFullInterpretation ? "Compact" : "Detailed")
                                .font(.caption.weight(.medium))
                                .foregroundColor(LCSTheme.goldAccent)
                        }
                    }

                    ForEach(CognitiveDimension.allCases) { dimension in
                        DimensionScoreView(
                            dimension: dimension,
                            score: profile.score(for: dimension),
                            showInterpretation: showFullInterpretation || selectedDimension == dimension
                        )
                        .lcsCard()
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                if selectedDimension == dimension {
                                    selectedDimension = nil
                                } else {
                                    selectedDimension = dimension
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)

                // Key Insights
                VStack(alignment: .leading, spacing: LCSTheme.Spacing.md) {
                    Text("Key Insights")
                        .font(.headline)
                        .foregroundColor(LCSTheme.textPrimary)

                    // Home Territory
                    InsightCard(
                        icon: "house.fill",
                        title: "Home Territory",
                        description: "Your strongest orientations define your natural cognitive home.",
                        color: LCSTheme.crystalBlue,
                        details: homeInsight
                    )

                    // Developmental Edge
                    InsightCard(
                        icon: "arrow.up.right.circle.fill",
                        title: "Developmental Edge",
                        description: ProfileTypeNamer.coachingSuggestion(for: profile),
                        color: LCSTheme.emerald,
                        details: nil
                    )

                    // Balance
                    InsightCard(
                        icon: "scale.3d",
                        title: "Balance Profile",
                        description: balanceInsight,
                        color: LCSTheme.violet,
                        details: nil
                    )
                }
                .padding(.horizontal)

                // Share Button
                if let onShare = onShare {
                    Button(action: onShare) {
                        Label("Share Your Signature", systemImage: "square.and.arrow.up")
                    }
                    .buttonStyle(LCSTheme.PrimaryButtonStyle())
                    .padding(.vertical, LCSTheme.Spacing.lg)
                }

                Spacer(minLength: LCSTheme.Spacing.xxl)
            }
        }
        .background(LCSTheme.backgroundGradient.ignoresSafeArea())
    }

    private var homeInsight: String {
        let edges = profile.developmentalEdges
        let descriptions = edges.map { dim in
            let score = profile.score(for: dim)
            let pole = score > 5.5 ? dim.highPole : dim.lowPole
            return "\(pole) (\(dim.shortName): \(ScoreFormatter.formatted(score)))"
        }
        return descriptions.joined(separator: ", ")
    }

    private var balanceInsight: String {
        let scores = profile.orderedScores.map { abs($0.score - 5.5) }
        let avgDeviation = scores.reduce(0, +) / Double(scores.count)
        if avgDeviation < 1.5 {
            return "Your profile is notably balanced, suggesting cognitive versatility across all dimensions."
        } else if avgDeviation < 2.5 {
            return "Your profile shows moderate differentiation, with clear preferences balanced by flexibility."
        } else {
            return "Your profile is highly differentiated, with strong orientations that define a distinctive cognitive style."
        }
    }
}

// MARK: - Insight Card

struct InsightCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    var details: String?

    var body: some View {
        VStack(alignment: .leading, spacing: LCSTheme.Spacing.sm) {
            HStack(spacing: LCSTheme.Spacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(color)

                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(LCSTheme.textPrimary)
            }

            Text(description)
                .font(.caption)
                .foregroundColor(LCSTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            if let details = details {
                Text(details)
                    .font(.caption.weight(.medium))
                    .foregroundColor(color.opacity(0.9))
                    .padding(.top, 2)
            }
        }
        .lcsCard()
    }
}
