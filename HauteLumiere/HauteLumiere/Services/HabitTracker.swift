// HabitTracker.swift
// Haute Lumière — Habit Tracking Service

import SwiftUI
import Combine

/// Manages habits, streaks, daily/weekly goals, and Watch sync
final class HabitTracker: ObservableObject {
    // MARK: - Published State
    @Published var habits: [Habit] = []
    @Published var todayCompletions: Set<UUID> = []
    @Published var currentStreak: Int = 0
    @Published var longestStreak: Int = 0
    @Published var totalSessionsCompleted: Int = 0
    @Published var totalMinutesPracticed: Int = 0
    @Published var weeklyProgress: [DayProgress] = []

    struct DayProgress: Identifiable {
        let id = UUID()
        let date: Date
        let completionRate: Double
        let minutesPracticed: Int

        var dayName: String {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE"
            return formatter.string(from: date)
        }
    }

    // MARK: - Initialization
    init() {
        setupDefaultHabits()
        calculateWeeklyProgress()
    }

    // MARK: - Default Habits
    private func setupDefaultHabits() {
        if habits.isEmpty {
            habits = [
                Habit(name: "Morning Meditation", icon: "sunrise.fill", frequency: .daily, category: .meditation),
                Habit(name: "Breathing Practice", icon: "wind", frequency: .daily, category: .breathing),
                Habit(name: "Yoga Nidra", icon: "moon.stars.fill", frequency: .threePerWeek, category: .meditation),
                Habit(name: "Mindful Movement", icon: "figure.walk", frequency: .daily, category: .movement),
                Habit(name: "Evening Reflection", icon: "moon.fill", frequency: .daily, category: .mindfulness),
                Habit(name: "Gratitude Journal", icon: "heart.text.square.fill", frequency: .daily, category: .mindfulness),
            ]
        }
    }

    // MARK: - Habit Management
    func addHabit(_ habit: Habit) {
        habits.append(habit)
    }

    func removeHabit(_ id: UUID) {
        habits.removeAll { $0.id == id }
    }

    func toggleCompletion(for habitId: UUID) {
        if todayCompletions.contains(habitId) {
            todayCompletions.remove(habitId)
        } else {
            todayCompletions.insert(habitId)
            if let index = habits.firstIndex(where: { $0.id == habitId }) {
                habits[index].completions.append(Date())
            }
        }
        updateStreak()
        calculateWeeklyProgress()
    }

    func isCompletedToday(_ habitId: UUID) -> Bool {
        todayCompletions.contains(habitId)
    }

    // MARK: - Session Tracking
    func recordSession(type: SessionType, minutes: Int) {
        totalSessionsCompleted += 1
        totalMinutesPracticed += minutes
    }

    // MARK: - Streak Calculation
    private func updateStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var streak = 0
        var checkDate = today

        // Check consecutive days with at least one completion
        while true {
            let dayCompletions = habits.flatMap(\.completions).filter {
                calendar.startOfDay(for: $0) == checkDate
            }
            if dayCompletions.isEmpty && checkDate != today {
                break
            }
            if !dayCompletions.isEmpty {
                streak += 1
            }
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
            checkDate = previousDay
        }

        currentStreak = streak
        longestStreak = max(longestStreak, streak)
    }

    // MARK: - Weekly Progress
    private func calculateWeeklyProgress() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        weeklyProgress = (0..<7).compactMap { daysAgo in
            guard let date = calendar.date(byAdding: .day, value: -daysAgo, to: today) else { return nil }
            let dayCompletions = habits.flatMap(\.completions).filter {
                calendar.startOfDay(for: $0) == date
            }
            let rate = habits.isEmpty ? 0 : Double(dayCompletions.count) / Double(habits.count)
            return DayProgress(date: date, completionRate: min(rate, 1.0), minutesPracticed: dayCompletions.count * 15)
        }.reversed()
    }

    // MARK: - Today's Summary
    var todayCompletionRate: Double {
        guard !habits.isEmpty else { return 0 }
        return Double(todayCompletions.count) / Double(habits.count)
    }

    var todayCompletedCount: Int {
        todayCompletions.count
    }

    var todayTotalCount: Int {
        habits.count
    }

    // MARK: - Watch Data
    func watchSummary() -> WatchHabitSummary {
        WatchHabitSummary(
            completedCount: todayCompletedCount,
            totalCount: todayTotalCount,
            currentStreak: currentStreak,
            nextHabit: habits.first { !todayCompletions.contains($0.id) }?.name ?? "All done!"
        )
    }
}

struct WatchHabitSummary: Codable {
    let completedCount: Int
    let totalCount: Int
    let currentStreak: Int
    let nextHabit: String
}
