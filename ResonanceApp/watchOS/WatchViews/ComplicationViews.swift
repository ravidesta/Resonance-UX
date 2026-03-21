// ComplicationViews.swift
// Resonance — Design for the Exhale
//
// Watch complications — glanceable current phase and spaciousness.

import SwiftUI
import WidgetKit

#if os(watchOS)

// MARK: - Complication Timeline Entry

struct ResonanceComplicationEntry: TimelineEntry {
    let date: Date
    let phase: DailyPhase
    let spaciousnessPercent: Int
}

// MARK: - Circular Complication

struct CircularComplicationView: View {
    let entry: ResonanceComplicationEntry

    var body: some View {
        ZStack {
            // Phase background ring
            Circle()
                .stroke(entry.phase.accentColor.opacity(0.2), lineWidth: 3)

            Circle()
                .trim(from: 0, to: CGFloat(entry.spaciousnessPercent) / 100)
                .stroke(entry.phase.accentColor, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .rotationEffect(.degrees(-90))

            VStack(spacing: 1) {
                Image(systemName: entry.phase.icon)
                    .font(.system(size: 14))
                    .foregroundStyle(entry.phase.accentColor)

                Text(String(entry.phase.rawValue.prefix(3)))
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(.primary)
            }
        }
    }
}

// MARK: - Rectangular Complication

struct RectangularComplicationView: View {
    let entry: ResonanceComplicationEntry

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: entry.phase.icon)
                .font(.system(size: 18))
                .foregroundStyle(entry.phase.accentColor)

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.phase.rawValue)
                    .font(.system(size: 13, weight: .medium))

                Text(entry.phase.timeRange)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Image(systemName: "wind")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
                Text("\(entry.spaciousnessPercent)%")
                    .font(.system(size: 11, weight: .medium))
            }
        }
    }
}

// MARK: - Corner Complication

struct CornerComplicationView: View {
    let entry: ResonanceComplicationEntry

    var body: some View {
        ZStack {
            Image(systemName: entry.phase.icon)
                .font(.system(size: 20))
                .foregroundStyle(entry.phase.accentColor)
        }
    }
}

// MARK: - Inline Complication

struct InlineComplicationView: View {
    let entry: ResonanceComplicationEntry

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: entry.phase.icon)
            Text(entry.phase.rawValue)
            Text("·")
            Image(systemName: "wind")
            Text("\(entry.spaciousnessPercent)%")
        }
        .font(.system(size: 12))
    }
}
#endif
