// AppState.swift
// Haute Lumière

import SwiftUI
import Combine

/// Central app state managing user context, theme, and navigation
final class AppState: ObservableObject {
    // MARK: - User Profile
    @Published var userName: String = ""
    @Published var userAvatar: Data?
    @Published var selectedCoach: CoachPersona = .avaAzure
    @Published var lifeWheel: LifeWheel = LifeWheel()

    // MARK: - Theme
    @Published var isNightMode: Bool = false
    @Published var nightModeTheme: NightModeTheme = .denseForest

    // MARK: - Navigation
    @Published var selectedTab: MainTab = .home
    @Published var showingCoachChat: Bool = false

    // MARK: - Session
    @Published var currentSessionId: UUID?
    @Published var isInActiveSession: Bool = false

    // MARK: - 5D Coaching Cycle (Hidden Progressive Framework)
    @Published var currentCyclePhase: FiveDPhase = .discover
    @Published var cycleProgress: Double = 0.0

    enum MainTab: Int, CaseIterable {
        case home = 0
        case practice
        case coach
        case journey
        case profile
    }

    enum NightModeTheme: String, CaseIterable {
        case denseForest = "Dense Forest"
        case starryCanopy = "Starry Canopy"
        case moonlitMeadow = "Moonlit Meadow"
        case deepWoods = "Deep Woods"
        case mistyGrove = "Misty Grove"

        var backgroundGradient: [Color] {
            switch self {
            case .denseForest: return [Color(hex: "0A1C14"), Color(hex: "122E21"), Color(hex: "0D2118")]
            case .starryCanopy: return [Color(hex: "0B0D1A"), Color(hex: "141833"), Color(hex: "0E1225")]
            case .moonlitMeadow: return [Color(hex: "0F1A15"), Color(hex: "1A2E24"), Color(hex: "142319")]
            case .deepWoods: return [Color(hex: "080E0B"), Color(hex: "0F1D15"), Color(hex: "0A150F")]
            case .mistyGrove: return [Color(hex: "101A16"), Color(hex: "1C3028"), Color(hex: "15261E")]
            }
        }
    }
}

// MARK: - 5D Coaching Cycle
/// The hidden progressive development framework that guides users
/// through transformation without their explicit awareness
enum FiveDPhase: Int, CaseIterable, Codable {
    case discover = 0     // Week 1-2: Understanding baseline
    case define = 1       // Week 3-4: Clarifying intentions
    case develop = 2      // Week 5-8: Building practices
    case deepen = 3       // Week 9-12: Intensifying commitment
    case deliver = 4      // Week 13+: Sustaining transformation

    var displayName: String {
        switch self {
        case .discover: return "Foundation"
        case .define: return "Clarity"
        case .develop: return "Growth"
        case .deepen: return "Mastery"
        case .deliver: return "Radiance"
        }
    }

    var coachingFocus: String {
        switch self {
        case .discover: return "Building awareness and establishing baseline habits"
        case .define: return "Setting meaningful intentions aligned with values"
        case .develop: return "Consistent practice development and skill building"
        case .deepen: return "Advanced techniques and deeper self-inquiry"
        case .deliver: return "Integration, leadership presence, and sustained transformation"
        }
    }
}
