// NatalChartView.swift
// Haute Lumière Date & Time — Full Natal Chart
//
// Complete birth chart with 1-4000 words per planet per aspect.
// Each interpretation is personalized to the user's coaching journey,
// Living Systems profile, dosha, element, and enneagram type.
// This is social-media shareable — impeccably illustrated.

import SwiftUI

struct NatalChartView: View {
    @EnvironmentObject var cosmicEngine: CosmicEngine
    @State private var selectedPlanet: PlanetPlacement?
    @State private var showShareSheet = false

    private let gold = Color(hex: "D4AF37")
    private let ivory = Color(hex: "FAFAF5")
    private let muted = Color(hex: "8A8A85")
    private let bg = Color(hex: "050505")

    var body: some View {
        NavigationStack {
            ZStack {
                bg.ignoresSafeArea()

                if let profile = cosmicEngine.profile {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 24) {
                            // Chart wheel visualization
                            chartWheel(profile.astrology)
                                .frame(height: 320)
                                .padding(.top, 12)

                            // Big 3
                            bigThreeCards(profile.astrology)

                            // All planets
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Your Planetary Positions")
                                    .font(.custom("Cormorant Garamond", size: 22).weight(.medium))
                                    .foregroundColor(ivory)
                                    .padding(.horizontal, 16)

                                ForEach(profile.astrology.allPlanets) { placement in
                                    planetCard(placement)
                                        .onTapGesture { selectedPlanet = placement }
                                }
                            }

                            // Traditions summary
                            traditionsSummary(profile)

                            // Share button
                            Button(action: { showShareSheet = true }) {
                                HStack {
                                    Image(systemName: "square.and.arrow.up")
                                    Text("Share Your Chart")
                                        .font(.custom("Avenir Next", size: 15).weight(.medium))
                                }
                                .foregroundColor(bg)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(gold)
                                .clipShape(RoundedRectangle(cornerRadius: 100))
                            }
                            .padding(.horizontal, 16)

                            Spacer(minLength: 100)
                        }
                    }
                } else {
                    Text("Generate your profile first")
                        .foregroundColor(muted)
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Your Chart")
                        .font(.custom("Cormorant Garamond", size: 18).weight(.medium))
                        .foregroundColor(ivory)
                }
            }
            .sheet(item: $selectedPlanet) { placement in
                if let profile = cosmicEngine.profile {
                    PlanetDetailView(
                        interpretation: cosmicEngine.interpretPlanet(placement, profile: profile)
                    )
                }
            }
        }
    }

    // MARK: - Chart Wheel
    private func chartWheel(_ astrology: AstrologyProfile) -> some View {
        ZStack {
            // Outer ring — zodiac signs
            ForEach(0..<12, id: \.self) { i in
                let sign = ZodiacSign.allCases[i]
                let angle = Double(i) * 30.0 - 90
                Text(sign.symbol)
                    .font(.system(size: 18))
                    .foregroundColor(sign == astrology.sunSign ? gold : ivory.opacity(0.4))
                    .offset(
                        x: cos(angle * .pi / 180) * 130,
                        y: sin(angle * .pi / 180) * 130
                    )
            }

            // Ring circles
            Circle().stroke(gold.opacity(0.15), lineWidth: 0.5).frame(width: 280, height: 280)
            Circle().stroke(gold.opacity(0.1), lineWidth: 0.5).frame(width: 200, height: 200)
            Circle().stroke(gold.opacity(0.08), lineWidth: 0.5).frame(width: 120, height: 120)

            // Planet positions (simplified)
            ForEach(astrology.allPlanets) { placement in
                let signIndex = ZodiacSign.allCases.firstIndex(of: placement.sign) ?? 0
                let angle = Double(signIndex) * 30.0 + placement.degree - 90
                let radius: Double = 85

                Text(placement.planet.symbol)
                    .font(.system(size: 14))
                    .foregroundColor(gold)
                    .offset(
                        x: cos(angle * .pi / 180) * radius,
                        y: sin(angle * .pi / 180) * radius
                    )
            }

            // Center
            VStack(spacing: 2) {
                Text(astrology.sunSign.symbol)
                    .font(.system(size: 28))
                Text(astrology.sunSign.displayName)
                    .font(.custom("Cormorant Garamond", size: 12))
                    .foregroundColor(gold)
            }

            // Brand watermark
            VStack {
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "light.max")
                        .font(.system(size: 8, weight: .ultraLight))
                    Text("Haute Lumière")
                        .font(.custom("Cormorant Garamond", size: 9))
                }
                .foregroundColor(gold.opacity(0.4))
            }
            .frame(height: 300)
        }
    }

    // MARK: - Big Three
    private func bigThreeCards(_ astrology: AstrologyProfile) -> some View {
        HStack(spacing: 10) {
            bigThreeCard("Sun", sign: astrology.sunSign, subtitle: "Core Self")
            bigThreeCard("Moon", sign: astrology.moonSign, subtitle: "Inner World")
            bigThreeCard("Rising", sign: astrology.risingSign, subtitle: "Outer Mask")
        }
        .padding(.horizontal, 16)
    }

    private func bigThreeCard(_ label: String, sign: ZodiacSign, subtitle: String) -> some View {
        VStack(spacing: 6) {
            Text(sign.symbol)
                .font(.system(size: 24))
            Text(sign.displayName)
                .font(.custom("Cormorant Garamond", size: 14).weight(.medium))
                .foregroundColor(ivory)
            Text(label)
                .font(.custom("Avenir Next", size: 10).weight(.semibold))
                .foregroundColor(gold)
            Text(subtitle)
                .font(.custom("Avenir Next", size: 9))
                .foregroundColor(muted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(RoundedRectangle(cornerRadius: 14).fill(Color.white.opacity(0.03)))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(gold.opacity(0.15), lineWidth: 0.5))
    }

    // MARK: - Planet Card
    private func planetCard(_ placement: PlanetPlacement) -> some View {
        HStack(spacing: 14) {
            Text(placement.planet.symbol)
                .font(.system(size: 22))
                .frame(width: 36)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(placement.planet.displayName)
                        .font(.custom("Avenir Next", size: 14).weight(.semibold))
                        .foregroundColor(ivory)
                    if placement.isRetrograde {
                        Text("℞")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "C45A5A"))
                    }
                }
                Text("\(placement.sign.displayName) \(placement.sign.symbol) · \(String(format: "%.0f", placement.degree))° · House \(placement.house)")
                    .font(.custom("Avenir Next", size: 11))
                    .foregroundColor(muted)
                Text(placement.planet.domain)
                    .font(.custom("Avenir Next", size: 10))
                    .foregroundColor(ivory.opacity(0.5))
                    .lineLimit(1)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(gold.opacity(0.4))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.02)))
    }

    // MARK: - Traditions Summary
    private func traditionsSummary(_ profile: CosmicProfile) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Cosmic Identity")
                .font(.custom("Cormorant Garamond", size: 22).weight(.medium))
                .foregroundColor(ivory)

            HStack(spacing: 10) {
                identityPill("Life Path \(profile.numerology.lifePathNumber)", icon: "number.circle.fill")
                identityPill(profile.ayurveda.primaryDosha.rawValue, icon: "leaf.circle.fill")
                identityPill(profile.fiveElements.dominantElement.rawValue, icon: "flame.circle.fill")
            }

            HStack(spacing: 10) {
                identityPill(profile.enneagram.coreType.displayName, icon: "circle.hexagongrid.circle.fill")
                identityPill("\(profile.astrology.dominantElement.rawValue.capitalized) Dominant", icon: "star.circle.fill")
            }
        }
        .padding(.horizontal, 16)
    }

    private func identityPill(_ text: String, icon: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon).font(.system(size: 10)).foregroundColor(gold)
            Text(text).font(.custom("Avenir Next", size: 10)).foregroundColor(ivory.opacity(0.7))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Capsule().fill(Color.white.opacity(0.04)))
    }
}

// MARK: - Planet Detail View (1-4000 words per planet)
struct PlanetDetailView: View {
    let interpretation: PlanetInterpretation
    @Environment(\.dismiss) private var dismiss

    private let gold = Color(hex: "D4AF37")
    private let ivory = Color(hex: "FAFAF5")
    private let muted = Color(hex: "8A8A85")

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "050505").ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        // Header
                        HStack {
                            Text(interpretation.placement.planet.symbol)
                                .font(.system(size: 40))
                            VStack(alignment: .leading, spacing: 4) {
                                Text(interpretation.title)
                                    .font(.custom("Cormorant Garamond", size: 22).weight(.medium))
                                    .foregroundColor(ivory)
                                Text("House \(interpretation.placement.house) · \(String(format: "%.1f", interpretation.placement.degree))°\(interpretation.placement.isRetrograde ? " ℞ Retrograde" : "")")
                                    .font(.custom("Avenir Next", size: 12))
                                    .foregroundColor(muted)
                            }
                        }

                        Rectangle().fill(gold.opacity(0.2)).frame(height: 0.5)

                        // Full interpretation
                        Text(interpretation.body)
                            .font(.custom("Avenir Next", size: 14))
                            .foregroundColor(ivory.opacity(0.85))
                            .lineSpacing(6)

                        Rectangle().fill(gold.opacity(0.2)).frame(height: 0.5)

                        // Connections
                        VStack(alignment: .leading, spacing: 12) {
                            connectionRow(icon: "chart.pie.fill", label: "Life Wheel", value: interpretation.relatedLifeWheel)
                            connectionRow(icon: "heart.circle.fill", label: "Living System", value: interpretation.relatedLivingSystem)
                            connectionRow(icon: "moon.stars.fill", label: "Aligned Meditation", value: interpretation.meditationAlignment)
                        }

                        // Share
                        Button(action: {}) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Share This Reading")
                                    .font(.custom("Avenir Next", size: 14).weight(.medium))
                            }
                            .foregroundColor(Color(hex: "050505"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(gold)
                            .clipShape(RoundedRectangle(cornerRadius: 100))
                        }

                        Spacer(minLength: 40)
                    }
                    .padding(20)
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }.foregroundColor(muted)
                }
            }
        }
    }

    private func connectionRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon).foregroundColor(gold).frame(width: 20)
            VStack(alignment: .leading, spacing: 2) {
                Text(label).font(.custom("Avenir Next", size: 10)).foregroundColor(muted)
                Text(value).font(.custom("Avenir Next", size: 13)).foregroundColor(ivory)
            }
        }
    }
}
