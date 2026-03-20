// LuminousWatchApp.swift
// Luminous Cosmic Architecture™ — watchOS
// Compact astrology companion for Apple Watch

import SwiftUI

@main
struct LuminousWatchApp: App {
    @StateObject private var watchState = WatchState()

    var body: some Scene {
        WindowGroup {
            WatchRootView()
                .environmentObject(watchState)
        }
    }
}

// MARK: - Watch State

final class WatchState: ObservableObject {
    @Published var currentMoonPhase: WatchMoonPhase = .waxingCrescent
    @Published var sunSign: String = "Pisces"
    @Published var moonSign: String = "Scorpio"
    @Published var risingSign: String = "Leo"
    @Published var dailyInsight: String = "Growth spirals. You return to familiar places with deeper understanding."
    @Published var currentTransit: String = "Venus trine Jupiter"
    @Published var transitDescription: String = "Expanding love and abundance"

    var zodiacSeason: String { "\(sunSign) Season" }

    var seasonDateRange: String { "Feb 19 \u{2013} Mar 20" }
}

// MARK: - Moon Phase (Watch)

enum WatchMoonPhase: String, CaseIterable {
    case newMoon = "New Moon"
    case waxingCrescent = "Waxing Crescent"
    case firstQuarter = "First Quarter"
    case waxingGibbous = "Waxing Gibbous"
    case fullMoon = "Full Moon"
    case waningGibbous = "Waning Gibbous"
    case lastQuarter = "Last Quarter"
    case waningCrescent = "Waning Crescent"

    var illumination: Double {
        switch self {
        case .newMoon: return 0.0
        case .waxingCrescent: return 0.25
        case .firstQuarter: return 0.50
        case .waxingGibbous: return 0.75
        case .fullMoon: return 1.0
        case .waningGibbous: return 0.75
        case .lastQuarter: return 0.50
        case .waningCrescent: return 0.25
        }
    }

    var symbol: String {
        switch self {
        case .newMoon: return "\u{1F311}"
        case .waxingCrescent: return "\u{1F312}"
        case .firstQuarter: return "\u{1F313}"
        case .waxingGibbous: return "\u{1F314}"
        case .fullMoon: return "\u{1F315}"
        case .waningGibbous: return "\u{1F316}"
        case .lastQuarter: return "\u{1F317}"
        case .waningCrescent: return "\u{1F318}"
        }
    }
}

// MARK: - Root View

struct WatchRootView: View {
    @EnvironmentObject var watchState: WatchState

    var body: some View {
        TabView {
            WatchDashboardView()
            WatchMoonPhaseView()
            WatchDailyInsightView()
            WatchChartGlanceView()
            WatchMeditationView()
        }
        .tabViewStyle(.verticalPage)
    }
}
