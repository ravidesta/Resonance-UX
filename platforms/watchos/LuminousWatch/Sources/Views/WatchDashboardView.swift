// WatchDashboardView.swift
// Luminous Cosmic Architecture™ — watchOS Dashboard
// Compact overview: zodiac season, moon, insight, transit

import SwiftUI

struct WatchDashboardView: View {
    @EnvironmentObject var watchState: WatchState
    @State private var shimmer: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: WatchTheme.Spacing.lg) {
                // Header
                headerSection

                // Moon phase compact
                moonCompact

                // Daily insight teaser
                insightTeaser

                // Key transit
                transitTeaser
            }
            .padding(.horizontal, WatchTheme.Spacing.md)
        }
        .background(WatchTheme.Colors.background)
        .onAppear {
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                shimmer = true
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: WatchTheme.Spacing.sm) {
            Image(systemName: "sparkle")
                .font(.system(size: 12, weight: .light))
                .foregroundStyle(WatchTheme.Colors.gold)
                .opacity(shimmer ? 1.0 : 0.5)

            Text(watchState.zodiacSeason)
                .font(WatchTheme.Typography.title)
                .foregroundStyle(WatchTheme.Colors.textPrimary)

            Text(watchState.seasonDateRange)
                .font(WatchTheme.Typography.caption2)
                .foregroundStyle(WatchTheme.Colors.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, WatchTheme.Spacing.md)
    }

    // MARK: - Moon Compact

    private var moonCompact: some View {
        HStack(spacing: WatchTheme.Spacing.md) {
            Text(watchState.currentMoonPhase.symbol)
                .font(.system(size: 22))

            VStack(alignment: .leading, spacing: 1) {
                Text(watchState.currentMoonPhase.rawValue)
                    .font(WatchTheme.Typography.caption)
                    .foregroundStyle(WatchTheme.Colors.textPrimary)

                Text("\(Int(watchState.currentMoonPhase.illumination * 100))%")
                    .font(WatchTheme.Typography.caption2)
                    .foregroundStyle(WatchTheme.Colors.textSecondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 8, weight: .bold))
                .foregroundStyle(WatchTheme.Colors.textTertiary)
        }
        .watchCard()
    }

    // MARK: - Insight Teaser

    private var insightTeaser: some View {
        VStack(alignment: .leading, spacing: WatchTheme.Spacing.sm) {
            HStack {
                Image(systemName: "sparkles")
                    .font(.system(size: 10))
                    .foregroundStyle(WatchTheme.Colors.gold)
                Text("Today")
                    .font(WatchTheme.Typography.caption2)
                    .foregroundStyle(WatchTheme.Colors.gold)
                Spacer()
            }

            Text(watchState.dailyInsight)
                .font(WatchTheme.Typography.caption)
                .foregroundStyle(WatchTheme.Colors.textPrimary)
                .lineLimit(3)
                .lineSpacing(2)
        }
        .watchCard()
    }

    // MARK: - Transit Teaser

    private var transitTeaser: some View {
        HStack(spacing: WatchTheme.Spacing.md) {
            ZStack {
                Circle()
                    .fill(WatchTheme.Colors.surfaceAccent)
                    .frame(width: 28, height: 28)

                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: 11, weight: .light))
                    .foregroundStyle(WatchTheme.Colors.gold)
            }

            VStack(alignment: .leading, spacing: 1) {
                Text(watchState.currentTransit)
                    .font(WatchTheme.Typography.caption)
                    .foregroundStyle(WatchTheme.Colors.textPrimary)
                    .lineLimit(1)

                Text(watchState.transitDescription)
                    .font(WatchTheme.Typography.caption2)
                    .foregroundStyle(WatchTheme.Colors.textSecondary)
                    .lineLimit(1)
            }

            Spacer()
        }
        .watchCard()
    }
}
