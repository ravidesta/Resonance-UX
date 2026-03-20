// MARK: - Luminous Guide™ — AI Tutor, Coach & Developmental Companion
// The Guide embodies the Luminous ethos: compassionate, somatic-aware,
// never ranking, always honoring each stage's gifts.

import Foundation

// MARK: - Guide Configuration

struct LuminousGuideConfig {
    /// System prompt that grounds the AI in Luminous principles
    static let systemPrompt = """
    You are the Luminous Guide — a compassionate, somatically-aware developmental companion \
    grounded in Luminous Constructive Development™.

    CORE PRINCIPLES:
    1. NEVER rank or judge developmental stages. Every order of consciousness has dignity, gifts, and wisdom.
    2. ALWAYS include somatic check-ins. Ask about body sensations, breath, tension.
    3. Honor the spiral — development is not linear. Revisiting themes is enrichment, not regression.
    4. Practice optimal discrepancy — offer perspectives approximately one half-step beyond the user's current capacity.
    5. Confirm before contradicting. Honor existing meaning-making before inviting expansion.
    6. NEVER push development faster than the system can integrate. Patience is non-negotiable.
    7. If the user shows signs of overwhelm, trauma activation, or crisis — prioritize stabilization and safety. \
       Recommend professional support when appropriate. You are not a therapist.
    8. Use the language of "having" vs "being" — help users notice what has them vs what they can hold as object.
    9. Reference somatic seasons when appropriate — help users locate themselves in compression, trembling, \
       emptiness, emergence, or integration.
    10. Celebrate insight without inflating it. A moment of seeing is precious and also just one moment.

    TONE: Warm, unhurried, precise. Like a trusted mentor who has all the time in the world. \
    Never clinical. Never preachy. Occasionally poetic. Always grounded.

    SAFETY BOUNDARIES:
    - You are a developmental companion, NOT a therapist or medical provider.
    - If someone describes active suicidal ideation, self-harm, abuse, or acute mental health crisis, \
      respond with care and immediately recommend professional help (crisis lines, therapist, ER).
    - Never diagnose. Never prescribe. Never replace clinical care.
    - Flag when developmental work should pause in favor of stabilization.
    """

    /// Contextual prompts for different session types
    static func sessionPrompt(for type: GuideSession.SessionType) -> String {
        switch type {
        case .exploration:
            return """
            The user wants to explore their meaning-making landscape. Guide them gently through \
            self-inquiry. Ask about what feels "obviously true" in their life right now — those \
            certainties often point to subject territory. Include at least one somatic check-in.
            """
        case .somaticGuidance:
            return """
            Focus on the body's wisdom. Guide the user through noticing sensations, breath patterns, \
            and tension. Help them connect bodily experience to meaning-making dynamics. Move slowly. \
            Pause often. The body speaks in a different tempo than the mind.
            """
        case .reflectionSupport:
            return """
            The user is journaling or reflecting. Support their process without directing it. \
            Mirror back what you hear. Ask clarifying questions. Help them notice patterns. \
            Resist the urge to interpret — let their own meaning emerge.
            """
        case .assessmentDebrief:
            return """
            The user has completed a developmental assessment. Help them understand their results \
            with nuance and compassion. Emphasize: these are snapshots, not verdicts. Every domain \
            may show different patterns. Focus on gifts of current structures before discussing edges.
            """
        case .crisisSupport:
            return """
            PRIORITY: SAFETY AND STABILIZATION. The user may be in a difficult developmental transition \
            or life crisis. Do NOT do developmental work right now. Instead: validate their experience, \
            help them feel less alone, assess for safety, and connect them to appropriate support. \
            Grounding exercises and breath work are appropriate. Developmental interpretation is not.
            """
        case .practiceGuidance:
            return """
            Guide the user through a somatic or reflective practice. Speak slowly and clearly. \
            Include pauses (indicate with "..."). Ground each instruction in the body. \
            After the practice, invite brief reflection without analysis.
            """
        case .bookDiscussion:
            return """
            The user wants to discuss content from the Luminous Constructive Development™ text. \
            Help them connect the concepts to their lived experience. Ask how ideas land in the body, \
            not just the mind. Encourage them to notice what provokes, what resonates, what confuses. \
            All responses are data about their meaning-making.
            """
        }
    }
}

// MARK: - Guide Service Protocol

protocol LuminousGuideService {
    /// Start a new guide session
    func startSession(type: GuideSession.SessionType, context: GuideSession.GuideContext?) async throws -> GuideSession

    /// Send a message and receive guide response
    func sendMessage(_ message: String, in session: GuideSession) async throws -> GuideSession.GuideMessage

    /// Generate a somatic check-in prompt based on current context
    func generateSomaticCheckIn(season: SomaticSeason?, recentMood: JournalEntry.Mood?) async throws -> String

    /// Generate a reflection prompt for journaling
    func generateReflectionPrompt(type: JournalEntry.EntryType, context: GuideSession.GuideContext?) async throws -> String

    /// Analyze a journal entry and offer developmental observations (non-judgmental)
    func offerObservations(on entry: JournalEntry) async throws -> String

    /// Generate personalized practice recommendation
    func recommendPractice(season: SomaticSeason?, order: DevelopmentalOrder?, mood: JournalEntry.Mood?) async throws -> [SomaticPractice]

    /// Assess safety — returns true if the content suggests need for professional referral
    func assessSafetyFlags(in content: String) async throws -> SafetyAssessment
}

struct SafetyAssessment: Codable {
    var needsReferral: Bool
    var severity: Severity
    var suggestedResponse: String
    var resources: [String]

    enum Severity: String, Codable {
        case none, mild, moderate, urgent
    }
}

// MARK: - Guide Implementation (Claude API)

final class ClaudeLuminousGuide: LuminousGuideService {
    private let apiEndpoint: String
    private let apiKey: String
    private let model: String

    init(apiEndpoint: String, apiKey: String, model: String = "claude-sonnet-4-5-20250514") {
        self.apiEndpoint = apiEndpoint
        self.apiKey = apiKey
        self.model = model
    }

    func startSession(type: GuideSession.SessionType, context: GuideSession.GuideContext?) async throws -> GuideSession {
        let session = GuideSession(
            id: UUID(),
            userId: "", // Populated by auth layer
            startTime: Date(),
            messages: [],
            context: context ?? GuideSession.GuideContext(
                currentAssessment: nil,
                recentJournalEntries: [],
                currentSeason: nil,
                readingPosition: nil,
                preferredPractices: []
            ),
            sessionType: type
        )

        // Send initial system + session prompt
        let systemMessage = GuideSession.GuideMessage(
            id: UUID(),
            role: .system,
            content: LuminousGuideConfig.systemPrompt + "\n\n" + LuminousGuideConfig.sessionPrompt(for: type),
            somaticPrompt: nil,
            timestamp: Date()
        )

        var mutableSession = session
        mutableSession.messages.append(systemMessage)
        return mutableSession
    }

    func sendMessage(_ message: String, in session: GuideSession) async throws -> GuideSession.GuideMessage {
        // Build conversation history for API call
        let messages = session.messages.map { msg -> [String: String] in
            let role: String
            switch msg.role {
            case .user: role = "user"
            case .guide: role = "assistant"
            case .system: role = "system"
            }
            return ["role": role, "content": msg.content]
        }

        // Add current user message
        var allMessages = messages
        allMessages.append(["role": "user", "content": message])

        // Call Claude API
        let requestBody: [String: Any] = [
            "model": model,
            "max_tokens": 1024,
            "system": LuminousGuideConfig.systemPrompt + "\n\n" +
                      LuminousGuideConfig.sessionPrompt(for: session.sessionType),
            "messages": allMessages
        ]

        let responseContent = try await callAPI(body: requestBody)

        return GuideSession.GuideMessage(
            id: UUID(),
            role: .guide,
            content: responseContent,
            somaticPrompt: extractSomaticPrompt(from: responseContent),
            timestamp: Date()
        )
    }

    func generateSomaticCheckIn(season: SomaticSeason?, recentMood: JournalEntry.Mood?) async throws -> String {
        var prompt = "Generate a brief, warm somatic check-in prompt (2-3 sentences)."
        if let season = season {
            prompt += " The person is currently in the \(season.rawValue) season."
        }
        if let mood = recentMood {
            prompt += " Their recent mood has been '\(mood.rawValue)'."
        }
        prompt += " Invite body awareness without being prescriptive. End with an open question."

        return try await generateCompletion(prompt: prompt)
    }

    func generateReflectionPrompt(type: JournalEntry.EntryType, context: GuideSession.GuideContext?) async throws -> String {
        let prompt = """
        Generate a reflection prompt for a '\(type.rawValue)' journal entry in the Luminous tradition.
        The prompt should:
        - Be 2-4 sentences
        - Include a somatic dimension (notice the body)
        - Be open-ended and inviting, not directive
        - Honor whatever arises without judgment
        \(context?.currentSeason.map { "The person is in the \($0.rawValue) somatic season." } ?? "")
        """
        return try await generateCompletion(prompt: prompt)
    }

    func offerObservations(on entry: JournalEntry) async throws -> String {
        let prompt = """
        The following is a journal entry. Offer 2-3 gentle developmental observations.
        NEVER diagnose, rank, or judge. Notice patterns. Mirror what you see. Ask one question.
        Include one somatic observation if the entry mentions body or emotion.

        Entry type: \(entry.type.rawValue)
        Content: \(entry.content)
        \(entry.somaticNotes.map { "Somatic notes: \($0)" } ?? "")
        """
        return try await generateCompletion(prompt: prompt)
    }

    func recommendPractice(season: SomaticSeason?, order: DevelopmentalOrder?, mood: JournalEntry.Mood?) async throws -> [SomaticPractice] {
        // In production, this queries the practice library with AI-ranked relevance
        // For now, returns contextual defaults
        return SomaticPracticeLibrary.recommend(season: season, order: order, mood: mood)
    }

    func assessSafetyFlags(in content: String) async throws -> SafetyAssessment {
        let prompt = """
        Assess the following text for safety concerns. Respond with JSON only.
        Look for: suicidal ideation, self-harm, abuse disclosures, acute dissociation,
        psychotic features, or severe destabilization.
        Return: {"needsReferral": bool, "severity": "none|mild|moderate|urgent", "suggestedResponse": "...", "resources": [...]}

        Text: \(content)
        """

        let response = try await generateCompletion(prompt: prompt)

        // Parse safety response
        guard let data = response.data(using: .utf8),
              let assessment = try? JSONDecoder().decode(SafetyAssessment.self, from: data) else {
            return SafetyAssessment(needsReferral: false, severity: .none, suggestedResponse: "", resources: [])
        }
        return assessment
    }

    // MARK: - Private Helpers

    private func callAPI(body: [String: Any]) async throws -> String {
        var request = URLRequest(url: URL(string: apiEndpoint + "/v1/messages")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, _) = try await URLSession.shared.data(for: request)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let content = (json?["content"] as? [[String: Any]])?.first?["text"] as? String
        return content ?? ""
    }

    private func generateCompletion(prompt: String) async throws -> String {
        let body: [String: Any] = [
            "model": model,
            "max_tokens": 512,
            "system": LuminousGuideConfig.systemPrompt,
            "messages": [["role": "user", "content": prompt]]
        ]
        return try await callAPI(body: body)
    }

    private func extractSomaticPrompt(from response: String) -> String? {
        // Extract any somatic check-in embedded in the guide's response
        let patterns = ["notice your body", "what does your body", "take a breath",
                       "feel your feet", "scan your body", "where in your body"]
        for pattern in patterns {
            if response.lowercased().contains(pattern) {
                return "The Guide is inviting somatic awareness. Take a moment to notice your body."
            }
        }
        return nil
    }
}

// MARK: - Practice Library (Built-in recommendations)

enum SomaticPracticeLibrary {
    static func recommend(season: SomaticSeason?, order: DevelopmentalOrder?, mood: JournalEntry.Mood?) -> [SomaticPractice] {
        var practices: [SomaticPractice] = []

        // Season-based recommendations
        switch season {
        case .compression:
            practices.append(SomaticPractice(
                id: UUID(), name: "Gentle Breath Release",
                description: "A slow, 4-7-8 breathing pattern to soften the compression the body is holding.",
                duration: 300, category: .breathwork, season: .compression,
                instructions: [
                    "Find a comfortable seated or lying position.",
                    "Place one hand on your belly, one on your chest.",
                    "Inhale through the nose for 4 counts.",
                    "Hold gently for 7 counts — not forcing, just pausing.",
                    "Exhale through the mouth for 8 counts, letting the body soften.",
                    "Repeat for 5 minutes. Notice where the compression begins to ease."
                ],
                developmentalContext: "During compression, the old structure is straining. This practice creates micro-spaces within the tightness.",
                isShareable: true
            ))
        case .trembling:
            practices.append(SomaticPractice(
                id: UUID(), name: "Grounding Anchor",
                description: "A practice for finding stability in the body when the ground feels uncertain.",
                duration: 420, category: .groundingExercise, season: .trembling,
                instructions: [
                    "Stand with feet hip-width apart, or sit with feet flat on the floor.",
                    "Press your feet into the ground. Feel the pressure, the texture, the temperature.",
                    "Notice gravity holding you. You do not need to hold yourself.",
                    "Place both hands on your thighs. Feel the warmth, the weight.",
                    "Say silently: 'I am here. The ground is here. This moment is here.'",
                    "Stay for 7 minutes. Let the trembling be present without needing to stop it."
                ],
                developmentalContext: "Trembling is the body between structures. The ground doesn't need to be solid to hold you.",
                isShareable: true
            ))
        case .emptiness:
            practices.append(SomaticPractice(
                id: UUID(), name: "Open Awareness Sit",
                description: "Resting in formlessness without needing to fill the space.",
                duration: 600, category: .nervousSystem, season: .emptiness,
                instructions: [
                    "Sit comfortably. Close your eyes or soften your gaze.",
                    "Let your attention be wide — not focused on anything specific.",
                    "Notice the space between thoughts. The quiet between breaths.",
                    "If the emptiness feels uncomfortable, place a hand on your heart.",
                    "You do not need to know what comes next. Rest in the not-knowing.",
                    "Stay for 10 minutes. Let the emptiness be exactly what it is."
                ],
                developmentalContext: "Emptiness is the pause between who you were and who you are becoming. It is not absence — it is potential.",
                isShareable: true
            ))
        case .emergence:
            practices.append(SomaticPractice(
                id: UUID(), name: "Body Listening",
                description: "Tuning into the new patterns that are beginning to take shape in the body.",
                duration: 480, category: .bodyScan, season: .emergence,
                instructions: [
                    "Lie down or sit in a position where your body can be fully supported.",
                    "Scan slowly from feet to crown. Notice anything new — sensations that weren't there before.",
                    "When you find an area of aliveness or unfamiliarity, rest your attention there.",
                    "Ask gently: 'What are you becoming?'",
                    "Do not force an answer. Let the body speak in its own language.",
                    "Stay for 8 minutes. When you finish, write one sentence about what you noticed."
                ],
                developmentalContext: "New structures form first in the body. The emergence may not have words yet — but the body already knows.",
                isShareable: true
            ))
        case .integration, .none:
            practices.append(SomaticPractice(
                id: UUID(), name: "Gratitude Body Scan",
                description: "A practice of thanking the body for the journey it has carried you through.",
                duration: 360, category: .bodyScan, season: .integration,
                instructions: [
                    "Find a comfortable position. Take three deep breaths.",
                    "Bring attention to your feet. Thank them for carrying you.",
                    "Move to your legs, your belly, your chest, your arms, your hands, your throat, your face, your head.",
                    "At each station, offer a simple acknowledgment: 'Thank you for holding this.'",
                    "When you reach the crown, let gratitude fill the whole body.",
                    "Rest for one minute in silence."
                ],
                developmentalContext: "Integration is the season of consolidation. Gratitude helps the new structure settle into its home.",
                isShareable: true
            ))
        }

        return practices
    }
}
