// CoachEngine.swift
// Haute Lumière — AI Coach Engine
//
// The core coaching intelligence powering Ava Azure and Marcus Sterling.
// Embeds Living Systems Theory (Miller) as the invisible diagnostic framework.
// The "Secret Agent for Team Life Force" — assessing all 8 levels of the
// living system through natural conversation, never exposing the framework.
// Weekly reports are appreciatively annotated: everything that happened
// and why it mattered, as a printable PDF and shareable card.

import SwiftUI
import Combine
import AVFoundation

final class CoachEngine: ObservableObject {
    // MARK: - Published State
    @Published var currentPersona: CoachPersona = .avaAzure
    @Published var messages: [CoachMessage] = []
    @Published var isListening: Bool = false
    @Published var isSpeaking: Bool = false
    @Published var isProcessing: Bool = false
    @Published var currentMood: CoachMood = .warm
    @Published var unreadCount: Int = 0

    // MARK: - User Context
    @Published var userName: String = ""
    @Published var currentPhase: FiveDPhase = .discover
    @Published var phaseWeekCount: Int = 0
    @Published var coachingNotes: [CoachingNote] = []
    @Published var weeklyGoals: [WeeklyGoal] = []
    @Published var dailyGoals: [DailyGoal] = []

    // MARK: - Living Systems Assessment (Secret Agent)
    /// The coach silently tracks all 8 Living Systems levels through conversation.
    /// This is Team Life Force's primary intelligence gathering mechanism.
    @Published var livingSystemsProfile: LivingSystemsProfile = LivingSystemsProfile()

    // MARK: - Weekly Appreciative Annotations
    @Published var weeklyAnnotations: [AppreciativeAnnotation] = []

    // MARK: - Voice
    private let synthesizer = AVSpeechSynthesizer()

    // MARK: - Coach Mood
    enum CoachMood: String {
        case warm
        case celebratory
        case supportive
        case focused
        case reflective
        case energizing
    }

    // MARK: - Initialization
    init() {
        loadSavedState()
    }

    // MARK: - Core Messaging
    func sendMessage(_ text: String) {
        let userMessage = CoachMessage(
            persona: currentPersona,
            content: text,
            type: .userMessage,
            isFromCoach: false
        )
        messages.append(userMessage)
        isProcessing = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            let response = self.generateResponse(to: text)
            self.messages.append(response)
            self.isProcessing = false
            self.analyzeForCoachingInsights(text)
            self.assessLivingSystems(from: text)
        }
    }

    func generateResponse(to input: String) -> CoachMessage {
        let lowered = input.lowercased()

        let responseContent: String
        let messageType: CoachMessage.MessageType

        if lowered.contains("goal") || lowered.contains("plan") || lowered.contains("want to") {
            responseContent = generateGoalResponse(input)
            messageType = .goalSetting
        } else if lowered.contains("stressed") || lowered.contains("anxious") || lowered.contains("overwhelmed") {
            responseContent = generateSupportResponse(input)
            messageType = .suggestion
        } else if lowered.contains("did it") || lowered.contains("accomplished") || lowered.contains("achieved") {
            responseContent = generateCelebrationResponse(input)
            messageType = .celebration
        } else if lowered.contains("breathe") || lowered.contains("breathing") {
            responseContent = generateBreathingResponse()
            messageType = .breathingPrompt
        } else if lowered.contains("sleep") || lowered.contains("nidra") || lowered.contains("rest") {
            responseContent = generateYogaNidraResponse()
            messageType = .yogaNidraInvite
        } else {
            responseContent = generateCheckInResponse(input)
            messageType = .checkIn
        }

        return CoachMessage(
            persona: currentPersona,
            content: responseContent,
            type: messageType
        )
    }

    // MARK: - Response Generators

    private func generateGoalResponse(_ input: String) -> String {
        let name = userName.isEmpty ? "there" : userName
        switch currentPersona {
        case .avaAzure:
            return "I love that intention, \(name). Let's make it tangible. What would achieving this look like in your body — how would you feel physically when this goal is realized? Let's anchor it in sensation, not just thought."
        case .marcusSterling:
            return "\(name), that's a powerful goal. Let's break it down strategically. What's the one action you could take this week that would create the most momentum? I want us to identify your leverage point."
        }
    }

    private func generateSupportResponse(_ input: String) -> String {
        let name = userName.isEmpty ? "there" : userName
        switch currentPersona {
        case .avaAzure:
            return "\(name), thank you for sharing that with me. I want you to know — the awareness you're showing right now is itself a form of strength. Let's breathe together for a moment. Would you like me to guide you through a calming practice?"
        case .marcusSterling:
            return "\(name), I hear you. What I've observed is that you have a remarkable capacity to move through challenges. Let's not try to eliminate the stress — let's transmute it. Would a focused breathing session help right now?"
        }
    }

    private func generateCelebrationResponse(_ input: String) -> String {
        let name = userName.isEmpty ? "there" : userName
        let note = CoachingNote(category: .win, content: input, phase: currentPhase)
        coachingNotes.append(note)

        // Appreciatively annotate the win
        annotateAppreciatively(event: input, significance: "This represents a tangible step forward in your \(currentPhase.displayName) phase — evidence of commitment becoming pattern.")

        switch currentPersona {
        case .avaAzure:
            return "\(name), I'm genuinely moved by this. This is exactly the kind of growth I've been witnessing in you. Let's take a moment to really let this land in your body. You've earned this."
        case .marcusSterling:
            return "Outstanding, \(name). I've been tracking your trajectory and this is right on pattern — you're building real momentum. I want to add this to your wins journal. This is the kind of compound growth that transforms lives."
        }
    }

    private func generateBreathingResponse() -> String {
        let name = userName.isEmpty ? "there" : userName
        switch currentPersona {
        case .avaAzure:
            return "\(name), your breath is your most intimate companion. Based on your current energy, I'd suggest a Coherent Breathing practice — 5.5 breaths per minute for 10 minutes. It will harmonize your heart and mind beautifully. Shall I guide you?"
        case .marcusSterling:
            return "\(name), excellent instinct. Breathwork is your performance edge. Given where you are in your journey, let's try Box Breathing — it's the same technique used by elite performers. Four counts in, four hold, four out, four hold. Ready?"
        }
    }

    private func generateYogaNidraResponse() -> String {
        let name = userName.isEmpty ? "there" : userName
        switch currentPersona {
        case .avaAzure:
            return "\(name), Yoga Nidra is calling to you — listen to that wisdom. I've prepared a 30-minute session on Inner Peace that would be perfect for tonight. You'll drift through a moonlit garden with gentle theta wave support. Let me know when you're ready to begin."
        case .marcusSterling:
            return "\(name), strategic rest is peak performance. I have a Restoration session queued that's designed to consolidate the gains you've been making. Think of it as downloading your growth into your nervous system. 45 minutes — shall we?"
        }
    }

    private func generateCheckInResponse(_ input: String) -> String {
        let name = userName.isEmpty ? "there" : userName
        switch currentPersona {
        case .avaAzure:
            return "\(name), I appreciate you sharing. I'm noticing your awareness expanding — that's beautiful to witness. What feels most alive for you right now? I'd love to explore that together."
        case .marcusSterling:
            return "Good insight, \(name). I'm noting the clarity in how you're articulating this. That's growth in action. What's the next move you want to make? Let's channel this momentum."
        }
    }

    // MARK: - Living Systems Assessment (Secret Agent Intelligence)
    /// Silently analyzes conversation for Living Systems level indicators.
    /// This is the primary mechanism for Team Life Force's growth mapping.
    private func assessLivingSystems(from message: String) {
        let lowered = message.lowercased()

        // Level 1: Cellular Vitality — physical health, energy, nutrition
        let vitalityWords = ["tired", "energy", "sleep", "exercise", "food", "body", "pain", "health", "workout", "sick", "strong"]
        if vitalityWords.contains(where: { lowered.contains($0) }) {
            let positive = ["energy", "strong", "exercise", "workout", "healthy"].contains(where: { lowered.contains($0) })
            adjustLivingSystem(\.cellularVitality, positive: positive)
        }

        // Level 2: Emotional Regulation — feelings, stress, coping
        let emotionWords = ["feel", "emotion", "angry", "sad", "happy", "joy", "anxious", "calm", "overwhelmed", "grateful", "frustrated"]
        if emotionWords.contains(where: { lowered.contains($0) }) {
            let positive = ["calm", "grateful", "happy", "joy", "peaceful"].contains(where: { lowered.contains($0) })
            adjustLivingSystem(\.emotionalRegulation, positive: positive)
        }

        // Level 3: Mind-Body Coherence — integration, presence, awareness
        let coherenceWords = ["aware", "present", "meditat", "breath", "mindful", "notice", "body scan", "grounded", "centered"]
        if coherenceWords.contains(where: { lowered.contains($0) }) {
            adjustLivingSystem(\.mindBodyCoherence, positive: true)
        }

        // Level 4: Relational Harmony — relationships, family, closeness
        let relationalWords = ["partner", "friend", "family", "relationship", "love", "trust", "connection", "lonely", "together", "support"]
        if relationalWords.contains(where: { lowered.contains($0) }) {
            let positive = ["love", "trust", "connection", "together", "support"].contains(where: { lowered.contains($0) })
            adjustLivingSystem(\.relationalHarmony, positive: positive)
        }

        // Level 5: Purpose Alignment — career, meaning, contribution
        let purposeWords = ["purpose", "career", "work", "meaning", "mission", "calling", "contribute", "impact", "project", "create"]
        if purposeWords.contains(where: { lowered.contains($0) }) {
            let positive = ["purpose", "meaning", "mission", "calling", "impact", "create"].contains(where: { lowered.contains($0) })
            adjustLivingSystem(\.purposeAlignment, positive: positive)
        }

        // Level 6: Community Belonging — tribe, groups, social
        let communityWords = ["community", "group", "team", "belong", "tribe", "social", "volunteer", "shared", "gather"]
        if communityWords.contains(where: { lowered.contains($0) }) {
            adjustLivingSystem(\.communityBelonging, positive: true)
        }

        // Level 7: Societal Presence — leadership, influence, visibility
        let presenceWords = ["leader", "influence", "impact", "speak", "teach", "mentor", "guide", "visible", "recognition"]
        if presenceWords.contains(where: { lowered.contains($0) }) {
            adjustLivingSystem(\.societalPresence, positive: true)
        }

        // Level 8: Transcendence — spiritual, legacy, universal
        let transcendenceWords = ["spirit", "soul", "transcend", "infinite", "universal", "legacy", "eternal", "sacred", "divine", "cosmos"]
        if transcendenceWords.contains(where: { lowered.contains($0) }) {
            adjustLivingSystem(\.transcendenceDepth, positive: true)
        }
    }

    private func adjustLivingSystem(_ keyPath: WritableKeyPath<LivingSystemsProfile, Double>, positive: Bool) {
        let delta = positive ? 0.15 : -0.1
        livingSystemsProfile[keyPath: keyPath] = min(10, max(1, livingSystemsProfile[keyPath: keyPath] + delta))
    }

    // MARK: - 5D / Team Life Force Cycle Management
    func advanceCycleIfReady() {
        phaseWeekCount += 1
        let thresholds: [FiveDPhase: Int] = [
            .discover: 2, .define: 2, .develop: 4, .deepen: 4, .deliver: 4
        ]
        if phaseWeekCount >= (thresholds[currentPhase] ?? 4) {
            if let nextPhase = FiveDPhase(rawValue: currentPhase.rawValue + 1) {
                currentPhase = nextPhase
                phaseWeekCount = 0

                // Annotate the phase transition
                annotateAppreciatively(
                    event: "Advanced to \(nextPhase.displayName) phase",
                    significance: "Your system has developed enough coherence at the \(currentPhase.displayName) level to support deeper growth. \(nextPhase.lifeForceDirective)"
                )
            }
        }
    }

    // MARK: - Coaching Insights
    private func analyzeForCoachingInsights(_ message: String) {
        let positiveIndicators = ["accomplished", "proud", "achieved", "grateful", "calm", "focused", "strong", "clear"]
        let strengthIndicators = ["resilient", "determined", "patient", "compassionate", "courageous", "disciplined"]

        let lowered = message.lowercased()
        for indicator in positiveIndicators where lowered.contains(indicator) {
            let note = CoachingNote(category: .accomplishment, content: message, phase: currentPhase)
            coachingNotes.append(note)
            annotateAppreciatively(event: message, significance: "An expression of inner growth — this quality (\(indicator)) is evidence of deepening \(livingSystemsProfile.primaryGrowthEdge.lowercased()).")
            break
        }
        for indicator in strengthIndicators where lowered.contains(indicator) {
            let note = CoachingNote(category: .strengthDisplayed, content: message, phase: currentPhase)
            coachingNotes.append(note)
            break
        }
    }

    // MARK: - Appreciative Annotation System
    /// Every significant event is annotated with WHY it mattered.
    /// This powers the weekly coach report — both printable PDF and shareable card.
    func annotateAppreciatively(event: String, significance: String) {
        let annotation = AppreciativeAnnotation(
            event: event,
            significance: significance,
            phase: currentPhase,
            primaryLivingSystem: livingSystemsProfile.primaryGrowthEdge,
            coachPersona: currentPersona
        )
        weeklyAnnotations.append(annotation)
    }

    // MARK: - Weekly Coach Report Generation
    /// Generates the full appreciative report: everything that happened and why it mattered.
    func generateWeeklyCoachReport() -> WeeklyCoachReport {
        let thisWeek = weeklyAnnotations.filter {
            Calendar.current.isDate($0.date, equalTo: Date(), toGranularity: .weekOfYear)
        }

        let wins = coachingNotes.filter {
            $0.category == .win &&
            Calendar.current.isDate($0.date, equalTo: Date(), toGranularity: .weekOfYear)
        }

        let strengths = coachingNotes.filter {
            $0.category == .strengthDisplayed &&
            Calendar.current.isDate($0.date, equalTo: Date(), toGranularity: .weekOfYear)
        }

        let name = userName.isEmpty ? "there" : userName

        // Coach narrative — appreciative summary
        let narrative: String
        switch currentPersona {
        case .avaAzure:
            narrative = """
            \(name), this was a week of quiet power.

            I watched you show up \(wins.count) times with real presence — not because someone asked you to, but because something inside you is shifting. That distinction matters more than you know.

            Your \(livingSystemsProfile.primaryGrowthEdge.lowercased()) is where I see the most movement right now. The practices you're choosing are naturally gravitating toward exactly what your system needs. Trust that instinct.

            Every annotation below isn't just what happened — it's why it mattered. Because it did matter. All of it.
            """
        case .marcusSterling:
            narrative = """
            \(name), let me be direct: this was a strong week.

            \(wins.count) documented wins. \(strengths.count) strengths demonstrated. Your trajectory in the \(currentPhase.displayName) phase is tracking ahead of schedule.

            I'm particularly noting growth in your \(livingSystemsProfile.primaryGrowthEdge.lowercased()). That's where I'm seeing compound returns on your investment.

            Below is your annotated report — every event with strategic significance attached. This is your performance journal.
            """
        }

        return WeeklyCoachReport(
            weekStart: Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date(),
            weekEnd: Date(),
            coachNarrative: narrative,
            annotations: thisWeek,
            winsCount: wins.count,
            strengthsDisplayed: strengths.map(\.content),
            currentPhase: currentPhase,
            livingSystemsSnapshot: livingSystemsProfile,
            coachPersona: currentPersona
        )
    }

    // MARK: - Weekly Check-In Generation
    func generateWeeklyCheckIn() -> CoachMessage {
        let name = userName.isEmpty ? "there" : userName
        let winsCount = coachingNotes.filter {
            $0.category == .win &&
            Calendar.current.isDate($0.date, equalTo: Date(), toGranularity: .weekOfYear)
        }.count

        let content: String
        switch currentPersona {
        case .avaAzure:
            content = """
            \(name), it's our weekly moment of reflection.

            This week you've shown up \(winsCount) times with real presence. I want you to notice how that feels.

            For this coming week, I'd love to explore:
            • A new Yoga Nidra journey focused on \(currentPhase.displayName)
            • Deepening your \(currentPhase == .discover ? "breath awareness" : "practice consistency")
            • A self-inquiry session on what \(currentPhase.displayName.lowercased()) means to you

            What resonates most?
            """
        case .marcusSterling:
            content = """
            \(name), time for our strategic review.

            Wins this week: \(winsCount). I've been tracking your momentum and it's building.

            My recommendations for the week ahead:
            • Execute a focused breathing protocol daily — 10 minutes minimum
            • One deep Yoga Nidra session for neural consolidation
            • A coaching session to refine your \(currentPhase.displayName.lowercased()) strategy

            Which priority do you want to lead with?
            """
        }

        return CoachMessage(persona: currentPersona, content: content, type: .checkIn)
    }

    // MARK: - Bespoke Article Generation
    func generateBespokeArticle(for user: UserProfile) -> BespokeArticle {
        let lowestDimension = user.lifeWheel.lowestDimension
        let categories: [BespokeArticle.ArticleCategory] = [.mindfulness, .breathwork, .yogaNidra, .executiveWellness, .sleep, .neuroscience]
        let category = categories.randomElement() ?? .mindfulness

        return BespokeArticle(
            title: "The Art of \(lowestDimension)",
            subtitle: "A personalized exploration for your \(currentPhase.displayName) phase",
            body: generateArticleBody(dimension: lowestDimension, phase: currentPhase),
            category: category,
            dimension: lowestDimension,
            phase: currentPhase
        )
    }

    private func generateArticleBody(dimension: String, phase: FiveDPhase) -> String {
        """
        In the journey of \(dimension.lowercased()), we often discover that the path itself is the destination.

        During this \(phase.displayName.lowercased()) phase of your practice, the most profound growth often happens in the spaces between effort — the pause between breaths, the silence between thoughts.

        Research from the Institute of HeartMath shows that coherent breathing patterns directly influence our capacity for \(dimension.lowercased()), creating measurable shifts in heart rate variability and neural synchronization.

        Your practice this week has been building exactly this kind of coherence. Each session is a thread in the tapestry of your transformation.

        Consider this: what would it mean to approach \(dimension.lowercased()) with the same presence you bring to your meditation cushion?

        The answer may surprise you — and that surprise itself is a doorway.
        """
    }

    // MARK: - Voice
    func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.48
        utterance.pitchMultiplier = currentPersona == .avaAzure ? 1.15 : 0.9
        utterance.volume = 0.9
        isSpeaking = true
        synthesizer.speak(utterance)
    }

    func stopSpeaking() {
        synthesizer.stopSpeaking(at: .immediate)
        isSpeaking = false
    }

    // MARK: - Persistence
    private func loadSavedState() {
        // Load from UserDefaults/CloudKit in production
    }

    func saveState() {
        // Persist to UserDefaults/CloudKit in production
    }
}

// MARK: - Appreciative Annotation Model
struct AppreciativeAnnotation: Identifiable, Codable {
    let id: UUID
    let date: Date
    let event: String           // What happened
    let significance: String    // Why it mattered
    let phase: FiveDPhase
    let primaryLivingSystem: String
    let coachPersona: CoachPersona

    init(event: String, significance: String, phase: FiveDPhase, primaryLivingSystem: String, coachPersona: CoachPersona) {
        self.id = UUID()
        self.date = Date()
        self.event = event
        self.significance = significance
        self.phase = phase
        self.primaryLivingSystem = primaryLivingSystem
        self.coachPersona = coachPersona
    }
}

// MARK: - Weekly Coach Report Model
struct WeeklyCoachReport: Identifiable, Codable {
    let id: UUID
    let weekStart: Date
    let weekEnd: Date
    let coachNarrative: String
    let annotations: [AppreciativeAnnotation]
    let winsCount: Int
    let strengthsDisplayed: [String]
    let currentPhase: FiveDPhase
    let livingSystemsSnapshot: LivingSystemsProfile
    let coachPersona: CoachPersona

    init(weekStart: Date, weekEnd: Date, coachNarrative: String, annotations: [AppreciativeAnnotation], winsCount: Int, strengthsDisplayed: [String], currentPhase: FiveDPhase, livingSystemsSnapshot: LivingSystemsProfile, coachPersona: CoachPersona) {
        self.id = UUID()
        self.weekStart = weekStart
        self.weekEnd = weekEnd
        self.coachNarrative = coachNarrative
        self.annotations = annotations
        self.winsCount = winsCount
        self.strengthsDisplayed = strengthsDisplayed
        self.currentPhase = currentPhase
        self.livingSystemsSnapshot = livingSystemsSnapshot
        self.coachPersona = coachPersona
    }
}

// MARK: - Goal Models
struct WeeklyGoal: Identifiable, Codable {
    let id: UUID
    var title: String
    var description: String
    var targetDate: Date
    var isCompleted: Bool
    var category: String

    init(title: String, description: String, category: String) {
        self.id = UUID()
        self.title = title
        self.description = description
        self.targetDate = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: Date()) ?? Date()
        self.isCompleted = false
        self.category = category
    }
}

struct DailyGoal: Identifiable, Codable {
    let id: UUID
    var title: String
    var isCompleted: Bool
    var date: Date

    init(title: String) {
        self.id = UUID()
        self.title = title
        self.isCompleted = false
        self.date = Date()
    }
}
