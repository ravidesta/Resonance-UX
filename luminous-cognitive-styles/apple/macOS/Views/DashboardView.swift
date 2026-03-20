// DashboardView.swift
// Luminous Cognitive Styles™ — macOS
// Overview dashboard with radar chart and quick access to all features

import SwiftUI

struct MacDashboardView: View {
    @EnvironmentObject var viewModel: AssessmentViewModel
    @State private var selectedDimension: CognitiveDimension?

    var body: some View {
        ScrollView {
            VStack(spacing: LCSTheme.Spacing.xl) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Dashboard")
                            .font(.largeTitle.weight(.bold))
                            .foregroundColor(LCSTheme.textPrimary)
                        Text("Your cognitive style at a glance")
                            .font(.subheadline)
                            .foregroundColor(LCSTheme.textSecondary)
                    }
                    Spacer()

                    if viewModel.currentProfile == nil {
                        Button("Take Quick Profile") {
                            NotificationCenter.default.post(name: .navigateToQuickProfile, object: nil)
                        }
                        .buttonStyle(LCSTheme.PrimaryButtonStyle())
                    }
                }
                .padding(.horizontal, LCSTheme.Spacing.xl)
                .padding(.top, LCSTheme.Spacing.xl)

                if let profile = viewModel.currentProfile {
                    // Main content with profile
                    HStack(alignment: .top, spacing: LCSTheme.Spacing.xl) {
                        // Left column: Radar chart
                        VStack(spacing: LCSTheme.Spacing.lg) {
                            VStack(spacing: LCSTheme.Spacing.md) {
                                Text(profile.profileTypeName)
                                    .font(.title2.weight(.bold))
                                    .foregroundColor(LCSTheme.textPrimary)

                                Text(profile.profileSummary)
                                    .font(.subheadline)
                                    .foregroundColor(LCSTheme.textSecondary)
                                    .multilineTextAlignment(.center)
                            }

                            RadarChartView(
                                profile: profile,
                                showLabels: true,
                                showAdaptiveRange: true,
                                animated: true,
                                size: 300
                            )

                            HStack(spacing: LCSTheme.Spacing.md) {
                                Label(profile.assessmentType.rawValue, systemImage: "checkmark.seal")
                                    .font(.caption)
                                    .foregroundColor(LCSTheme.textTertiary)

                                Label(profile.createdAt.formatted(date: .abbreviated, time: .shortened), systemImage: "calendar")
                                    .font(.caption)
                                    .foregroundColor(LCSTheme.textTertiary)
                            }
                        }
                        .lcsCard()
                        .frame(maxWidth: .infinity)

                        // Right column: Dimension details
                        VStack(spacing: LCSTheme.Spacing.md) {
                            Text("Dimensions")
                                .font(.headline)
                                .foregroundColor(LCSTheme.textPrimary)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            ForEach(CognitiveDimension.allCases) { dim in
                                MacDimensionRow(
                                    dimension: dim,
                                    score: profile.score(for: dim),
                                    isSelected: selectedDimension == dim
                                ) {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        selectedDimension = selectedDimension == dim ? nil : dim
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal, LCSTheme.Spacing.xl)

                    // Insights row
                    HStack(alignment: .top, spacing: LCSTheme.Spacing.lg) {
                        InsightCard(
                            icon: "house.fill",
                            title: "Home Territory",
                            description: homeInsight(profile),
                            color: LCSTheme.crystalBlue
                        )
                        .frame(maxWidth: .infinity)

                        InsightCard(
                            icon: "arrow.up.right.circle.fill",
                            title: "Growth Edge",
                            description: ProfileTypeNamer.coachingSuggestion(for: profile),
                            color: LCSTheme.emerald
                        )
                        .frame(maxWidth: .infinity)

                        InsightCard(
                            icon: "chart.line.uptrend.xyaxis",
                            title: "Assessments",
                            description: "\(viewModel.profileHistory.count) total assessments recorded. Track your development over time.",
                            color: LCSTheme.amberGold
                        )
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal, LCSTheme.Spacing.xl)

                } else {
                    // No profile state
                    noProfileView
                }

                // Quick actions
                quickActionsGrid

                Spacer(minLength: LCSTheme.Spacing.xxl)
            }
        }
        .background(LCSTheme.backgroundGradient.ignoresSafeArea())
    }

    // MARK: - No Profile View

    private var noProfileView: some View {
        VStack(spacing: LCSTheme.Spacing.xl) {
            Spacer(minLength: LCSTheme.Spacing.xxl)

            Image(systemName: "brain.head.profile")
                .font(.system(size: 64))
                .foregroundStyle(LCSTheme.heroGradient)

            Text("Discover Your Cognitive Signature")
                .font(.title.weight(.bold))
                .foregroundColor(LCSTheme.textPrimary)

            Text("Take the Quick Profile assessment to reveal your unique cognitive style across 7 dimensions.")
                .font(.body)
                .foregroundColor(LCSTheme.textSecondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 500)

            HStack(spacing: LCSTheme.Spacing.lg) {
                Button("Quick Profile (2 min)") {
                    NotificationCenter.default.post(name: .navigateToQuickProfile, object: nil)
                }
                .buttonStyle(LCSTheme.PrimaryButtonStyle())

                Button("Full Assessment (15 min)") {
                    NotificationCenter.default.post(name: .navigateToFullAssessment, object: nil)
                }
                .buttonStyle(LCSTheme.SecondaryButtonStyle())
            }

            Spacer(minLength: LCSTheme.Spacing.xxl)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Quick Actions

    private var quickActionsGrid: some View {
        VStack(alignment: .leading, spacing: LCSTheme.Spacing.md) {
            Text("Quick Actions")
                .font(.headline)
                .foregroundColor(LCSTheme.textPrimary)

            HStack(spacing: LCSTheme.Spacing.md) {
                MacQuickAction(icon: "bolt.fill", title: "Quick Profile", color: LCSTheme.amberGold) {
                    NotificationCenter.default.post(name: .navigateToQuickProfile, object: nil)
                }
                MacQuickAction(icon: "doc.text.magnifyingglass", title: "Full Assessment", color: LCSTheme.crystalBlue) {
                    NotificationCenter.default.post(name: .navigateToFullAssessment, object: nil)
                }
                MacQuickAction(icon: "book.fill", title: "Read Book", color: LCSTheme.emerald) {
                    NotificationCenter.default.post(name: .navigateToBook, object: nil)
                }
                MacQuickAction(icon: "message.fill", title: "Coaching", color: LCSTheme.violet) {
                    NotificationCenter.default.post(name: .navigateToAssessment, object: nil)
                }
            }
        }
        .padding(.horizontal, LCSTheme.Spacing.xl)
    }

    private func homeInsight(_ profile: CognitiveProfile) -> String {
        let edges = profile.developmentalEdges
        let descriptions = edges.map { dim in
            let score = profile.score(for: dim)
            let pole = score > 5.5 ? dim.highPole : dim.lowPole
            return "\(pole) \(dim.shortName)"
        }
        return "Your cognitive home base: \(descriptions.joined(separator: " and "))."
    }
}

// MARK: - Mac Dimension Row

struct MacDimensionRow: View {
    let dimension: CognitiveDimension
    let score: Double
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: LCSTheme.Spacing.sm) {
            HStack(spacing: LCSTheme.Spacing.sm) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(dimension.color)
                    .frame(width: 3, height: 20)

                Image(systemName: dimension.icon)
                    .font(.system(size: 12))
                    .foregroundColor(dimension.color)

                Text(dimension.name)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(LCSTheme.textPrimary)

                Spacer()

                Text(ScoreFormatter.formatted(score))
                    .font(.system(.subheadline, design: .monospaced).weight(.bold))
                    .foregroundColor(dimension.color)

                Image(systemName: isSelected ? "chevron.up" : "chevron.down")
                    .font(.caption2)
                    .foregroundColor(LCSTheme.textTertiary)
            }

            // Score bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.white.opacity(0.06))
                    RoundedRectangle(cornerRadius: 3)
                        .fill(LCSTheme.dimensionGradient(for: dimension))
                        .frame(width: geo.size.width * CGFloat(ScoreFormatter.percentPosition(score)))
                }
            }
            .frame(height: 4)

            HStack {
                Text(dimension.lowPole)
                    .font(.system(size: 9))
                    .foregroundColor(LCSTheme.textTertiary)
                Spacer()
                Text(dimension.highPole)
                    .font(.system(size: 9))
                    .foregroundColor(LCSTheme.textTertiary)
            }

            if isSelected {
                Text(dimension.interpretation(for: score))
                    .font(.caption)
                    .foregroundColor(LCSTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 4)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(LCSTheme.Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: LCSTheme.Radius.sm)
                .fill(isSelected ? dimension.color.opacity(0.05) : Color.clear)
        )
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }
}

// MARK: - Quick Action

struct MacQuickAction: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: LCSTheme.Spacing.sm) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                Text(title)
                    .font(.caption.weight(.medium))
                    .foregroundColor(LCSTheme.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, LCSTheme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: LCSTheme.Radius.md)
                    .fill(LCSTheme.darkSurface.opacity(0.6))
                    .overlay(
                        RoundedRectangle(cornerRadius: LCSTheme.Radius.md)
                            .stroke(color.opacity(0.15), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}
