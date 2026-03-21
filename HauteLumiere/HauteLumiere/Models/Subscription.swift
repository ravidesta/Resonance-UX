// Subscription.swift
// Haute Lumière

import Foundation

// MARK: - Subscription Tiers
enum SubscriptionTier: String, Codable, CaseIterable {
    case meditation = "Lumière Essential"
    case premium = "Lumière Premium"
    case coaching = "Lumière Coaching"
    case unlimited = "Lumière Unlimited"

    var monthlyPrice: Decimal {
        switch self {
        case .meditation: return 50
        case .premium: return 99
        case .coaching: return 198 // premium + coaching add-on
        case .unlimited: return 83.25 // $999/yr
        }
    }

    var annualPrice: Decimal? {
        switch self {
        case .unlimited: return 999
        default: return nil
        }
    }

    var displayPrice: String {
        switch self {
        case .meditation: return "$50/mo"
        case .premium: return "$99/mo"
        case .coaching: return "$99/mo + $99 coaching"
        case .unlimited: return "$999/yr"
        }
    }

    var tagline: String {
        switch self {
        case .meditation: return "Begin Your Luminous Journey"
        case .premium: return "Full Spectrum Wellness"
        case .coaching: return "Guided Transformation"
        case .unlimited: return "Limitless Radiance"
        }
    }

    var features: [SubscriptionFeature] {
        switch self {
        case .meditation:
            return [
                .init(name: "Guided Meditation Library", included: true),
                .init(name: "Breathing Instruction", included: true),
                .init(name: "Yoga Nidra Basics", included: true),
                .init(name: "Nature Soundscapes", included: true),
                .init(name: "Daily Coach Check-ins", included: true),
                .init(name: "Habit Tracker", included: true),
                .init(name: "Night Mode", included: true),
                .init(name: "Full Yoga Nidra Library", included: false),
                .init(name: "Advanced Breathing", included: false),
                .init(name: "Live Coaching Sessions", included: false),
                .init(name: "Weekly Reports", included: false),
                .init(name: "Bespoke Articles", included: false),
            ]
        case .premium:
            return [
                .init(name: "Everything in Essential", included: true),
                .init(name: "100+ Yoga Nidra Sessions", included: true),
                .init(name: "100+ Breathing Experiences", included: true),
                .init(name: "Generative Visualizations", included: true),
                .init(name: "Full Soundscape Library", included: true),
                .init(name: "Binaural Beats Engine", included: true),
                .init(name: "Weekly Coach Reports", included: true),
                .init(name: "Bespoke Articles", included: true),
                .init(name: "Apple Watch Integration", included: true),
                .init(name: "Vision Pro Immersive", included: true),
                .init(name: "Live Coaching Sessions", included: false),
                .init(name: "Executive Coaching", included: false),
            ]
        case .coaching:
            return [
                .init(name: "Everything in Premium", included: true),
                .init(name: "4× 45-min Life Coaching/week", included: true),
                .init(name: "90-min Executive Sessions", included: true),
                .init(name: "Goal Setting & Accountability", included: true),
                .init(name: "Strengths Assessment", included: true),
                .init(name: "Priority Coach Access", included: true),
            ]
        case .unlimited:
            return [
                .init(name: "Everything in All Tiers", included: true),
                .init(name: "Unlimited Coaching Sessions", included: true),
                .init(name: "Priority Scheduling", included: true),
                .init(name: "Exclusive Content Library", included: true),
                .init(name: "Annual Wellness Review", included: true),
                .init(name: "Save $189/year", included: true),
            ]
        }
    }
}

struct SubscriptionFeature: Identifiable {
    let id = UUID()
    let name: String
    let included: Bool
}

// MARK: - Date & Time Products (Companion App)
/// Pricing for the Haute Lumière Date & Time companion app
enum DateTimeProduct: String, Codable, CaseIterable {
    case bespokeReading = "Bespoke Reading"       // $30 — 10-page illustrated PDF + audiobook
    case yearAhead = "Year Ahead"                  // $99 — 30+ page comprehensive forecast
    case relationshipReading = "Relationship Reading" // $99 — synastry across all 5 traditions

    var price: Decimal {
        switch self {
        case .bespokeReading: return 30
        case .yearAhead: return 99
        case .relationshipReading: return 99
        }
    }

    var displayPrice: String {
        switch self {
        case .bespokeReading: return "$30"
        case .yearAhead: return "$99"
        case .relationshipReading: return "$99"
        }
    }

    var description: String {
        switch self {
        case .bespokeReading: return "10-page impeccably illustrated PDF + audiobook narration on any topic"
        case .yearAhead: return "30+ page year-ahead forecast across all life wheel dimensions + all traditions"
        case .relationshipReading: return "Synastry + composite across astrology, numerology, ayurveda, elements, enneagram"
        }
    }

    var includedTraditions: [String] {
        ["Western Astrology", "Numerology", "Ayurveda", "Five Elements", "Enneagram"]
    }
}

// MARK: - Article Model
struct BespokeArticle: Identifiable, Codable {
    let id: UUID
    let title: String
    let subtitle: String
    let body: String
    let imageURL: String?
    let category: ArticleCategory
    let relatedLifeWheelDimension: String?
    let fiveDPhase: FiveDPhase
    let publishDate: Date
    var isRead: Bool
    var isSaved: Bool

    enum ArticleCategory: String, Codable, CaseIterable {
        case mindfulness = "Mindfulness"
        case breathwork = "Breathwork"
        case yogaNidra = "Yoga Nidra"
        case executiveWellness = "Executive Wellness"
        case relationships = "Relationships"
        case nutrition = "Nutrition"
        case movement = "Movement"
        case sleep = "Sleep Science"
        case neuroscience = "Neuroscience"
        case ancientWisdom = "Ancient Wisdom"
        case leadership = "Leadership"
        case creativity = "Creativity"
    }

    init(
        title: String,
        subtitle: String,
        body: String,
        category: ArticleCategory,
        dimension: String? = nil,
        phase: FiveDPhase = .discover
    ) {
        self.id = UUID()
        self.title = title
        self.subtitle = subtitle
        self.body = body
        self.imageURL = nil
        self.category = category
        self.relatedLifeWheelDimension = dimension
        self.fiveDPhase = phase
        self.publishDate = Date()
        self.isRead = false
        self.isSaved = false
    }
}

// MARK: - Weekly Report
struct WeeklyReport: Identifiable, Codable {
    let id: UUID
    let weekStartDate: Date
    let weekEndDate: Date
    let totalMinutesPracticed: Int
    let sessionsCompleted: Int
    let currentStreak: Int
    let longestStreak: Int
    let practiceBreakdown: [String: Int] // SessionType: minutes
    let coachHighlights: [String]
    let winsOfTheWeek: [String]
    let strengthsDisplayed: [String]
    let nextWeekFocus: String
    let inspirationalQuote: String
    let shareableImageURL: String?

    init(weekStart: Date, weekEnd: Date) {
        self.id = UUID()
        self.weekStartDate = weekStart
        self.weekEndDate = weekEnd
        self.totalMinutesPracticed = 0
        self.sessionsCompleted = 0
        self.currentStreak = 0
        self.longestStreak = 0
        self.practiceBreakdown = [:]
        self.coachHighlights = []
        self.winsOfTheWeek = []
        self.strengthsDisplayed = []
        self.nextWeekFocus = ""
        self.inspirationalQuote = ""
        self.shareableImageURL = nil
    }
}

// MARK: - Habit
struct Habit: Identifiable, Codable {
    let id: UUID
    var name: String
    var icon: String
    var targetFrequency: HabitFrequency
    var completions: [Date]
    var createdDate: Date
    var isActive: Bool
    var category: HabitCategory

    enum HabitFrequency: String, Codable, CaseIterable {
        case daily = "Daily"
        case weekdays = "Weekdays"
        case threePerWeek = "3x/week"
        case weekly = "Weekly"
    }

    enum HabitCategory: String, Codable, CaseIterable {
        case meditation = "Meditation"
        case breathing = "Breathing"
        case movement = "Movement"
        case sleep = "Sleep"
        case mindfulness = "Mindfulness"
        case selfCare = "Self-Care"
        case custom = "Custom"
    }

    init(name: String, icon: String, frequency: HabitFrequency, category: HabitCategory) {
        self.id = UUID()
        self.name = name
        self.icon = icon
        self.targetFrequency = frequency
        self.completions = []
        self.createdDate = Date()
        self.isActive = true
        self.category = category
    }

    var currentStreak: Int {
        guard !completions.isEmpty else { return 0 }
        let calendar = Calendar.current
        let sorted = completions.sorted(by: >)
        var streak = 0
        var checkDate = calendar.startOfDay(for: Date())
        for date in sorted {
            let completionDay = calendar.startOfDay(for: date)
            if completionDay == checkDate {
                streak += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
            } else if completionDay < checkDate {
                break
            }
        }
        return streak
    }
}
