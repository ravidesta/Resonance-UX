// HomeView.swift
// Haute Lumière — Home Dashboard

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var coachEngine: CoachEngine
    @EnvironmentObject var habitTracker: HabitTracker
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @State private var showCoachMessage = false
    @State private var animateGreeting = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                if appState.isNightMode {
                    ForestNightBackground(theme: appState.nightModeTheme)
                } else {
                    Color.hlCream.ignoresSafeArea()
                }

                ScrollView(showsIndicators: false) {
                    VStack(spacing: HLSpacing.lg) {
                        // Header
                        headerSection
                            .padding(.horizontal, HLSpacing.lg)

                        // Coach Greeting Card
                        coachGreetingCard
                            .padding(.horizontal, HLSpacing.lg)

                        // Today's Practice
                        todaysPracticeSection
                            .padding(.horizontal, HLSpacing.lg)

                        // Quick Actions
                        quickActionsGrid
                            .padding(.horizontal, HLSpacing.lg)

                        // Habit Progress
                        habitProgressSection
                            .padding(.horizontal, HLSpacing.lg)

                        // Recommended Session
                        recommendedSessionCard
                            .padding(.horizontal, HLSpacing.lg)

                        // Weekly Streak
                        weeklyStreakView
                            .padding(.horizontal, HLSpacing.lg)

                        Spacer(minLength: 120)
                    }
                    .padding(.top, HLSpacing.md)
                }
            }
            .navigationBarHidden(true)
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(greeting)
                    .font(HLTypography.sansLight(14))
                    .foregroundColor(appState.isNightMode ? .hlNightTextMuted : .hlTextSecondary)

                Text(appState.userName.isEmpty ? "Welcome" : appState.userName)
                    .font(HLTypography.screenTitle)
                    .foregroundColor(appState.isNightMode ? .hlGoldLight : .hlTextPrimary)
            }

            Spacer()

            // Night mode toggle
            Button(action: {
                withAnimation(.easeInOut(duration: 0.5)) {
                    appState.isNightMode.toggle()
                }
            }) {
                Image(systemName: appState.isNightMode ? "moon.stars.fill" : "sun.max.fill")
                    .font(.system(size: 20))
                    .foregroundColor(appState.isNightMode ? .hlGold : .hlGreen600)
                    .padding(10)
                    .background(
                        Circle()
                            .fill(appState.isNightMode ? Color.hlNightForest : .hlGreen50)
                    )
            }
        }
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<21: return "Good evening"
        default: return "Good night"
        }
    }

    // MARK: - Coach Greeting
    private var coachGreetingCard: some View {
        let coach = appState.selectedCoach
        return HStack(spacing: HLSpacing.md) {
            // Coach avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(colors: coach.gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: 44, height: 44)
                Image(systemName: coach.avatarSymbol)
                    .foregroundColor(.white)
                    .font(.system(size: 18))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(coach.displayName)
                    .font(HLTypography.label)
                    .foregroundColor(appState.isNightMode ? .hlNightText : .hlTextPrimary)

                Text(coachEngine.messages.last?.content ?? "Ready to begin today's practice?")
                    .font(HLTypography.bodySmall)
                    .foregroundColor(appState.isNightMode ? .hlNightTextMuted : .hlTextSecondary)
                    .lineLimit(2)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.hlTextTertiary)
        }
        .padding(HLSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: HLRadius.lg)
                .fill(appState.isNightMode ? Color.white.opacity(0.05) : .hlSurface)
        )
        .hlShadowSubtle()
    }

    // MARK: - Today's Practice
    private var todaysPracticeSection: some View {
        VStack(alignment: .leading, spacing: HLSpacing.md) {
            Text("Today's Practice")
                .font(HLTypography.sectionTitle)
                .foregroundColor(appState.isNightMode ? .hlGoldLight : .hlTextPrimary)

            // Featured session card
            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: HLRadius.xl)
                    .fill(
                        LinearGradient(
                            colors: appState.isNightMode
                                ? [Color(hex: "0A1C14"), Color(hex: "1B402E")]
                                : [Color(hex: "1B402E"), Color(hex: "2A5A42")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 180)

                VStack(alignment: .leading, spacing: HLSpacing.sm) {
                    HStack {
                        Image(systemName: "moon.stars.fill")
                            .foregroundColor(.hlGoldLight)
                        Text("Yoga Nidra")
                            .font(HLTypography.caption)
                            .foregroundColor(.hlGoldLight)
                    }

                    Text("Moonlit Sanctuary")
                        .font(HLTypography.serifMedium(24))
                        .foregroundColor(.white)

                    Text("30 min · Deep Sleep · Theta Waves")
                        .font(HLTypography.bodySmall)
                        .foregroundColor(.white.opacity(0.7))

                    Button(action: {}) {
                        HStack(spacing: 6) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 10))
                            Text("Begin Session")
                                .font(HLTypography.label)
                        }
                        .foregroundColor(.hlGreen900)
                        .padding(.horizontal, HLSpacing.md)
                        .padding(.vertical, 8)
                        .background(Color.hlGold)
                        .clipShape(Capsule())
                    }
                }
                .padding(HLSpacing.lg)
            }
        }
    }

    // MARK: - Quick Actions
    private var quickActionsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: HLSpacing.sm) {
            QuickActionCard(icon: "wind", title: "Breathe", subtitle: "5 min calm", color: .hlAzure, isNightMode: appState.isNightMode)
            QuickActionCard(icon: "eye.fill", title: "Visualize", subtitle: "New journey", color: .hlGreen500, isNightMode: appState.isNightMode)
            QuickActionCard(icon: "waveform", title: "Soundscape", subtitle: "Nature mix", color: .hlGold, isNightMode: appState.isNightMode)
            QuickActionCard(icon: "person.2.fill", title: "Coach", subtitle: "Talk now", color: Color(hex: "C47B7B"), isNightMode: appState.isNightMode)
        }
    }

    // MARK: - Habit Progress
    private var habitProgressSection: some View {
        VStack(alignment: .leading, spacing: HLSpacing.md) {
            HStack {
                Text("Today's Habits")
                    .font(HLTypography.sectionTitle)
                    .foregroundColor(appState.isNightMode ? .hlGoldLight : .hlTextPrimary)
                Spacer()
                Text("\(habitTracker.todayCompletedCount)/\(habitTracker.todayTotalCount)")
                    .font(HLTypography.label)
                    .foregroundColor(.hlGold)
            }

            // Progress ring
            HStack(spacing: HLSpacing.lg) {
                ZStack {
                    Circle()
                        .stroke(Color.hlGreen100, lineWidth: 6)
                        .frame(width: 60, height: 60)
                    Circle()
                        .trim(from: 0, to: habitTracker.todayCompletionRate)
                        .stroke(Color.hlGold, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                        .frame(width: 60, height: 60)
                        .rotationEffect(.degrees(-90))

                    Text("\(Int(habitTracker.todayCompletionRate * 100))%")
                        .font(HLTypography.label)
                        .foregroundColor(appState.isNightMode ? .hlNightText : .hlTextPrimary)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("\(habitTracker.currentStreak) day streak")
                        .font(HLTypography.sansMedium(15))
                        .foregroundColor(appState.isNightMode ? .hlNightText : .hlTextPrimary)
                    Text("Keep going — consistency is your superpower")
                        .font(HLTypography.bodySmall)
                        .foregroundColor(appState.isNightMode ? .hlNightTextMuted : .hlTextSecondary)
                }
            }
            .padding(HLSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: HLRadius.lg)
                    .fill(appState.isNightMode ? Color.white.opacity(0.05) : .hlSurface)
            )
            .hlShadowSubtle()
        }
    }

    // MARK: - Recommended
    private var recommendedSessionCard: some View {
        VStack(alignment: .leading, spacing: HLSpacing.md) {
            Text("Recommended for You")
                .font(HLTypography.sectionTitle)
                .foregroundColor(appState.isNightMode ? .hlGoldLight : .hlTextPrimary)

            HStack(spacing: HLSpacing.md) {
                ZStack {
                    RoundedRectangle(cornerRadius: HLRadius.md)
                        .fill(LinearGradient(colors: [.hlAzure, .hlAzureLight], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 56, height: 56)
                    Image(systemName: "wind")
                        .font(.system(size: 22))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Coherent Breathing")
                        .font(HLTypography.cardTitle)
                        .foregroundColor(appState.isNightMode ? .hlNightText : .hlTextPrimary)
                    Text("10 min · Optimal heart coherence")
                        .font(HLTypography.bodySmall)
                        .foregroundColor(appState.isNightMode ? .hlNightTextMuted : .hlTextSecondary)
                }

                Spacer()

                Button(action: {}) {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 36))
                        .foregroundColor(.hlGold)
                }
            }
            .padding(HLSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: HLRadius.lg)
                    .fill(appState.isNightMode ? Color.white.opacity(0.05) : .hlSurface)
            )
            .hlShadowSubtle()
        }
    }

    // MARK: - Weekly Streak
    private var weeklyStreakView: some View {
        VStack(alignment: .leading, spacing: HLSpacing.md) {
            Text("This Week")
                .font(HLTypography.sectionTitle)
                .foregroundColor(appState.isNightMode ? .hlGoldLight : .hlTextPrimary)

            HStack(spacing: HLSpacing.sm) {
                ForEach(habitTracker.weeklyProgress) { day in
                    VStack(spacing: 6) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(day.completionRate > 0 ? Color.hlGold : Color.hlGreen100)
                            .frame(width: 36, height: max(8, CGFloat(day.completionRate) * 50))

                        Text(day.dayName)
                            .font(HLTypography.caption)
                            .foregroundColor(appState.isNightMode ? .hlNightTextMuted : .hlTextTertiary)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(HLSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: HLRadius.lg)
                    .fill(appState.isNightMode ? Color.white.opacity(0.05) : .hlSurface)
            )
            .hlShadowSubtle()
        }
    }
}

// MARK: - Quick Action Card
struct QuickActionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let isNightMode: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(color)

            Text(title)
                .font(HLTypography.cardTitle)
                .foregroundColor(isNightMode ? .hlNightText : .hlTextPrimary)

            Text(subtitle)
                .font(HLTypography.caption)
                .foregroundColor(isNightMode ? .hlNightTextMuted : .hlTextTertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(HLSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: HLRadius.lg)
                .fill(isNightMode ? Color.white.opacity(0.05) : .hlSurface)
        )
        .hlShadowSubtle()
    }
}
