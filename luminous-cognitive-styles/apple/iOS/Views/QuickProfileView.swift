// QuickProfileView.swift
// Luminous Cognitive Styles™ — iOS
// 7 sliders for quick self-assessment with custom styling

import SwiftUI

struct QuickProfileView: View {
    @EnvironmentObject var viewModel: AssessmentViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showResults = false
    @State private var generatedProfile: CognitiveProfile?
    @State private var currentPage = 0

    var body: some View {
        VStack(spacing: 0) {
            // Progress indicator
            ProgressView(value: Double(currentPage + 1), total: Double(CognitiveDimension.allCases.count + 1))
                .tint(currentDimension?.color ?? LCSTheme.goldAccent)
                .padding(.horizontal)
                .padding(.top, LCSTheme.Spacing.sm)

            if currentPage < CognitiveDimension.allCases.count {
                // Dimension slider page
                let dimension = CognitiveDimension.allCases[currentPage]
                dimensionSliderPage(dimension: dimension)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                    .id(currentPage)
            } else {
                // Confirm page
                confirmPage
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .background(LCSTheme.backgroundGradient.ignoresSafeArea())
        .navigationTitle("Quick Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
                    .foregroundColor(LCSTheme.textSecondary)
            }
        }
        .fullScreenCover(isPresented: $showResults) {
            NavigationStack {
                if let profile = generatedProfile {
                    CognitiveSignatureView(profile: profile) {
                        // Share action placeholder
                    }
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") {
                                showResults = false
                                dismiss()
                            }
                            .foregroundColor(LCSTheme.goldAccent)
                        }
                    }
                }
            }
        }
    }

    private var currentDimension: CognitiveDimension? {
        currentPage < CognitiveDimension.allCases.count ? CognitiveDimension.allCases[currentPage] : nil
    }

    // MARK: - Dimension Slider Page

    private func dimensionSliderPage(dimension: CognitiveDimension) -> some View {
        VStack(spacing: LCSTheme.Spacing.xl) {
            Spacer()

            // Icon and name
            Image(systemName: dimension.icon)
                .font(.system(size: 48))
                .foregroundColor(dimension.color)
                .shadow(color: dimension.color.opacity(0.5), radius: 12)

            Text(dimension.name)
                .font(.title2.weight(.bold))
                .foregroundColor(LCSTheme.textPrimary)

            Text(dimension.description)
                .font(.subheadline)
                .foregroundColor(LCSTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, LCSTheme.Spacing.xl)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()

            // Slider area
            VStack(spacing: LCSTheme.Spacing.lg) {
                // Pole labels
                HStack {
                    VStack(alignment: .leading) {
                        Text(dimension.lowPole)
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(dimension.color.opacity(0.7))
                        Text("1")
                            .font(.caption.weight(.bold).monospacedDigit())
                            .foregroundColor(LCSTheme.textTertiary)
                    }
                    Spacer()
                    Text(ScoreFormatter.formatted(viewModel.quickProfileItems[dimension.rawValue].score))
                        .font(.system(size: 36, weight: .bold, design: .monospaced))
                        .foregroundColor(dimension.color)
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text(dimension.highPole)
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(dimension.color)
                        Text("10")
                            .font(.caption.weight(.bold).monospacedDigit())
                            .foregroundColor(LCSTheme.textTertiary)
                    }
                }
                .padding(.horizontal)

                // Custom slider
                LCSSlider(
                    value: Binding(
                        get: { viewModel.quickProfileItems[dimension.rawValue].score },
                        set: { viewModel.updateQuickProfileScore(dimension: dimension, score: $0) }
                    ),
                    range: 1...10,
                    color: dimension.color
                )
                .padding(.horizontal, LCSTheme.Spacing.md)

                // Interpretation
                Text(dimension.interpretation(for: viewModel.quickProfileItems[dimension.rawValue].score))
                    .font(.caption)
                    .foregroundColor(LCSTheme.textTertiary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, LCSTheme.Spacing.xl)
                    .frame(minHeight: 50)
                    .animation(.easeInOut(duration: 0.2), value: viewModel.quickProfileItems[dimension.rawValue].score)
            }

            Spacer()

            // Navigation
            HStack(spacing: LCSTheme.Spacing.lg) {
                if currentPage > 0 {
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) { currentPage -= 1 }
                    } label: {
                        Label("Back", systemImage: "chevron.left")
                    }
                    .buttonStyle(LCSTheme.SecondaryButtonStyle())
                }

                Spacer()

                Button {
                    withAnimation(.easeInOut(duration: 0.3)) { currentPage += 1 }
                } label: {
                    Label("Next", systemImage: "chevron.right")
                }
                .buttonStyle(LCSTheme.PrimaryButtonStyle())
            }
            .padding(.horizontal)
            .padding(.bottom, LCSTheme.Spacing.xl)
        }
    }

    // MARK: - Confirm Page

    private var confirmPage: some View {
        VStack(spacing: LCSTheme.Spacing.xl) {
            Spacer()

            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 56))
                .foregroundStyle(LCSTheme.goldGradient)

            Text("Ready to See\nYour Profile?")
                .font(.title.weight(.bold))
                .foregroundColor(LCSTheme.textPrimary)
                .multilineTextAlignment(.center)

            // Score summary
            VStack(spacing: LCSTheme.Spacing.sm) {
                ForEach(CognitiveDimension.allCases) { dim in
                    CompactDimensionScoreView(
                        dimension: dim,
                        score: viewModel.quickProfileItems[dim.rawValue].score
                    )
                }
            }
            .lcsCard()
            .padding(.horizontal)

            Spacer()

            HStack(spacing: LCSTheme.Spacing.lg) {
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) { currentPage -= 1 }
                } label: {
                    Text("Adjust")
                }
                .buttonStyle(LCSTheme.SecondaryButtonStyle())

                Button {
                    let profile = viewModel.generateQuickProfile()
                    generatedProfile = profile
                    showResults = true
                } label: {
                    Text("See My Profile")
                }
                .buttonStyle(LCSTheme.PrimaryButtonStyle())
            }
            .padding(.bottom, LCSTheme.Spacing.xl)
        }
    }
}
