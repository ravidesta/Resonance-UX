// OnboardingView.swift
// Luminous Cosmic Architecture™
// Multi-Step Onboarding Flow

import SwiftUI

// MARK: - Onboarding View

struct OnboardingView: View {
    @Binding var isOnboarding: Bool
    @StateObject private var viewModel = OnboardingViewModel()
    @Environment(\.resonanceTheme) var theme

    var body: some View {
        ZStack {
            CosmicBackground(showStars: true, blobCount: 3)

            VStack {
                // Progress dots
                HStack(spacing: ResonanceSpacing.xs) {
                    ForEach(0..<4) { index in
                        Capsule()
                            .fill(index <= viewModel.currentStep
                                ? ResonanceColors.goldPrimary
                                : theme.border)
                            .frame(
                                width: index == viewModel.currentStep ? 24 : 8,
                                height: 4
                            )
                            .animation(ResonanceAnimation.springSmooth, value: viewModel.currentStep)
                    }
                }
                .padding(.top, ResonanceSpacing.xxl)

                Spacer()

                // Step content
                TabView(selection: $viewModel.currentStep) {
                    WelcomeStep()
                        .tag(0)

                    CosmicIntroStep()
                        .tag(1)

                    BirthDataStep(viewModel: viewModel)
                        .tag(2)

                    ChartRevealStep(viewModel: viewModel)
                        .tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(ResonanceAnimation.springSmooth, value: viewModel.currentStep)

                Spacer()

                // Navigation buttons
                HStack {
                    if viewModel.currentStep > 0 {
                        Button {
                            withAnimation(ResonanceAnimation.springSmooth) {
                                viewModel.currentStep -= 1
                            }
                            ResonanceHaptics.light()
                        } label: {
                            Text("Back")
                                .font(ResonanceTypography.bodyMedium)
                                .foregroundColor(theme.textSecondary)
                        }
                    }

                    Spacer()

                    Button {
                        if viewModel.currentStep < 3 {
                            withAnimation(ResonanceAnimation.springSmooth) {
                                viewModel.currentStep += 1
                            }
                            ResonanceHaptics.medium()
                        } else {
                            completeOnboarding()
                        }
                    } label: {
                        Text(viewModel.currentStep == 3 ? "Begin Your Journey" : "Continue")
                            .goldButton()
                    }
                    .disabled(viewModel.currentStep == 2 && !viewModel.isFormValid)
                    .opacity(viewModel.currentStep == 2 && !viewModel.isFormValid ? 0.5 : 1.0)
                }
                .padding(.horizontal, ResonanceSpacing.lg)
                .padding(.bottom, ResonanceSpacing.xxl)
            }
        }
    }

    private func completeOnboarding() {
        ResonanceHaptics.success()
        withAnimation(ResonanceAnimation.slowReveal) {
            isOnboarding = false
        }
    }
}

// MARK: - Onboarding ViewModel

class OnboardingViewModel: ObservableObject {
    @Published var currentStep = 0
    @Published var name = ""
    @Published var birthDate = Date()
    @Published var birthTime = Date()
    @Published var birthPlace = ""
    @Published var knowsBirthTime = true
    @Published var generatedChart: NatalChart?

    var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !birthPlace.trimmingCharacters(in: .whitespaces).isEmpty
    }

    func generateChart() {
        let calculator = ChartCalculator()
        let calendar = Calendar.current

        var components = calendar.dateComponents([.year, .month, .day], from: birthDate)
        if knowsBirthTime {
            let timeComponents = calendar.dateComponents([.hour, .minute], from: birthTime)
            components.hour = timeComponents.hour
            components.minute = timeComponents.minute
        }

        let date = calendar.date(from: components) ?? birthDate

        generatedChart = calculator.calculateChart(
            birthDate: date,
            birthPlace: birthPlace,
            latitude: 40.7128,
            longitude: -74.0060
        )
    }
}

// MARK: - Welcome Step

struct WelcomeStep: View {
    @Environment(\.resonanceTheme) var theme
    @State private var appear = false

    var body: some View {
        VStack(spacing: ResonanceSpacing.xl) {
            Spacer()

            CosmicOrb(size: 180)
                .scaleEffect(appear ? 1.0 : 0.3)
                .opacity(appear ? 1.0 : 0)

            VStack(spacing: ResonanceSpacing.md) {
                Text("Luminous Cosmic")
                    .font(ResonanceTypography.displayLarge)
                    .foregroundColor(theme.textPrimary)
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : 20)

                Text("Architecture")
                    .font(ResonanceTypography.displayMedium)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [ResonanceColors.goldDark, ResonanceColors.goldPrimary, ResonanceColors.goldLight],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : 20)

                Text("Your developmental map\nwritten in the stars")
                    .font(ResonanceTypography.bodyLarge)
                    .foregroundColor(theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : 15)
            }

            Spacer()
            Spacer()
        }
        .onAppear {
            withAnimation(ResonanceAnimation.springGentle.delay(0.3)) {
                appear = true
            }
        }
    }
}

// MARK: - Cosmic Intro Step

struct CosmicIntroStep: View {
    @Environment(\.resonanceTheme) var theme
    @State private var appear = false

    private let features: [(icon: String, title: String, desc: String)] = [
        ("sparkles", "Birth Chart", "Your unique cosmic blueprint at the moment of birth"),
        ("moon.stars", "Daily Insights", "Personalized guidance through current transits"),
        ("book.closed", "Cosmic Wisdom", "Chapters of developmental astrology to explore"),
        ("figure.mind.and.body", "Meditation", "Stargazer's attunement exercises for alignment")
    ]

    var body: some View {
        VStack(spacing: ResonanceSpacing.xl) {
            Text("Discover Your\nCosmic Blueprint")
                .font(ResonanceTypography.displaySmall)
                .foregroundColor(theme.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.top, ResonanceSpacing.lg)

            VStack(spacing: ResonanceSpacing.md) {
                ForEach(Array(features.enumerated()), id: \.offset) { index, feature in
                    HStack(spacing: ResonanceSpacing.md) {
                        Image(systemName: feature.icon)
                            .font(.system(size: 22))
                            .foregroundColor(ResonanceColors.goldPrimary)
                            .frame(width: 44, height: 44)
                            .background(
                                Circle()
                                    .fill(ResonanceColors.goldPrimary.opacity(0.1))
                            )

                        VStack(alignment: .leading, spacing: 2) {
                            Text(feature.title)
                                .font(ResonanceTypography.headlineSmall)
                                .foregroundColor(theme.textPrimary)

                            Text(feature.desc)
                                .font(ResonanceTypography.bodySmall)
                                .foregroundColor(theme.textSecondary)
                                .lineLimit(2)
                        }

                        Spacer()
                    }
                    .padding(ResonanceSpacing.md)
                    .glassCard(cornerRadius: ResonanceRadius.md, intensity: .subtle)
                    .opacity(appear ? 1 : 0)
                    .offset(x: appear ? 0 : 40)
                    .animation(
                        ResonanceAnimation.springSmooth.delay(Double(index) * 0.15),
                        value: appear
                    )
                }
            }
            .padding(.horizontal, ResonanceSpacing.lg)
        }
        .onAppear {
            withAnimation {
                appear = true
            }
        }
    }
}

// MARK: - Birth Data Step

struct BirthDataStep: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Environment(\.resonanceTheme) var theme
    @State private var appear = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: ResonanceSpacing.xl) {
                VStack(spacing: ResonanceSpacing.xs) {
                    Text("Your Birth Data")
                        .font(ResonanceTypography.displaySmall)
                        .foregroundColor(theme.textPrimary)

                    Text("This information creates your natal chart")
                        .font(ResonanceTypography.bodyMedium)
                        .foregroundColor(theme.textSecondary)
                }
                .padding(.top, ResonanceSpacing.lg)

                VStack(spacing: ResonanceSpacing.md) {
                    // Name field
                    VStack(alignment: .leading, spacing: ResonanceSpacing.xxs) {
                        Text("Name")
                            .font(ResonanceTypography.caption)
                            .foregroundColor(theme.textSecondary)
                            .textCase(.uppercase)
                            .tracking(1)

                        TextField("Your name", text: $viewModel.name)
                            .font(ResonanceTypography.bodyLarge)
                            .foregroundColor(theme.textPrimary)
                            .padding(ResonanceSpacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: ResonanceRadius.md)
                                    .fill(theme.surface.opacity(0.5))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: ResonanceRadius.md)
                                    .strokeBorder(theme.border, lineWidth: 0.5)
                            )
                            .accessibilityLabel("Enter your name")
                    }

                    // Birth date
                    VStack(alignment: .leading, spacing: ResonanceSpacing.xxs) {
                        Text("Birth Date")
                            .font(ResonanceTypography.caption)
                            .foregroundColor(theme.textSecondary)
                            .textCase(.uppercase)
                            .tracking(1)

                        DatePicker(
                            "Birth Date",
                            selection: $viewModel.birthDate,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.compact)
                        .labelsHidden()
                        .padding(ResonanceSpacing.sm)
                        .background(
                            RoundedRectangle(cornerRadius: ResonanceRadius.md)
                                .fill(theme.surface.opacity(0.5))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: ResonanceRadius.md)
                                .strokeBorder(theme.border, lineWidth: 0.5)
                        )
                        .tint(ResonanceColors.goldPrimary)
                    }

                    // Birth time
                    VStack(alignment: .leading, spacing: ResonanceSpacing.xxs) {
                        HStack {
                            Text("Birth Time")
                                .font(ResonanceTypography.caption)
                                .foregroundColor(theme.textSecondary)
                                .textCase(.uppercase)
                                .tracking(1)

                            Spacer()

                            Toggle("Known", isOn: $viewModel.knowsBirthTime)
                                .labelsHidden()
                                .tint(ResonanceColors.goldPrimary)
                                .scaleEffect(0.8)

                            Text(viewModel.knowsBirthTime ? "Known" : "Unknown")
                                .font(ResonanceTypography.caption)
                                .foregroundColor(theme.textTertiary)
                        }

                        if viewModel.knowsBirthTime {
                            DatePicker(
                                "Birth Time",
                                selection: $viewModel.birthTime,
                                displayedComponents: .hourAndMinute
                            )
                            .datePickerStyle(.compact)
                            .labelsHidden()
                            .padding(ResonanceSpacing.sm)
                            .background(
                                RoundedRectangle(cornerRadius: ResonanceRadius.md)
                                    .fill(theme.surface.opacity(0.5))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: ResonanceRadius.md)
                                    .strokeBorder(theme.border, lineWidth: 0.5)
                            )
                            .tint(ResonanceColors.goldPrimary)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                    .animation(ResonanceAnimation.springSmooth, value: viewModel.knowsBirthTime)

                    // Birth place
                    VStack(alignment: .leading, spacing: ResonanceSpacing.xxs) {
                        Text("Birth Place")
                            .font(ResonanceTypography.caption)
                            .foregroundColor(theme.textSecondary)
                            .textCase(.uppercase)
                            .tracking(1)

                        TextField("City, Country", text: $viewModel.birthPlace)
                            .font(ResonanceTypography.bodyLarge)
                            .foregroundColor(theme.textPrimary)
                            .padding(ResonanceSpacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: ResonanceRadius.md)
                                    .fill(theme.surface.opacity(0.5))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: ResonanceRadius.md)
                                    .strokeBorder(theme.border, lineWidth: 0.5)
                            )
                            .accessibilityLabel("Enter your birth place")
                    }
                }
                .padding(.horizontal, ResonanceSpacing.lg)
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : 30)
            }
        }
        .onAppear {
            withAnimation(ResonanceAnimation.springGentle.delay(0.2)) {
                appear = true
            }
        }
    }
}

// MARK: - Chart Reveal Step

struct ChartRevealStep: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Environment(\.resonanceTheme) var theme
    @State private var revealed = false
    @State private var chartScale: CGFloat = 0.5

    var body: some View {
        VStack(spacing: ResonanceSpacing.lg) {
            Text("Your Cosmic Blueprint")
                .font(ResonanceTypography.displaySmall)
                .foregroundColor(theme.textPrimary)
                .opacity(revealed ? 1 : 0)

            if let chart = viewModel.generatedChart {
                ZodiacWheel(chart: chart, size: 260)
                    .scaleEffect(chartScale)
                    .opacity(revealed ? 1 : 0)

                VStack(spacing: ResonanceSpacing.sm) {
                    HStack(spacing: ResonanceSpacing.xl) {
                        VStack {
                            Text("Sun")
                                .font(ResonanceTypography.caption)
                                .foregroundColor(theme.textTertiary)
                            ZodiacSignBadge(sign: chart.sunSign, size: 32)
                        }

                        VStack {
                            Text("Moon")
                                .font(ResonanceTypography.caption)
                                .foregroundColor(theme.textTertiary)
                            ZodiacSignBadge(sign: chart.moonSign, size: 32)
                        }

                        VStack {
                            Text("Rising")
                                .font(ResonanceTypography.caption)
                                .foregroundColor(theme.textTertiary)
                            ZodiacSignBadge(sign: chart.risingSign, size: 32)
                        }
                    }
                    .padding(ResonanceSpacing.md)
                    .glassCard(cornerRadius: ResonanceRadius.lg, intensity: .subtle)
                }
                .opacity(revealed ? 1 : 0)
                .offset(y: revealed ? 0 : 20)
            } else {
                ProgressView()
                    .tint(ResonanceColors.goldPrimary)
                    .scaleEffect(1.5)
            }
        }
        .onAppear {
            viewModel.generateChart()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(ResonanceAnimation.springGentle) {
                    revealed = true
                    chartScale = 1.0
                }
            }
        }
    }
}
