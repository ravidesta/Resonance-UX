// LuminousCognitiveStylesApp.swift
// Luminous Cognitive Styles™ — watchOS
// Watch app entry point with navigation

import SwiftUI

@main
struct LuminousCognitiveStylesWatchApp: App {
    @StateObject private var viewModel = AssessmentViewModel()

    var body: some Scene {
        WindowGroup {
            WatchHomeView()
                .environmentObject(viewModel)
        }
    }
}

struct WatchHomeView: View {
    @EnvironmentObject var viewModel: AssessmentViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    // Profile glance or CTA
                    if let profile = viewModel.currentProfile {
                        NavigationLink {
                            GlanceView(profile: profile)
                        } label: {
                            VStack(spacing: 6) {
                                CompactRadarChartView(profile: profile, size: 60)
                                Text(profile.profileTypeName)
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(LCSTheme.goldAccent)
                                    .lineLimit(1)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                        }
                    } else {
                        VStack(spacing: 4) {
                            Image(systemName: "sparkles")
                                .font(.title3)
                                .foregroundColor(LCSTheme.goldAccent)
                            Text("No profile yet")
                                .font(.caption2)
                                .foregroundColor(LCSTheme.textTertiary)
                        }
                        .padding(.vertical, 8)
                    }

                    // Quick Check-In
                    NavigationLink {
                        QuickCheckInView()
                    } label: {
                        WatchMenuRow(
                            icon: "heart.text.square",
                            title: "Check In",
                            subtitle: "1 minute",
                            color: LCSTheme.rose
                        )
                    }

                    // Glance
                    if let profile = viewModel.currentProfile {
                        NavigationLink {
                            GlanceView(profile: profile)
                        } label: {
                            WatchMenuRow(
                                icon: "chart.pie",
                                title: "My Profile",
                                subtitle: profile.profileTypeName,
                                color: LCSTheme.crystalBlue
                            )
                        }
                    }

                    // Daily Tip
                    NavigationLink {
                        DailyTipView()
                    } label: {
                        WatchMenuRow(
                            icon: "lightbulb.fill",
                            title: "Daily Tip",
                            subtitle: "Cognitive insight",
                            color: LCSTheme.amberGold
                        )
                    }
                }
                .padding(.horizontal, 4)
            }
            .navigationTitle("LCS")
            .containerBackground(LCSTheme.deepNavy.gradient, for: .navigation)
        }
    }
}

// MARK: - Watch Menu Row

struct WatchMenuRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.6))
                    .lineLimit(1)
            }

            Spacer()
        }
        .padding(.vertical, 6)
    }
}

// MARK: - Daily Tip View

struct DailyTipView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                Image(systemName: "lightbulb.fill")
                    .font(.title2)
                    .foregroundColor(LCSTheme.amberGold)

                Text("Today's Insight")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)

                let tips = [
                    "Your cognitive style is your home base, not your cage. You can always expand.",
                    "Notice which dimension you're using most right now. Awareness is the first step.",
                    "Opposites on any dimension aren't wrong — they're complementary.",
                    "Your developmental edge is where growth happens. Lean in gently.",
                    "Collaboration thrives when cognitive differences are understood.",
                    "Rest and reflection often activate different cognitive modes than effort.",
                    "Your body knows things your conscious mind hasn't caught up to yet.",
                ]
                let dayIndex = Calendar.current.component(.day, from: Date()) % tips.count

                Text(tips[dayIndex])
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding()
        }
        .navigationTitle("Tip")
        .containerBackground(LCSTheme.deepNavy.gradient, for: .navigation)
    }
}
