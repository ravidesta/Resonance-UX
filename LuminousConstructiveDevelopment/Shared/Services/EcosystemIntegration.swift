// MARK: - Resonance-UX Ecosystem Integration Layer
// Connects Luminous Journey™ with all other Resonance-UX products:
//   • Daily Flow (task/rhythm management)
//   • Resonance Comms (Inner Circle messaging)
//   • Writer (prose sanctuary)
//   • iPAD Provider Module (coach/therapist integration)
//   • Watch (somatic tracking)

import Foundation

// MARK: - Integration Protocol

protocol ResonanceEcosystemIntegration {
    // ─── Daily Flow Integration ──────────────────────────────────
    /// Map somatic practices to Daily Flow rhythm phases
    func syncPracticeToPhase(practice: SomaticPractice, phase: DailyFlowPhase) async throws
    /// Import energy levels from Daily Flow for practice recommendations
    func fetchCurrentEnergyLevel() async throws -> EnergyLevel
    /// Add journal reminder to Daily Flow's Descent phase
    func scheduleReflectionReminder(time: DailyFlowPhase) async throws

    // ─── Resonance Comms Integration ─────────────────────────────
    /// Share a beautiful insight with Inner Circle contacts
    func shareToInnerCircle(content: ShareableContent, contactIds: [String]) async throws
    /// Update intentional status from LCD (e.g., "In practice", "Reflecting")
    func updateIntentionalStatus(_ status: CommunityMember.IntentionalStatus) async throws

    // ─── Writer Integration ──────────────────────────────────────
    /// Export journal entry to Writer sanctuary for deeper prose work
    func exportToWriter(entry: JournalEntry) async throws -> String // Returns Writer doc ID
    /// Import prose from Writer as journal content
    func importFromWriter(documentId: String) async throws -> String

    // ─── iPAD Provider Integration ───────────────────────────────
    /// Share developmental assessment with connected provider
    func shareAssessmentWithProvider(assessment: DevelopmentalAssessment) async throws
    /// Receive provider's observations into Guide context
    func fetchProviderObservations() async throws -> [String]
    /// Sync somatic tracking data with provider's Morning Triage
    func syncSomaticDataToProvider(data: SomaticTrackingData) async throws
    /// Connect coaching session through iPAD's Async Care channel
    func requestCoachSession(type: GuideSession.SessionType) async throws

    // ─── Watch Integration ───────────────────────────────────────
    /// Sync current somatic season to watch complications
    func syncSeasonToWatch(season: SomaticSeason) async throws
    /// Receive somatic check-in data from watch
    func fetchWatchSomaticData() async throws -> [WatchSomaticEntry]
    /// Push breathing entrainment pattern to watch
    func pushBreathingPattern(pattern: BreathPattern) async throws
    /// Sync audiobook position for watch mini-player
    func syncAudioPositionToWatch(position: Audiobook.AudioPosition) async throws
}

// MARK: - Supporting Types

enum DailyFlowPhase: String, Codable {
    case ascend     = "Ascend"      // Morning — high energy practices
    case zenith     = "Zenith"      // Midday — check-ins, reflections
    case descent    = "Descent"     // Evening — journaling, wind-down practices
    case rest       = "Rest"        // Night — contemplative, sleep practices
}

enum EnergyLevel: String, Codable {
    case high       = "High"        // Deep work, intensive practices
    case balanced   = "Balanced"    // Flow state, moderate practices
    case low        = "Low"         // Gentle, restorative practices
    case restorative = "Restorative" // Rest-focused, minimal demand
}

struct SomaticTrackingData: Codable {
    var timestamp: Date
    var season: SomaticSeason
    var bodyLocations: [JournalEntry.BodyLocation]
    var heartRate: Double?
    var hrvScore: Double?
    var breathRate: Double?
    var sleepQuality: Double?        // 0.0 - 1.0
}

struct WatchSomaticEntry: Codable {
    var timestamp: Date
    var bodyArea: String
    var sensation: String
    var intensity: Double
    var heartRate: Double?
}

struct BreathPattern: Codable {
    var name: String
    var inhaleSeconds: Double
    var holdSeconds: Double
    var exhaleSeconds: Double
    var restSeconds: Double
    var cycles: Int
}

// MARK: - Implementation

final class ResonanceEcosystemService: ResonanceEcosystemIntegration {

    private let baseURL: String
    private let authToken: String

    init(baseURL: String = "https://api.resonance.ux", authToken: String) {
        self.baseURL = baseURL
        self.authToken = authToken
    }

    // ─── Daily Flow ──────────────────────────────────────────────

    func syncPracticeToPhase(practice: SomaticPractice, phase: DailyFlowPhase) async throws {
        // POST /daily-flow/practices
        // Maps practice to the appropriate phase:
        //   Ascend  → energizing breathwork, body activation
        //   Zenith  → midday somatic check-in, grounding
        //   Descent → body scan, journaling prompt, reflection
        //   Rest    → contemplative sit, sleep breathing
        let mapping: [String: Any] = [
            "practiceId": practice.id.uuidString,
            "phase": phase.rawValue,
            "duration": practice.duration,
            "energyLevel": energyForPhase(phase).rawValue,
        ]
        try await post(endpoint: "/daily-flow/practices", body: mapping)
    }

    func fetchCurrentEnergyLevel() async throws -> EnergyLevel {
        // GET /daily-flow/current-energy
        let data = try await get(endpoint: "/daily-flow/current-energy")
        let level = (data["energyLevel"] as? String).flatMap { EnergyLevel(rawValue: $0) }
        return level ?? .balanced
    }

    func scheduleReflectionReminder(time: DailyFlowPhase) async throws {
        try await post(endpoint: "/daily-flow/reminders", body: [
            "type": "reflection",
            "phase": time.rawValue,
            "message": "Time for your evening reflection. What did your body hold today?",
        ])
    }

    // ─── Resonance Comms ─────────────────────────────────────────

    func shareToInnerCircle(content: ShareableContent, contactIds: [String]) async throws {
        // Uses Resonance Comms API to share beautiful content cards
        try await post(endpoint: "/resonance/share", body: [
            "contentId": content.id.uuidString,
            "type": content.type.rawValue,
            "excerpt": content.excerpt,
            "recipients": contactIds,
            "style": content.backgroundStyle.rawValue,
        ])
    }

    func updateIntentionalStatus(_ status: CommunityMember.IntentionalStatus) async throws {
        // Updates the user's intentional status across Resonance apps
        // "In practice" / "Reflecting" / "Deep work" etc.
        try await post(endpoint: "/resonance/status", body: [
            "status": status.rawValue,
            "source": "luminous-journey",
        ])
    }

    // ─── Writer ──────────────────────────────────────────────────

    func exportToWriter(entry: JournalEntry) async throws -> String {
        // Creates a new document in Writer sanctuary
        let response = try await post(endpoint: "/writer/documents", body: [
            "title": "Reflection: \(entry.type.rawValue)",
            "content": entry.content,
            "somaticNotes": entry.somaticNotes ?? "",
            "source": "luminous-journey",
        ])
        return response["documentId"] as? String ?? ""
    }

    func importFromWriter(documentId: String) async throws -> String {
        let data = try await get(endpoint: "/writer/documents/\(documentId)")
        return data["content"] as? String ?? ""
    }

    // ─── iPAD Provider ───────────────────────────────────────────

    func shareAssessmentWithProvider(assessment: DevelopmentalAssessment) async throws {
        // Shares to the provider's Encounter Holarchy for review
        try await post(endpoint: "/provider/assessments", body: [
            "assessmentId": assessment.id.uuidString,
            "domains": assessment.domainAssessments.map { domain in
                [
                    "domain": domain.domain.rawValue,
                    "primaryOrder": domain.primaryOrder.rawValue,
                    "growingEdge": domain.growingEdge ?? "",
                ]
            },
            "season": assessment.somaticSeason?.rawValue ?? "",
            "reflection": assessment.overallReflection ?? "",
        ])
    }

    func fetchProviderObservations() async throws -> [String] {
        let data = try await get(endpoint: "/provider/observations")
        return data["observations"] as? [String] ?? []
    }

    func syncSomaticDataToProvider(data: SomaticTrackingData) async throws {
        // Feeds into provider's Morning Triage biometric panel
        try await post(endpoint: "/provider/somatic-data", body: [
            "season": data.season.rawValue,
            "heartRate": data.heartRate ?? 0,
            "hrv": data.hrvScore ?? 0,
            "breathRate": data.breathRate ?? 0,
            "sleepQuality": data.sleepQuality ?? 0,
        ])
    }

    func requestCoachSession(type: GuideSession.SessionType) async throws {
        try await post(endpoint: "/provider/session-request", body: [
            "type": type.rawValue,
            "source": "luminous-journey",
        ])
    }

    // ─── Watch ───────────────────────────────────────────────────

    func syncSeasonToWatch(season: SomaticSeason) async throws {
        // Updates watch complications
        try await post(endpoint: "/watch/season", body: [
            "season": season.rawValue,
        ])
    }

    func fetchWatchSomaticData() async throws -> [WatchSomaticEntry] {
        let data = try await get(endpoint: "/watch/somatic-entries")
        // Parse entries
        return []
    }

    func pushBreathingPattern(pattern: BreathPattern) async throws {
        try await post(endpoint: "/watch/breathing", body: [
            "name": pattern.name,
            "inhale": pattern.inhaleSeconds,
            "hold": pattern.holdSeconds,
            "exhale": pattern.exhaleSeconds,
            "rest": pattern.restSeconds,
            "cycles": pattern.cycles,
        ])
    }

    func syncAudioPositionToWatch(position: Audiobook.AudioPosition) async throws {
        try await post(endpoint: "/watch/audio-position", body: [
            "chapter": position.chapterIndex,
            "offset": position.timeOffset,
        ])
    }

    // ─── Private Helpers ─────────────────────────────────────────

    private func energyForPhase(_ phase: DailyFlowPhase) -> EnergyLevel {
        switch phase {
        case .ascend:  return .high
        case .zenith:  return .balanced
        case .descent: return .low
        case .rest:    return .restorative
        }
    }

    private func post(endpoint: String, body: [String: Any]) async throws {
        var request = URLRequest(url: URL(string: baseURL + endpoint)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode < 300 else {
            throw EcosystemError.requestFailed
        }
    }

    @discardableResult
    private func get(endpoint: String) async throws -> [String: Any] {
        var request = URLRequest(url: URL(string: baseURL + endpoint)!)
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        let (data, _) = try await URLSession.shared.data(for: request)
        return (try? JSONSerialization.jsonObject(with: data)) as? [String: Any] ?? [:]
    }

    enum EcosystemError: Error {
        case requestFailed
        case invalidResponse
    }
}
