// UserProfile.swift
// Haute Lumière

import Foundation

// MARK: - User Profile
struct UserProfile: Codable, Identifiable {
    let id: UUID
    var firstName: String
    var lastName: String
    var email: String
    var avatarData: Data?
    var dateJoined: Date
    var selectedCoach: CoachPersona
    var subscriptionTier: SubscriptionTier
    var preferences: UserPreferences
    var lifeWheel: LifeWheel
    var intakeAnswers: IntakeAnswers
    var coachingHistory: [CoachingNote]

    var displayName: String { firstName }

    init(
        firstName: String = "",
        lastName: String = "",
        email: String = "",
        selectedCoach: CoachPersona = .avaAzure
    ) {
        self.id = UUID()
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.dateJoined = Date()
        self.selectedCoach = selectedCoach
        self.subscriptionTier = .meditation
        self.preferences = UserPreferences()
        self.lifeWheel = LifeWheel()
        self.intakeAnswers = IntakeAnswers()
        self.coachingHistory = []
    }
}

// MARK: - Preferences
struct UserPreferences: Codable {
    var preferredSessionLength: SessionLength = .medium
    var preferredTimeOfDay: TimeOfDay = .morning
    var enableBinauralBeats: Bool = true
    var enableNatureAmbience: Bool = true
    var nightModeAutomatic: Bool = true
    var nightModeStartHour: Int = 20
    var nightModeEndHour: Int = 6
    var hapticFeedback: Bool = true
    var dailyReminderEnabled: Bool = true
    var dailyReminderTime: Date = Calendar.current.date(from: DateComponents(hour: 7, minute: 0)) ?? Date()
    var weeklyReportDay: Weekday = .sunday
    var socialShareEnabled: Bool = true
}

enum SessionLength: String, Codable, CaseIterable {
    case brief = "15 min"
    case medium = "30 min"
    case extended = "45 min"
    case deep = "60 min"

    var minutes: Int {
        switch self {
        case .brief: return 15
        case .medium: return 30
        case .extended: return 45
        case .deep: return 60
        }
    }
}

enum TimeOfDay: String, Codable, CaseIterable {
    case earlyMorning = "Early Morning"
    case morning = "Morning"
    case afternoon = "Afternoon"
    case evening = "Evening"
    case lateNight = "Late Night"
}

enum Weekday: String, Codable, CaseIterable {
    case sunday, monday, tuesday, wednesday, thursday, friday, saturday
}

// MARK: - Life Wheel (Implicit Coaching Framework)
struct LifeWheel: Codable {
    var career: Double = 5.0
    var finances: Double = 5.0
    var health: Double = 5.0
    var relationships: Double = 5.0
    var romance: Double = 5.0
    var personalGrowth: Double = 5.0
    var funRecreation: Double = 5.0
    var physicalEnvironment: Double = 5.0
    var spirituality: Double = 5.0
    var contribution: Double = 5.0

    var dimensions: [(String, Double)] {
        [
            ("Career", career), ("Finances", finances), ("Health", health),
            ("Relationships", relationships), ("Romance", romance),
            ("Personal Growth", personalGrowth), ("Fun & Recreation", funRecreation),
            ("Environment", physicalEnvironment), ("Spirituality", spirituality),
            ("Contribution", contribution)
        ]
    }

    var lowestDimension: String {
        dimensions.min(by: { $0.1 < $1.1 })?.0 ?? "Health"
    }

    var overallBalance: Double {
        dimensions.map(\.1).reduce(0, +) / Double(dimensions.count)
    }
}

// MARK: - Intake
struct IntakeAnswers: Codable {
    var primaryGoals: [WellnessGoal] = []
    var stressLevel: Int = 5
    var sleepQuality: Int = 5
    var meditationExperience: ExperienceLevel = .beginner
    var breathworkExperience: ExperienceLevel = .beginner
    var yogaExperience: ExperienceLevel = .beginner
    var interests: [String] = []
    var challengeAreas: [String] = []
    var coachingGoals: [String] = []
}

enum WellnessGoal: String, Codable, CaseIterable {
    case stressRelief = "Stress Relief"
    case betterSleep = "Better Sleep"
    case focusClarity = "Focus & Clarity"
    case emotionalBalance = "Emotional Balance"
    case physicalWellness = "Physical Wellness"
    case spiritualGrowth = "Spiritual Growth"
    case executivePresence = "Executive Presence"
    case creativity = "Creativity"
    case relationships = "Relationships"
    case confidence = "Confidence"
}

enum ExperienceLevel: String, Codable, CaseIterable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
}

// MARK: - Coaching Notes (Coach's Internal Tracking)
struct CoachingNote: Codable, Identifiable {
    let id: UUID
    let date: Date
    let category: NoteCategory
    let content: String
    let fiveDPhase: FiveDPhase

    enum NoteCategory: String, Codable {
        case win
        case accomplishment
        case strengthDisplayed
        case growthArea
        case insight
        case goalProgress
        case qualityObserved
    }

    init(category: NoteCategory, content: String, phase: FiveDPhase) {
        self.id = UUID()
        self.date = Date()
        self.category = category
        self.content = content
        self.fiveDPhase = phase
    }
}
