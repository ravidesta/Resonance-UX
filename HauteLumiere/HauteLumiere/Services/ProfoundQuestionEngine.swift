// ProfoundQuestionEngine.swift
// Haute Lumière — Profound Question Generator
//
// Every journal entry passes through this engine, which surfaces
// a single profound question worthy of being shared. Not affirmations —
// real questions that make people think. The kind of question that
// makes someone screenshot it and post it.

import Foundation

/// Generates profound, postable questions from journal content.
/// These are NOT affirmations. They're the kind of questions that
/// stop you mid-scroll and make you reconsider everything.
final class ProfoundQuestionEngine: ObservableObject {
    @Published var currentQuestion: ProfoundQuestion?
    @Published var questionHistory: [ProfoundQuestion] = []

    // MARK: - Question Generation

    /// Analyze a journal entry and surface a profound question
    func generateQuestion(from entry: DiaryEntry, phase: FiveDPhase, livingProfile: LivingSystemsProfile) -> ProfoundQuestion {
        let themes = detectThemes(in: entry.textContent)
        let depth = livingProfile.systemVitality
        let growthEdge = livingProfile.primaryGrowthEdge

        // Select question pool based on detected themes + growth edge
        let pool = selectQuestionPool(themes: themes, growthEdge: growthEdge, depth: depth, phase: phase)
        let selected = pool.randomElement() ?? ProfoundQuestion.fallback

        currentQuestion = selected
        questionHistory.append(selected)
        return selected
    }

    // MARK: - Theme Detection

    private func detectThemes(in text: String) -> Set<JournalTheme> {
        let lowered = text.lowercased()
        var themes = Set<JournalTheme>()

        let themeKeywords: [JournalTheme: [String]] = [
            .identity: ["who am i", "myself", "identity", "becoming", "authentic", "real me", "mask"],
            .time: ["time", "rushing", "slow", "waiting", "aging", "years", "moment", "present"],
            .connection: ["love", "relationship", "partner", "friend", "lonely", "together", "distance"],
            .purpose: ["purpose", "meaning", "why", "calling", "mission", "contribute", "legacy"],
            .fear: ["afraid", "fear", "scared", "worry", "anxious", "risk", "safe"],
            .freedom: ["free", "freedom", "trapped", "escape", "choice", "control", "let go"],
            .creativity: ["create", "art", "write", "express", "imagination", "beauty", "build"],
            .loss: ["lost", "grief", "miss", "gone", "ending", "goodbye", "change"],
            .power: ["power", "strength", "weak", "capable", "confidence", "voice", "stand"],
            .stillness: ["quiet", "still", "peace", "silence", "calm", "rest", "breathe"],
            .growth: ["grow", "learn", "evolve", "transform", "better", "progress", "develop"],
            .truth: ["truth", "honest", "lie", "pretend", "real", "illusion", "clarity"],
        ]

        for (theme, keywords) in themeKeywords {
            if keywords.contains(where: { lowered.contains($0) }) {
                themes.insert(theme)
            }
        }

        if themes.isEmpty { themes.insert(.stillness) }
        return themes
    }

    // MARK: - Question Pool Selection

    private func selectQuestionPool(themes: Set<JournalTheme>, growthEdge: String, depth: Double, phase: FiveDPhase) -> [ProfoundQuestion] {
        var pool: [ProfoundQuestion] = []

        for theme in themes {
            pool.append(contentsOf: questionsForTheme(theme))
        }

        // Add growth-edge-specific questions
        pool.append(contentsOf: questionsForGrowthEdge(growthEdge))

        // Add phase-appropriate depth questions
        pool.append(contentsOf: questionsForPhase(phase))

        return pool
    }

    // MARK: - Question Libraries

    private func questionsForTheme(_ theme: JournalTheme) -> [ProfoundQuestion] {
        switch theme {
        case .identity:
            return [
                ProfoundQuestion(text: "Who would you be if you stopped explaining yourself?", theme: theme, attribution: nil),
                ProfoundQuestion(text: "What part of you have you been keeping in the dark that's actually your brightest light?", theme: theme, attribution: nil),
                ProfoundQuestion(text: "If the person you're becoming could send a message to who you are now, what would they whisper?", theme: theme, attribution: nil),
            ]
        case .time:
            return [
                ProfoundQuestion(text: "What would change if you treated this moment as the one you've been waiting for?", theme: theme, attribution: nil),
                ProfoundQuestion(text: "Are you spending your time, or is your time spending you?", theme: theme, attribution: nil),
                ProfoundQuestion(text: "What if urgency is the last thing this moment needs?", theme: theme, attribution: nil),
            ]
        case .connection:
            return [
                ProfoundQuestion(text: "What are you protecting by keeping your distance?", theme: theme, attribution: nil),
                ProfoundQuestion(text: "Who in your life has never heard the thing you most need to say?", theme: theme, attribution: nil),
                ProfoundQuestion(text: "What would your relationships look like if you stopped keeping score?", theme: theme, attribution: nil),
            ]
        case .purpose:
            return [
                ProfoundQuestion(text: "What would you build if you knew it couldn't make you famous?", theme: theme, attribution: nil),
                ProfoundQuestion(text: "What problem in the world bothers you so much that you can't look away?", theme: theme, attribution: nil),
                ProfoundQuestion(text: "If your life had a thesis statement, what would it be right now?", theme: theme, attribution: nil),
            ]
        case .fear:
            return [
                ProfoundQuestion(text: "What if the thing you're most afraid of is already behind you?", theme: theme, attribution: nil),
                ProfoundQuestion(text: "What would you attempt if your fear had no vote?", theme: theme, attribution: nil),
                ProfoundQuestion(text: "Is this fear protecting you, or is it protecting an old version of you?", theme: theme, attribution: nil),
            ]
        case .freedom:
            return [
                ProfoundQuestion(text: "What cage are you decorating instead of leaving?", theme: theme, attribution: nil),
                ProfoundQuestion(text: "What would you stop doing tomorrow if nobody was watching?", theme: theme, attribution: nil),
                ProfoundQuestion(text: "What if freedom isn't the absence of commitment but the presence of choice?", theme: theme, attribution: nil),
            ]
        case .creativity:
            return [
                ProfoundQuestion(text: "What wants to be created through you that you keep postponing?", theme: theme, attribution: nil),
                ProfoundQuestion(text: "When was the last time you made something with no audience in mind?", theme: theme, attribution: nil),
                ProfoundQuestion(text: "What if your creativity isn't a talent to develop but a conversation to join?", theme: theme, attribution: nil),
            ]
        case .loss:
            return [
                ProfoundQuestion(text: "What has this loss made room for that you haven't noticed yet?", theme: theme, attribution: nil),
                ProfoundQuestion(text: "What are you still carrying that was never yours to hold?", theme: theme, attribution: nil),
                ProfoundQuestion(text: "What if grief is just love with nowhere to land?", theme: theme, attribution: nil),
            ]
        case .power:
            return [
                ProfoundQuestion(text: "Where in your life have you been asking for permission you don't need?", theme: theme, attribution: nil),
                ProfoundQuestion(text: "What would your most powerful self do right now — and why aren't you?", theme: theme, attribution: nil),
                ProfoundQuestion(text: "What truth have you been whispering that deserves to be spoken aloud?", theme: theme, attribution: nil),
            ]
        case .stillness:
            return [
                ProfoundQuestion(text: "What would you discover about yourself if you sat still for an hour with no input?", theme: theme, attribution: nil),
                ProfoundQuestion(text: "What is the silence between your thoughts trying to tell you?", theme: theme, attribution: nil),
                ProfoundQuestion(text: "When was the last time you were truly bored — and what did it teach you?", theme: theme, attribution: nil),
            ]
        case .growth:
            return [
                ProfoundQuestion(text: "What version of yourself are you outgrowing right now?", theme: theme, attribution: nil),
                ProfoundQuestion(text: "What if you're not behind — what if you're exactly on time for a path nobody else has walked?", theme: theme, attribution: nil),
                ProfoundQuestion(text: "What would you do differently if growth didn't have to hurt?", theme: theme, attribution: nil),
            ]
        case .truth:
            return [
                ProfoundQuestion(text: "What truth about yourself have you been too comfortable to face?", theme: theme, attribution: nil),
                ProfoundQuestion(text: "What story are you telling yourself that felt true at 20 but isn't anymore?", theme: theme, attribution: nil),
                ProfoundQuestion(text: "If you could only be honest about one thing this year, what would it be?", theme: theme, attribution: nil),
            ]
        }
    }

    private func questionsForGrowthEdge(_ edge: String) -> [ProfoundQuestion] {
        switch edge {
        case "Vitality":
            return [ProfoundQuestion(text: "What would your body tell you if you finally listened?", theme: .stillness, attribution: nil)]
        case "Emotional Flow":
            return [ProfoundQuestion(text: "Which emotion are you most fluent in — and which one do you keep translating?", theme: .identity, attribution: nil)]
        case "Coherence":
            return [ProfoundQuestion(text: "Where is the gap between what you know and how you live?", theme: .truth, attribution: nil)]
        case "Relational Harmony":
            return [ProfoundQuestion(text: "Who in your life do you love — but haven't actually shown this week?", theme: .connection, attribution: nil)]
        case "Purpose":
            return [ProfoundQuestion(text: "What would you work on even if nobody ever saw it?", theme: .purpose, attribution: nil)]
        case "Belonging":
            return [ProfoundQuestion(text: "Where do you feel most yourself — and who is there when you do?", theme: .connection, attribution: nil)]
        case "Presence":
            return [ProfoundQuestion(text: "What room changes when you walk into it?", theme: .power, attribution: nil)]
        case "Transcendence":
            return [ProfoundQuestion(text: "What would remain of you if everything external was stripped away?", theme: .identity, attribution: nil)]
        default:
            return [ProfoundQuestion(text: "What do you know now that you wish you'd trusted earlier?", theme: .truth, attribution: nil)]
        }
    }

    private func questionsForPhase(_ phase: FiveDPhase) -> [ProfoundQuestion] {
        switch phase {
        case .discover:
            return [ProfoundQuestion(text: "What have you been too busy to notice about yourself?", theme: .stillness, attribution: nil)]
        case .define:
            return [ProfoundQuestion(text: "If you could only change one thing about your life, what would it be — and what's really stopping you?", theme: .truth, attribution: nil)]
        case .develop:
            return [ProfoundQuestion(text: "What daily choice are you making that your future self will thank you for?", theme: .growth, attribution: nil)]
        case .deepen:
            return [ProfoundQuestion(text: "What have you been building that you haven't given yourself credit for?", theme: .power, attribution: nil)]
        case .deliver:
            return [ProfoundQuestion(text: "What would happen if you stopped becoming and started being?", theme: .stillness, attribution: nil)]
        }
    }
}

// MARK: - Models

struct ProfoundQuestion: Identifiable, Codable {
    let id: UUID
    let text: String
    let theme: JournalTheme
    let attribution: String?  // nil = original Haute Lumière question
    let createdAt: Date

    init(text: String, theme: JournalTheme, attribution: String?) {
        self.id = UUID()
        self.text = text
        self.theme = theme
        self.attribution = attribution
        self.createdAt = Date()
    }

    static let fallback = ProfoundQuestion(
        text: "What would you do today if you trusted yourself completely?",
        theme: .identity,
        attribution: nil
    )
}

enum JournalTheme: String, Codable, CaseIterable {
    case identity, time, connection, purpose, fear, freedom
    case creativity, loss, power, stillness, growth, truth

    var displayName: String { rawValue.capitalized }

    var icon: String {
        switch self {
        case .identity: return "person.crop.circle"
        case .time: return "clock.arrow.circlepath"
        case .connection: return "heart.circle"
        case .purpose: return "star.circle"
        case .fear: return "bolt.circle"
        case .freedom: return "bird"
        case .creativity: return "paintbrush"
        case .loss: return "leaf"
        case .power: return "flame"
        case .stillness: return "wind"
        case .growth: return "arrow.up.circle"
        case .truth: return "eye.circle"
        }
    }
}

// MARK: - Diary Entry Model
struct DiaryEntry: Identifiable, Codable {
    let id: UUID
    var textContent: String
    var audioFileURL: String?
    var videoFileURL: String?
    var selfieImageData: Data?
    var mood: DiaryMood
    var profoundQuestion: ProfoundQuestion?
    var isSharedToStudio: Bool
    let createdAt: Date
    var updatedAt: Date

    enum DiaryMood: String, Codable, CaseIterable {
        case radiant = "Radiant"
        case peaceful = "Peaceful"
        case contemplative = "Contemplative"
        case heavy = "Heavy"
        case fiery = "Fiery"
        case tender = "Tender"
        case expansive = "Expansive"

        var icon: String {
            switch self {
            case .radiant: return "sun.max.fill"
            case .peaceful: return "leaf.fill"
            case .contemplative: return "moon.fill"
            case .heavy: return "cloud.fill"
            case .fiery: return "flame.fill"
            case .tender: return "heart.fill"
            case .expansive: return "sparkles"
            }
        }

        var accentColor: String {
            switch self {
            case .radiant: return "D4AF37"
            case .peaceful: return "7BA7C4"
            case .contemplative: return "9A8AC5"
            case .heavy: return "5C6B73"
            case .fiery: return "C45A5A"
            case .tender: return "C5908A"
            case .expansive: return "C5A059"
            }
        }
    }

    init(textContent: String = "", mood: DiaryMood = .contemplative) {
        self.id = UUID()
        self.textContent = textContent
        self.mood = mood
        self.isSharedToStudio = false
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

// MARK: - Vetted Profound Quotes (for Apple Watch)
/// Real, vetted quotes from real people. Not affirmations.
/// The kind that make you sound smarter the more you wear this watch.
struct ProfoundQuoteLibrary {
    static let quotes: [(text: String, author: String)] = [
        // Philosophy
        ("The only true wisdom is in knowing you know nothing.", "Socrates"),
        ("He who has a why to live for can bear almost any how.", "Friedrich Nietzsche"),
        ("The unexamined life is not worth living.", "Socrates"),
        ("We suffer more in imagination than in reality.", "Seneca"),
        ("No man is free who is not master of himself.", "Epictetus"),
        ("The soul becomes dyed with the color of its thoughts.", "Marcus Aurelius"),
        ("Between stimulus and response there is a space. In that space is our freedom.", "Viktor Frankl"),

        // Literature & Poetry
        ("We read to know we are not alone.", "C.S. Lewis"),
        ("The wound is the place where the Light enters you.", "Rumi"),
        ("Not all those who wander are lost.", "J.R.R. Tolkien"),
        ("One must still have chaos in oneself to give birth to a dancing star.", "Friedrich Nietzsche"),
        ("I am not what happened to me. I am what I choose to become.", "Carl Jung"),
        ("The privilege of a lifetime is to become who you truly are.", "Carl Jung"),
        ("Until you make the unconscious conscious, it will direct your life and you will call it fate.", "Carl Jung"),

        // Science & Consciousness
        ("The measure of intelligence is the ability to change.", "Albert Einstein"),
        ("Reality is merely an illusion, albeit a very persistent one.", "Albert Einstein"),
        ("The most beautiful thing we can experience is the mysterious.", "Albert Einstein"),
        ("If you want to find the secrets of the universe, think in terms of energy, frequency and vibration.", "Nikola Tesla"),

        // Eastern Wisdom
        ("When you realize nothing is lacking, the whole world belongs to you.", "Lao Tzu"),
        ("The journey of a thousand miles begins with a single step.", "Lao Tzu"),
        ("Knowing others is intelligence; knowing yourself is true wisdom.", "Lao Tzu"),
        ("What you think, you become. What you feel, you attract. What you imagine, you create.", "Buddha"),
        ("Peace comes from within. Do not seek it without.", "Buddha"),
        ("The mind is everything. What you think you become.", "Buddha"),
        ("In the middle of difficulty lies opportunity.", "Albert Einstein"),

        // Modern Wisdom
        ("Your task is not to seek for love, but merely to seek and find all the barriers within yourself that you have built against it.", "Rumi"),
        ("Don't ask what the world needs. Ask what makes you come alive, and go do it.", "Howard Thurman"),
        ("The most common way people give up their power is by thinking they don't have any.", "Alice Walker"),
        ("The quality of your life is determined by the quality of your questions.", "Tony Robbins"),
        ("You do not rise to the level of your goals. You fall to the level of your systems.", "James Clear"),
        ("Almost everything will work again if you unplug it for a few minutes, including you.", "Anne Lamott"),
        ("Be yourself; everyone else is already taken.", "Oscar Wilde"),
        ("The best time to plant a tree was 20 years ago. The second best time is now.", "Chinese Proverb"),

        // Leadership & Performance
        ("A leader is one who knows the way, goes the way, and shows the way.", "John C. Maxwell"),
        ("The greatest glory in living lies not in never falling, but in rising every time we fall.", "Nelson Mandela"),
        ("It is not the strongest of the species that survives, nor the most intelligent, but the one most responsive to change.", "Charles Darwin"),
        ("What lies behind us and what lies before us are tiny matters compared to what lies within us.", "Ralph Waldo Emerson"),

        // Depth Psychology & Consciousness
        ("Where your fear is, there is your task.", "Carl Jung"),
        ("People will do anything, no matter how absurd, to avoid facing their own souls.", "Carl Jung"),
        ("Loneliness does not come from having no people around, but from being unable to communicate the things that seem important to oneself.", "Carl Jung"),
        ("Your visions will become clear only when you can look into your own heart.", "Carl Jung"),
    ]

    /// Get a quote for the current hour — rotates throughout the day
    static func quoteForNow() -> (text: String, author: String) {
        let hour = Calendar.current.component(.hour, from: Date())
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let index = (dayOfYear * 24 + hour) % quotes.count
        return quotes[index]
    }

    /// Get a curated set of quotes for the day (4 quotes, one per ~6 hours)
    static func dailyQuotes() -> [(text: String, author: String)] {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        return (0..<4).map { slot in
            let index = (dayOfYear * 4 + slot) % quotes.count
            return quotes[index]
        }
    }
}
