// HomeView.swift
// Luminous Cognitive Styles™ — iOS
// Welcome screen with animated gradient, profile summary, navigation

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: AssessmentViewModel
    @State private var animateGradient = false
    @State private var showQuickProfile = false
    @State private var showResults = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Hero Section
                    heroSection

                    // Profile Summary or CTA
                    if let profile = viewModel.currentProfile {
                        profileSummarySection(profile)
                    } else {
                        ctaSection
                    }

                    // Quick Links
                    quickLinksSection

                    // Daily Insight
                    dailyInsightSection

                    Spacer(minLength: 100)
                }
            }
            .background(
                ZStack {
                    LCSTheme.deepNavy.ignoresSafeArea()
                    animatedBackground
                }
            )
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .fullScreenCover(isPresented: $showQuickProfile) {
                NavigationStack { QuickProfileView() }
                    .environmentObject(viewModel)
            }
            .sheet(isPresented: $showResults) {
                if let profile = viewModel.currentProfile {
                    CognitiveSignatureView(profile: profile)
                }
            }
        }
    }

    // MARK: - Hero

    private var heroSection: some View {
        VStack(spacing: LCSTheme.Spacing.md) {
            Spacer(minLength: LCSTheme.Spacing.xl)

            Image(systemName: "sparkles")
                .font(.system(size: 44))
                .foregroundStyle(
                    LinearGradient(
                        colors: [LCSTheme.goldAccent, LCSTheme.gold],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: LCSTheme.goldAccent.opacity(0.4), radius: 12)

            Text("Luminous")
                .font(.system(size: 36, weight: .bold, design: .serif))
                .foregroundColor(LCSTheme.textPrimary)
            + Text("\nCognitive Styles")
                .font(.system(size: 20, weight: .medium, design: .serif))
                .foregroundColor(LCSTheme.textSecondary)

            Text("Discover the unique signature of your mind")
                .font(.subheadline)
                .foregroundColor(LCSTheme.textTertiary)
                .multilineTextAlignment(.center)

            Spacer(minLength: LCSTheme.Spacing.md)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, LCSTheme.Spacing.xl)
    }

    // MARK: - Animated Background

    private var animatedBackground: some View {
        LinearGradient(
            colors: [
                LCSTheme.indigo.opacity(animateGradient ? 0.15 : 0.05),
                LCSTheme.violet.opacity(animateGradient ? 0.08 : 0.15),
                LCSTheme.teal.opacity(animateGradient ? 0.12 : 0.04),
            ],
            startPoint: animateGradient ? .topLeading : .bottomTrailing,
            endPoint: animateGradient ? .bottomTrailing : .topLeading
        )
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: true)) {
                animateGradient = true
            }
        }
    }

    // MARK: - CTA (no profile yet)

    private var ctaSection: some View {
        VStack(spacing: LCSTheme.Spacing.md) {
            Button("Take the Quick Profile") { showQuickProfile = true }
                .buttonStyle(LCSTheme.PrimaryButtonStyle())

            Text("2 minutes to discover your cognitive signature")
                .font(.caption)
                .foregroundColor(LCSTheme.textTertiary)
        }
        .padding(.vertical, LCSTheme.Spacing.xl)
    }

    // MARK: - Profile Summary

    private func profileSummarySection(_ profile: CognitiveProfile) -> some View {
        VStack(spacing: LCSTheme.Spacing.md) {
            Button {
                showResults = true
            } label: {
                VStack(spacing: LCSTheme.Spacing.md) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Your Profile")
                                .font(.caption.weight(.semibold))
                                .textCase(.uppercase)
                                .tracking(1.5)
                                .foregroundColor(LCSTheme.goldAccent)

                            Text(profile.profileTypeName)
                                .font(.title3.weight(.bold))
                                .foregroundColor(LCSTheme.textPrimary)
                        }
                        Spacer()
                        CompactRadarChartView(profile: profile, size: 70)
                    }

                    // Mini dimension bars
                    ForEach(CognitiveDimension.allCases) { dim in
                        CompactDimensionScoreView(dimension: dim, score: profile.score(for: dim))
                    }

                    HStack {
                        Text(profile.assessmentType.rawValue)
                            .font(.caption2)
                            .foregroundColor(LCSTheme.textTertiary)
                        Spacer()
                        Text("Tap to view full results")
                            .font(.caption2)
                            .foregroundColor(LCSTheme.goldAccent)
                        Image(systemName: "chevron.right")
                            .font(.caption2)
                            .foregroundColor(LCSTheme.goldAccent)
                    }
                }
                .lcsCard()
                .padding(.horizontal)
            }

            // Retake
            Button("Retake Assessment") { showQuickProfile = true }
                .buttonStyle(LCSTheme.SecondaryButtonStyle())
        }
        .padding(.vertical, LCSTheme.Spacing.lg)
    }

    // MARK: - Quick Links

    private var quickLinksSection: some View {
        VStack(alignment: .leading, spacing: LCSTheme.Spacing.md) {
            Text("Explore")
                .font(.headline)
                .foregroundColor(LCSTheme.textPrimary)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: LCSTheme.Spacing.md) {
                    QuickLinkCard(icon: "book.fill", title: "Read the Book", subtitle: "\(Int(viewModel.totalBookProgress * 100))% complete", color: LCSTheme.emerald)
                    QuickLinkCard(icon: "message.fill", title: "Coaching", subtitle: "Personal guidance", color: LCSTheme.violet)
                    QuickLinkCard(icon: "chart.bar.fill", title: "History", subtitle: "\(viewModel.profileHistory.count) profiles", color: LCSTheme.crystalBlue)
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical, LCSTheme.Spacing.md)
    }

    // MARK: - Daily Insight

    private var dailyInsightSection: some View {
        VStack(alignment: .leading, spacing: LCSTheme.Spacing.sm) {
            Text("Daily Insight")
                .font(.headline)
                .foregroundColor(LCSTheme.textPrimary)

            let insights = [
                "Your cognitive style is not your destiny — it's your home base for exploration.",
                "The most creative solutions often come from the intersection of opposing cognitive modes.",
                "Notice when you're operating outside your home territory. That awareness itself is growth.",
                "Every cognitive style has shadow sides — strengths that become limitations when overused.",
                "The goal isn't cognitive balance — it's cognitive awareness and strategic flexibility.",
                "Your developmental edge is where discomfort meets possibility.",
                "Collaboration works best when cognitive diversity is understood and valued.",
            ]
            let dayIndex = Calendar.current.component(.day, from: Date()) % insights.count

            Text(insights[dayIndex])
                .font(.subheadline)
                .foregroundColor(LCSTheme.textSecondary)
                .italic()
                .fixedSize(horizontal: false, vertical: true)
        }
        .lcsCard()
        .padding(.horizontal)
    }
}

// MARK: - Quick Link Card

struct QuickLinkCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: LCSTheme.Spacing.sm) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)

            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(LCSTheme.textPrimary)

            Text(subtitle)
                .font(.caption)
                .foregroundColor(LCSTheme.textTertiary)
        }
        .frame(width: 140, alignment: .leading)
        .lcsCard()
    }
}
