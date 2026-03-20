// TransitCard.swift
// Luminous Cosmic Architecture™
// Transit Event Card Component

import SwiftUI

// MARK: - Transit Card

struct TransitCard: View {
    let transit: Transit
    var isExpanded: Bool = false

    @Environment(\.resonanceTheme) var theme
    @State private var showDetail = false

    var body: some View {
        VStack(alignment: .leading, spacing: ResonanceSpacing.sm) {
            // Header
            HStack(spacing: ResonanceSpacing.sm) {
                // Transit planet glyph
                PlanetGlyphView(
                    planet: transit.planet,
                    size: 20,
                    style: .highlighted
                )

                // Aspect symbol
                if let aspectType = transit.aspectType {
                    Text(aspectType.symbol)
                        .font(.system(size: 14))
                        .foregroundColor(aspectType.color)
                }

                // Natal planet glyph
                if let natalPlanet = transit.natalPlanet {
                    PlanetGlyphView(
                        planet: natalPlanet,
                        size: 18,
                        style: .subdued
                    )
                }

                Spacer()

                // Intensity indicator
                IntensityDots(intensity: transit.intensity)
            }

            // Description
            Text(transit.description)
                .font(ResonanceTypography.bodyMedium)
                .foregroundColor(theme.textPrimary)
                .lineLimit(isExpanded ? nil : 2)

            // Sign context
            HStack(spacing: ResonanceSpacing.xs) {
                Text(transit.sign.glyph)
                    .font(.system(size: 14))

                Text("in \(transit.sign.name)")
                    .font(ResonanceTypography.caption)
                    .foregroundColor(theme.textSecondary)

                Spacer()

                if transit.isActive {
                    ActiveBadge()
                }
            }

            // Expanded details
            if isExpanded || showDetail {
                Divider()
                    .background(theme.border)

                VStack(alignment: .leading, spacing: ResonanceSpacing.xs) {
                    if let aspectType = transit.aspectType {
                        HStack {
                            Text("Aspect:")
                                .font(ResonanceTypography.caption)
                                .foregroundColor(theme.textTertiary)
                            Text(aspectType.name)
                                .font(ResonanceTypography.bodySmall)
                                .foregroundColor(aspectType.color)
                        }

                        Text(aspectInterpretation(aspectType))
                            .font(ResonanceTypography.bodySmall)
                            .foregroundColor(theme.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(ResonanceSpacing.md)
        .glassCard(cornerRadius: ResonanceRadius.lg, intensity: .subtle)
        .onTapGesture {
            withAnimation(ResonanceAnimation.springSmooth) {
                showDetail.toggle()
            }
            ResonanceHaptics.light()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(transit.description)
        .accessibilityHint("Tap to \(showDetail ? "collapse" : "expand") details")
    }

    private func aspectInterpretation(_ aspect: AspectType) -> String {
        switch aspect {
        case .conjunction:
            return "A powerful merging of energies. New beginnings and intensified focus in this area of life."
        case .sextile:
            return "An opportunity for growth. Cooperative energies that support creative expression."
        case .square:
            return "A dynamic tension calling for action. Growth through challenge and adjustment."
        case .trine:
            return "A harmonious flow of energy. Natural talents and ease in this area."
        case .opposition:
            return "A call for balance and integration. Awareness through seeing both sides."
        }
    }
}

// MARK: - Intensity Dots

struct IntensityDots: View {
    let intensity: Double
    @Environment(\.resonanceTheme) var theme

    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<5) { index in
                Circle()
                    .fill(index < activeDots ? ResonanceColors.goldPrimary : theme.border)
                    .frame(width: 4, height: 4)
            }
        }
        .accessibilityLabel("Intensity: \(activeDots) out of 5")
    }

    private var activeDots: Int {
        max(1, min(5, Int(intensity * 5)))
    }
}

// MARK: - Active Badge

struct ActiveBadge: View {
    @State private var pulse = false

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(ResonanceColors.goldPrimary)
                .frame(width: 6, height: 6)
                .scaleEffect(pulse ? 1.3 : 1.0)

            Text("ACTIVE")
                .font(.system(size: 9, weight: .bold, design: .default))
                .foregroundColor(ResonanceColors.goldPrimary)
                .tracking(1)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(
            Capsule()
                .fill(ResonanceColors.goldPrimary.opacity(0.1))
        )
        .overlay(
            Capsule()
                .strokeBorder(ResonanceColors.goldPrimary.opacity(0.3), lineWidth: 0.5)
        )
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }
}

// MARK: - Transit List

struct TransitListView: View {
    let transits: [Transit]
    @Environment(\.resonanceTheme) var theme

    var body: some View {
        VStack(alignment: .leading, spacing: ResonanceSpacing.md) {
            HStack {
                Text("Current Transits")
                    .font(ResonanceTypography.headlineMedium)
                    .foregroundColor(theme.textPrimary)

                Spacer()

                Text("\(transits.count) active")
                    .font(ResonanceTypography.caption)
                    .foregroundColor(theme.textTertiary)
            }

            if transits.isEmpty {
                VStack(spacing: ResonanceSpacing.sm) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 32))
                        .foregroundColor(theme.accent)
                        .opacity(0.6)

                    Text("No major transits at this time")
                        .font(ResonanceTypography.bodyMedium)
                        .foregroundColor(theme.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, ResonanceSpacing.xl)
            } else {
                ForEach(transits.prefix(5)) { transit in
                    TransitCard(transit: transit)
                }
            }
        }
    }
}
