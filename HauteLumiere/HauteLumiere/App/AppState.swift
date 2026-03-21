// AppState.swift
// Haute Lumière

import SwiftUI
import Combine

/// Central app state managing user context, theme, navigation, and style preferences
final class AppState: ObservableObject {
    // MARK: - User Profile
    @Published var userName: String = ""
    @Published var userAvatar: Data?
    @Published var selectedCoach: CoachPersona = .avaAzure
    @Published var lifeWheel: LifeWheel = LifeWheel()

    // MARK: - Style Preferences (Swappable)
    @Published var selectedFontPairing: HLFontPairing = .classicGrace {
        didSet { HLTypography.currentPairing = selectedFontPairing }
    }
    @Published var selectedColorPalette: HLColorPalette = .forestSanctuary

    // MARK: - Theme
    @Published var isNightMode: Bool = false
    @Published var nightModeTheme: NightModeTheme = .denseForest

    // MARK: - Navigation
    @Published var selectedTab: MainTab = .home
    @Published var showingCoachChat: Bool = false

    // MARK: - Session
    @Published var currentSessionId: UUID?
    @Published var isInActiveSession: Bool = false

    // MARK: - Living Systems Assessment (Hidden — derived from intake + coach)
    /// The coach intake secretly maps the user across all Living Systems levels.
    /// This drives content selection, coaching depth, and cycle pacing.
    @Published var livingSystemsProfile: LivingSystemsProfile = LivingSystemsProfile()

    // MARK: - Team Life Force Cycle (formerly 5D — Hidden Progressive Framework)
    /// "Secret Agent for Team Life Force" — the invisible engine that
    /// guides users through transformation. The user never sees this.
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

// MARK: - Living Systems Theory Profile
/// Miller's Living Systems Theory applied to personal development.
/// Each level represents a dimension of the human system that the coach
/// assesses through intake + ongoing conversation — never shown to the user.
struct LivingSystemsProfile: Codable {
    // Level 1: Cell — Biological vitality, nutrition, physical health
    var cellularVitality: Double = 5.0

    // Level 2: Organ — Emotional regulation, stress response
    var emotionalRegulation: Double = 5.0

    // Level 3: Organism — Whole-person integration, mind-body coherence
    var mindBodyCoherence: Double = 5.0

    // Level 4: Group — Close relationships, family, inner circle
    var relationalHarmony: Double = 5.0

    // Level 5: Organization — Career, purpose, professional contribution
    var purposeAlignment: Double = 5.0

    // Level 6: Community — Social belonging, tribe, shared meaning
    var communityBelonging: Double = 5.0

    // Level 7: Society — Cultural engagement, leadership, influence
    var societalPresence: Double = 5.0

    // Level 8: Supranational — Transcendence, spiritual connection, legacy
    var transcendenceDepth: Double = 5.0

    var levels: [(name: String, metaphor: String, score: Double)] {
        [
            ("Vitality", "The fire in your cells", cellularVitality),
            ("Emotional Flow", "The river of feeling", emotionalRegulation),
            ("Coherence", "Mind and body as one instrument", mindBodyCoherence),
            ("Relational Harmony", "The garden of connection", relationalHarmony),
            ("Purpose", "Your north star", purposeAlignment),
            ("Belonging", "The tribe that sees you", communityBelonging),
            ("Presence", "Your ripple in the world", societalPresence),
            ("Transcendence", "The light beyond the self", transcendenceDepth),
        ]
    }

    /// Which Living Systems level needs the most attention
    var primaryGrowthEdge: String {
        levels.min(by: { $0.score < $1.score })?.name ?? "Coherence"
    }

    /// Overall system health (0-10)
    var systemVitality: Double {
        levels.map(\.score).reduce(0, +) / Double(levels.count)
    }
}

// MARK: - Team Life Force Cycle (Secret Agent Framework)
/// The hidden progressive development framework that guides users
/// through transformation without their explicit awareness.
/// Internally known as "Secret Agent for Team Life Force."
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

    /// Secret Agent directive — what Team Life Force is doing behind the scenes
    var lifeForceDirective: String {
        switch self {
        case .discover: return "Mapping the terrain — assessing all Living Systems levels through natural conversation"
        case .define: return "Identifying leverage points — where small shifts create system-wide awakening"
        case .develop: return "Building coherence — strengthening weakest Living Systems levels through targeted practices"
        case .deepen: return "Integration cascade — upper-level systems (community, purpose) begin activating"
        case .deliver: return "Self-sustaining vitality — the system maintains its own growth momentum"
        }
    }

    /// Which Living Systems levels this phase primarily targets
    var targetLivingSystems: [String] {
        switch self {
        case .discover: return ["Vitality", "Emotional Flow", "Coherence"]
        case .define: return ["Purpose", "Coherence", "Relational Harmony"]
        case .develop: return ["Emotional Flow", "Coherence", "Purpose"]
        case .deepen: return ["Relational Harmony", "Belonging", "Presence"]
        case .deliver: return ["Presence", "Transcendence", "Belonging"]
        }
    }
}
