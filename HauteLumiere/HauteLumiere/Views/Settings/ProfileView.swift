// ProfileView.swift
// Haute Lumière — Profile & Settings

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @EnvironmentObject var coachEngine: CoachEngine
    @EnvironmentObject var habitTracker: HabitTracker

    var body: some View {
        NavigationStack {
            ZStack {
                if appState.isNightMode {
                    ForestNightBackground(theme: appState.nightModeTheme)
                } else {
                    Color.hlCream.ignoresSafeArea()
                }

                ScrollView(showsIndicators: false) {
                    VStack(spacing: HLSpacing.lg) {
                        // Profile header
                        profileHeader

                        // Subscription
                        subscriptionCard

                        // Quick links
                        VStack(spacing: HLSpacing.sm) {
                            NavigationLink(destination: HabitTrackerView()) {
                                profileRow(icon: "checkmark.circle", title: "Habit Tracker", value: "\(habitTracker.currentStreak) day streak")
                            }

                            NavigationLink(destination: WeeklyReportView()) {
                                profileRow(icon: "chart.bar.doc.horizontal", title: "Weekly Reports", value: "View latest")
                            }

                            NavigationLink(destination: CoachingSessionsView()) {
                                profileRow(icon: "person.2.fill", title: "Coaching Sessions", value: "Schedule")
                            }

                            NavigationLink(destination: ArticlesView()) {
                                profileRow(icon: "doc.richtext", title: "Articles for You", value: "New this week")
                            }
                        }
                        .padding(.horizontal, HLSpacing.lg)

                        // Preferences
                        VStack(alignment: .leading, spacing: HLSpacing.md) {
                            Text("Preferences")
                                .font(HLTypography.sectionTitle)
                                .foregroundColor(appState.isNightMode ? .hlGoldLight : .hlTextPrimary)

                            VStack(spacing: HLSpacing.sm) {
                                // Night mode
                                HStack {
                                    Image(systemName: "moon.stars.fill")
                                        .foregroundColor(.hlGold)
                                    Text("Night Mode")
                                        .font(HLTypography.cardTitle)
                                        .foregroundColor(appState.isNightMode ? .hlNightText : .hlTextPrimary)
                                    Spacer()
                                    Toggle("", isOn: $appState.isNightMode)
                                        .tint(.hlGold)
                                }
                                .padding(HLSpacing.sm)

                                // Night theme
                                if appState.isNightMode {
                                    VStack(alignment: .leading, spacing: HLSpacing.sm) {
                                        Text("Forest Theme")
                                            .font(HLTypography.label)
                                            .foregroundColor(.hlNightTextMuted)

                                        ForEach(AppState.NightModeTheme.allCases, id: \.self) { theme in
                                            Button(action: { appState.nightModeTheme = theme }) {
                                                HStack {
                                                    Circle()
                                                        .fill(LinearGradient(colors: theme.backgroundGradient, startPoint: .leading, endPoint: .trailing))
                                                        .frame(width: 24, height: 24)
                                                    Text(theme.rawValue)
                                                        .font(HLTypography.body)
                                                        .foregroundColor(.hlNightText)
                                                    Spacer()
                                                    if appState.nightModeTheme == theme {
                                                        Image(systemName: "checkmark")
                                                            .foregroundColor(.hlGold)
                                                    }
                                                }
                                            }
                                            .padding(.vertical, 4)
                                        }
                                    }
                                    .padding(.horizontal, HLSpacing.sm)
                                }

                                // Coach selection
                                VStack(alignment: .leading, spacing: HLSpacing.sm) {
                                    HStack {
                                        Image(systemName: "person.circle")
                                            .foregroundColor(.hlGold)
                                        Text("Your Coach")
                                            .font(HLTypography.cardTitle)
                                            .foregroundColor(appState.isNightMode ? .hlNightText : .hlTextPrimary)
                                    }
                                    .padding(.horizontal, HLSpacing.sm)

                                    ForEach(CoachPersona.allCases) { coach in
                                        Button(action: {
                                            appState.selectedCoach = coach
                                            coachEngine.currentPersona = coach
                                        }) {
                                            HStack {
                                                ZStack {
                                                    Circle()
                                                        .fill(LinearGradient(colors: coach.gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing))
                                                        .frame(width: 32, height: 32)
                                                    Image(systemName: coach.avatarSymbol)
                                                        .foregroundColor(.white)
                                                        .font(.system(size: 14))
                                                }
                                                VStack(alignment: .leading) {
                                                    Text(coach.displayName)
                                                        .font(HLTypography.cardTitle)
                                                    Text(coach.title)
                                                        .font(HLTypography.caption)
                                                        .foregroundColor(.hlTextTertiary)
                                                }
                                                .foregroundColor(appState.isNightMode ? .hlNightText : .hlTextPrimary)
                                                Spacer()
                                                if appState.selectedCoach == coach {
                                                    Image(systemName: "checkmark.circle.fill")
                                                        .foregroundColor(.hlGold)
                                                }
                                            }
                                        }
                                        .padding(.horizontal, HLSpacing.sm)
                                    }
                                }
                            }
                            .padding(HLSpacing.sm)
                            .background(
                                RoundedRectangle(cornerRadius: HLRadius.lg)
                                    .fill(appState.isNightMode ? Color.white.opacity(0.05) : .hlSurface)
                            )
                        }
                        .padding(.horizontal, HLSpacing.lg)

                        // Platform badges
                        VStack(alignment: .leading, spacing: HLSpacing.md) {
                            Text("Available On")
                                .font(HLTypography.sectionTitle)
                                .foregroundColor(appState.isNightMode ? .hlGoldLight : .hlTextPrimary)

                            HStack(spacing: HLSpacing.md) {
                                PlatformBadge(icon: "iphone", name: "iPhone")
                                PlatformBadge(icon: "applewatch", name: "Watch")
                                PlatformBadge(icon: "vision.pro", name: "Vision Pro")
                                PlatformBadge(icon: "macbook", name: "Mac")
                            }
                        }
                        .padding(.horizontal, HLSpacing.lg)

                        Spacer(minLength: 120)
                    }
                    .padding(.top, HLSpacing.md)
                }
            }
            .navigationBarHidden(true)
        }
    }

    // MARK: - Profile Header
    private var profileHeader: some View {
        VStack(spacing: HLSpacing.md) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [.hlGreen700, .hlGreen500], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 80, height: 80)
                Text(appState.userName.prefix(1).uppercased())
                    .font(HLTypography.serifMedium(32))
                    .foregroundColor(.hlGoldLight)
            }

            Text(appState.userName.isEmpty ? "Welcome" : appState.userName)
                .font(HLTypography.serifMedium(24))
                .foregroundColor(appState.isNightMode ? .hlGoldLight : .hlTextPrimary)

            Text("Member since \(memberSinceString)")
                .font(HLTypography.caption)
                .foregroundColor(.hlTextTertiary)

            // Phase indicator
            HStack(spacing: HLSpacing.sm) {
                Image(systemName: "sparkles")
                    .foregroundColor(.hlGold)
                Text("\(coachEngine.currentPhase.displayName) Phase")
                    .font(HLTypography.label)
                    .foregroundColor(.hlGold)
            }
            .padding(.horizontal, HLSpacing.md)
            .padding(.vertical, 6)
            .background(
                Capsule().fill(Color.hlGold.opacity(0.12))
            )
        }
        .padding(HLSpacing.lg)
    }

    // MARK: - Subscription Card
    private var subscriptionCard: some View {
        VStack(spacing: HLSpacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(subscriptionManager.currentTier.rawValue)
                        .font(HLTypography.cardTitle)
                        .foregroundColor(.hlGoldLight)
                    Text(subscriptionManager.currentTier.displayPrice)
                        .font(HLTypography.bodySmall)
                        .foregroundColor(.hlNightTextMuted)
                }
                Spacer()
                if subscriptionManager.isInTrial {
                    Text("\(subscriptionManager.trialDaysRemaining) days left in trial")
                        .font(HLTypography.caption)
                        .foregroundColor(.hlGold)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Color.hlGold.opacity(0.15)))
                }
            }

            if subscriptionManager.currentTier != .unlimited {
                Button(action: { subscriptionManager.showPaywall = true }) {
                    Text("Upgrade Plan")
                        .font(HLTypography.sansMedium(14))
                        .foregroundColor(.hlGreen900)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.hlGold)
                        .clipShape(Capsule())
                }
            }
        }
        .padding(HLSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: HLRadius.lg)
                .fill(LinearGradient(colors: [Color(hex: "0A1C14"), Color(hex: "1B402E")], startPoint: .topLeading, endPoint: .bottomTrailing))
        )
        .hlGoldBorder()
        .padding(.horizontal, HLSpacing.lg)
    }

    // MARK: - Helpers
    private func profileRow(icon: String, title: String, value: String) -> some View {
        HStack(spacing: HLSpacing.md) {
            Image(systemName: icon)
                .foregroundColor(.hlGold)
                .frame(width: 24)
            Text(title)
                .font(HLTypography.cardTitle)
                .foregroundColor(appState.isNightMode ? .hlNightText : .hlTextPrimary)
            Spacer()
            Text(value)
                .font(HLTypography.bodySmall)
                .foregroundColor(.hlTextTertiary)
            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(.hlTextTertiary)
        }
        .padding(HLSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: HLRadius.md)
                .fill(appState.isNightMode ? Color.white.opacity(0.05) : .hlSurface)
        )
    }

    private var memberSinceString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: Date())
    }
}

// MARK: - Platform Badge
struct PlatformBadge: View {
    let icon: String
    let name: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(.hlGold)
            Text(name)
                .font(HLTypography.caption)
                .foregroundColor(.hlTextTertiary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Journey View (Tab)
struct JourneyView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var coachEngine: CoachEngine
    @EnvironmentObject var habitTracker: HabitTracker

    var body: some View {
        NavigationStack {
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
                            Text("Your Journey")
                                .font(HLTypography.screenTitle)
                                .foregroundColor(appState.isNightMode ? .hlGoldLight : .hlTextPrimary)
                            Text("Track your transformation over time")
                                .font(HLTypography.body)
                                .foregroundColor(appState.isNightMode ? .hlNightTextMuted : .hlTextSecondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, HLSpacing.lg)

                        // Phase progress (hidden 5D visualization)
                        phaseProgressView
                            .padding(.horizontal, HLSpacing.lg)

                        // Links
                        NavigationLink(destination: WeeklyReportView()) {
                            journeyRow(icon: "chart.bar.doc.horizontal", title: "Weekly Reports", subtitle: "Beautiful shareable summaries")
                        }

                        NavigationLink(destination: HabitTrackerView()) {
                            journeyRow(icon: "checkmark.circle", title: "Habit Tracker", subtitle: "\(habitTracker.currentStreak) day streak")
                        }

                        NavigationLink(destination: CoachingSessionsView()) {
                            journeyRow(icon: "person.2.fill", title: "Coaching", subtitle: "Schedule sessions")
                        }

                        NavigationLink(destination: ArticlesView()) {
                            journeyRow(icon: "doc.richtext", title: "Articles", subtitle: "Curated for you")
                        }

                        // Stats overview
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: HLSpacing.sm) {
                            StatCard(title: "Total Minutes", value: "\(habitTracker.totalMinutesPracticed)", icon: "clock", isNightMode: appState.isNightMode)
                            StatCard(title: "Sessions", value: "\(habitTracker.totalSessionsCompleted)", icon: "checkmark.circle", isNightMode: appState.isNightMode)
                            StatCard(title: "Streak", value: "\(habitTracker.currentStreak)", icon: "flame.fill", isNightMode: appState.isNightMode)
                            StatCard(title: "Phase", value: coachEngine.currentPhase.displayName, icon: "sparkles", isNightMode: appState.isNightMode)
                        }
                        .padding(.horizontal, HLSpacing.lg)

                        Spacer(minLength: 120)
                    }
                    .padding(.top, HLSpacing.md)
                }
            }
            .navigationBarHidden(true)
        }
    }

    // MARK: - Phase Progress
    private var phaseProgressView: some View {
        VStack(alignment: .leading, spacing: HLSpacing.md) {
            Text("Your Growth Path")
                .font(HLTypography.sectionTitle)
                .foregroundColor(appState.isNightMode ? .hlGoldLight : .hlTextPrimary)

            HStack(spacing: 4) {
                ForEach(FiveDPhase.allCases, id: \.self) { phase in
                    VStack(spacing: 6) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(phase.rawValue <= coachEngine.currentPhase.rawValue ? Color.hlGold : Color.hlGreen100.opacity(0.3))
                            .frame(height: 6)

                        Text(phase.displayName)
                            .font(HLTypography.caption)
                            .foregroundColor(phase == coachEngine.currentPhase ? .hlGold : .hlTextTertiary)
                    }
                }
            }
        }
        .padding(HLSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: HLRadius.lg)
                .fill(appState.isNightMode ? Color.white.opacity(0.05) : .hlSurface)
        )
    }

    private func journeyRow(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: HLSpacing.md) {
            Image(systemName: icon)
                .foregroundColor(.hlGold)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(HLTypography.cardTitle)
                    .foregroundColor(appState.isNightMode ? .hlNightText : .hlTextPrimary)
                Text(subtitle)
                    .font(HLTypography.caption)
                    .foregroundColor(.hlTextTertiary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(.hlTextTertiary)
        }
        .padding(HLSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: HLRadius.lg)
                .fill(appState.isNightMode ? Color.white.opacity(0.05) : .hlSurface)
        )
        .padding(.horizontal, HLSpacing.lg)
    }
}
