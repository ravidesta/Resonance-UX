// WeeklyReportView.swift
// Haute Lumière — Weekly Reports (Social-Media Ready)

import SwiftUI

struct WeeklyReportView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var habitTracker: HabitTracker
    @EnvironmentObject var coachEngine: CoachEngine
    @State private var showShareSheet = false

    var body: some View {
        ZStack {
            if appState.isNightMode {
                ForestNightBackground(theme: appState.nightModeTheme)
            } else {
                Color.hlCream.ignoresSafeArea()
            }

            ScrollView(showsIndicators: false) {
                VStack(spacing: HLSpacing.lg) {
                    // Shareable report card
                    shareableReportCard
                        .padding(.horizontal, HLSpacing.lg)

                    // Share button
                    Button(action: { showShareSheet = true }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share Your Journey")
                                .font(HLTypography.sansMedium(15))
                        }
                        .foregroundColor(.hlGreen900)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.hlGold)
                        .clipShape(RoundedRectangle(cornerRadius: HLRadius.pill))
                    }
                    .padding(.horizontal, HLSpacing.lg)

                    // Detailed breakdown
                    detailedBreakdown
                        .padding(.horizontal, HLSpacing.lg)

                    // Coach highlights
                    coachHighlightsSection
                        .padding(.horizontal, HLSpacing.lg)

                    // Next week focus
                    nextWeekCard
                        .padding(.horizontal, HLSpacing.lg)

                    Spacer(minLength: 120)
                }
                .padding(.top, HLSpacing.md)
            }
        }
        .navigationTitle("Weekly Report")
    }

    // MARK: - Shareable Report Card (Social Media Ready)
    private var shareableReportCard: some View {
        VStack(spacing: HLSpacing.lg) {
            // Header
            VStack(spacing: HLSpacing.sm) {
                Image(systemName: "light.max")
                    .font(.system(size: 24, weight: .ultraLight))
                    .foregroundColor(.hlGold)

                Text("Haute Lumière")
                    .font(HLTypography.serifLight(16))
                    .foregroundColor(.hlGoldLight)

                Text("Weekly Wellness Report")
                    .font(HLTypography.serifMedium(24))
                    .foregroundColor(.white)

                Text(weekRangeString)
                    .font(HLTypography.caption)
                    .foregroundColor(.hlNightTextMuted)
            }

            // Key metrics
            HStack(spacing: HLSpacing.lg) {
                ReportMetric(value: "\(habitTracker.totalSessionsCompleted)", label: "Sessions", icon: "checkmark.circle")
                ReportMetric(value: "\(habitTracker.totalMinutesPracticed)", label: "Minutes", icon: "clock")
                ReportMetric(value: "\(habitTracker.currentStreak)", label: "Day Streak", icon: "flame.fill")
            }

            // Divider
            Rectangle()
                .fill(Color.hlGold.opacity(0.3))
                .frame(height: 0.5)
                .padding(.horizontal, HLSpacing.lg)

            // Quote
            VStack(spacing: HLSpacing.sm) {
                Text("\"The present moment is the only moment available to us, and it is the door to all moments.\"")
                    .font(HLTypography.serifItalic(14))
                    .foregroundColor(.hlNightText.opacity(0.8))
                    .multilineTextAlignment(.center)

                Text("— Thich Nhat Hanh")
                    .font(HLTypography.caption)
                    .foregroundColor(.hlNightTextMuted)
            }
            .padding(.horizontal, HLSpacing.md)

            // Weekly bar chart
            HStack(spacing: 6) {
                ForEach(habitTracker.weeklyProgress) { day in
                    VStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(day.completionRate > 0 ? Color.hlGold : Color.white.opacity(0.1))
                            .frame(width: 28, height: max(4, CGFloat(day.completionRate) * 40))

                        Text(day.dayName)
                            .font(.system(size: 9))
                            .foregroundColor(.hlNightTextMuted)
                    }
                }
            }

            // Coach's note
            VStack(spacing: HLSpacing.sm) {
                HStack(spacing: 6) {
                    Image(systemName: appState.selectedCoach.avatarSymbol)
                        .font(.system(size: 12))
                        .foregroundColor(.hlGold)
                    Text(appState.selectedCoach.displayName)
                        .font(HLTypography.caption)
                        .foregroundColor(.hlGold)
                }

                Text("Your consistency this week shows the discipline of someone truly committed to their growth. I see real momentum building.")
                    .font(HLTypography.bodySmall)
                    .foregroundColor(.hlNightText.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(HLSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: HLRadius.xl)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "0A1C14"), Color(hex: "122E21"), Color(hex: "0D2118")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: HLRadius.xl)
                .stroke(
                    LinearGradient(colors: [.hlGold.opacity(0.4), .hlGoldLight.opacity(0.2), .hlGold.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: 1
                )
        )
    }

    // MARK: - Detailed Breakdown
    private var detailedBreakdown: some View {
        VStack(alignment: .leading, spacing: HLSpacing.md) {
            Text("Practice Breakdown")
                .font(HLTypography.sectionTitle)
                .foregroundColor(appState.isNightMode ? .hlGoldLight : .hlTextPrimary)

            VStack(spacing: HLSpacing.sm) {
                BreakdownRow(label: "Yoga Nidra", minutes: 90, color: Color(hex: "1a1a3e"), isNightMode: appState.isNightMode)
                BreakdownRow(label: "Guided Breathing", minutes: 45, color: .hlAzure, isNightMode: appState.isNightMode)
                BreakdownRow(label: "Visualization", minutes: 30, color: .hlGreen500, isNightMode: appState.isNightMode)
                BreakdownRow(label: "Soundscapes", minutes: 60, color: .hlGold, isNightMode: appState.isNightMode)
            }
        }
    }

    // MARK: - Coach Highlights
    private var coachHighlightsSection: some View {
        VStack(alignment: .leading, spacing: HLSpacing.md) {
            Text("Your Coach Noticed")
                .font(HLTypography.sectionTitle)
                .foregroundColor(appState.isNightMode ? .hlGoldLight : .hlTextPrimary)

            VStack(spacing: HLSpacing.sm) {
                HighlightCard(icon: "star.fill", title: "Strength Displayed", text: "Remarkable consistency in showing up daily", color: .hlGold, isNightMode: appState.isNightMode)
                HighlightCard(icon: "trophy.fill", title: "Win of the Week", text: "Completed your first advanced breathing session", color: .hlSuccess, isNightMode: appState.isNightMode)
                HighlightCard(icon: "arrow.up.right", title: "Growth Area", text: "Sleep quality improving with evening Nidra practice", color: .hlAzure, isNightMode: appState.isNightMode)
            }
        }
    }

    // MARK: - Next Week
    private var nextWeekCard: some View {
        VStack(alignment: .leading, spacing: HLSpacing.md) {
            Text("Next Week's Focus")
                .font(HLTypography.sectionTitle)
                .foregroundColor(appState.isNightMode ? .hlGoldLight : .hlTextPrimary)

            VStack(alignment: .leading, spacing: HLSpacing.sm) {
                Text("\(appState.selectedCoach.displayName)'s Recommendation")
                    .font(HLTypography.label)
                    .foregroundColor(.hlGold)

                Text("Based on your progress in the \(coachEngine.currentPhase.displayName) phase, I recommend focusing on deeper Yoga Nidra sessions and introducing Nadi Shodhana breathing to enhance your nervous system balance.")
                    .font(HLTypography.body)
                    .foregroundColor(appState.isNightMode ? .hlNightTextMuted : .hlTextSecondary)
            }
            .padding(HLSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: HLRadius.lg)
                    .fill(appState.isNightMode ? Color.white.opacity(0.05) : .hlSurface)
            )
        }
    }

    private var weekRangeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        let end = Date()
        let start = Calendar.current.date(byAdding: .day, value: -7, to: end) ?? end
        return "\(formatter.string(from: start)) — \(formatter.string(from: end))"
    }
}

// MARK: - Report Metric
struct ReportMetric: View {
    let value: String
    let label: String
    let icon: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.hlGold)
            Text(value)
                .font(HLTypography.serifMedium(24))
                .foregroundColor(.white)
            Text(label)
                .font(HLTypography.caption)
                .foregroundColor(.hlNightTextMuted)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Breakdown Row
struct BreakdownRow: View {
    let label: String
    let minutes: Int
    let color: Color
    let isNightMode: Bool

    var body: some View {
        HStack(spacing: HLSpacing.md) {
            RoundedRectangle(cornerRadius: 3)
                .fill(color)
                .frame(width: 4, height: 32)

            Text(label)
                .font(HLTypography.cardTitle)
                .foregroundColor(isNightMode ? .hlNightText : .hlTextPrimary)

            Spacer()

            Text("\(minutes) min")
                .font(HLTypography.label)
                .foregroundColor(.hlGold)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Highlight Card
struct HighlightCard: View {
    let icon: String
    let title: String
    let text: String
    let color: Color
    let isNightMode: Bool

    var body: some View {
        HStack(spacing: HLSpacing.md) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 18))
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(HLTypography.label)
                    .foregroundColor(isNightMode ? .hlNightText : .hlTextPrimary)
                Text(text)
                    .font(HLTypography.bodySmall)
                    .foregroundColor(isNightMode ? .hlNightTextMuted : .hlTextSecondary)
            }

            Spacer()
        }
        .padding(HLSpacing.sm)
        .background(
            RoundedRectangle(cornerRadius: HLRadius.md)
                .fill(isNightMode ? Color.white.opacity(0.04) : .hlSurface)
        )
    }
}
