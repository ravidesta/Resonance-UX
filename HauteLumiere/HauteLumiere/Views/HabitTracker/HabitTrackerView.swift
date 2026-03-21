// HabitTrackerView.swift
// Haute Lumière — Habit Tracker (App + Watch)

import SwiftUI

struct HabitTrackerView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var habitTracker: HabitTracker
    @State private var showAddHabit = false

    var body: some View {
        ZStack {
            if appState.isNightMode {
                ForestNightBackground(theme: appState.nightModeTheme)
            } else {
                Color.hlCream.ignoresSafeArea()
            }

            ScrollView(showsIndicators: false) {
                VStack(spacing: HLSpacing.lg) {
                    // Overview ring
                    overviewCard

                    // Streak
                    streakCard

                    // Habits list
                    VStack(alignment: .leading, spacing: HLSpacing.md) {
                        HStack {
                            Text("Daily Habits")
                                .font(HLTypography.sectionTitle)
                                .foregroundColor(appState.isNightMode ? .hlGoldLight : .hlTextPrimary)
                            Spacer()
                            Button(action: { showAddHabit = true }) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.hlGold)
                                    .font(.system(size: 24))
                            }
                        }

                        ForEach(habitTracker.habits) { habit in
                            HabitRow(
                                habit: habit,
                                isCompleted: habitTracker.isCompletedToday(habit.id),
                                isNightMode: appState.isNightMode
                            ) {
                                withAnimation(.spring(response: 0.3)) {
                                    habitTracker.toggleCompletion(for: habit.id)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, HLSpacing.lg)

                    // Weekly view
                    weeklyView

                    // Stats
                    statsGrid

                    Spacer(minLength: 120)
                }
                .padding(.top, HLSpacing.md)
            }
        }
        .navigationTitle("Habits")
    }

    // MARK: - Overview
    private var overviewCard: some View {
        VStack(spacing: HLSpacing.md) {
            ZStack {
                Circle()
                    .stroke(appState.isNightMode ? Color.white.opacity(0.1) : .hlGreen100, lineWidth: 10)
                    .frame(width: 120, height: 120)

                Circle()
                    .trim(from: 0, to: habitTracker.todayCompletionRate)
                    .stroke(Color.hlGold, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.6), value: habitTracker.todayCompletionRate)

                VStack(spacing: 2) {
                    Text("\(habitTracker.todayCompletedCount)")
                        .font(HLTypography.serifMedium(32))
                        .foregroundColor(appState.isNightMode ? .hlGoldLight : .hlTextPrimary)
                    Text("of \(habitTracker.todayTotalCount)")
                        .font(HLTypography.caption)
                        .foregroundColor(.hlTextTertiary)
                }
            }

            Text("Today's Progress")
                .font(HLTypography.label)
                .foregroundColor(appState.isNightMode ? .hlNightText : .hlTextPrimary)
        }
        .padding(HLSpacing.lg)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: HLRadius.xl)
                .fill(appState.isNightMode ? Color.white.opacity(0.05) : .hlSurface)
        )
        .hlShadowSubtle()
        .padding(.horizontal, HLSpacing.lg)
    }

    // MARK: - Streak
    private var streakCard: some View {
        HStack(spacing: HLSpacing.lg) {
            VStack(spacing: 4) {
                Text("\(habitTracker.currentStreak)")
                    .font(HLTypography.serifMedium(28))
                    .foregroundColor(.hlGold)
                Text("Current Streak")
                    .font(HLTypography.caption)
                    .foregroundColor(.hlTextTertiary)
            }

            Divider().frame(height: 40)

            VStack(spacing: 4) {
                Text("\(habitTracker.longestStreak)")
                    .font(HLTypography.serifMedium(28))
                    .foregroundColor(appState.isNightMode ? .hlNightText : .hlTextPrimary)
                Text("Longest Streak")
                    .font(HLTypography.caption)
                    .foregroundColor(.hlTextTertiary)
            }

            Divider().frame(height: 40)

            VStack(spacing: 4) {
                Text("\(habitTracker.totalSessionsCompleted)")
                    .font(HLTypography.serifMedium(28))
                    .foregroundColor(appState.isNightMode ? .hlNightText : .hlTextPrimary)
                Text("Total Sessions")
                    .font(HLTypography.caption)
                    .foregroundColor(.hlTextTertiary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(HLSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: HLRadius.lg)
                .fill(appState.isNightMode ? Color.white.opacity(0.05) : .hlSurface)
        )
        .hlShadowSubtle()
        .padding(.horizontal, HLSpacing.lg)
    }

    // MARK: - Weekly
    private var weeklyView: some View {
        VStack(alignment: .leading, spacing: HLSpacing.md) {
            Text("This Week")
                .font(HLTypography.sectionTitle)
                .foregroundColor(appState.isNightMode ? .hlGoldLight : .hlTextPrimary)

            HStack(spacing: HLSpacing.sm) {
                ForEach(habitTracker.weeklyProgress) { day in
                    VStack(spacing: 6) {
                        ZStack {
                            Circle()
                                .fill(day.completionRate >= 1.0 ? Color.hlGold : (appState.isNightMode ? Color.white.opacity(0.08) : .hlGreen50))
                                .frame(width: 36, height: 36)

                            if day.completionRate >= 1.0 {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.hlGreen900)
                            } else if day.completionRate > 0 {
                                Circle()
                                    .trim(from: 0, to: day.completionRate)
                                    .stroke(Color.hlGold, lineWidth: 3)
                                    .frame(width: 30, height: 30)
                                    .rotationEffect(.degrees(-90))
                            }
                        }

                        Text(day.dayName)
                            .font(HLTypography.caption)
                            .foregroundColor(.hlTextTertiary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.horizontal, HLSpacing.lg)
    }

    // MARK: - Stats
    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: HLSpacing.sm) {
            StatCard(title: "Minutes Practiced", value: "\(habitTracker.totalMinutesPracticed)", icon: "clock", isNightMode: appState.isNightMode)
            StatCard(title: "Sessions Done", value: "\(habitTracker.totalSessionsCompleted)", icon: "checkmark.circle", isNightMode: appState.isNightMode)
        }
        .padding(.horizontal, HLSpacing.lg)
    }
}

// MARK: - Habit Row
struct HabitRow: View {
    let habit: Habit
    let isCompleted: Bool
    let isNightMode: Bool
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: HLSpacing.md) {
            Button(action: onToggle) {
                ZStack {
                    Circle()
                        .stroke(isCompleted ? Color.hlGold : .hlTextTertiary.opacity(0.3), lineWidth: 2)
                        .frame(width: 28, height: 28)

                    if isCompleted {
                        Circle()
                            .fill(Color.hlGold)
                            .frame(width: 28, height: 28)
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.hlGreen900)
                    }
                }
            }

            Image(systemName: habit.icon)
                .font(.system(size: 16))
                .foregroundColor(isCompleted ? .hlGold : .hlTextTertiary)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(habit.name)
                    .font(HLTypography.cardTitle)
                    .foregroundColor(isNightMode ? .hlNightText : .hlTextPrimary)
                    .strikethrough(isCompleted, color: .hlTextTertiary)

                Text(habit.targetFrequency.rawValue)
                    .font(HLTypography.caption)
                    .foregroundColor(.hlTextTertiary)
            }

            Spacer()

            if habit.currentStreak > 0 {
                HStack(spacing: 2) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 12))
                    Text("\(habit.currentStreak)")
                        .font(HLTypography.caption)
                }
                .foregroundColor(.hlGold)
            }
        }
        .padding(HLSpacing.sm)
        .background(
            RoundedRectangle(cornerRadius: HLRadius.md)
                .fill(isNightMode ? Color.white.opacity(isCompleted ? 0.06 : 0.03) : (isCompleted ? .hlGold.opacity(0.05) : .hlSurface))
        )
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let isNightMode: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            Image(systemName: icon)
                .foregroundColor(.hlGold)
                .font(.system(size: 18))

            Text(value)
                .font(HLTypography.serifMedium(24))
                .foregroundColor(isNightMode ? .hlNightText : .hlTextPrimary)

            Text(title)
                .font(HLTypography.caption)
                .foregroundColor(.hlTextTertiary)
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
