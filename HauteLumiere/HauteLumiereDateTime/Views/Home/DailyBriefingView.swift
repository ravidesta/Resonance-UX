// DailyBriefingView.swift
// Haute Lumière Date & Time — Daily 5-Page Illustrated Briefing
//
// Opens every morning to an impeccably illustrated briefing:
// Page 1: Cosmic Weather Overview
// Page 2: Life Wheel Forecasts (every spoke)
// Page 3: Auspicious Times for Goal Initiation
// Page 4: Numerology + Dosha + Element Focus
// Page 5: Your Cosmic Meditation (synced to stars/numbers/doshas)

import SwiftUI

struct DailyBriefingView: View {
    @EnvironmentObject var cosmicEngine: CosmicEngine
    @State private var currentPage = 0
    @State private var showReadingPurchase = false

    private let gold = Color(hex: "D4AF37")
    private let ivory = Color(hex: "FAFAF5")
    private let muted = Color(hex: "8A8A85")
    private let bg = Color(hex: "050505")

    var body: some View {
        NavigationStack {
            ZStack {
                bg.ignoresSafeArea()

                if let forecast = cosmicEngine.todaysForecast {
                    TabView(selection: $currentPage) {
                        // Page 1: Cosmic Weather
                        cosmicWeatherPage(forecast)
                            .tag(0)

                        // Page 2: Life Wheel Forecasts
                        lifeWheelPage(forecast)
                            .tag(1)

                        // Page 3: Auspicious Times
                        auspiciousTimesPage(forecast)
                            .tag(2)

                        // Page 4: Traditions Synthesis
                        traditionsSynthesisPage(forecast)
                            .tag(3)

                        // Page 5: Cosmic Meditation
                        cosmicMeditationPage()
                            .tag(4)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))

                    // Page indicator
                    VStack {
                        Spacer()
                        HStack(spacing: 8) {
                            ForEach(0..<5, id: \.self) { page in
                                Circle()
                                    .fill(currentPage == page ? gold : ivory.opacity(0.2))
                                    .frame(width: 6, height: 6)
                            }
                        }
                        .padding(.bottom, 20)
                    }
                } else {
                    VStack(spacing: 16) {
                        ProgressView().tint(gold)
                        Text("Aligning your cosmos...")
                            .font(.custom("Cormorant Garamond", size: 18))
                            .foregroundColor(muted)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 6) {
                        Image(systemName: "light.max")
                            .font(.system(size: 10, weight: .ultraLight))
                            .foregroundColor(gold)
                        Text("Today's Briefing")
                            .font(.custom("Cormorant Garamond", size: 18).weight(.medium))
                            .foregroundColor(ivory)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showReadingPurchase = true }) {
                        Image(systemName: "doc.richtext")
                            .foregroundColor(gold)
                    }
                }
            }
            .sheet(isPresented: $showReadingPurchase) {
                CosmicReadingView()
                    .environmentObject(cosmicEngine)
            }
        }
    }

    // MARK: - Page 1: Cosmic Weather
    private func cosmicWeatherPage(_ forecast: DailyCosmicForecast) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Date
                Text(forecast.date, style: .date)
                    .font(.custom("Avenir Next", size: 12))
                    .foregroundColor(muted)

                // Moon + Sun
                HStack(spacing: 32) {
                    VStack(spacing: 8) {
                        Image(systemName: forecast.moonPhase.icon)
                            .font(.system(size: 36, weight: .ultraLight))
                            .foregroundColor(gold)
                        Text(forecast.moonPhase.rawValue)
                            .font(.custom("Cormorant Garamond", size: 14))
                            .foregroundColor(ivory)
                    }
                    VStack(spacing: 8) {
                        Text(forecast.sunTransit.symbol)
                            .font(.system(size: 36))
                        Text("Sun in \(forecast.sunTransit.displayName)")
                            .font(.custom("Cormorant Garamond", size: 14))
                            .foregroundColor(ivory)
                    }
                }

                // Cosmic Weather narrative
                Text(forecast.cosmicWeather)
                    .font(.custom("Avenir Next", size: 14))
                    .foregroundColor(ivory.opacity(0.8))
                    .lineSpacing(5)
                    .padding(.horizontal, 24)

                // Overall energy
                VStack(spacing: 8) {
                    Text("Overall Cosmic Energy")
                        .font(.custom("Avenir Next", size: 11))
                        .foregroundColor(muted)
                    Text(forecast.overallEnergy)
                        .font(.custom("Cormorant Garamond", size: 48).weight(.light))
                        .foregroundColor(gold)
                }

                // Element + Dosha
                HStack(spacing: 24) {
                    cosmicPill(icon: "flame.circle.fill", label: "\(forecast.elementFocus.rawValue) Element")
                    cosmicPill(icon: "leaf.circle.fill", label: forecast.doshaAdvice.components(separatedBy: ":").first ?? "")
                }

                Spacer(minLength: 60)
            }
            .padding(.top, 20)
        }
    }

    // MARK: - Page 2: Life Wheel Forecasts
    private func lifeWheelPage(_ forecast: DailyCosmicForecast) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                Text("Life Wheel Forecast")
                    .font(.custom("Cormorant Garamond", size: 24).weight(.medium))
                    .foregroundColor(ivory)

                ForEach(forecast.lifeWheelForecasts) { wheelForecast in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(wheelForecast.dimension)
                                .font(.custom("Avenir Next", size: 14).weight(.semibold))
                                .foregroundColor(ivory)
                            Spacer()

                            // Energy bar
                            HStack(spacing: 2) {
                                ForEach(0..<10, id: \.self) { i in
                                    RoundedRectangle(cornerRadius: 1)
                                        .fill(Double(i) < wheelForecast.energy ? gold : ivory.opacity(0.1))
                                        .frame(width: 12, height: 4)
                                }
                            }
                        }

                        Text(wheelForecast.forecast)
                            .font(.custom("Avenir Next", size: 12))
                            .foregroundColor(ivory.opacity(0.7))
                            .lineSpacing(3)
                            .lineLimit(3)

                        // Cosmic support
                        Text(wheelForecast.cosmicSupport)
                            .font(.custom("Cormorant Garamond", size: 11).italic())
                            .foregroundColor(gold.opacity(0.6))
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.03))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(gold.opacity(0.08), lineWidth: 0.5)
                    )
                }

                Spacer(minLength: 60)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
        }
    }

    // MARK: - Page 3: Auspicious Times
    private func auspiciousTimesPage(_ forecast: DailyCosmicForecast) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                Text("Auspicious Times")
                    .font(.custom("Cormorant Garamond", size: 24).weight(.medium))
                    .foregroundColor(ivory)

                Text("Aligned across traditions for your birth chart")
                    .font(.custom("Avenir Next", size: 12))
                    .foregroundColor(muted)

                ForEach(forecast.auspiciousTimes) { time in
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(time.timeWindow)
                                    .font(.custom("Cormorant Garamond", size: 20).weight(.medium))
                                    .foregroundColor(gold)
                                Text(time.activity)
                                    .font(.custom("Avenir Next", size: 14))
                                    .foregroundColor(ivory)
                            }
                            Spacer()

                            // Strength indicator
                            Text(time.strength.rawValue)
                                .font(.custom("Avenir Next", size: 10).weight(.semibold))
                                .foregroundColor(bg)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule().fill(time.strength == .exceptional ? gold : gold.opacity(0.6))
                                )
                        }

                        HStack(spacing: 8) {
                            Text("\(time.planetaryHour.symbol) \(time.planetaryHour.displayName) hour")
                                .font(.custom("Avenir Next", size: 11))
                                .foregroundColor(muted)

                            Text("·")
                                .foregroundColor(muted)

                            Text(time.traditions.joined(separator: " · "))
                                .font(.custom("Avenir Next", size: 10))
                                .foregroundColor(gold.opacity(0.5))
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.03))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(colors: [gold.opacity(0.3), gold.opacity(0.1)],
                                               startPoint: .topLeading, endPoint: .bottomTrailing),
                                lineWidth: 0.5
                            )
                    )
                }

                Spacer(minLength: 60)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
        }
    }

    // MARK: - Page 4: Traditions Synthesis
    private func traditionsSynthesisPage(_ forecast: DailyCosmicForecast) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                Text("Your Cosmic Synthesis")
                    .font(.custom("Cormorant Garamond", size: 24).weight(.medium))
                    .foregroundColor(ivory)

                // Numerology
                traditionCard(
                    icon: "number.circle.fill",
                    title: "Numerology",
                    headline: "Personal Day \(forecast.dailyNumerology.personalDay)",
                    body: forecast.dailyNumerology.advice
                )

                // Dosha
                traditionCard(
                    icon: "leaf.circle.fill",
                    title: "Ayurveda",
                    headline: "Dosha Guidance",
                    body: forecast.doshaAdvice
                )

                // Five Elements
                traditionCard(
                    icon: "flame.circle.fill",
                    title: "Five Elements",
                    headline: "\(forecast.elementFocus.rawValue) Element Day",
                    body: "Organ focus: \(forecast.elementFocus.organ). Emotional axis: \(forecast.elementFocus.emotion). Practice: \(forecast.elementFocus.qiGungBreathing)"
                )

                // Enneagram (if profile exists)
                if let profile = cosmicEngine.profile {
                    traditionCard(
                        icon: "circle.hexagongrid.circle.fill",
                        title: "Enneagram",
                        headline: profile.enneagram.coreType.displayName,
                        body: "Core motivation: \(profile.enneagram.coreType.coreMotivation). Today's \(forecast.dailyNumerology.vibration.lowercased()) energy supports your integration direction."
                    )
                }

                Spacer(minLength: 60)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
        }
    }

    // MARK: - Page 5: Cosmic Meditation
    private func cosmicMeditationPage() -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                Text("Your Cosmic Practice")
                    .font(.custom("Cormorant Garamond", size: 24).weight(.medium))
                    .foregroundColor(ivory)

                Text("Synchronized with your stars, numbers, and doshas")
                    .font(.custom("Avenir Next", size: 12))
                    .foregroundColor(muted)

                if let meditation = cosmicEngine.cosmicMeditationRecommendation() {
                    VStack(spacing: 20) {
                        // Duration + Time
                        HStack(spacing: 24) {
                            VStack(spacing: 4) {
                                Text("\(meditation.duration)")
                                    .font(.custom("Cormorant Garamond", size: 42).weight(.light))
                                    .foregroundColor(gold)
                                Text("minutes")
                                    .font(.custom("Avenir Next", size: 11))
                                    .foregroundColor(muted)
                            }
                            VStack(spacing: 4) {
                                Text(meditation.auspiciousTime)
                                    .font(.custom("Cormorant Garamond", size: 18).weight(.medium))
                                    .foregroundColor(ivory)
                                Text("auspicious time")
                                    .font(.custom("Avenir Next", size: 11))
                                    .foregroundColor(muted)
                            }
                        }

                        // Breathing
                        meditationDetail(icon: "wind", title: "Breathing", detail: meditation.breathingTechnique)
                        meditationDetail(icon: "waveform", title: "Soundscape", detail: meditation.soundscape)
                        meditationDetail(icon: "eye", title: "Visualization", detail: meditation.visualization)
                        meditationDetail(icon: "waveform.path", title: "Binaural", detail: "\(String(format: "%.1f", meditation.binauralFrequency)) Hz")

                        // Rationale
                        Text(meditation.cosmicRationale)
                            .font(.custom("Cormorant Garamond", size: 13).italic())
                            .foregroundColor(gold.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .lineSpacing(3)
                            .padding(.horizontal, 12)

                        // Begin button
                        Button(action: {}) {
                            HStack {
                                Image(systemName: "play.fill")
                                Text("Begin Cosmic Practice")
                                    .font(.custom("Avenir Next", size: 15).weight(.medium))
                            }
                            .foregroundColor(bg)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(gold)
                            .clipShape(RoundedRectangle(cornerRadius: 100))
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.03))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(gold.opacity(0.2), lineWidth: 0.5)
                    )
                }

                Spacer(minLength: 60)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
        }
    }

    // MARK: - Helpers

    private func cosmicPill(icon: String, label: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(gold)
            Text(label)
                .font(.custom("Avenir Next", size: 12))
                .foregroundColor(ivory.opacity(0.7))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Capsule().fill(Color.white.opacity(0.04)))
        .overlay(Capsule().stroke(gold.opacity(0.15), lineWidth: 0.5))
    }

    private func traditionCard(icon: String, title: String, headline: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(gold)
                Text(title)
                    .font(.custom("Avenir Next", size: 12).weight(.semibold))
                    .foregroundColor(gold)
            }
            Text(headline)
                .font(.custom("Cormorant Garamond", size: 20).weight(.medium))
                .foregroundColor(ivory)
            Text(body)
                .font(.custom("Avenir Next", size: 13))
                .foregroundColor(ivory.opacity(0.7))
                .lineSpacing(3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.03)))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(gold.opacity(0.1), lineWidth: 0.5))
    }

    private func meditationDetail(icon: String, title: String, detail: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(gold)
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.custom("Avenir Next", size: 11))
                    .foregroundColor(muted)
                Text(detail)
                    .font(.custom("Avenir Next", size: 13))
                    .foregroundColor(ivory)
            }
            Spacer()
        }
    }
}
