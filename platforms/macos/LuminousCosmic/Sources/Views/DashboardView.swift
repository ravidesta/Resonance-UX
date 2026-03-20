// DashboardView.swift
// Luminous Cosmic Architecture™ — macOS Dashboard
// Multi-column cosmic overview with daily insights

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var appState: AppState
    @State private var animateEntrance = false

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: ResonanceMacTheme.Spacing.lg) {
                headerSection

                HStack(alignment: .top, spacing: ResonanceMacTheme.Spacing.lg) {
                    // Left column — primary content
                    VStack(spacing: ResonanceMacTheme.Spacing.lg) {
                        dailyInsightCard
                        transitOverviewCard
                    }
                    .frame(maxWidth: .infinity)

                    // Right column — glanceable widgets
                    VStack(spacing: ResonanceMacTheme.Spacing.lg) {
                        moonPhaseCard
                        cosmicWeatherCard
                        quickActionsCard
                    }
                    .frame(width: 300)
                }
            }
            .padding(ResonanceMacTheme.Spacing.xl)
        }
        .onAppear {
            withAnimation(ResonanceMacTheme.Animation.spring.delay(0.1)) {
                animateEntrance = true
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: ResonanceMacTheme.Spacing.xs) {
                Text("Good \(timeOfDayGreeting)")
                    .font(ResonanceMacTheme.Typography.largeTitle)
                    .foregroundStyle(
                        appState.isNightMode
                            ? ResonanceMacTheme.Colors.cream
                            : ResonanceMacTheme.Colors.forestDeep
                    )

                Text(formattedDate)
                    .font(ResonanceMacTheme.Typography.callout)
                    .foregroundStyle(ResonanceMacTheme.Colors.mutedGreen)
            }

            Spacer()

            HStack(spacing: ResonanceMacTheme.Spacing.md) {
                cosmicBadge(icon: "sun.max", label: "Pisces", sublabel: "Sun")
                cosmicBadge(icon: "moon", label: "Scorpio", sublabel: "Moon")
                cosmicBadge(icon: "arrow.up.right", label: "Leo", sublabel: "Rising")
            }
        }
        .opacity(animateEntrance ? 1 : 0)
        .offset(y: animateEntrance ? 0 : 10)
    }

    private func cosmicBadge(icon: String, label: String, sublabel: String) -> some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(ResonanceMacTheme.Colors.forestLight.opacity(0.15))
                    .frame(width: 40, height: 40)

                Image(systemName: icon)
                    .font(.system(size: 16, weight: .light))
                    .foregroundStyle(ResonanceMacTheme.Colors.gold)
            }

            Text(label)
                .font(ResonanceMacTheme.Typography.caption)
                .foregroundStyle(
                    appState.isNightMode
                        ? ResonanceMacTheme.Colors.cream
                        : ResonanceMacTheme.Colors.forestDeep
                )

            Text(sublabel)
                .font(ResonanceMacTheme.Typography.caption2)
                .foregroundStyle(ResonanceMacTheme.Colors.mutedGreenLight)
        }
    }

    // MARK: - Daily Insight

    private var dailyInsightCard: some View {
        VStack(alignment: .leading, spacing: ResonanceMacTheme.Spacing.md) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundStyle(ResonanceMacTheme.Colors.gold)
                Text("Daily Insight")
                    .font(ResonanceMacTheme.Typography.headline)
                    .foregroundStyle(
                        appState.isNightMode
                            ? ResonanceMacTheme.Colors.cream
                            : ResonanceMacTheme.Colors.forestDeep
                    )
                Spacer()
                Text("March 20")
                    .font(ResonanceMacTheme.Typography.caption)
                    .foregroundStyle(ResonanceMacTheme.Colors.mutedGreenLight)
            }

            Text(appState.dailyInsight)
                .font(ResonanceMacTheme.Typography.title2)
                .foregroundStyle(
                    appState.isNightMode
                        ? ResonanceMacTheme.Colors.creamWarm
                        : ResonanceMacTheme.Colors.forestMid
                )
                .lineSpacing(6)
                .fixedSize(horizontal: false, vertical: true)

            Divider()
                .overlay(ResonanceMacTheme.Colors.goldLight.opacity(0.2))

            HStack(spacing: ResonanceMacTheme.Spacing.lg) {
                insightAction(icon: "pencil.line", label: "Reflect")
                insightAction(icon: "square.and.arrow.up", label: "Share")
                insightAction(icon: "bookmark", label: "Save")
            }
        }
        .cosmicCard(isNightMode: appState.isNightMode)
        .opacity(animateEntrance ? 1 : 0)
        .offset(y: animateEntrance ? 0 : 20)
    }

    private func insightAction(icon: String, label: String) -> some View {
        Button(action: {}) {
            Label(label, systemImage: icon)
                .font(ResonanceMacTheme.Typography.caption)
                .foregroundStyle(ResonanceMacTheme.Colors.gold)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Transit Overview

    private var transitOverviewCard: some View {
        VStack(alignment: .leading, spacing: ResonanceMacTheme.Spacing.md) {
            HStack {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .foregroundStyle(ResonanceMacTheme.Colors.gold)
                Text("Active Transits")
                    .font(ResonanceMacTheme.Typography.headline)
                    .foregroundStyle(
                        appState.isNightMode
                            ? ResonanceMacTheme.Colors.cream
                            : ResonanceMacTheme.Colors.forestDeep
                    )
                Spacer()
            }

            ForEach(sampleTransits, id: \.name) { transit in
                transitRow(transit)
            }
        }
        .cosmicCard(isNightMode: appState.isNightMode)
        .opacity(animateEntrance ? 1 : 0)
        .offset(y: animateEntrance ? 0 : 20)
    }

    private func transitRow(_ transit: TransitData) -> some View {
        HStack(spacing: ResonanceMacTheme.Spacing.md) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [ResonanceMacTheme.Colors.forestLight, ResonanceMacTheme.Colors.forestMid],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 36, height: 36)

                Text(transit.glyph)
                    .font(.system(size: 16))
                    .foregroundStyle(ResonanceMacTheme.Colors.gold)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(transit.name)
                    .font(ResonanceMacTheme.Typography.body)
                    .foregroundStyle(
                        appState.isNightMode
                            ? ResonanceMacTheme.Colors.cream
                            : ResonanceMacTheme.Colors.forestDeep
                    )

                Text(transit.description)
                    .font(ResonanceMacTheme.Typography.caption)
                    .foregroundStyle(ResonanceMacTheme.Colors.mutedGreen)
            }

            Spacer()

            Text(transit.aspect)
                .font(ResonanceMacTheme.Typography.data)
                .foregroundStyle(ResonanceMacTheme.Colors.gold)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(ResonanceMacTheme.Colors.gold.opacity(0.1))
                )
        }
        .padding(.vertical, 4)
    }

    // MARK: - Moon Phase

    private var moonPhaseCard: some View {
        VStack(spacing: ResonanceMacTheme.Spacing.md) {
            Text("Moon Phase")
                .font(ResonanceMacTheme.Typography.headline)
                .foregroundStyle(
                    appState.isNightMode
                        ? ResonanceMacTheme.Colors.cream
                        : ResonanceMacTheme.Colors.forestDeep
                )

            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                ResonanceMacTheme.Colors.goldLight.opacity(0.3),
                                ResonanceMacTheme.Colors.forestDeep.opacity(0.1)
                            ],
                            center: .center,
                            startRadius: 10,
                            endRadius: 60
                        )
                    )
                    .frame(width: 100, height: 100)

                MoonPhaseShape(illumination: appState.currentMoonPhase.illumination)
                    .fill(ResonanceMacTheme.Colors.goldLight)
                    .frame(width: 60, height: 60)

                Circle()
                    .strokeBorder(ResonanceMacTheme.Colors.gold.opacity(0.4), lineWidth: 1)
                    .frame(width: 60, height: 60)
            }

            Text(appState.currentMoonPhase.rawValue)
                .font(ResonanceMacTheme.Typography.title3)
                .foregroundStyle(
                    appState.isNightMode
                        ? ResonanceMacTheme.Colors.cream
                        : ResonanceMacTheme.Colors.forestDeep
                )

            Text("\(Int(appState.currentMoonPhase.illumination * 100))% illuminated")
                .font(ResonanceMacTheme.Typography.caption)
                .foregroundStyle(ResonanceMacTheme.Colors.mutedGreen)
        }
        .frame(maxWidth: .infinity)
        .cosmicCard(isNightMode: appState.isNightMode)
        .opacity(animateEntrance ? 1 : 0)
        .offset(y: animateEntrance ? 0 : 20)
    }

    // MARK: - Cosmic Weather

    private var cosmicWeatherCard: some View {
        VStack(alignment: .leading, spacing: ResonanceMacTheme.Spacing.md) {
            Text("Cosmic Weather")
                .font(ResonanceMacTheme.Typography.headline)
                .foregroundStyle(
                    appState.isNightMode
                        ? ResonanceMacTheme.Colors.cream
                        : ResonanceMacTheme.Colors.forestDeep
                )

            ForEach(cosmicWeatherItems, id: \.label) { item in
                HStack {
                    Text(item.icon)
                        .font(.system(size: 14))
                    Text(item.label)
                        .font(ResonanceMacTheme.Typography.caption)
                        .foregroundStyle(ResonanceMacTheme.Colors.mutedGreen)
                    Spacer()
                    Text(item.value)
                        .font(ResonanceMacTheme.Typography.caption)
                        .foregroundStyle(
                            appState.isNightMode
                                ? ResonanceMacTheme.Colors.cream
                                : ResonanceMacTheme.Colors.forestDeep
                        )
                }
            }
        }
        .frame(maxWidth: .infinity)
        .cosmicCard(isNightMode: appState.isNightMode)
        .opacity(animateEntrance ? 1 : 0)
        .offset(y: animateEntrance ? 0 : 20)
    }

    // MARK: - Quick Actions

    private var quickActionsCard: some View {
        VStack(spacing: ResonanceMacTheme.Spacing.sm) {
            quickAction(icon: "pencil.line", label: "New Reflection", color: ResonanceMacTheme.Colors.gold) {
                appState.selectedSection = .reflections
            }
            quickAction(icon: "moon.stars", label: "Start Meditation", color: ResonanceMacTheme.Colors.mutedGreen) {
                appState.selectedSection = .meditations
            }
            quickAction(icon: "circle.circle", label: "View Chart", color: ResonanceMacTheme.Colors.goldDark) {
                appState.selectedSection = .birthChart
            }
        }
        .cosmicCard(isNightMode: appState.isNightMode)
        .opacity(animateEntrance ? 1 : 0)
        .offset(y: animateEntrance ? 0 : 20)
    }

    private func quickAction(icon: String, label: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: { withAnimation(ResonanceMacTheme.Animation.spring) { action() } }) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                    .frame(width: 20)
                Text(label)
                    .font(ResonanceMacTheme.Typography.body)
                    .foregroundStyle(
                        appState.isNightMode
                            ? ResonanceMacTheme.Colors.cream
                            : ResonanceMacTheme.Colors.forestDeep
                    )
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(ResonanceMacTheme.Colors.mutedGreenLight)
            }
            .padding(.vertical, 6)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Helpers

    private var timeOfDayGreeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Morning"
        case 12..<17: return "Afternoon"
        default: return "Evening"
        }
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: Date())
    }

    private var sampleTransits: [TransitData] {
        [
            TransitData(name: "Venus trine Jupiter", glyph: PlanetGlyph.venus, description: "Expanding love and abundance", aspect: "120\u{00B0}"),
            TransitData(name: "Mars square Saturn", glyph: PlanetGlyph.mars, description: "Tension between action and discipline", aspect: "90\u{00B0}"),
            TransitData(name: "Mercury conjunct Neptune", glyph: PlanetGlyph.mercury, description: "Dreamy, intuitive communication", aspect: "0\u{00B0}"),
        ]
    }

    private var cosmicWeatherItems: [(icon: String, label: String, value: String)] {
        [
            (ZodiacGlyph.pisces, "Sun Sign", "Pisces"),
            (PlanetGlyph.moon, "Moon Sign", "Scorpio"),
            (PlanetGlyph.mercury, "Mercury", "Direct"),
            (PlanetGlyph.venus, "Venus", "Aries"),
        ]
    }
}

struct TransitData {
    let name: String
    let glyph: String
    let description: String
    let aspect: String
}

// MARK: - Moon Phase Shape

struct MoonPhaseShape: Shape {
    var illumination: Double

    var animatableData: Double {
        get { illumination }
        set { illumination = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2

        // Full circle for the lit portion
        path.addArc(center: center, radius: radius, startAngle: .degrees(-90), endAngle: .degrees(90), clockwise: false)

        // Curve back based on illumination
        let controlOffset = radius * (1 - 2 * illumination)
        path.addCurve(
            to: CGPoint(x: center.x, y: center.y - radius),
            control1: CGPoint(x: center.x + controlOffset, y: center.y + radius * 0.55),
            control2: CGPoint(x: center.x + controlOffset, y: center.y - radius * 0.55)
        )

        return path
    }
}
