// CoachPersona.swift
// Haute Lumière

import SwiftUI

// MARK: - Coach Personas
enum CoachPersona: String, Codable, CaseIterable, Identifiable {
    case avaAzure = "ava_azure"
    case marcusSterling = "marcus_sterling"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .avaAzure: return "Ava Azure"
        case .marcusSterling: return "Marcus Sterling"
        }
    }

    var title: String {
        switch self {
        case .avaAzure: return "Mindfulness & Wellness Guide"
        case .marcusSterling: return "Executive Performance Coach"
        }
    }

    var shortBio: String {
        switch self {
        case .avaAzure:
            return "A luminous presence combining ancient wisdom with modern neuroscience. Ava's voice carries the warmth of sunrise meditation and the precision of evidence-based coaching."
        case .marcusSterling:
            return "Grounded strength meets compassionate insight. Marcus brings executive leadership mastery, breathwork expertise, and an unwavering belief in your potential."
        }
    }

    var voiceDescription: String {
        switch self {
        case .avaAzure: return "Bright, warm, crystalline — like light through morning mist"
        case .marcusSterling: return "Deep, resonant, steady — like an ancient oak in still air"
        }
    }

    var accentColor: Color {
        switch self {
        case .avaAzure: return Color(hex: "7BA7C4")
        case .marcusSterling: return Color(hex: "C5A059")
        }
    }

    var gradientColors: [Color] {
        switch self {
        case .avaAzure: return [Color(hex: "7BA7C4"), Color(hex: "A8C5D8"), Color(hex: "D4E4ED")]
        case .marcusSterling: return [Color(hex: "C5A059"), Color(hex: "D4B87A"), Color(hex: "E6D0A1")]
        }
    }

    var avatarSymbol: String {
        switch self {
        case .avaAzure: return "sparkles"
        case .marcusSterling: return "mountain.2.fill"
        }
    }

    var coachingStyle: CoachingStyle {
        switch self {
        case .avaAzure: return .mindfulAppreciative
        case .marcusSterling: return .executiveStrength
        }
    }

    var greetings: [String] {
        switch self {
        case .avaAzure:
            return [
                "Welcome back, {name}. I've been looking forward to our time together.",
                "Beautiful to see you, {name}. How is your inner landscape today?",
                "Hello, {name}. Let's breathe together for a moment before we begin.",
                "{name}, I notice something different about your energy today. Tell me more.",
                "Welcome, {name}. Your consistency is truly inspiring."
            ]
        case .marcusSterling:
            return [
                "{name}, good to see you. Ready to build on your momentum?",
                "Welcome back, {name}. I've been tracking your progress — impressive.",
                "{name}, let's dive in. I have some thoughts on your journey this week.",
                "Good to connect, {name}. Your dedication is paying dividends.",
                "{name}, I see the strength you're building. Let's channel it today."
            ]
        }
    }
}

enum CoachingStyle: String, Codable {
    case mindfulAppreciative  // Ava: Mindfulness + Appreciative Inquiry
    case executiveStrength    // Marcus: Executive coaching + Strengths-based
}

// MARK: - Coach Message Templates
struct CoachMessage: Identifiable, Codable {
    let id: UUID
    let persona: CoachPersona
    let content: String
    let type: MessageType
    let timestamp: Date
    let isFromCoach: Bool

    enum MessageType: String, Codable {
        case greeting
        case checkIn
        case encouragement
        case suggestion
        case reflection
        case goalSetting
        case celebration
        case article
        case sessionReminder
        case weeklyReport
        case breathingPrompt
        case yogaNidraInvite
        case userMessage
        case voiceNote
    }

    init(persona: CoachPersona, content: String, type: MessageType, isFromCoach: Bool = true) {
        self.id = UUID()
        self.persona = persona
        self.content = content
        self.type = type
        self.timestamp = Date()
        self.isFromCoach = isFromCoach
    }
}
