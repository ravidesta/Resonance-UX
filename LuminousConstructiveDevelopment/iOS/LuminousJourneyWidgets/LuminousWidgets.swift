// MARK: - Home Screen Widgets — Luminous Journey™
// iOS 17+ WidgetKit • Interactive • Multiple sizes • Lock Screen
// Somatic Check-In, Season Tracker, Practice Reminder, Reading Progress, Daily Quote

import WidgetKit
import SwiftUI

// MARK: - Widget Bundle

@main
struct LuminousWidgetBundle: WidgetBundle {
    var body: some Widget {
        SomaticCheckInWidget()
        SeasonTrackerWidget()
        PracticeReminderWidget()
        ReadingProgressWidget()
        DailyQuoteWidget()
        AudiobookMiniWidget()
    }
}

// ─── 1. Somatic Check-In Widget ─────────────────────────────────────────

struct SomaticCheckInWidget: Widget {
    let kind = "SomaticCheckIn"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SomaticProvider()) { entry in
            SomaticCheckInWidgetView(entry: entry)
                .containerBackground(for: .widget) {
                    LinearGradient(
                        colors: [Color(hex: "FAFAF8"), Color(hex: "F5F0E8")],
                        startPoint: .top, endPoint: .bottom
                    )
                }
        }
        .configurationDisplayName("Somatic Check-In")
        .description("A gentle invitation to notice your body")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryCircular, .accessoryRectangular])
    }
}

struct SomaticEntry: TimelineEntry {
    let date: Date
    let prompt: String
    let season: String
    let seasonColor: Color
}

struct SomaticProvider: TimelineProvider {
    func placeholder(in context: Context) -> SomaticEntry {
        SomaticEntry(date: Date(), prompt: "What does your body notice right now?", season: "Emergence", seasonColor: Color(hex: "4A9A6A"))
    }
    func getSnapshot(in context: Context, completion: @escaping (SomaticEntry) -> Void) {
        completion(placeholder(in: context))
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<SomaticEntry>) -> Void) {
        let prompts = [
            "What does your body notice right now?",
            "Where is there tension? Where is there ease?",
            "Take a breath. What arrives?",
            "Place your attention on your chest. What lives there?",
            "Notice your feet on the ground. What do they tell you?",
            "Where in your body is the growing edge?",
        ]
        let entry = SomaticEntry(
            date: Date(),
            prompt: prompts.randomElement()!,
            season: "Emergence",
            seasonColor: Color(hex: "4A9A6A")
        )
        let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(3600)))
        completion(timeline)
    }
}

struct SomaticCheckInWidgetView: View {
    let entry: SomaticEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 4) {
                    Image(systemName: "waveform")
                        .font(.system(size: 10))
                        .foregroundColor(Color(hex: "C5A059"))
                    Text("SOMATIC")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(Color(hex: "C5A059"))
                        .tracking(0.5)
                }

                Text(entry.prompt)
                    .font(.custom("Cormorant Garamond", size: 16))
                    .foregroundColor(Color(hex: "1B402E"))
                    .lineSpacing(2)
                    .lineLimit(4)

                Spacer()

                HStack(spacing: 4) {
                    Circle()
                        .fill(entry.seasonColor)
                        .frame(width: 6, height: 6)
                    Text(entry.season)
                        .font(.system(size: 9))
                        .foregroundColor(Color(hex: "8A9C91"))
                }
            }
            .padding(14)

        case .systemMedium:
            HStack(spacing: 16) {
                // Breathing orb
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(hex: "C5A059").opacity(0.2), Color.clear],
                            center: .center, startRadius: 5, endRadius: 40
                        )
                    )
                    .frame(width: 80, height: 80)

                VStack(alignment: .leading, spacing: 8) {
                    Text("SOMATIC CHECK-IN")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(Color(hex: "C5A059"))
                        .tracking(0.5)

                    Text(entry.prompt)
                        .font(.custom("Cormorant Garamond", size: 18))
                        .foregroundColor(Color(hex: "1B402E"))
                        .lineSpacing(2)

                    HStack(spacing: 4) {
                        Circle().fill(entry.seasonColor).frame(width: 6, height: 6)
                        Text("Season of \(entry.season)")
                            .font(.system(size: 10))
                            .foregroundColor(Color(hex: "8A9C91"))
                    }
                }
            }
            .padding(16)

        case .accessoryCircular:
            ZStack {
                Circle()
                    .fill(Color(hex: "C5A059").opacity(0.2))
                Image(systemName: "waveform")
                    .font(.system(size: 18))
            }

        case .accessoryRectangular:
            VStack(alignment: .leading) {
                Text("Somatic Check-In")
                    .font(.system(size: 12, weight: .semibold))
                Text(entry.prompt)
                    .font(.system(size: 11))
                    .lineLimit(2)
            }

        default:
            Text(entry.prompt)
        }
    }
}

// ─── 2. Season Tracker Widget ────────────────────────────────────────────

struct SeasonTrackerWidget: Widget {
    let kind = "SeasonTracker"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SeasonProvider()) { entry in
            SeasonWidgetView(entry: entry)
                .containerBackground(for: .widget) {
                    Color(hex: "0A1C14")
                }
        }
        .configurationDisplayName("Somatic Season")
        .description("Your current developmental season")
        .supportedFamilies([.systemSmall, .accessoryCircular])
    }
}

struct SeasonEntry: TimelineEntry {
    let date: Date
    let season: String
    let icon: String
    let color: Color
    let description: String
}

struct SeasonProvider: TimelineProvider {
    func placeholder(in context: Context) -> SeasonEntry {
        SeasonEntry(date: Date(), season: "Emergence", icon: "leaf", color: Color(hex: "4A9A6A"), description: "New patterns forming")
    }
    func getSnapshot(in context: Context, completion: @escaping (SeasonEntry) -> Void) { completion(placeholder(in: context)) }
    func getTimeline(in context: Context, completion: @escaping (Timeline<SeasonEntry>) -> Void) {
        let entry = placeholder(in: context)
        completion(Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(86400))))
    }
}

struct SeasonWidgetView: View {
    let entry: SeasonEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            VStack(spacing: 12) {
                Circle()
                    .fill(entry.color)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: entry.icon)
                            .foregroundColor(.white)
                    )

                Text(entry.season)
                    .font(.custom("Cormorant Garamond", size: 20))
                    .foregroundColor(Color(hex: "FAFAF8"))

                Text(entry.description)
                    .font(.system(size: 10))
                    .foregroundColor(Color(hex: "8A9C91"))
                    .multilineTextAlignment(.center)
            }
            .padding(14)

        case .accessoryCircular:
            ZStack {
                Circle().fill(entry.color.opacity(0.3))
                Image(systemName: entry.icon)
                    .font(.system(size: 16))
            }

        default:
            Text(entry.season)
        }
    }
}

// ─── 3. Practice Reminder Widget ─────────────────────────────────────────

struct PracticeReminderWidget: Widget {
    let kind = "PracticeReminder"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PracticeProvider()) { entry in
            PracticeWidgetView(entry: entry)
                .containerBackground(for: .widget) {
                    LinearGradient(
                        colors: [Color(hex: "FAFAF8"), Color(hex: "F5F0E8")],
                        startPoint: .top, endPoint: .bottom
                    )
                }
        }
        .configurationDisplayName("Today's Practice")
        .description("Your recommended somatic practice")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct PracticeEntry: TimelineEntry {
    let date: Date
    let name: String
    let duration: String
    let category: String
    let streak: Int
}

struct PracticeProvider: TimelineProvider {
    func placeholder(in context: Context) -> PracticeEntry {
        PracticeEntry(date: Date(), name: "Body Listening", duration: "8 min", category: "Body Scan", streak: 12)
    }
    func getSnapshot(in context: Context, completion: @escaping (PracticeEntry) -> Void) { completion(placeholder(in: context)) }
    func getTimeline(in context: Context, completion: @escaping (Timeline<PracticeEntry>) -> Void) {
        completion(Timeline(entries: [placeholder(in: context)], policy: .after(Date().addingTimeInterval(3600))))
    }
}

struct PracticeWidgetView: View {
    let entry: PracticeEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "figure.mind.and.body")
                    .foregroundColor(Color(hex: "8B6BB0"))
                Text("PRACTICE")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(Color(hex: "8B6BB0"))
                    .tracking(0.5)
                Spacer()
                Text("\(entry.streak) day streak")
                    .font(.system(size: 9))
                    .foregroundColor(Color(hex: "C5A059"))
            }

            Text(entry.name)
                .font(.custom("Cormorant Garamond", size: 18))
                .foregroundColor(Color(hex: "1B402E"))

            Text("\(entry.duration) · \(entry.category)")
                .font(.system(size: 10))
                .foregroundColor(Color(hex: "8A9C91"))

            Spacer()
        }
        .padding(14)
    }
}

// ─── 4. Reading Progress Widget ──────────────────────────────────────────

struct ReadingProgressWidget: Widget {
    let kind = "ReadingProgress"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ReadingProvider()) { entry in
            ReadingWidgetView(entry: entry)
                .containerBackground(for: .widget) {
                    Color(hex: "122E21")
                }
        }
        .configurationDisplayName("Reading Progress")
        .description("Continue where you left off")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct ReadingEntry: TimelineEntry {
    let date: Date
    let chapter: String
    let progress: Double
    let isAudiobook: Bool
    let timeRemaining: String
}

struct ReadingProvider: TimelineProvider {
    func placeholder(in context: Context) -> ReadingEntry {
        ReadingEntry(date: Date(), chapter: "Subject-Object Dynamics", progress: 0.42, isAudiobook: false, timeRemaining: "18 min")
    }
    func getSnapshot(in context: Context, completion: @escaping (ReadingEntry) -> Void) { completion(placeholder(in: context)) }
    func getTimeline(in context: Context, completion: @escaping (Timeline<ReadingEntry>) -> Void) {
        completion(Timeline(entries: [placeholder(in: context)], policy: .after(Date().addingTimeInterval(3600))))
    }
}

struct ReadingWidgetView: View {
    let entry: ReadingEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: entry.isAudiobook ? "headphones" : "book")
                    .foregroundColor(Color(hex: "C5A059"))
                Text(entry.isAudiobook ? "LISTENING" : "READING")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(Color(hex: "C5A059"))
                    .tracking(0.5)
            }

            Text(entry.chapter)
                .font(.custom("Cormorant Garamond", size: 17))
                .foregroundColor(Color(hex: "FAFAF8"))
                .lineLimit(2)

            Spacer()

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 3)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(hex: "C5A059"))
                        .frame(width: geo.size.width * entry.progress, height: 3)
                }
            }
            .frame(height: 3)

            HStack {
                Text("\(Int(entry.progress * 100))%")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(Color(hex: "C5A059"))
                Spacer()
                Text(entry.timeRemaining + " left")
                    .font(.system(size: 10))
                    .foregroundColor(Color(hex: "8A9C91"))
            }
        }
        .padding(14)
    }
}

// ─── 5. Daily Quote Widget ───────────────────────────────────────────────

struct DailyQuoteWidget: Widget {
    let kind = "DailyQuote"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: QuoteProvider()) { entry in
            QuoteWidgetView(entry: entry)
                .containerBackground(for: .widget) {
                    LinearGradient(
                        colors: [Color(hex: "0A1C14"), Color(hex: "1B402E")],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                }
        }
        .configurationDisplayName("Daily Luminous Quote")
        .description("A daily invitation to deeper awareness")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

struct QuoteEntry: TimelineEntry {
    let date: Date
    let quote: String
    let source: String
}

struct QuoteProvider: TimelineProvider {
    let quotes = [
        ("We do not see the world as it is. We see the world as we are — and in that seeing, both we and the world are transformed.", "Chapter 1"),
        ("Every subject-object shift is a small death and a small birth — the old self releasing, the new self forming.", "Chapter 2"),
        ("The very act of turning attention toward how you make meaning is itself a developmental act.", "Chapter 1"),
        ("Development is not a competition. Every stage has its own dignity, its own gifts, its own luminosity.", "Core Teaching"),
        ("We do not grow in a straight line. We grow in spirals.", "Chapter 3"),
        ("The body often knows what the mind has not yet articulated.", "Chapter 2"),
    ]
    func placeholder(in context: Context) -> QuoteEntry {
        QuoteEntry(date: Date(), quote: quotes[0].0, source: quotes[0].1)
    }
    func getSnapshot(in context: Context, completion: @escaping (QuoteEntry) -> Void) { completion(placeholder(in: context)) }
    func getTimeline(in context: Context, completion: @escaping (Timeline<QuoteEntry>) -> Void) {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
        let q = quotes[dayOfYear % quotes.count]
        completion(Timeline(entries: [QuoteEntry(date: Date(), quote: q.0, source: q.1)], policy: .after(Calendar.current.startOfDay(for: Date().addingTimeInterval(86400)))))
    }
}

struct QuoteWidgetView: View {
    let entry: QuoteEntry

    var body: some View {
        VStack(spacing: 12) {
            Spacer()
            Text("\"\(entry.quote)\"")
                .font(.custom("Cormorant Garamond", size: 16))
                .foregroundColor(Color(hex: "FAFAF8"))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 16)

            Text("— Luminous Constructive Development™ · \(entry.source)")
                .font(.system(size: 9))
                .foregroundColor(Color(hex: "C5A059").opacity(0.7))
            Spacer()
        }
    }
}

// ─── 6. Audiobook Mini Widget ────────────────────────────────────────────

struct AudiobookMiniWidget: Widget {
    let kind = "AudiobookMini"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ReadingProvider()) { entry in
            AudiobookMiniWidgetView(entry: entry)
                .containerBackground(for: .widget) {
                    Color(hex: "0A1C14")
                }
        }
        .configurationDisplayName("Audiobook")
        .description("Quick play controls")
        .supportedFamilies([.accessoryRectangular])
    }
}

struct AudiobookMiniWidgetView: View {
    let entry: ReadingEntry

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "headphones")
                .foregroundColor(Color(hex: "C5A059"))
            VStack(alignment: .leading) {
                Text(entry.chapter)
                    .font(.system(size: 11, weight: .medium))
                    .lineLimit(1)
                Text(entry.timeRemaining + " left")
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
            }
            Spacer()
            Image(systemName: "play.fill")
                .font(.system(size: 14))
        }
    }
}

// ─── Color Extension ─────────────────────────────────────────────────────

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(.sRGB, red: r, green: g, blue: b, opacity: 1)
    }
}
