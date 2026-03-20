// AttachmentModels.swift
// Luminous Attachment — Resonance UX
// Data models for the transformative attachment healing experience

import Foundation
import SwiftUI

// MARK: - Design System

enum ResonanceColors {
    static let green900 = Color(hex: "0A1C14")
    static let green800 = Color(hex: "122E21")
    static let green700 = Color(hex: "1B402E")
    static let green200 = Color(hex: "D1E0D7")
    static let green100 = Color(hex: "E8F0EA")
    static let goldPrimary = Color(hex: "C5A059")
    static let goldLight = Color(hex: "E6D0A1")
    static let goldDark = Color(hex: "9A7A3A")

    static func background(for scheme: ColorScheme) -> Color {
        scheme == .dark ? green900 : green100
    }

    static func surface(for scheme: ColorScheme) -> Color {
        scheme == .dark ? green800 : .white
    }

    static func surfaceSecondary(for scheme: ColorScheme) -> Color {
        scheme == .dark ? green700 : green200
    }

    static func text(for scheme: ColorScheme) -> Color {
        scheme == .dark ? green100 : green900
    }

    static func textSecondary(for scheme: ColorScheme) -> Color {
        scheme == .dark ? green200 : green700
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
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

// MARK: - Attachment Style

enum AttachmentStyle: String, Codable, CaseIterable, Identifiable {
    case secure = "Secure"
    case anxious = "Anxious-Preoccupied"
    case avoidant = "Dismissive-Avoidant"
    case fearful = "Fearful-Avoidant"
    case unknown = "Exploring"

    var id: String { rawValue }

    var description: String {
        switch self {
        case .secure:
            return "You feel comfortable with closeness and can depend on others while maintaining independence."
        case .anxious:
            return "You seek deep intimacy but may worry about whether your partner truly loves you."
        case .avoidant:
            return "You value independence highly and may feel uncomfortable with too much closeness."
        case .fearful:
            return "You desire closeness but also fear it, sometimes pushing people away to protect yourself."
        case .unknown:
            return "You are on a journey of self-discovery. Every step brings clarity."
        }
    }

    var icon: String {
        switch self {
        case .secure: return "shield.checkered"
        case .anxious: return "heart.text.clipboard"
        case .avoidant: return "figure.walk.departure"
        case .fearful: return "water.waves"
        case .unknown: return "sparkles"
        }
    }

    var color: Color {
        switch self {
        case .secure: return ResonanceColors.goldPrimary
        case .anxious: return Color(hex: "D4A373")
        case .avoidant: return Color(hex: "8DB6A4")
        case .fearful: return Color(hex: "B8A9C9")
        case .unknown: return ResonanceColors.green200
        }
    }
}

// MARK: - Mood

enum MoodLevel: Int, Codable, CaseIterable, Identifiable {
    case seed = 1
    case sprout = 2
    case leaf = 3
    case flower = 4
    case tree = 5

    var id: Int { rawValue }

    var name: String {
        switch self {
        case .seed: return "Seed"
        case .sprout: return "Sprout"
        case .leaf: return "Leaf"
        case .flower: return "Flower"
        case .tree: return "Tree"
        }
    }

    var icon: String {
        switch self {
        case .seed: return "leaf.circle"
        case .sprout: return "leaf.arrow.circlepath"
        case .leaf: return "leaf"
        case .flower: return "camera.macro"
        case .tree: return "tree"
        }
    }

    var description: String {
        switch self {
        case .seed: return "Planting intentions"
        case .sprout: return "Starting to grow"
        case .leaf: return "Feeling grounded"
        case .flower: return "Blossoming"
        case .tree: return "Deeply rooted"
        }
    }

    var color: Color {
        switch self {
        case .seed: return ResonanceColors.green700
        case .sprout: return ResonanceColors.green200
        case .leaf: return Color(hex: "4A7C5E")
        case .flower: return ResonanceColors.goldPrimary
        case .tree: return ResonanceColors.goldDark
        }
    }
}

struct MoodEntry: Codable, Identifiable {
    let id: UUID
    let level: MoodLevel
    let date: Date
    var note: String?
    var tags: [String]

    init(id: UUID = UUID(), level: MoodLevel, date: Date = Date(), note: String? = nil, tags: [String] = []) {
        self.id = id
        self.level = level
        self.date = date
        self.note = note
        self.tags = tags
    }
}

// MARK: - User

@Observable
class UserProfile {
    var id: UUID = UUID()
    var name: String = ""
    var attachmentStyle: AttachmentStyle = .unknown
    var joinDate: Date = Date()
    var streakDays: Int = 0
    var lastActiveDate: Date = Date()
    var moodHistory: [MoodEntry] = []
    var completedChapters: Set<Int> = []
    var bookmarks: [Bookmark] = []
    var highlights: [Highlight] = []
    var totalJournalEntries: Int = 0
    var totalCoachSessions: Int = 0
    var totalMeditationMinutes: Double = 0
    var preferredPencilColor: String = "1B402E"

    var currentStreak: Int {
        streakDays
    }

    func updateStreak() {
        let calendar = Calendar.current
        if calendar.isDateInToday(lastActiveDate) { return }
        if calendar.isDateInYesterday(lastActiveDate) {
            streakDays += 1
        } else {
            streakDays = 1
        }
        lastActiveDate = Date()
    }
}

// MARK: - Journal

enum JournalMode: String, Codable, CaseIterable {
    case typed = "Typed"
    case voice = "Voice"
    case pencil = "Apple Pencil"

    var icon: String {
        switch self {
        case .typed: return "keyboard"
        case .voice: return "mic"
        case .pencil: return "pencil.tip"
        }
    }
}

struct JournalEntry: Codable, Identifiable {
    let id: UUID
    var title: String
    var textContent: String
    var voiceRecordingURL: URL?
    var pencilDrawingData: Data?
    var mood: MoodLevel?
    var tags: [String]
    var prompt: String?
    var date: Date
    var isFavorite: Bool
    var isSharedWithCoach: Bool
    var mode: JournalMode

    init(
        id: UUID = UUID(),
        title: String = "",
        textContent: String = "",
        voiceRecordingURL: URL? = nil,
        pencilDrawingData: Data? = nil,
        mood: MoodLevel? = nil,
        tags: [String] = [],
        prompt: String? = nil,
        date: Date = Date(),
        isFavorite: Bool = false,
        isSharedWithCoach: Bool = false,
        mode: JournalMode = .typed
    ) {
        self.id = id
        self.title = title
        self.textContent = textContent
        self.voiceRecordingURL = voiceRecordingURL
        self.pencilDrawingData = pencilDrawingData
        self.mood = mood
        self.tags = tags
        self.prompt = prompt
        self.date = date
        self.isFavorite = isFavorite
        self.isSharedWithCoach = isSharedWithCoach
        self.mode = mode
    }
}

// MARK: - Coach

enum CoachMessageType: String, Codable {
    case text
    case voiceMemo
    case journalReference
    case exerciseCard
    case meditationCard
    case insightCard
    case quickReplies
}

enum MessageSender: String, Codable {
    case user
    case coach
}

struct CoachMessage: Codable, Identifiable {
    let id: UUID
    let sender: MessageSender
    let type: CoachMessageType
    var text: String
    var voiceURL: URL?
    var journalEntryId: UUID?
    var exerciseTitle: String?
    var exerciseDescription: String?
    var exerciseDurationMinutes: Int?
    var meditationTitle: String?
    var meditationDurationMinutes: Int?
    var quickReplies: [String]?
    let timestamp: Date

    init(
        id: UUID = UUID(),
        sender: MessageSender,
        type: CoachMessageType = .text,
        text: String,
        voiceURL: URL? = nil,
        journalEntryId: UUID? = nil,
        exerciseTitle: String? = nil,
        exerciseDescription: String? = nil,
        exerciseDurationMinutes: Int? = nil,
        meditationTitle: String? = nil,
        meditationDurationMinutes: Int? = nil,
        quickReplies: [String]? = nil,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.sender = sender
        self.type = type
        self.text = text
        self.voiceURL = voiceURL
        self.journalEntryId = journalEntryId
        self.exerciseTitle = exerciseTitle
        self.exerciseDescription = exerciseDescription
        self.exerciseDurationMinutes = exerciseDurationMinutes
        self.meditationTitle = meditationTitle
        self.meditationDurationMinutes = meditationDurationMinutes
        self.quickReplies = quickReplies
        self.timestamp = timestamp
    }
}

// MARK: - EBook / Chapter

struct Chapter: Codable, Identifiable {
    let id: Int
    let title: String
    let subtitle: String
    let content: String
    let reflectionPrompts: [String]
    let keyTerms: [String]
    let estimatedReadingMinutes: Int
    let audioDurationMinutes: Int

    var chapterLabel: String {
        "Chapter \(id)"
    }
}

struct Bookmark: Codable, Identifiable {
    let id: UUID
    let chapterId: Int
    let position: Int
    let note: String?
    let date: Date

    init(id: UUID = UUID(), chapterId: Int, position: Int, note: String? = nil, date: Date = Date()) {
        self.id = id
        self.chapterId = chapterId
        self.position = position
        self.note = note
        self.date = date
    }
}

struct Highlight: Codable, Identifiable {
    let id: UUID
    let chapterId: Int
    let text: String
    let color: String
    let date: Date

    init(id: UUID = UUID(), chapterId: Int, text: String, color: String = "goldPrimary", date: Date = Date()) {
        self.id = id
        self.chapterId = chapterId
        self.text = text
        self.color = color
        self.date = date
    }
}

// MARK: - Glossary

struct GlossaryTerm: Codable, Identifiable {
    let id: UUID
    let term: String
    let definition: String
    let relatedTerms: [String]
    let chapterReferences: [Int]

    init(id: UUID = UUID(), term: String, definition: String, relatedTerms: [String] = [], chapterReferences: [Int] = []) {
        self.id = id
        self.term = term
        self.definition = definition
        self.relatedTerms = relatedTerms
        self.chapterReferences = chapterReferences
    }
}

// MARK: - Audio Chapter

struct AudioChapter: Identifiable {
    let id: Int
    let title: String
    let duration: TimeInterval
    let fileName: String

    var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Share Card

enum ShareCardType: String, Codable, CaseIterable {
    case quote = "Quote"
    case insight = "Insight"
    case progress = "Progress"
    case journalExcerpt = "Journal Excerpt"
    case coachWisdom = "Coach Wisdom"

    var icon: String {
        switch self {
        case .quote: return "quote.opening"
        case .insight: return "lightbulb"
        case .progress: return "chart.line.uptrend.xyaxis"
        case .journalExcerpt: return "book"
        case .coachWisdom: return "bubble.left.and.text.bubble.right"
        }
    }
}

struct ShareCard: Identifiable {
    let id: UUID
    let type: ShareCardType
    var title: String
    var body: String
    var attributionText: String
    var accentColor: Color
    var backgroundStyle: ShareCardBackground

    init(
        id: UUID = UUID(),
        type: ShareCardType,
        title: String,
        body: String,
        attributionText: String = "Luminous Attachment by Resonance UX",
        accentColor: Color = ResonanceColors.goldPrimary,
        backgroundStyle: ShareCardBackground = .greenGradient
    ) {
        self.id = id
        self.type = type
        self.title = title
        self.body = body
        self.attributionText = attributionText
        self.accentColor = accentColor
        self.backgroundStyle = backgroundStyle
    }
}

enum ShareCardBackground: String, Codable, CaseIterable {
    case greenGradient = "Forest"
    case goldGradient = "Golden Hour"
    case darkGradient = "Night Sky"
    case lightGradient = "Morning Dew"

    var gradient: LinearGradient {
        switch self {
        case .greenGradient:
            return LinearGradient(colors: [ResonanceColors.green900, ResonanceColors.green700], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .goldGradient:
            return LinearGradient(colors: [ResonanceColors.goldDark, ResonanceColors.goldPrimary], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .darkGradient:
            return LinearGradient(colors: [Color(hex: "0A0F1C"), ResonanceColors.green900], startPoint: .top, endPoint: .bottom)
        case .lightGradient:
            return LinearGradient(colors: [ResonanceColors.green100, ResonanceColors.green200], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }

    var textColor: Color {
        switch self {
        case .greenGradient, .goldGradient, .darkGradient:
            return .white
        case .lightGradient:
            return ResonanceColors.green900
        }
    }
}

// MARK: - Daily Insight

struct DailyInsight: Identifiable {
    let id: UUID
    let text: String
    let author: String
    let category: String
    let date: Date

    init(id: UUID = UUID(), text: String, author: String = "Luminous Attachment", category: String = "Healing", date: Date = Date()) {
        self.id = id
        self.text = text
        self.author = author
        self.category = category
        self.date = date
    }
}

// MARK: - Breathing Exercise

struct BreathingExercise: Identifiable {
    let id: UUID
    let name: String
    let inhaleSeconds: Double
    let holdSeconds: Double
    let exhaleSeconds: Double
    let cycles: Int
    let description: String

    init(id: UUID = UUID(), name: String, inhaleSeconds: Double, holdSeconds: Double, exhaleSeconds: Double, cycles: Int, description: String) {
        self.id = id
        self.name = name
        self.inhaleSeconds = inhaleSeconds
        self.holdSeconds = holdSeconds
        self.exhaleSeconds = exhaleSeconds
        self.cycles = cycles
        self.description = description
    }

    var totalDurationMinutes: Double {
        let cycleSeconds = inhaleSeconds + holdSeconds + exhaleSeconds
        return (cycleSeconds * Double(cycles)) / 60.0
    }

    static let grounding = BreathingExercise(
        name: "Grounding Breath",
        inhaleSeconds: 4, holdSeconds: 4, exhaleSeconds: 6, cycles: 6,
        description: "A calming breath pattern that activates your parasympathetic nervous system, helping you feel safe and grounded."
    )

    static let heartOpening = BreathingExercise(
        name: "Heart-Opening Breath",
        inhaleSeconds: 5, holdSeconds: 2, exhaleSeconds: 5, cycles: 8,
        description: "This balanced breath expands your capacity for connection and vulnerability."
    )

    static let releaseAndLetGo = BreathingExercise(
        name: "Release & Let Go",
        inhaleSeconds: 4, holdSeconds: 0, exhaleSeconds: 8, cycles: 5,
        description: "Extended exhales signal deep safety to your body, releasing stored tension and old attachment wounds."
    )
}

// MARK: - Journal Prompt

struct JournalPrompt: Identifiable {
    let id: UUID
    let text: String
    let category: String
    let relatedChapter: Int?

    init(id: UUID = UUID(), text: String, category: String, relatedChapter: Int? = nil) {
        self.id = id
        self.text = text
        self.category = category
        self.relatedChapter = relatedChapter
    }

    static let dailyPrompts: [JournalPrompt] = [
        JournalPrompt(text: "What made you feel safe today? Describe that moment in detail.", category: "Safety", relatedChapter: 1),
        JournalPrompt(text: "When did you notice yourself reaching for connection today? What did that feel like in your body?", category: "Connection", relatedChapter: 2),
        JournalPrompt(text: "Write a letter to your younger self about what you wish someone had told you about love.", category: "Inner Child", relatedChapter: 4),
        JournalPrompt(text: "What boundary did you hold or wish you had held today?", category: "Boundaries", relatedChapter: 7),
        JournalPrompt(text: "Describe a moment when you felt truly seen by another person.", category: "Visibility", relatedChapter: 3),
        JournalPrompt(text: "What attachment pattern did you notice in yourself today? How did it serve you once, and does it still serve you now?", category: "Patterns", relatedChapter: 5),
        JournalPrompt(text: "If your anxiety could speak, what would it say it needs right now?", category: "Anxiety", relatedChapter: 6),
        JournalPrompt(text: "What does secure love look like to you? Paint a picture with words.", category: "Vision", relatedChapter: 12),
        JournalPrompt(text: "Who in your life models healthy attachment? What do you admire about how they love?", category: "Models", relatedChapter: 9),
        JournalPrompt(text: "What are you grieving in your relationships right now? Give yourself permission to feel it fully.", category: "Grief", relatedChapter: 8),
        JournalPrompt(text: "Write about a time you chose yourself. How did it feel? What did it cost?", category: "Self-Worth", relatedChapter: 10),
        JournalPrompt(text: "What would change if you believed, truly believed, that you are worthy of love exactly as you are?", category: "Core Beliefs", relatedChapter: 11),
        JournalPrompt(text: "Describe how your body feels right now. Where do you hold tension? What is your body trying to tell you?", category: "Somatic", relatedChapter: 3),
        JournalPrompt(text: "What is one thing you did today that your future securely-attached self would be proud of?", category: "Growth", relatedChapter: 12),
    ]

    static func promptOfTheDay() -> JournalPrompt {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        return dailyPrompts[dayOfYear % dailyPrompts.count]
    }
}

// MARK: - Insights Data

struct InsightsProvider {
    static let dailyInsights: [DailyInsight] = [
        DailyInsight(text: "Your attachment style is not your destiny. It is your starting point.", author: "Dr. Sue Johnson", category: "Hope"),
        DailyInsight(text: "The greatest gift you can give yourself is to become the safe harbor you always needed.", category: "Self-Compassion"),
        DailyInsight(text: "Healing is not linear. Some days you plant seeds; other days you water them. Both matter.", category: "Patience"),
        DailyInsight(text: "You do not need to be fixed. You need to be witnessed, held, and understood.", author: "Dr. Dan Siegel", category: "Acceptance"),
        DailyInsight(text: "Every relationship is an opportunity to heal or to repeat. Choose healing.", category: "Choice"),
        DailyInsight(text: "Your nervous system learned to protect you. Now you can gently teach it that safety is possible.", category: "Somatic"),
        DailyInsight(text: "Secure attachment is not the absence of fear. It is the presence of trust.", category: "Security"),
        DailyInsight(text: "The way you were loved as a child is not a verdict. It is a chapter in a longer story you are still writing.", category: "Narrative"),
        DailyInsight(text: "Vulnerability is not weakness. It is the birthplace of connection.", author: "Brene Brown", category: "Courage"),
        DailyInsight(text: "You are allowed to outgrow the coping mechanisms that once saved you.", category: "Growth"),
        DailyInsight(text: "Repair matters more than perfection. Returning to each other after disconnection is the heart of secure love.", category: "Repair"),
        DailyInsight(text: "Your body keeps the score, but it also keeps the compass. Listen to it.", category: "Somatic"),
        DailyInsight(text: "Being alone is not the same as being abandoned. Solitude can be a form of self-love.", category: "Solitude"),
        DailyInsight(text: "The anxious heart does not need more reassurance. It needs to learn to trust its own steadiness.", category: "Anxious"),
    ]

    static func insightOfTheDay() -> DailyInsight {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        return dailyInsights[dayOfYear % dailyInsights.count]
    }
}

// MARK: - Tab Definition

enum AppTab: String, CaseIterable, Identifiable {
    case home = "Home"
    case learn = "Learn"
    case journal = "Journal"
    case coach = "Coach"
    case library = "Library"
    case share = "Share"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .home: return "house"
        case .learn: return "book"
        case .journal: return "pencil.and.scribble"
        case .coach: return "bubble.left.and.text.bubble.right"
        case .library: return "books.vertical"
        case .share: return "square.and.arrow.up.on.square"
        }
    }

    var selectedIcon: String {
        switch self {
        case .home: return "house.fill"
        case .learn: return "book.fill"
        case .journal: return "pencil.and.scribble"
        case .coach: return "bubble.left.and.text.bubble.right.fill"
        case .library: return "books.vertical.fill"
        case .share: return "square.and.arrow.up.on.square.fill"
        }
    }
}
