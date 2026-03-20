// ComplicationViews.swift
// Luminous Cosmic Architecture™ — watchOS Complications
// WidgetKit complications: moon phase, zodiac energy, transit alerts

import SwiftUI
import WidgetKit

// MARK: - Complication Entry

struct CosmicTimelineEntry: TimelineEntry {
    let date: Date
    let moonPhase: WatchMoonPhase
    let zodiacSign: String
    let zodiacGlyph: String
    let transitAlert: String?
    let illumination: Double
}

// MARK: - Complication Provider

struct CosmicTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> CosmicTimelineEntry {
        CosmicTimelineEntry(
            date: Date(),
            moonPhase: .waxingCrescent,
            zodiacSign: "Pisces",
            zodiacGlyph: "\u{2653}",
            transitAlert: "Venus trine Jupiter",
            illumination: 0.25
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (CosmicTimelineEntry) -> Void) {
        let entry = CosmicTimelineEntry(
            date: Date(),
            moonPhase: .waxingCrescent,
            zodiacSign: "Pisces",
            zodiacGlyph: "\u{2653}",
            transitAlert: "Venus trine Jupiter",
            illumination: 0.25
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CosmicTimelineEntry>) -> Void) {
        let currentDate = Date()
        let entry = CosmicTimelineEntry(
            date: currentDate,
            moonPhase: .waxingCrescent,
            zodiacSign: "Pisces",
            zodiacGlyph: "\u{2653}",
            transitAlert: "Venus trine Jupiter",
            illumination: 0.25
        )

        // Update every 6 hours
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 6, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

// MARK: - Moon Phase Complication

struct MoonPhaseComplicationView: View {
    let entry: CosmicTimelineEntry

    var body: some View {
        ZStack {
            // Background
            Circle()
                .fill(Color(hex: 0x05100B))

            // Moon glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: 0xC5A059).opacity(0.15),
                            Color.clear,
                        ],
                        center: .center,
                        startRadius: 2,
                        endRadius: 20
                    )
                )
                .frame(width: 36, height: 36)

            // Moon shape
            WatchMoonShape(illumination: entry.illumination)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: 0xE6D0A1), Color(hex: 0xC5A059)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 20, height: 20)

            Circle()
                .strokeBorder(Color(hex: 0xC5A059).opacity(0.4), lineWidth: 0.5)
                .frame(width: 20, height: 20)
        }
    }
}

// MARK: - Zodiac Energy Complication

struct ZodiacEnergyComplicationView: View {
    let entry: CosmicTimelineEntry

    var body: some View {
        VStack(spacing: 2) {
            Text(entry.zodiacGlyph)
                .font(.system(size: 18))
                .foregroundStyle(Color(hex: 0xC5A059))

            Text(entry.zodiacSign)
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(Color(hex: 0xFAFAF8))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hex: 0x05100B))
    }
}

// MARK: - Transit Alert Complication

struct TransitAlertComplicationView: View {
    let entry: CosmicTimelineEntry

    var body: some View {
        VStack(spacing: 2) {
            Image(systemName: "arrow.triangle.2.circlepath")
                .font(.system(size: 10, weight: .light))
                .foregroundStyle(Color(hex: 0xC5A059))

            if let transit = entry.transitAlert {
                Text(transit)
                    .font(.system(size: 9, weight: .regular))
                    .foregroundStyle(Color(hex: 0xFAFAF8))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(4)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hex: 0x05100B))
    }
}

// MARK: - Rectangular Complication (Large)

struct CosmicRectangularComplicationView: View {
    let entry: CosmicTimelineEntry

    var body: some View {
        HStack(spacing: 8) {
            // Moon
            ZStack {
                WatchMoonShape(illumination: entry.illumination)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: 0xE6D0A1), Color(hex: 0xC5A059)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 16, height: 16)

                Circle()
                    .strokeBorder(Color(hex: 0xC5A059).opacity(0.4), lineWidth: 0.5)
                    .frame(width: 16, height: 16)
            }

            VStack(alignment: .leading, spacing: 1) {
                Text("\(entry.zodiacGlyph) \(entry.zodiacSign) Season")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color(hex: 0xFAFAF8))

                HStack(spacing: 4) {
                    Text(entry.moonPhase.rawValue)
                        .font(.system(size: 9))
                        .foregroundStyle(Color(hex: 0x8A9C91))

                    if let transit = entry.transitAlert {
                        Text("\u{2022}")
                            .font(.system(size: 6))
                            .foregroundStyle(Color(hex: 0x5C7065))
                        Text(transit)
                            .font(.system(size: 9))
                            .foregroundStyle(Color(hex: 0xC5A059))
                            .lineLimit(1)
                    }
                }
            }
        }
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(Color(hex: 0x05100B))
    }
}

// MARK: - Inline Complication

struct CosmicInlineComplicationView: View {
    let entry: CosmicTimelineEntry

    var body: some View {
        HStack(spacing: 4) {
            Text(entry.moonPhase.symbol)
                .font(.system(size: 12))
            Text(entry.zodiacGlyph)
                .font(.system(size: 12))
            Text(entry.zodiacSign)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color(hex: 0xFAFAF8))
        }
    }
}

// MARK: - Widget Configuration

struct LuminousCosmicWidget: Widget {
    let kind: String = "LuminousCosmicWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CosmicTimelineProvider()) { entry in
            MoonPhaseComplicationView(entry: entry)
        }
        .configurationDisplayName("Cosmic Phase")
        .description("Current moon phase and zodiac energy")
        .supportedFamilies([
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline,
            .accessoryCorner,
        ])
    }
}

struct ZodiacEnergyWidget: Widget {
    let kind: String = "ZodiacEnergyWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CosmicTimelineProvider()) { entry in
            ZodiacEnergyComplicationView(entry: entry)
        }
        .configurationDisplayName("Zodiac Energy")
        .description("Current zodiac season at a glance")
        .supportedFamilies([.accessoryCircular])
    }
}

struct TransitAlertWidget: Widget {
    let kind: String = "TransitAlertWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CosmicTimelineProvider()) { entry in
            TransitAlertComplicationView(entry: entry)
        }
        .configurationDisplayName("Transit Alert")
        .description("Today's key planetary transit")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular])
    }
}
