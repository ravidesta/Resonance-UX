// NatalChartView.swift
// Luminous Cosmic Architecture™
// Interactive Circular Natal Chart View

import SwiftUI

// MARK: - Natal Chart View

struct NatalChartView: View {
    let chart: NatalChart
    @Environment(\.resonanceTheme) var theme
    @Environment(\.dismiss) var dismiss
    @State private var selectedTab: ChartTab = .chart
    @State private var selectedPlanet: PlanetaryPosition?
    @State private var chartScale: CGFloat = 1.0
    @State private var appear = false

    enum ChartTab: String, CaseIterable {
        case chart = "Chart"
        case planets = "Planets"
        case houses = "Houses"
        case aspects = "Aspects"
    }

    var body: some View {
        ZStack {
            CosmicBackground(showStars: true, blobCount: 2)

            VStack(spacing: 0) {
                // Navigation Bar
                chartNavBar

                // Tab Selector
                chartTabSelector

                // Content
                TabView(selection: $selectedTab) {
                    chartView.tag(ChartTab.chart)
                    planetsListView.tag(ChartTab.planets)
                    housesListView.tag(ChartTab.houses)
                    aspectsListView.tag(ChartTab.aspects)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
        }
        .onAppear {
            withAnimation(ResonanceAnimation.springGentle.delay(0.2)) {
                appear = true
            }
        }
    }

    // MARK: - Nav Bar

    private var chartNavBar: some View {
        HStack {
            Button {
                dismiss()
                ResonanceHaptics.light()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(theme.textSecondary)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(theme.surface.opacity(0.5)))
            }

            Spacer()

            VStack(spacing: 2) {
                Text("Natal Chart")
                    .font(ResonanceTypography.headlineSmall)
                    .foregroundColor(theme.textPrimary)

                Text(chart.birthPlace)
                    .font(ResonanceTypography.caption)
                    .foregroundColor(theme.textTertiary)
            }

            Spacer()

            // Placeholder for symmetry
            Color.clear.frame(width: 36, height: 36)
        }
        .padding(.horizontal, ResonanceSpacing.md)
        .padding(.top, ResonanceSpacing.sm)
    }

    // MARK: - Tab Selector

    private var chartTabSelector: some View {
        HStack(spacing: ResonanceSpacing.xxs) {
            ForEach(ChartTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(ResonanceAnimation.springSmooth) {
                        selectedTab = tab
                    }
                    ResonanceHaptics.selection()
                } label: {
                    Text(tab.rawValue)
                        .font(ResonanceTypography.bodySmall)
                        .fontWeight(selectedTab == tab ? .semibold : .regular)
                        .foregroundColor(selectedTab == tab ? theme.textPrimary : theme.textTertiary)
                        .padding(.horizontal, ResonanceSpacing.md)
                        .padding(.vertical, ResonanceSpacing.xs)
                        .background(
                            Capsule()
                                .fill(selectedTab == tab ? theme.accent.opacity(0.15) : .clear)
                        )
                }
            }
        }
        .padding(.horizontal, ResonanceSpacing.md)
        .padding(.vertical, ResonanceSpacing.sm)
    }

    // MARK: - Chart View

    private var chartView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: ResonanceSpacing.lg) {
                // Main Chart Wheel
                ZodiacWheel(
                    chart: chart,
                    size: min(UIScreen.main.bounds.width - 40, 360),
                    showPlanets: true,
                    showHouses: true,
                    showAspects: true,
                    interactive: true
                )
                .scaleEffect(appear ? 1 : 0.7)
                .opacity(appear ? 1 : 0)
                .padding(.top, ResonanceSpacing.md)

                // Big Three Summary
                bigThreeSummary

                // Selected Planet Detail
                if let planet = selectedPlanet {
                    planetDetailCard(planet)
                        .transition(.asymmetric(
                            insertion: .move(edge: .bottom).combined(with: .opacity),
                            removal: .opacity
                        ))
                }

                Spacer(minLength: ResonanceSpacing.xxxl)
            }
        }
    }

    // MARK: - Big Three Summary

    private var bigThreeSummary: some View {
        VStack(spacing: ResonanceSpacing.md) {
            Text("The Big Three")
                .font(ResonanceTypography.headlineMedium)
                .foregroundColor(theme.textPrimary)

            HStack(spacing: ResonanceSpacing.lg) {
                bigThreeDetail(
                    title: "Sun",
                    sign: chart.sunSign,
                    description: "Your core identity and life purpose"
                )

                Divider()
                    .frame(height: 60)
                    .background(theme.border)

                bigThreeDetail(
                    title: "Moon",
                    sign: chart.moonSign,
                    description: "Your emotional nature and inner world"
                )

                Divider()
                    .frame(height: 60)
                    .background(theme.border)

                bigThreeDetail(
                    title: "Rising",
                    sign: chart.risingSign,
                    description: "How you appear to the world"
                )
            }
        }
        .padding(ResonanceSpacing.lg)
        .glassCard(cornerRadius: ResonanceRadius.xl)
        .padding(.horizontal, ResonanceSpacing.md)
    }

    private func bigThreeDetail(title: String, sign: ZodiacSign, description: String) -> some View {
        VStack(spacing: ResonanceSpacing.xs) {
            Text(title)
                .font(ResonanceTypography.overline)
                .foregroundColor(theme.textTertiary)
                .textCase(.uppercase)
                .tracking(1)

            Text(sign.glyph)
                .font(.system(size: 28))
                .foregroundColor(sign.color)

            Text(sign.name)
                .font(ResonanceTypography.bodySmall)
                .fontWeight(.medium)
                .foregroundColor(theme.textPrimary)

            Text(description)
                .font(.system(size: 10))
                .foregroundColor(theme.textTertiary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Planet Detail Card

    private func planetDetailCard(_ position: PlanetaryPosition) -> some View {
        VStack(alignment: .leading, spacing: ResonanceSpacing.sm) {
            HStack {
                PlanetGlyphView(planet: position.planet, size: 28, style: .highlighted)

                VStack(alignment: .leading) {
                    Text(position.planet.name)
                        .font(ResonanceTypography.headlineMedium)
                        .foregroundColor(theme.textPrimary)

                    Text(position.formattedPosition)
                        .font(ResonanceTypography.bodySmall)
                        .foregroundColor(theme.textSecondary)
                }

                Spacer()

                Button {
                    withAnimation(ResonanceAnimation.springSmooth) {
                        selectedPlanet = nil
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(theme.textTertiary)
                }
            }

            Divider().background(theme.border)

            Text(planetInterpretation(position))
                .font(ResonanceTypography.bodyMedium)
                .foregroundColor(theme.textSecondary)
                .lineSpacing(4)
        }
        .padding(ResonanceSpacing.lg)
        .glassCard(cornerRadius: ResonanceRadius.lg)
        .padding(.horizontal, ResonanceSpacing.md)
    }

    // MARK: - Planets List

    private var planetsListView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: ResonanceSpacing.xs) {
                ForEach(chart.planets) { position in
                    Button {
                        withAnimation(ResonanceAnimation.springSmooth) {
                            selectedPlanet = position
                            selectedTab = .chart
                        }
                        ResonanceHaptics.light()
                    } label: {
                        PlanetRow(position: position)
                            .padding(.horizontal, ResonanceSpacing.md)
                            .padding(.vertical, ResonanceSpacing.xs)
                    }
                    .buttonStyle(.plain)

                    if position.planet != chart.planets.last?.planet {
                        Divider()
                            .background(theme.border)
                            .padding(.horizontal, ResonanceSpacing.xl)
                    }
                }
            }
            .padding(.vertical, ResonanceSpacing.md)
            .glassCard(cornerRadius: ResonanceRadius.xl)
            .padding(.horizontal, ResonanceSpacing.md)
            .padding(.top, ResonanceSpacing.md)
        }
    }

    // MARK: - Houses List

    private var housesListView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: ResonanceSpacing.xs) {
                ForEach(chart.houses) { house in
                    HStack {
                        Text(house.romanNumeral)
                            .font(ResonanceTypography.headlineSmall)
                            .foregroundColor(theme.accent)
                            .frame(width: 36)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(house.meaning)
                                .font(ResonanceTypography.bodyMedium)
                                .foregroundColor(theme.textPrimary)

                            HStack(spacing: 4) {
                                Text(house.sign.glyph)
                                    .font(.system(size: 14))
                                Text(house.sign.name)
                                    .font(ResonanceTypography.bodySmall)
                                    .foregroundColor(theme.textSecondary)
                            }
                        }

                        Spacer()

                        Text("\(Int(house.cuspDegree))\u{00B0}")
                            .font(ResonanceTypography.caption)
                            .foregroundColor(theme.textTertiary)
                            .monospacedDigit()
                    }
                    .padding(.horizontal, ResonanceSpacing.md)
                    .padding(.vertical, ResonanceSpacing.sm)

                    if house.number != 12 {
                        Divider()
                            .background(theme.border)
                            .padding(.horizontal, ResonanceSpacing.xl)
                    }
                }
            }
            .padding(.vertical, ResonanceSpacing.md)
            .glassCard(cornerRadius: ResonanceRadius.xl)
            .padding(.horizontal, ResonanceSpacing.md)
            .padding(.top, ResonanceSpacing.md)
        }
    }

    // MARK: - Aspects List

    private var aspectsListView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: ResonanceSpacing.xs) {
                ForEach(chart.aspects) { aspect in
                    HStack(spacing: ResonanceSpacing.sm) {
                        HStack(spacing: 4) {
                            Text(aspect.planet1.glyph)
                                .foregroundColor(aspect.planet1.color)

                            Text(aspect.type.symbol)
                                .foregroundColor(aspect.type.color)

                            Text(aspect.planet2.glyph)
                                .foregroundColor(aspect.planet2.color)
                        }
                        .font(.system(size: 18))
                        .frame(width: 80)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(aspect.planet1.name) \(aspect.type.name) \(aspect.planet2.name)")
                                .font(ResonanceTypography.bodySmall)
                                .foregroundColor(theme.textPrimary)

                            Text("Orb: \(String(format: "%.1f", aspect.orb))\u{00B0}")
                                .font(ResonanceTypography.caption)
                                .foregroundColor(theme.textTertiary)
                        }

                        Spacer()

                        // Harmony indicator
                        Image(systemName: aspect.type.isHarmonious ? "hand.thumbsup" : "bolt.fill")
                            .font(.system(size: 12))
                            .foregroundColor(aspect.type.isHarmonious ? ResonanceColors.water : ResonanceColors.fire)
                    }
                    .padding(.horizontal, ResonanceSpacing.md)
                    .padding(.vertical, ResonanceSpacing.sm)

                    if aspect.id != chart.aspects.last?.id {
                        Divider()
                            .background(theme.border)
                            .padding(.horizontal, ResonanceSpacing.xl)
                    }
                }
            }
            .padding(.vertical, ResonanceSpacing.md)
            .glassCard(cornerRadius: ResonanceRadius.xl)
            .padding(.horizontal, ResonanceSpacing.md)
            .padding(.top, ResonanceSpacing.md)
        }
    }

    // MARK: - Interpretation

    private func planetInterpretation(_ position: PlanetaryPosition) -> String {
        let planet = position.planet
        let sign = position.sign

        switch planet {
        case .sun:
            return "Your Sun in \(sign.name) reveals your core identity and life direction. The \(sign.element.name) element infuses your being with \(sign.element == .fire ? "passion and initiative" : sign.element == .earth ? "groundedness and practicality" : sign.element == .air ? "intellect and communication" : "emotional depth and intuition")."
        case .moon:
            return "Your Moon in \(sign.name) speaks to your emotional landscape and inner needs. You process feelings through the lens of \(sign.element.name), seeking \(sign.element == .fire ? "excitement and inspiration" : sign.element == .earth ? "security and stability" : sign.element == .air ? "understanding and connection" : "emotional authenticity and depth")."
        case .mercury:
            return "Mercury in \(sign.name) shapes how you think and communicate. Your mind operates with \(sign.modality.name) \(sign.element.name) energy, giving you a \(sign.modality == .cardinal ? "pioneering" : sign.modality == .fixed ? "focused" : "versatile") approach to learning."
        case .venus:
            return "Venus in \(sign.name) reveals your approach to love, beauty, and values. You are drawn to \(sign.element == .fire ? "passionate, dynamic" : sign.element == .earth ? "sensual, tangible" : sign.element == .air ? "intellectual, aesthetic" : "deep, soulful") expressions of affection."
        case .mars:
            return "Mars in \(sign.name) drives your ambition and how you assert yourself. Your energy is channeled through \(sign.element.name), making you \(sign.element == .fire ? "bold and direct" : sign.element == .earth ? "persistent and methodical" : sign.element == .air ? "strategic and diplomatic" : "emotionally driven and tenacious")."
        default:
            return "\(planet.name) in \(sign.name) adds a layer of \(sign.element.name) influence to the themes of \(planet.name.lowercased()) in your chart. This placement operates on a \(planet.isPersonal ? "personal" : "generational") level."
        }
    }
}
