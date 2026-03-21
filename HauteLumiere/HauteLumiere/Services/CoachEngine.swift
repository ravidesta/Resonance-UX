// CoachEngine.swift
// Haute Lumière — AI Coach Engine

import SwiftUI
import Combine
import AVFoundation

/// The core coaching intelligence that powers Ava Azure and Marcus Sterling.
/// Manages conversation, coaching cycle progression, personalized content,
/// and the hidden 5D development framework.
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

    // MARK: - Voice
    private let synthesizer = AVSpeechSynthesizer()

    // MARK: - Coach Mood (affects tone of responses)
    enum CoachMood: String {
        case warm       // Default
        case celebratory // After wins
        case supportive  // During struggles
        case focused    // During coaching sessions
        case reflective // During self-inquiry
        case energizing // Morning/motivation
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

        // Simulate AI processing
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            let response = self.generateResponse(to: text)
            self.messages.append(response)
            self.isProcessing = false
            self.analyzeForCoachingInsights(text)
        }
    }

    func generateResponse(to input: String) -> CoachMessage {
        let lowered = input.lowercased()

        // Contextual response generation based on 5D phase and content
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

    // MARK: - 5D Cycle Management
    func advanceCycleIfReady() {
        phaseWeekCount += 1
        let thresholds: [FiveDPhase: Int] = [
            .discover: 2, .define: 2, .develop: 4, .deepen: 4, .deliver: 4
        ]
        if phaseWeekCount >= (thresholds[currentPhase] ?? 4) {
            if let nextPhase = FiveDPhase(rawValue: currentPhase.rawValue + 1) {
                currentPhase = nextPhase
                phaseWeekCount = 0
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
            break
        }
        for indicator in strengthIndicators where lowered.contains(indicator) {
            let note = CoachingNote(category: .strengthDisplayed, content: message, phase: currentPhase)
            coachingNotes.append(note)
            break
        }
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

    // MARK: - Persistence
    private func loadSavedState() {
        // Load from UserDefaults/CloudKit in production
    }

    func saveState() {
        // Persist to UserDefaults/CloudKit in production
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
