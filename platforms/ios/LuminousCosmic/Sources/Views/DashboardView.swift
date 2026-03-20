// DashboardView.swift
// Luminous Cosmic Architecture™
// Home Screen with Daily Cosmic Overview

import SwiftUI

// MARK: - Dashboard View

struct DashboardView: View {
    @StateObject private var calculator = ChartCalculator()
    @Environment(\.resonanceTheme) var theme
    @State private var showChartDetail = false
    @State private var greeting = ""
    @State private var dailyInsight = ""

    private let chart = ChartCalculator.sampleChart()

    var body: some View {
        NavigationStack {
            ZStack {
                CosmicBackgroundMinimal()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: ResonanceSpacing.lg) {
                        // Header
                        headerSection

                        // Moon Phase Card
                        moonPhaseCard

                        // Mini Chart + Big Three
                        chartOverviewCard

                        // Daily Insight
                        dailyInsightCard

                        // Current Transits
                        transitSection

                        // Quick Actions
                        quickActionsGrid

                        Spacer(minLength: ResonanceSpacing.xxxl)
                    }
                    .padding(.horizontal, ResonanceSpacing.md)
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            updateGreeting()
            calculator.calculateMoonPhase()
            _ = calculator.calculateCurrentTransits(natalChart: chart)
            generateDailyInsight()
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: ResonanceSpacing.xxs) {
            Text(greeting)
                .font(ResonanceTypography.bodyMedium)
                .foregroundColor(theme.textSecondary)

            Text("Cosmic Overview")
                .font(ResonanceTypography.displaySmall)
                .foregroundColor(theme.textPrimary)

            Text(formattedDate)
                .font(ResonanceTypography.caption)
                .foregroundColor(theme.textTertiary)
                .tracking(1)
                .textCase(.uppercase)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, ResonanceSpacing.xxl)
        .padding(.horizontal, ResonanceSpacing.xs)
    }

    // MARK: - Moon Phase Card

    private var moonPhaseCard: some View {
        HStack(spacing: ResonanceSpacing.md) {
            MoonPhaseView(
                phase: calculator.currentMoonPhase,
                size: 56,
                showDetails: false
            )

            VStack(alignment: .leading, spacing: ResonanceSpacing.xxs) {
                Text(calculator.currentMoonPhase.rawValue)
                    .font(ResonanceTypography.headlineSmall)
                    .foregroundColor(theme.textPrimary)

                Text(calculator.currentMoonPhase.ritual)
                    .font(ResonanceTypography.bodySmall)
                    .foregroundColor(theme.textSecondary)
                    .lineLimit(2)
            }

            Spacer()
        }
        .padding(ResonanceSpacing.md)
        .glassCard(cornerRadius: ResonanceRadius.lg, intensity: .standard)
    }

    // MARK: - Chart Overview

    private var chartOverviewCard: some View {
        VStack(spacing: ResonanceSpacing.md) {
            HStack {
                Text("Your Chart")
                    .font(ResonanceTypography.headlineMedium)
                    .foregroundColor(theme.textPrimary)

                Spacer()

                Button {
                    showChartDetail = true
                    ResonanceHaptics.light()
                } label: {
                    Text("View Full")
                        .font(ResonanceTypography.bodySmall)
                        .foregroundColor(theme.accent)
                }
            }

            // Mini zodiac wheel
            ZodiacWheel(chart: chart, size: 200, showAspects: false)
                .frame(height: 200)

            // Big Three
            HStack(spacing: ResonanceSpacing.md) {
                BigThreeItem(label: "Sun", sign: chart.sunSign)
                BigThreeItem(label: "Moon", sign: chart.moonSign)
                BigThreeItem(label: "Rising", sign: chart.risingSign)
            }
        }
        .padding(ResonanceSpacing.md)
        .glassCard(cornerRadius: ResonanceRadius.xl, intensity: .standard)
        .fullScreenCover(isPresented: $showChartDetail) {
            NatalChartView(chart: chart)
        }
    }

    // MARK: - Daily Insight

    private var dailyInsightCard: some View {
        VStack(alignment: .leading, spacing: ResonanceSpacing.sm) {
            HStack {
                Image(systemName: "sparkle")
                    .foregroundColor(theme.accent)
                Text("Daily Insight")
                    .font(ResonanceTypography.headlineSmall)
                    .foregroundColor(theme.textPrimary)
            }

            Text(dailyInsight)
                .font(ResonanceTypography.bodyMedium)
                .foregroundColor(theme.textSecondary)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)

            HStack {
                Spacer()
                Text("Based on current transits")
                    .font(ResonanceTypography.caption)
                    .foregroundColor(theme.textTertiary)
                    .italic()
            }
        }
        .padding(ResonanceSpacing.lg)
        .glassCard(cornerRadius: ResonanceRadius.lg)
    }

    // MARK: - Transit Section

    private var transitSection: some View {
        VStack(alignment: .leading, spacing: ResonanceSpacing.md) {
            HStack {
                Text("Active Transits")
                    .font(ResonanceTypography.headlineMedium)
                    .foregroundColor(theme.textPrimary)

                Spacer()

                Text("\(calculator.currentTransits.count)")
                    .font(ResonanceTypography.caption)
                    .foregroundColor(theme.accent)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(
                        Capsule()
                            .fill(theme.accent.opacity(0.1))
                    )
            }
            .padding(.horizontal, ResonanceSpacing.xs)

            ForEach(calculator.currentTransits.prefix(3)) { transit in
                TransitCard(transit: transit)
            }

            if calculator.currentTransits.isEmpty {
                Text("The cosmos is in a calm phase today")
                    .font(ResonanceTypography.bodyMedium)
                    .foregroundColor(theme.textTertiary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, ResonanceSpacing.lg)
            }
        }
    }

    // MARK: - Quick Actions

    private var quickActionsGrid: some View {
        VStack(alignment: .leading, spacing: ResonanceSpacing.md) {
            Text("Explore")
                .font(ResonanceTypography.headlineMedium)
                .foregroundColor(theme.textPrimary)
                .padding(.horizontal, ResonanceSpacing.xs)

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: ResonanceSpacing.md),
                GridItem(.flexible(), spacing: ResonanceSpacing.md)
            ], spacing: ResonanceSpacing.md) {
                QuickActionCard(
                    icon: "pencil.line",
                    title: "Daily Reflection",
                    subtitle: "Journal your insights",
                    color: ResonanceColors.water
                )

                QuickActionCard(
                    icon: "figure.mind.and.body",
                    title: "Meditate",
                    subtitle: "Stargazer's attunement",
                    color: ResonanceColors.air
                )

                QuickActionCard(
                    icon: "book.closed",
                    title: "Chapters",
                    subtitle: "Explore the map",
                    color: ResonanceColors.earth
                )

                QuickActionCard(
                    icon: "chart.dots.scatter",
                    title: "Aspects",
                    subtitle: "\(chart.aspects.count) found",
                    color: ResonanceColors.fire
                )
            }
        }
    }

    // MARK: - Helpers

    private func updateGreeting() {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: greeting = "Good morning"
        case 12..<17: greeting = "Good afternoon"
        case 17..<21: greeting = "Good evening"
        default: greeting = "Good night"
        }
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        return formatter.string(from: Date())
    }

    private func generateDailyInsight() {
        let insights = [
            "The Sun's transit through your chart activates themes of personal growth and self-expression. Today's energy supports creative endeavors and authentic communication.",
            "With the Moon moving through a sensitive area of your chart, today invites deeper emotional awareness. Honor what surfaces without judgment.",
            "Current planetary alignments emphasize transformation and renewal. Release what no longer serves your highest path to make space for new growth.",
            "The cosmic weather today supports building bridges in relationships. Approach conversations with both clarity and compassion.",
            "A harmonious transit activates your creative potential today. Let your imagination roam freely and notice what inspires you."
        ]
        dailyInsight = insights[Calendar.current.component(.day, from: Date()) % insights.count]
    }
}

// MARK: - Big Three Item

struct BigThreeItem: View {
    let label: String
    let sign: ZodiacSign
    @Environment(\.resonanceTheme) var theme

    var body: some View {
        VStack(spacing: ResonanceSpacing.xs) {
            Text(label)
                .font(ResonanceTypography.overline)
                .foregroundColor(theme.textTertiary)
                .textCase(.uppercase)
                .tracking(1)

            ZodiacSignBadge(sign: sign, size: 40)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label) sign: \(sign.name)")
    }
}

// MARK: - Quick Action Card

struct QuickActionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color

    @Environment(\.resonanceTheme) var theme
    @State private var isPressed = false

    var body: some View {
        VStack(alignment: .leading, spacing: ResonanceSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
                .frame(width: 44, height: 44)
                .background(
                    RoundedRectangle(cornerRadius: ResonanceRadius.sm)
                        .fill(color.opacity(0.1))
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(ResonanceTypography.headlineSmall)
                    .foregroundColor(theme.textPrimary)

                Text(subtitle)
                    .font(ResonanceTypography.caption)
                    .foregroundColor(theme.textTertiary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(ResonanceSpacing.md)
        .glassCard(cornerRadius: ResonanceRadius.lg, intensity: .subtle)
        .scaleEffect(isPressed ? 0.96 : 1.0)
        .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
            withAnimation(ResonanceAnimation.springBouncy) {
                isPressed = pressing
            }
        }, perform: {})
    }
}
