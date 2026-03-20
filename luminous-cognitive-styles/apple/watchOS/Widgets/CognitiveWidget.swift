// CognitiveWidget.swift
// Luminous Cognitive Styles™ — watchOS
// Widget showing today's cognitive focus and small radar chart

import SwiftUI
import WidgetKit

// MARK: - Widget Timeline Provider

struct CognitiveWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> CognitiveWidgetEntry {
        CognitiveWidgetEntry.placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (CognitiveWidgetEntry) -> Void) {
        completion(CognitiveWidgetEntry.placeholder)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CognitiveWidgetEntry>) -> Void) {
        let entry = loadCurrentEntry()
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 4, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func loadCurrentEntry() -> CognitiveWidgetEntry {
        let decoder = JSONDecoder()
        if let data = UserDefaults.standard.data(forKey: "lcs_current_profile"),
           let profile = try? decoder.decode(CognitiveProfile.self, from: data) {
            let topDim = profile.developmentalEdges.first ?? .perceptualMode
            return CognitiveWidgetEntry(
                date: Date(),
                hasProfile: true,
                profileTypeName: profile.profileTypeName,
                focusDimension: todaysFocusDimension(),
                scores: profile.scores
            )
        }
        return CognitiveWidgetEntry.placeholder
    }

    private func todaysFocusDimension() -> CognitiveDimension {
        let day = Calendar.current.component(.day, from: Date())
        let index = day % CognitiveDimension.allCases.count
        return CognitiveDimension.allCases[index]
    }
}

// MARK: - Widget Entry

struct CognitiveWidgetEntry: TimelineEntry {
    let date: Date
    let hasProfile: Bool
    let profileTypeName: String
    let focusDimension: CognitiveDimension
    let scores: [CognitiveDimension: Double]

    static var placeholder: CognitiveWidgetEntry {
        CognitiveWidgetEntry(
            date: Date(),
            hasProfile: true,
            profileTypeName: "The Visionary",
            focusDimension: .perceptualMode,
            scores: Dictionary(
                uniqueKeysWithValues: CognitiveDimension.allCases.map { ($0, Double.random(in: 3...8)) }
            )
        )
    }
}

// MARK: - Widget View

struct CognitiveWidgetView: View {
    let entry: CognitiveWidgetEntry

    var body: some View {
        if entry.hasProfile {
            profileWidget
        } else {
            noProfileWidget
        }
    }

    private var profileWidget: some View {
        VStack(spacing: 4) {
            // Mini radar
            ZStack {
                let scores = CognitiveDimension.allCases.map {
                    CGFloat((entry.scores[$0] ?? 5.0) / 10.0)
                }

                RadarPolygon(sides: 7, scale: 1.0)
                    .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                    .frame(width: 44, height: 44)

                RadarDataPolygon(values: scores, animationProgress: 1.0)
                    .fill(
                        AngularGradient(
                            colors: CognitiveDimension.allCases.map { $0.color.opacity(0.35) }
                                + [CognitiveDimension.allCases.first!.color.opacity(0.35)],
                            center: .center
                        )
                    )
                    .frame(width: 44, height: 44)

                RadarDataPolygon(values: scores, animationProgress: 1.0)
                    .stroke(
                        AngularGradient(
                            colors: CognitiveDimension.allCases.map { $0.color }
                                + [CognitiveDimension.allCases.first!.color],
                            center: .center
                        ),
                        lineWidth: 1.5
                    )
                    .frame(width: 44, height: 44)
            }

            // Today's focus
            Text("Today: \(entry.focusDimension.shortName)")
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(entry.focusDimension.color)

            // Focus dimension score
            let focusScore = entry.scores[entry.focusDimension] ?? 5.0
            HStack(spacing: 2) {
                Text(ScoreFormatter.formatted(focusScore))
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                Text(ScoreFormatter.poleLabel(dimension: entry.focusDimension, score: focusScore))
                    .font(.system(size: 8))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .containerBackground(LCSTheme.deepNavy.gradient, for: .widget)
    }

    private var noProfileWidget: some View {
        VStack(spacing: 4) {
            Image(systemName: "sparkles")
                .font(.system(size: 20))
                .foregroundColor(LCSTheme.goldAccent)

            Text("LCS")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.white)

            Text("Take Assessment")
                .font(.system(size: 9))
                .foregroundColor(.white.opacity(0.6))
        }
        .containerBackground(LCSTheme.deepNavy.gradient, for: .widget)
    }
}

// MARK: - Widget Configuration

struct CognitiveStyleWidget: Widget {
    let kind: String = "CognitiveStyleWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CognitiveWidgetProvider()) { entry in
            CognitiveWidgetView(entry: entry)
        }
        .configurationDisplayName("Cognitive Focus")
        .description("Today's cognitive dimension focus and your profile at a glance.")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}
