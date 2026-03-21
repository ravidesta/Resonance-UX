// ResonanceWidgets.swift
// Resonance — Design for the Exhale
//
// Home Screen & Lock Screen widgets for iOS, iPadOS, and macOS.
// Watch complications use the same timeline provider.

import SwiftUI
import WidgetKit

// MARK: - Timeline Provider

struct ResonanceTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> ResonanceWidgetEntry {
        ResonanceWidgetEntry(
            date: .now,
            phase: .zenith,
            spaciousnessPercent: 30,
            nextEvent: "Strategy review",
            nextEventTime: "11:30 AM"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (ResonanceWidgetEntry) -> Void) {
        let entry = ResonanceWidgetEntry(
            date: .now,
            phase: DailyPhase.current(),
            spaciousnessPercent: 30,
            nextEvent: "Deep work session",
            nextEventTime: "9:00 AM"
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ResonanceWidgetEntry>) -> Void) {
        var entries: [ResonanceWidgetEntry] = []
        let now = Date()

        // Generate entries for each phase transition
        for hourOffset in stride(from: 0, to: 24, by: 3) {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: now)!
            let phase = DailyPhase.current(at: entryDate)
            let entry = ResonanceWidgetEntry(
                date: entryDate,
                phase: phase,
                spaciousnessPercent: Int.random(in: 20...60),
                nextEvent: nil,
                nextEventTime: nil
            )
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

// MARK: - Widget Entry

struct ResonanceWidgetEntry: TimelineEntry {
    let date: Date
    let phase: DailyPhase
    let spaciousnessPercent: Int
    let nextEvent: String?
    let nextEventTime: String?
}

// MARK: - Small Widget (Phase Glance)

struct SmallPhaseWidget: View {
    let entry: ResonanceWidgetEntry

    var body: some View {
        ZStack {
            // Background
            Color(hex: "FAFAF8")

            // Subtle blob
            Circle()
                .fill(entry.phase.accentColor.opacity(0.08))
                .frame(width: 140, height: 140)
                .offset(x: 30, y: -20)
                .blur(radius: 30)

            VStack(alignment: .leading, spacing: 6) {
                // Phase icon
                Image(systemName: entry.phase.icon)
                    .font(.system(size: 22))
                    .foregroundStyle(entry.phase.accentColor)

                Spacer()

                // Phase name
                Text(entry.phase.rawValue)
                    .font(.custom("Cormorant Garamond", size: 22).weight(.medium))
                    .foregroundStyle(Color(hex: "122E21"))

                // Time range
                Text(entry.phase.timeRange)
                    .font(.system(size: 11))
                    .foregroundStyle(Color(hex: "8A9C91"))

                // Spaciousness bar
                HStack(spacing: 4) {
                    Image(systemName: "wind")
                        .font(.system(size: 9))
                        .foregroundStyle(Color(hex: "8A9C91"))

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color(hex: "E5EBE7"))
                                .frame(height: 2.5)

                            Capsule()
                                .fill(Color(hex: "C5A059").opacity(0.6))
                                .frame(width: geo.size.width * CGFloat(entry.spaciousnessPercent) / 100, height: 2.5)
                        }
                    }
                    .frame(height: 2.5)

                    Text("\(entry.spaciousnessPercent)%")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(Color(hex: "C5A059"))
                }
            }
            .padding(16)
        }
    }
}

// MARK: - Medium Widget (Phase + Next Event)

struct MediumPhaseWidget: View {
    let entry: ResonanceWidgetEntry

    var body: some View {
        ZStack {
            Color(hex: "FAFAF8")

            // Blobs
            Circle()
                .fill(Color(hex: "D1E0D7").opacity(0.3))
                .frame(width: 180, height: 180)
                .offset(x: -80, y: 40)
                .blur(radius: 50)

            Circle()
                .fill(Color(hex: "E6D0A1").opacity(0.15))
                .frame(width: 120, height: 120)
                .offset(x: 100, y: -30)
                .blur(radius: 40)

            HStack(spacing: 20) {
                // Phase info
                VStack(alignment: .leading, spacing: 6) {
                    Image(systemName: entry.phase.icon)
                        .font(.system(size: 24))
                        .foregroundStyle(entry.phase.accentColor)

                    Spacer()

                    Text(entry.phase.rawValue)
                        .font(.custom("Cormorant Garamond", size: 24).weight(.medium))
                        .foregroundStyle(Color(hex: "122E21"))

                    Text(entry.phase.description)
                        .font(.system(size: 11))
                        .foregroundStyle(Color(hex: "5C7065"))
                        .lineLimit(2)
                }

                Divider()
                    .foregroundStyle(Color(hex: "E5EBE7"))

                // Next event + spaciousness
                VStack(alignment: .leading, spacing: 8) {
                    Text("NEXT")
                        .font(.system(size: 9, weight: .medium))
                        .tracking(1.5)
                        .foregroundStyle(Color(hex: "8A9C91"))

                    if let event = entry.nextEvent {
                        Text(event)
                            .font(.custom("Cormorant Garamond", size: 16).weight(.medium))
                            .foregroundStyle(Color(hex: "122E21"))

                        if let time = entry.nextEventTime {
                            Text(time)
                                .font(.system(size: 11))
                                .foregroundStyle(Color(hex: "8A9C91"))
                        }
                    } else {
                        Text("Open space")
                            .font(.custom("Cormorant Garamond", size: 16))
                            .italic()
                            .foregroundStyle(Color(hex: "5C7065"))
                    }

                    Spacer()

                    // Spaciousness
                    HStack(spacing: 4) {
                        Image(systemName: "wind")
                            .font(.system(size: 10))
                        Text("\(entry.spaciousnessPercent)% spacious")
                            .font(.system(size: 10))
                    }
                    .foregroundStyle(Color(hex: "C5A059"))
                }
            }
            .padding(16)
        }
    }
}

// MARK: - Lock Screen Widget (Circular)

struct LockScreenCircularWidget: View {
    let entry: ResonanceWidgetEntry

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()

            VStack(spacing: 1) {
                Image(systemName: entry.phase.icon)
                    .font(.system(size: 14))
                Text(String(entry.phase.rawValue.prefix(3)))
                    .font(.system(size: 9, weight: .medium))
            }
        }
    }
}

// MARK: - Lock Screen Widget (Rectangular)

struct LockScreenRectangularWidget: View {
    let entry: ResonanceWidgetEntry

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: entry.phase.icon)
                .font(.system(size: 16))

            VStack(alignment: .leading, spacing: 1) {
                Text(entry.phase.rawValue)
                    .font(.system(size: 13, weight: .medium))
                Text(entry.phase.timeRange)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "wind")
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
            Text("\(entry.spaciousnessPercent)%")
                .font(.system(size: 11, weight: .medium))
        }
    }
}

// MARK: - Lock Screen Widget (Inline)

struct LockScreenInlineWidget: View {
    let entry: ResonanceWidgetEntry

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: entry.phase.icon)
            Text("\(entry.phase.rawValue) · \(entry.phase.timeRange)")
        }
    }
}

// MARK: - Widget Bundle

struct ResonanceWidget: Widget {
    let kind = "ResonancePhaseWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ResonanceTimelineProvider()) { entry in
            SmallPhaseWidget(entry: entry)
                .containerBackground(for: .widget) {
                    Color(hex: "FAFAF8")
                }
        }
        .configurationDisplayName("Daily Phase")
        .description("Your current rhythm phase and spaciousness.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct ResonanceLockScreenWidget: Widget {
    let kind = "ResonanceLockScreen"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ResonanceTimelineProvider()) { entry in
            LockScreenCircularWidget(entry: entry)
        }
        .configurationDisplayName("Phase")
        .description("Current daily phase at a glance.")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}

@main
struct ResonanceWidgetBundle: WidgetBundle {
    var body: some Widget {
        ResonanceWidget()
        ResonanceLockScreenWidget()
    }
}
