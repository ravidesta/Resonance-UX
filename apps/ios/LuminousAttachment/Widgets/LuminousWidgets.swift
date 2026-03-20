// LuminousWidgets.swift
// Luminous Attachment — Resonance UX
// WidgetKit widgets: DailyInsight, Mood, Breathing, Streak with timeline providers

import WidgetKit
import SwiftUI

// MARK: - Shared Data Access

struct WidgetDataProvider {
    static let appGroupID = "group.com.resonance-ux.luminous-attachment"

    static func currentInsight() -> DailyInsight {
        InsightsProvider.insightOfTheDay()
    }

    static func currentStreak() -> Int {
        let defaults = UserDefaults(suiteName: appGroupID)
        return defaults?.integer(forKey: "streakDays") ?? 0
    }

    static func lastMood() -> MoodLevel {
        let defaults = UserDefaults(suiteName: appGroupID)
        let raw = defaults?.integer(forKey: "lastMoodLevel") ?? 3
        return MoodLevel(rawValue: raw) ?? .leaf
    }

    static func journalCount() -> Int {
        let defaults = UserDefaults(suiteName: appGroupID)
        return defaults?.integer(forKey: "totalJournalEntries") ?? 0
    }

    static func completedChapters() -> Int {
        let defaults = UserDefaults(suiteName: appGroupID)
        return defaults?.integer(forKey: "completedChaptersCount") ?? 0
    }
}

// ═══════════════════════════════════════════════════════════════════
// MARK: - Daily Insight Widget
// ═══════════════════════════════════════════════════════════════════

struct InsightEntry: TimelineEntry {
    let date: Date
    let insight: DailyInsight
    let streak: Int
}

struct InsightTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> InsightEntry {
        InsightEntry(
            date: Date(),
            insight: DailyInsight(text: "Your attachment style is not your destiny.", author: "Luminous Attachment", category: "Hope"),
            streak: 7
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (InsightEntry) -> Void) {
        let entry = InsightEntry(
            date: Date(),
            insight: WidgetDataProvider.currentInsight(),
            streak: WidgetDataProvider.currentStreak()
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<InsightEntry>) -> Void) {
        let currentDate = Date()
        let midnight = Calendar.current.startOfDay(for: currentDate).addingTimeInterval(86400)

        let entry = InsightEntry(
            date: currentDate,
            insight: WidgetDataProvider.currentInsight(),
            streak: WidgetDataProvider.currentStreak()
        )

        let timeline = Timeline(entries: [entry], policy: .after(midnight))
        completion(timeline)
    }
}

struct DailyInsightWidgetView: View {
    var entry: InsightEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            smallInsightView
        case .systemMedium:
            mediumInsightView
        case .systemLarge:
            largeInsightView
        default:
            smallInsightView
        }
    }

    // MARK: Small

    private var smallInsightView: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "0A1C14"), Color(hex: "122E21")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "sparkles")
                        .font(.caption)
                        .foregroundStyle(Color(hex: "C5A059"))
                    Text("INSIGHT")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(Color(hex: "C5A059"))
                        .tracking(1)
                    Spacer()
                }

                Text(entry.insight.text)
                    .font(.caption.weight(.medium).leading(.tight))
                    .foregroundStyle(.white)
                    .lineLimit(4)
                    .minimumScaleFactor(0.8)

                Spacer()

                HStack {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(Color(hex: "C5A059"))
                    Text("\(entry.streak)")
                        .font(.caption.weight(.bold).monospacedDigit())
                        .foregroundStyle(Color(hex: "C5A059"))
                }
            }
            .padding(14)
        }
        .containerBackground(for: .widget) {
            Color(hex: "0A1C14")
        }
    }

    // MARK: Medium

    private var mediumInsightView: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "0A1C14"), Color(hex: "122E21")],
                startPoint: .leading,
                endPoint: .trailing
            )

            HStack(spacing: 16) {
                // Left: Icon
                VStack {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "C5A059").opacity(0.15))
                            .frame(width: 56, height: 56)
                        Image(systemName: "sparkles")
                            .font(.title2)
                            .foregroundStyle(Color(hex: "C5A059"))
                    }
                    Spacer()
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.caption)
                        Text("\(entry.streak) days")
                            .font(.caption.weight(.medium))
                    }
                    .foregroundStyle(Color(hex: "C5A059"))
                }

                // Right: Content
                VStack(alignment: .leading, spacing: 6) {
                    Text("Daily Insight")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color(hex: "C5A059"))
                        .textCase(.uppercase)
                        .tracking(1)

                    Text(entry.insight.text)
                        .font(.subheadline.weight(.medium).leading(.loose))
                        .foregroundStyle(.white)
                        .lineLimit(4)

                    if entry.insight.author != "Luminous Attachment" {
                        Text("— \(entry.insight.author)")
                            .font(.caption2.italic())
                            .foregroundStyle(Color(hex: "E6D0A1").opacity(0.6))
                    }

                    Spacer()
                }
            }
            .padding(16)
        }
        .containerBackground(for: .widget) {
            Color(hex: "0A1C14")
        }
    }

    // MARK: Large

    private var largeInsightView: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "0A1C14"), Color(hex: "122E21"), Color(hex: "1B402E")],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(spacing: 16) {
                HStack {
                    Image(systemName: "sparkles")
                        .foregroundStyle(Color(hex: "C5A059"))
                    Text("LUMINOUS ATTACHMENT")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(Color(hex: "C5A059"))
                        .tracking(2)
                    Spacer()
                    Text(entry.insight.category)
                        .font(.caption2.weight(.medium))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            Capsule()
                                .fill(Color(hex: "C5A059").opacity(0.15))
                        )
                        .foregroundStyle(Color(hex: "C5A059"))
                }

                Spacer()

                // Quote
                VStack(spacing: 12) {
                    Image(systemName: "quote.opening")
                        .font(.title)
                        .foregroundStyle(Color(hex: "C5A059").opacity(0.4))

                    Text(entry.insight.text)
                        .font(.title3.weight(.medium).leading(.loose))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)

                    if entry.insight.author != "Luminous Attachment" {
                        Text("— \(entry.insight.author)")
                            .font(.caption.italic())
                            .foregroundStyle(Color(hex: "E6D0A1").opacity(0.6))
                    }
                }

                Spacer()

                // Bottom stats
                HStack(spacing: 20) {
                    widgetStat(icon: "flame.fill", value: "\(entry.streak)", label: "Streak")
                    widgetStat(icon: "book.fill", value: "\(WidgetDataProvider.completedChapters())", label: "Chapters")
                    widgetStat(icon: "pencil.line", value: "\(WidgetDataProvider.journalCount())", label: "Entries")
                }

                Divider()
                    .overlay(Color(hex: "C5A059").opacity(0.2))

                Text("Tap for today's reflection")
                    .font(.caption2)
                    .foregroundStyle(Color(hex: "E6D0A1").opacity(0.4))
            }
            .padding(18)
        }
        .containerBackground(for: .widget) {
            Color(hex: "0A1C14")
        }
    }

    private func widgetStat(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(Color(hex: "C5A059"))
            Text(value)
                .font(.headline.monospacedDigit())
                .foregroundStyle(.white)
            Text(label)
                .font(.caption2)
                .foregroundStyle(Color(hex: "E6D0A1").opacity(0.5))
        }
        .frame(maxWidth: .infinity)
    }
}

struct DailyInsightWidget: Widget {
    let kind = "DailyInsightWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: InsightTimelineProvider()) { entry in
            DailyInsightWidgetView(entry: entry)
        }
        .configurationDisplayName("Daily Insight")
        .description("A daily attachment healing insight to guide your journey.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// ═══════════════════════════════════════════════════════════════════
// MARK: - Mood Widget
// ═══════════════════════════════════════════════════════════════════

struct MoodEntry: TimelineEntry {
    let date: Date
    let currentMood: MoodLevel
    let hasCheckedIn: Bool
}

struct MoodTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> MoodEntry {
        MoodEntry(date: Date(), currentMood: .leaf, hasCheckedIn: false)
    }

    func getSnapshot(in context: Context, completion: @escaping (MoodEntry) -> Void) {
        completion(MoodEntry(date: Date(), currentMood: WidgetDataProvider.lastMood(), hasCheckedIn: false))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<MoodEntry>) -> Void) {
        let entry = MoodEntry(
            date: Date(),
            currentMood: WidgetDataProvider.lastMood(),
            hasCheckedIn: false
        )
        let midnight = Calendar.current.startOfDay(for: Date()).addingTimeInterval(86400)
        completion(Timeline(entries: [entry], policy: .after(midnight)))
    }
}

struct MoodWidgetView: View {
    var entry: MoodEntry

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "0A1C14"), Color(hex: "122E21")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(spacing: 8) {
                if entry.hasCheckedIn {
                    Image(systemName: entry.currentMood.icon)
                        .font(.largeTitle)
                        .foregroundStyle(entry.currentMood.color)
                    Text(entry.currentMood.name)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white)
                    Text(entry.currentMood.description)
                        .font(.caption2)
                        .foregroundStyle(Color(hex: "E6D0A1").opacity(0.6))
                        .multilineTextAlignment(.center)
                } else {
                    Image(systemName: "heart.text.clipboard")
                        .font(.title)
                        .foregroundStyle(Color(hex: "C5A059"))
                    Text("Check In")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white)
                    Text("How are you feeling?")
                        .font(.caption2)
                        .foregroundStyle(Color(hex: "E6D0A1").opacity(0.6))
                }
            }
            .padding(14)
        }
        .containerBackground(for: .widget) {
            Color(hex: "0A1C14")
        }
    }
}

struct MoodWidget: Widget {
    let kind = "MoodWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MoodTimelineProvider()) { entry in
            MoodWidgetView(entry: entry)
        }
        .configurationDisplayName("Mood Check-In")
        .description("Quick access to check in with how you feel.")
        .supportedFamilies([.systemSmall])
    }
}

// ═══════════════════════════════════════════════════════════════════
// MARK: - Breathing Widget
// ═══════════════════════════════════════════════════════════════════

struct BreathingEntry: TimelineEntry {
    let date: Date
    let exerciseName: String
    let totalMinutes: Double
}

struct BreathingTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> BreathingEntry {
        BreathingEntry(date: Date(), exerciseName: "Grounding Breath", totalMinutes: 15)
    }

    func getSnapshot(in context: Context, completion: @escaping (BreathingEntry) -> Void) {
        let defaults = UserDefaults(suiteName: WidgetDataProvider.appGroupID)
        let minutes = defaults?.double(forKey: "totalMeditationMinutes") ?? 0
        completion(BreathingEntry(date: Date(), exerciseName: "Grounding Breath", totalMinutes: minutes))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<BreathingEntry>) -> Void) {
        let defaults = UserDefaults(suiteName: WidgetDataProvider.appGroupID)
        let minutes = defaults?.double(forKey: "totalMeditationMinutes") ?? 0
        let entry = BreathingEntry(date: Date(), exerciseName: "Grounding Breath", totalMinutes: minutes)
        let refresh = Date().addingTimeInterval(3600)
        completion(Timeline(entries: [entry], policy: .after(refresh)))
    }
}

struct BreathingWidgetView: View {
    var entry: BreathingEntry

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "0A1C14"), Color(hex: "122E21")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(spacing: 10) {
                // Breathing circle
                ZStack {
                    Circle()
                        .strokeBorder(Color(hex: "C5A059").opacity(0.2), lineWidth: 2)
                        .frame(width: 52, height: 52)
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color(hex: "C5A059").opacity(0.25), Color(hex: "C5A059").opacity(0.05)],
                                center: .center,
                                startRadius: 0,
                                endRadius: 22
                            )
                        )
                        .frame(width: 40, height: 40)
                    Image(systemName: "wind")
                        .font(.body)
                        .foregroundStyle(Color(hex: "C5A059"))
                }

                Text("Breathe")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white)

                Text(String(format: "%.0f min total", entry.totalMinutes))
                    .font(.caption2)
                    .foregroundStyle(Color(hex: "E6D0A1").opacity(0.5))
            }
            .padding(14)
        }
        .containerBackground(for: .widget) {
            Color(hex: "0A1C14")
        }
    }
}

struct BreathingWidget: Widget {
    let kind = "BreathingWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: BreathingTimelineProvider()) { entry in
            BreathingWidgetView(entry: entry)
        }
        .configurationDisplayName("Breathing")
        .description("Quick access to your grounding breath exercises.")
        .supportedFamilies([.systemSmall])
    }
}

// ═══════════════════════════════════════════════════════════════════
// MARK: - Streak Widget
// ═══════════════════════════════════════════════════════════════════

struct StreakEntry: TimelineEntry {
    let date: Date
    let streakDays: Int
    let chapters: Int
    let entries: Int
}

struct StreakTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> StreakEntry {
        StreakEntry(date: Date(), streakDays: 14, chapters: 5, entries: 23)
    }

    func getSnapshot(in context: Context, completion: @escaping (StreakEntry) -> Void) {
        completion(StreakEntry(
            date: Date(),
            streakDays: WidgetDataProvider.currentStreak(),
            chapters: WidgetDataProvider.completedChapters(),
            entries: WidgetDataProvider.journalCount()
        ))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<StreakEntry>) -> Void) {
        let entry = StreakEntry(
            date: Date(),
            streakDays: WidgetDataProvider.currentStreak(),
            chapters: WidgetDataProvider.completedChapters(),
            entries: WidgetDataProvider.journalCount()
        )
        let midnight = Calendar.current.startOfDay(for: Date()).addingTimeInterval(86400)
        completion(Timeline(entries: [entry], policy: .after(midnight)))
    }
}

struct StreakWidgetView: View {
    var entry: StreakEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            smallStreakView
        case .systemMedium:
            mediumStreakView
        default:
            smallStreakView
        }
    }

    private var smallStreakView: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "0A1C14"), Color(hex: "122E21")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(spacing: 8) {
                Image(systemName: "flame.fill")
                    .font(.title)
                    .foregroundStyle(Color(hex: "C5A059"))

                Text("\(entry.streakDays)")
                    .font(.system(size: 36, weight: .bold, design: .rounded).monospacedDigit())
                    .foregroundStyle(.white)

                Text("day streak")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Color(hex: "E6D0A1").opacity(0.6))
            }
            .padding(14)
        }
        .containerBackground(for: .widget) {
            Color(hex: "0A1C14")
        }
    }

    private var mediumStreakView: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "0A1C14"), Color(hex: "122E21")],
                startPoint: .leading,
                endPoint: .trailing
            )

            HStack(spacing: 20) {
                // Streak
                VStack(spacing: 6) {
                    Image(systemName: "flame.fill")
                        .font(.title2)
                        .foregroundStyle(Color(hex: "C5A059"))
                    Text("\(entry.streakDays)")
                        .font(.system(size: 32, weight: .bold, design: .rounded).monospacedDigit())
                        .foregroundStyle(.white)
                    Text("day streak")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(Color(hex: "E6D0A1").opacity(0.6))
                }
                .frame(maxWidth: .infinity)

                // Divider
                Rectangle()
                    .fill(Color(hex: "C5A059").opacity(0.2))
                    .frame(width: 1)
                    .padding(.vertical, 8)

                // Stats
                VStack(spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "book.fill")
                            .font(.caption)
                            .foregroundStyle(Color(hex: "C5A059"))
                        Text("\(entry.chapters) chapters")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.white)
                        Spacer()
                    }
                    HStack(spacing: 8) {
                        Image(systemName: "pencil.line")
                            .font(.caption)
                            .foregroundStyle(Color(hex: "C5A059"))
                        Text("\(entry.entries) entries")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.white)
                        Spacer()
                    }
                    HStack(spacing: 8) {
                        Image(systemName: "heart.fill")
                            .font(.caption)
                            .foregroundStyle(Color(hex: "C5A059"))
                        Text("Keep going")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(Color(hex: "E6D0A1").opacity(0.6))
                        Spacer()
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding(16)
        }
        .containerBackground(for: .widget) {
            Color(hex: "0A1C14")
        }
    }
}

struct StreakWidget: Widget {
    let kind = "StreakWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StreakTimelineProvider()) { entry in
            StreakWidgetView(entry: entry)
        }
        .configurationDisplayName("Healing Streak")
        .description("Track your daily attachment healing practice.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// ═══════════════════════════════════════════════════════════════════
// MARK: - Widget Bundle
// ═══════════════════════════════════════════════════════════════════

@main
struct LuminousWidgetBundle: WidgetBundle {
    var body: some Widget {
        DailyInsightWidget()
        MoodWidget()
        BreathingWidget()
        StreakWidget()
    }
}
