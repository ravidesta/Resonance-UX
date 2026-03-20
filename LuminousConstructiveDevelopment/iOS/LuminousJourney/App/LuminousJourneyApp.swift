// MARK: - Luminous Journey™ — iOS/iPadOS App Entry Point
// Part of the Resonance-UX ecosystem
// Native SwiftUI • Universal (iPhone + iPad + Mac Catalyst)

import SwiftUI

@main
struct LuminousJourneyApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var guideService = GuideServiceManager()
    @StateObject private var audiobookPlayer = AudiobookPlayerManager()
    @StateObject private var ecosystemBridge = ResonanceEcosystemBridge()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(themeManager)
                .environmentObject(guideService)
                .environmentObject(audiobookPlayer)
                .environmentObject(ecosystemBridge)
                .preferredColorScheme(themeManager.isDeepRest ? .dark : nil)
                .onAppear {
                    ecosystemBridge.syncWithResonance()
                }
        }
    }
}

// MARK: - App State

final class AppState: ObservableObject {
    @Published var currentTab: AppTab = .home
    @Published var user: UserProfile?
    @Published var currentAssessment: DevelopmentalAssessment?
    @Published var isOnboarded: Bool = false

    enum AppTab: String, CaseIterable {
        case home       = "Home"
        case learn      = "Learn"          // eBook + Chapters
        case listen     = "Listen"         // Audiobook
        case practice   = "Practice"       // Somatic Practices
        case journal    = "Journal"        // Reflection Journal
        case guide      = "Guide"          // AI Tutor/Coach
        case community  = "Community"      // Peer groups
    }
}

struct UserProfile: Codable {
    var id: String
    var displayName: String
    var currentSeason: SomaticSeason?
    var primaryOrder: DevelopmentalOrder?
    var readingPosition: EBook.ReadingPosition?
    var audioPosition: Audiobook.AudioPosition?
    var practiceStreak: Int
    var resonanceIntegration: ResonanceIntegration
}

// MARK: - Theme Manager (Resonance-UX Design System)

final class ThemeManager: ObservableObject {
    @Published var isDeepRest: Bool = false

    // Forest palette
    let forestDeepest   = Color(hex: "0A1C14")
    let forestDeep      = Color(hex: "122E21")
    let forestBase      = Color(hex: "1B402E")
    let forestMuted     = Color(hex: "2A5A42")

    // Gold palette
    let goldPrimary     = Color(hex: "C5A059")
    let goldMuted       = Color(hex: "9A7A3A")
    let goldLight       = Color(hex: "D4B878")

    // Earth palette
    let cream           = Color(hex: "FAFAF8")
    let warmEarth       = Color(hex: "F5F0E8")
    let sand            = Color(hex: "E8DFD0")

    // Semantic
    let textPrimary     = Color(hex: "1B402E")
    let textSecondary   = Color(hex: "8A9C91")
    let textMuted       = Color(hex: "A8B5AD")

    // Developmental order colors
    let orderColors: [DevelopmentalOrder: Color] = [
        .impulsive:        Color(hex: "E8A87C"),
        .imperial:         Color(hex: "D4956B"),
        .socialized:       Color(hex: "5A8AB0"),
        .selfAuthoring:    Color(hex: "4A9A6A"),
        .selfTransforming: Color(hex: "8B6BB0"),
    ]

    // Somatic season colors
    let seasonColors: [SomaticSeason: Color] = [
        .compression: Color(hex: "8A5A4A"),
        .trembling:   Color(hex: "B07A5A"),
        .emptiness:   Color(hex: "A8B5AD"),
        .emergence:   Color(hex: "4A9A6A"),
        .integration: Color(hex: "C5A059"),
    ]

    var background: Color { isDeepRest ? forestDeepest : cream }
    var surface: Color { isDeepRest ? forestDeep : .white }
    var text: Color { isDeepRest ? Color(hex: "C8D4CC") : textPrimary }
    var accent: Color { isDeepRest ? goldMuted : goldPrimary }
}

// MARK: - Guide Service Manager

final class GuideServiceManager: ObservableObject {
    @Published var currentSession: GuideSession?
    @Published var isTyping: Bool = false

    private lazy var guide: ClaudeLuminousGuide = {
        ClaudeLuminousGuide(
            apiEndpoint: "https://api.anthropic.com",
            apiKey: ProcessInfo.processInfo.environment["ANTHROPIC_API_KEY"] ?? "",
            model: "claude-sonnet-4-5-20250514"
        )
    }()

    func startSession(type: GuideSession.SessionType) async {
        do {
            currentSession = try await guide.startSession(type: type, context: nil)
        } catch {
            print("Failed to start guide session: \(error)")
        }
    }

    func send(_ message: String) async -> GuideSession.GuideMessage? {
        guard let session = currentSession else { return nil }
        await MainActor.run { isTyping = true }
        defer { Task { @MainActor in isTyping = false } }

        do {
            let response = try await guide.sendMessage(message, in: session)
            await MainActor.run {
                currentSession?.messages.append(
                    GuideSession.GuideMessage(id: UUID(), role: .user, content: message, timestamp: Date())
                )
                currentSession?.messages.append(response)
            }
            return response
        } catch {
            print("Guide error: \(error)")
            return nil
        }
    }
}

// MARK: - Audiobook Player Manager

final class AudiobookPlayerManager: ObservableObject {
    @Published var isPlaying: Bool = false
    @Published var currentChapter: Int = 0
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var playbackSpeed: Double = 1.0
    @Published var sleepTimerRemaining: TimeInterval?

    func play() { isPlaying = true }
    func pause() { isPlaying = false }
    func skipForward(_ seconds: TimeInterval = 30) { currentTime += seconds }
    func skipBackward(_ seconds: TimeInterval = 15) { currentTime -= seconds }
    func setSpeed(_ speed: Double) { playbackSpeed = speed }
    func setSleepTimer(minutes: Int) { sleepTimerRemaining = TimeInterval(minutes * 60) }
}

// MARK: - Resonance Ecosystem Bridge

final class ResonanceEcosystemBridge: ObservableObject {
    @Published var isDailyFlowConnected: Bool = false
    @Published var isResonanceCommsConnected: Bool = false
    @Published var isWriterConnected: Bool = false
    @Published var isProviderConnected: Bool = false

    func syncWithResonance() {
        // Sync practices with Daily Flow phases
        // Sync community with Resonance comms
        // Export reflections to Writer
        // Connect with provider through iPAD module
    }

    func sendToDailyFlow(practice: SomaticPractice, phase: String) {
        // Map practice to Daily Flow rhythm phase
    }

    func exportToWriter(entry: JournalEntry) {
        // Send journal entry to Writer sanctuary
    }

    func notifyProvider(assessment: DevelopmentalAssessment) {
        // Share assessment with connected coach/therapist through iPAD
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
