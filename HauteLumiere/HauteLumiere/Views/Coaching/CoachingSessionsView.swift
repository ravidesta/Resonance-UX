// CoachingSessionsView.swift
// Haute Lumière — Life & Executive Coaching Sessions

import SwiftUI

struct CoachingSessionsView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @State private var upcomingSessions: [CoachingSession] = []
    @State private var showScheduler = false
    @State private var selectedSessionType: CoachingSession.CoachingSessionType = .lifeCoaching

    var body: some View {
        ZStack {
            if appState.isNightMode {
                ForestNightBackground(theme: appState.nightModeTheme)
            } else {
                Color.hlCream.ignoresSafeArea()
            }

            ScrollView(showsIndicators: false) {
                VStack(spacing: HLSpacing.lg) {
                    // Header
                    VStack(alignment: .leading, spacing: HLSpacing.sm) {
                        Text("Coaching Sessions")
                            .font(HLTypography.screenTitle)
                            .foregroundColor(appState.isNightMode ? .hlGoldLight : .hlTextPrimary)

                        Text("Guided transformation with \(appState.selectedCoach.displayName)")
                            .font(HLTypography.body)
                            .foregroundColor(appState.isNightMode ? .hlNightTextMuted : .hlTextSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, HLSpacing.lg)

                    // Session types
                    VStack(spacing: HLSpacing.sm) {
                        SessionTypeCard(
                            title: "Life Coaching",
                            duration: "45 minutes",
                            frequency: "4 sessions per week",
                            description: "Appreciative coaching focused on your strengths, values, and vision",
                            icon: "person.2.fill",
                            color: .hlGreen500,
                            isNightMode: appState.isNightMode
                        )

                        SessionTypeCard(
                            title: "Executive Coaching",
                            duration: "90 minutes",
                            frequency: "Weekly deep dive",
                            description: "Strategic leadership presence, decision-making, and performance optimization",
                            icon: "briefcase.fill",
                            color: .hlGold,
                            isNightMode: appState.isNightMode
                        )

                        SessionTypeCard(
                            title: "Breathing Instruction",
                            duration: "30 minutes",
                            frequency: "On demand",
                            description: "One-on-one technique refinement from beginner to Qi Gung mastery",
                            icon: "wind",
                            color: .hlAzure,
                            isNightMode: appState.isNightMode
                        )

                        SessionTypeCard(
                            title: "Meditation Instruction",
                            duration: "30 minutes",
                            frequency: "On demand",
                            description: "Personalized guidance to deepen your visualization and awareness practice",
                            icon: "eye.fill",
                            color: Color(hex: "7B5EA7"),
                            isNightMode: appState.isNightMode
                        )
                    }
                    .padding(.horizontal, HLSpacing.lg)

                    // Schedule button
                    if subscriptionManager.hasAccess(to: .liveCoaching) {
                        Button(action: { showScheduler = true }) {
                            HStack {
                                Image(systemName: "calendar.badge.plus")
                                Text("Schedule a Session")
                                    .font(HLTypography.sansMedium(15))
                            }
                            .foregroundColor(.hlGreen900)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.hlGold)
                            .clipShape(RoundedRectangle(cornerRadius: HLRadius.pill))
                        }
                        .padding(.horizontal, HLSpacing.lg)
                    } else {
                        // Upgrade prompt
                        VStack(spacing: HLSpacing.md) {
                            Text("Unlock Live Coaching")
                                .font(HLTypography.sectionTitle)
                                .foregroundColor(appState.isNightMode ? .hlGoldLight : .hlTextPrimary)

                            Text("Add coaching to your plan for $99/month and receive personalized 1:1 sessions with \(appState.selectedCoach.displayName)")
                                .font(HLTypography.body)
                                .foregroundColor(.hlTextSecondary)
                                .multilineTextAlignment(.center)

                            Button(action: { subscriptionManager.showPaywall = true }) {
                                Text("Upgrade to Coaching")
                                    .font(HLTypography.sansMedium(15))
                                    .foregroundColor(.hlGreen900)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(Color.hlGold)
                                    .clipShape(RoundedRectangle(cornerRadius: HLRadius.pill))
                            }
                        }
                        .padding(HLSpacing.lg)
                        .background(
                            RoundedRectangle(cornerRadius: HLRadius.xl)
                                .fill(appState.isNightMode ? Color.white.opacity(0.05) : .hlSurface)
                        )
                        .hlGoldBorder()
                        .padding(.horizontal, HLSpacing.lg)
                    }

                    // Upcoming sessions
                    if !upcomingSessions.isEmpty {
                        VStack(alignment: .leading, spacing: HLSpacing.md) {
                            Text("Upcoming")
                                .font(HLTypography.sectionTitle)
                                .foregroundColor(appState.isNightMode ? .hlGoldLight : .hlTextPrimary)

                            ForEach(upcomingSessions) { session in
                                UpcomingSessionRow(session: session, isNightMode: appState.isNightMode)
                            }
                        }
                        .padding(.horizontal, HLSpacing.lg)
                    }

                    Spacer(minLength: 120)
                }
                .padding(.top, HLSpacing.md)
            }
        }
        .navigationTitle("Coaching")
    }
}

// MARK: - Session Type Card
struct SessionTypeCard: View {
    let title: String
    let duration: String
    let frequency: String
    let description: String
    let icon: String
    let color: Color
    let isNightMode: Bool

    var body: some View {
        HStack(spacing: HLSpacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: HLRadius.md)
                    .fill(color.opacity(0.15))
                    .frame(width: 48, height: 48)
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(HLTypography.cardTitle)
                    .foregroundColor(isNightMode ? .hlNightText : .hlTextPrimary)

                HStack(spacing: HLSpacing.sm) {
                    Text(duration)
                    Text("·")
                    Text(frequency)
                }
                .font(HLTypography.caption)
                .foregroundColor(.hlTextTertiary)

                Text(description)
                    .font(HLTypography.bodySmall)
                    .foregroundColor(isNightMode ? .hlNightTextMuted : .hlTextSecondary)
                    .lineLimit(2)
            }

            Spacer()
        }
        .padding(HLSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: HLRadius.lg)
                .fill(isNightMode ? Color.white.opacity(0.05) : .hlSurface)
        )
        .hlShadowSubtle()
    }
}

// MARK: - Upcoming Session Row
struct UpcomingSessionRow: View {
    let session: CoachingSession
    let isNightMode: Bool

    var body: some View {
        HStack(spacing: HLSpacing.md) {
            VStack(spacing: 2) {
                Text(dayString)
                    .font(HLTypography.label)
                    .foregroundColor(.hlGold)
                Text(timeString)
                    .font(HLTypography.caption)
                    .foregroundColor(.hlTextTertiary)
            }
            .frame(width: 50)

            VStack(alignment: .leading, spacing: 4) {
                Text(session.type.rawValue)
                    .font(HLTypography.cardTitle)
                    .foregroundColor(isNightMode ? .hlNightText : .hlTextPrimary)
                Text("\(session.duration) min")
                    .font(HLTypography.caption)
                    .foregroundColor(.hlTextTertiary)
            }

            Spacer()

            Button(action: {}) {
                Text("Join")
                    .font(HLTypography.label)
                    .foregroundColor(.hlGreen900)
                    .padding(.horizontal, HLSpacing.md)
                    .padding(.vertical, 6)
                    .background(Color.hlGold)
                    .clipShape(Capsule())
            }
        }
        .padding(HLSpacing.sm)
        .background(
            RoundedRectangle(cornerRadius: HLRadius.md)
                .fill(isNightMode ? Color.white.opacity(0.04) : .hlSurface)
        )
    }

    private var dayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: session.scheduledDate)
    }

    private var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: session.scheduledDate)
    }
}
