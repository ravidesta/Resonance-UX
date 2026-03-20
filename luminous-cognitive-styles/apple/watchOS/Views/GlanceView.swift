// GlanceView.swift
// Luminous Cognitive Styles™ — watchOS
// Compact radar chart, top dimension highlight, daily cognitive tip

import SwiftUI

struct GlanceView: View {
    let profile: CognitiveProfile
    @State private var showAllDimensions = false

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                // Profile type
                Text(profile.profileTypeName)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(LCSTheme.goldAccent)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)

                // Compact radar
                CompactRadarChartView(profile: profile, size: 100)
                    .padding(.vertical, 4)

                // Top dimensions (developmental edges)
                VStack(spacing: 6) {
                    ForEach(topDimensions, id: \.dimension) { item in
                        WatchDimensionBar(
                            dimension: item.dimension,
                            score: item.score
                        )
                    }
                }

                // Show more toggle
                Button {
                    withAnimation { showAllDimensions.toggle() }
                } label: {
                    HStack(spacing: 4) {
                        Text(showAllDimensions ? "Less" : "All Dimensions")
                            .font(.system(size: 11, weight: .medium))
                        Image(systemName: showAllDimensions ? "chevron.up" : "chevron.down")
                            .font(.system(size: 9))
                    }
                    .foregroundColor(LCSTheme.goldAccent)
                }
                .buttonStyle(.plain)

                if showAllDimensions {
                    VStack(spacing: 6) {
                        ForEach(remainingDimensions, id: \.dimension) { item in
                            WatchDimensionBar(
                                dimension: item.dimension,
                                score: item.score
                            )
                        }
                    }
                    .transition(.opacity)
                }

                // Assessment date
                Text(profile.createdAt.formatted(date: .abbreviated, time: .omitted))
                    .font(.system(size: 9))
                    .foregroundColor(.white.opacity(0.4))
                    .padding(.top, 4)
            }
            .padding(.horizontal, 4)
        }
        .navigationTitle("Profile")
        .containerBackground(LCSTheme.deepNavy.gradient, for: .navigation)
    }

    private var topDimensions: [(dimension: CognitiveDimension, score: Double)] {
        let sorted = profile.orderedScores.sorted { abs($0.score - 5.5) > abs($1.score - 5.5) }
        return Array(sorted.prefix(3))
    }

    private var remainingDimensions: [(dimension: CognitiveDimension, score: Double)] {
        let topIds = Set(topDimensions.map { $0.dimension })
        return profile.orderedScores.filter { !topIds.contains($0.dimension) }
    }
}

// MARK: - Watch Dimension Bar

struct WatchDimensionBar: View {
    let dimension: CognitiveDimension
    let score: Double

    var body: some View {
        VStack(spacing: 2) {
            HStack(spacing: 4) {
                Circle()
                    .fill(dimension.color)
                    .frame(width: 5, height: 5)

                Text(dimension.abbreviation)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(dimension.color)

                Spacer()

                Text(ScoreFormatter.formatted(score))
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.white.opacity(0.1))
                    RoundedRectangle(cornerRadius: 2)
                        .fill(dimension.color)
                        .frame(width: geo.size.width * CGFloat(ScoreFormatter.percentPosition(score)))
                }
            }
            .frame(height: 3)
        }
    }
}
