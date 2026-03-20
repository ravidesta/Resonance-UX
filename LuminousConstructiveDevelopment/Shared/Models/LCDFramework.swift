// MARK: - Luminous Constructive Development™ Core Domain Models
// Shared across iOS, iPadOS, macOS, watchOS
// Mirror implementations exist for Android (Kotlin) and Web (TypeScript)

import Foundation

// MARK: - Developmental Orders (Kegan's Five Orders of Consciousness)

enum DevelopmentalOrder: Int, Codable, CaseIterable, Identifiable {
    case impulsive = 1        // First Order
    case imperial = 2         // Second Order
    case socialized = 3       // Third Order
    case selfAuthoring = 4    // Fourth Order
    case selfTransforming = 5 // Fifth Order

    var id: Int { rawValue }

    var name: String {
        switch self {
        case .impulsive:        return "Impulsive Mind"
        case .imperial:         return "Imperial Mind"
        case .socialized:       return "Socialized Mind"
        case .selfAuthoring:    return "Self-Authoring Mind"
        case .selfTransforming: return "Self-Transforming Mind"
        }
    }

    var description: String {
        switch self {
        case .impulsive:
            return "Experience organized through immediate perceptions and impulses. Radical presence and sensory immediacy."
        case .imperial:
            return "Impulses coordinated into durable needs and interests. Foundation of purposeful action across time."
        case .socialized:
            return "Deep capacity for empathy, loyalty, and relational attunement. Meaning drawn from the social surround."
        case .selfAuthoring:
            return "Internal authority and self-generated values guide decisions. Capacity for principled autonomy."
        case .selfTransforming:
            return "Multiple frameworks held simultaneously. Comfort with paradox and the incomplete. Deepening wholeness."
        }
    }

    var gifts: [String] {
        switch self {
        case .impulsive:        return ["Radical presence", "Sensory aliveness", "Total absorption"]
        case .imperial:         return ["Purposeful action", "Self-direction", "Goal coordination"]
        case .socialized:       return ["Deep empathy", "Loyalty", "Relational attunement", "Belonging"]
        case .selfAuthoring:    return ["Principled autonomy", "Internal compass", "Moral courage", "Boundary setting"]
        case .selfTransforming: return ["Paradox-friendliness", "Multi-perspective holding", "Compassionate presence"]
        }
    }

    var shadow: String {
        switch self {
        case .impulsive:        return "No stable self-reflection; impulse-driven"
        case .imperial:         return "Others seen as instruments; limited genuine empathy"
        case .socialized:       return "Cannot author values independent of external validation"
        case .selfAuthoring:    return "Rigidity; ideology as identity; subtle contempt for dependency"
        case .selfTransforming: return "Paralysis of perspective; evasion of commitment; drift"
        }
    }
}

// MARK: - Subject-Object Dynamics

struct SubjectObjectState: Codable, Identifiable {
    let id: UUID
    var domain: LifeDomain
    var currentSubject: String      // What has you — invisible, automatic
    var emergingObject: String?     // What you're beginning to see
    var somaticSignature: String?   // Body's felt sense
    var reflectionNotes: String?
    var timestamp: Date

    init(domain: LifeDomain, currentSubject: String, emergingObject: String? = nil,
         somaticSignature: String? = nil, reflectionNotes: String? = nil) {
        self.id = UUID()
        self.domain = domain
        self.currentSubject = currentSubject
        self.emergingObject = emergingObject
        self.somaticSignature = somaticSignature
        self.reflectionNotes = reflectionNotes
        self.timestamp = Date()
    }
}

enum LifeDomain: String, Codable, CaseIterable {
    case personal       = "Personal"
    case professional   = "Professional"
    case relational     = "Relational"
    case emotional      = "Emotional"
    case spiritual      = "Spiritual"
    case somatic        = "Somatic"
}

// MARK: - Somatic Seasons

enum SomaticSeason: String, Codable, CaseIterable {
    case compression = "Compression"
    case trembling   = "Trembling"
    case emptiness   = "Emptiness"
    case emergence   = "Emergence"
    case integration = "Integration"

    var description: String {
        switch self {
        case .compression: return "Increasing tension. The old structure strains against life demands it cannot accommodate."
        case .trembling:   return "Instability between structures. Waves of emotion without clear trigger. The system is reorganizing."
        case .emptiness:   return "Surprising stillness. Formlessness. Waiting. Not-yet-knowing."
        case .emergence:   return "New patterns taking shape — first in the body, before cognition catches up."
        case .integration: return "The new structure consolidates. What was effortful becomes natural."
        }
    }

    var bodyPrompt: String {
        switch self {
        case .compression: return "Where do you feel tightness or constriction right now?"
        case .trembling:   return "What sensations of instability or movement do you notice?"
        case .emptiness:   return "Where do you feel spaciousness or quiet in your body?"
        case .emergence:   return "What new sensations or patterns are you beginning to notice?"
        case .integration: return "Where does your body feel settled and at home?"
        }
    }
}

// MARK: - Assessment

struct DevelopmentalAssessment: Codable, Identifiable {
    let id: UUID
    var userId: String
    var date: Date
    var domainAssessments: [DomainAssessment]
    var overallReflection: String?
    var somaticSeason: SomaticSeason?
    var guideNotes: String?         // AI tutor/coach observations

    struct DomainAssessment: Codable, Identifiable {
        let id: UUID
        var domain: LifeDomain
        var primaryOrder: DevelopmentalOrder
        var emergingOrder: DevelopmentalOrder?
        var subjectTerritory: [String]
        var objectTerritory: [String]
        var growingEdge: String?
        var confidence: Double      // 0.0 - 1.0
    }
}

// MARK: - Reflection Journal

struct JournalEntry: Codable, Identifiable {
    let id: UUID
    var timestamp: Date
    var type: EntryType
    var prompt: String?
    var content: String
    var somaticNotes: String?
    var bodyLocations: [BodyLocation]?
    var developmentalOrder: DevelopmentalOrder?
    var season: SomaticSeason?
    var mood: Mood?
    var isShareable: Bool           // Social sharing opt-in
    var shareExcerpt: String?       // Beautiful quote for social

    enum EntryType: String, Codable {
        case freeWrite          = "Free Write"
        case subjectScan        = "Subject Scan"
        case relationalMirror   = "Relational Mirror"
        case somaticWitness     = "Somatic Witness"
        case spiralMapping      = "Spiral Mapping"
        case gratitudeForSelf   = "Gratitude for Earlier Selves"
        case seasonInquiry      = "Season Inquiry"
        case guideDialogue      = "Guide Dialogue"
    }

    enum Mood: String, Codable, CaseIterable {
        case spacious, tender, activated, contracted, curious, grieving, emerging, settled
    }

    struct BodyLocation: Codable {
        var area: String           // "chest", "jaw", "belly", "shoulders", etc.
        var sensation: String      // "tightness", "warmth", "trembling", etc.
        var intensity: Double      // 0.0 - 1.0
    }
}

// MARK: - Somatic Practices

struct SomaticPractice: Codable, Identifiable {
    let id: UUID
    var name: String
    var description: String
    var duration: TimeInterval
    var category: Category
    var season: SomaticSeason?
    var audioAssetKey: String?
    var videoAssetKey: String?
    var instructions: [String]
    var developmentalContext: String?
    var isShareable: Bool

    enum Category: String, Codable, CaseIterable {
        case bodyScan           = "Body Scan"
        case breathwork         = "Breathwork"
        case movement           = "Movement"
        case somaticPause       = "Somatic Pause"
        case groundingExercise  = "Grounding"
        case nervousSystem      = "Nervous System"
        case relationalSomatic  = "Relational Somatic"
    }
}

// MARK: - Learning Path

struct LearningPath: Codable, Identifiable {
    let id: UUID
    var title: String
    var description: String
    var chapters: [Chapter]
    var currentChapter: Int
    var estimatedOrder: DevelopmentalOrder
    var isComplete: Bool

    struct Chapter: Codable, Identifiable {
        let id: UUID
        var number: Int
        var title: String
        var sections: [Section]
        var reflectionQuestions: [String]
        var practices: [UUID]       // References to SomaticPractice
        var isUnlocked: Bool
        var isComplete: Bool
        var readingProgress: Double // 0.0 - 1.0
    }

    struct Section: Codable, Identifiable {
        let id: UUID
        var title: String
        var content: String         // Rich text / markdown
        var type: SectionType
    }

    enum SectionType: String, Codable {
        case text, caseStudy, practice, reflection, luminousInvitation
    }
}

// MARK: - eBook

struct EBook: Codable, Identifiable {
    let id: UUID
    var title: String
    var subtitle: String
    var author: String
    var coverAssetKey: String
    var chapters: [EBookChapter]
    var totalWordCount: Int
    var estimatedReadingTime: TimeInterval
    var currentPosition: ReadingPosition?
    var bookmarks: [Bookmark]
    var highlights: [Highlight]

    struct EBookChapter: Codable, Identifiable {
        let id: UUID
        var number: Int
        var title: String
        var epigraph: String?
        var sections: [EBookSection]
        var wordCount: Int
    }

    struct EBookSection: Codable, Identifiable {
        let id: UUID
        var title: String
        var body: String            // Markdown / rich text
        var type: SectionType

        enum SectionType: String, Codable {
            case prose, caseStudy, practice, reflection, luminousInvitation, pitfall, safetyNote
        }
    }

    struct ReadingPosition: Codable {
        var chapterIndex: Int
        var sectionIndex: Int
        var paragraphIndex: Int
        var scrollOffset: Double
        var lastRead: Date
    }

    struct Bookmark: Codable, Identifiable {
        let id: UUID
        var chapterIndex: Int
        var sectionIndex: Int
        var note: String?
        var timestamp: Date
    }

    struct Highlight: Codable, Identifiable {
        let id: UUID
        var chapterIndex: Int
        var sectionIndex: Int
        var range: Range<Int>       // Character range
        var text: String
        var color: HighlightColor
        var note: String?
        var isShareable: Bool       // Can be shared to social
        var timestamp: Date

        enum HighlightColor: String, Codable {
            case gold, forest, somatic, relational, integration
        }
    }
}

// MARK: - Audiobook

struct Audiobook: Codable, Identifiable {
    let id: UUID
    var title: String
    var narrator: String
    var totalDuration: TimeInterval
    var chapters: [AudioChapter]
    var currentPosition: AudioPosition?
    var playbackSpeed: Double
    var sleepTimerMinutes: Int?
    var bookmarks: [AudioBookmark]

    struct AudioChapter: Codable, Identifiable {
        let id: UUID
        var number: Int
        var title: String
        var audioAssetKey: String
        var duration: TimeInterval
        var startTime: TimeInterval
    }

    struct AudioPosition: Codable {
        var chapterIndex: Int
        var timeOffset: TimeInterval
        var lastPlayed: Date
    }

    struct AudioBookmark: Codable, Identifiable {
        let id: UUID
        var chapterIndex: Int
        var timeOffset: TimeInterval
        var note: String?
        var timestamp: Date
    }
}

// MARK: - Community

struct CommunityGroup: Codable, Identifiable {
    let id: UUID
    var name: String
    var description: String
    var developmentalFocus: DevelopmentalOrder?
    var members: [CommunityMember]
    var posts: [CommunityPost]
    var isPublic: Bool
}

struct CommunityMember: Codable, Identifiable {
    let id: UUID
    var displayName: String
    var avatarAssetKey: String?
    var joinDate: Date
    var intentionalStatus: IntentionalStatus

    enum IntentionalStatus: String, Codable {
        case reflecting     = "Reflecting"
        case openToConnect  = "Open to connect"
        case inPractice     = "In practice"
        case deepWork       = "Deep work"
        case resting        = "Resting"
    }
}

struct CommunityPost: Codable, Identifiable {
    let id: UUID
    var authorId: UUID
    var content: String
    var type: PostType
    var sharedHighlight: EBook.Highlight?
    var sharedPractice: UUID?
    var timestamp: Date
    var resonanceCount: Int         // Not "likes" — "resonances"

    enum PostType: String, Codable {
        case reflection, insight, question, sharedHighlight, sharedPractice, gratitude
    }
}

// MARK: - Guide / AI Tutor-Coach

struct GuideSession: Codable, Identifiable {
    let id: UUID
    var userId: String
    var startTime: Date
    var messages: [GuideMessage]
    var context: GuideContext
    var sessionType: SessionType

    enum SessionType: String, Codable {
        case exploration        = "Exploration"
        case somaticGuidance    = "Somatic Guidance"
        case reflectionSupport  = "Reflection Support"
        case assessmentDebrief  = "Assessment Debrief"
        case crisisSupport      = "Gentle Holding"
        case practiceGuidance   = "Practice Guidance"
        case bookDiscussion     = "Book Discussion"
    }

    struct GuideMessage: Codable, Identifiable {
        let id: UUID
        var role: Role
        var content: String
        var somaticPrompt: String?  // Guide may offer somatic check-ins
        var timestamp: Date

        enum Role: String, Codable {
            case user, guide, system
        }
    }

    struct GuideContext: Codable {
        var currentAssessment: DevelopmentalAssessment?
        var recentJournalEntries: [UUID]
        var currentSeason: SomaticSeason?
        var readingPosition: EBook.ReadingPosition?
        var preferredPractices: [UUID]
    }
}

// MARK: - Social Sharing

struct ShareableContent: Codable, Identifiable {
    let id: UUID
    var type: ShareType
    var title: String
    var excerpt: String             // Beautiful, shareable text
    var attributionLine: String     // "From Luminous Constructive Development™"
    var backgroundStyle: BackgroundStyle
    var sourceChapter: Int?
    var generatedImageKey: String?  // Pre-rendered share card
    var deepLink: String            // Universal link back to app

    enum ShareType: String, Codable {
        case quote, highlight, reflection, insight, practiceCompletion, milestone
    }

    enum BackgroundStyle: String, Codable {
        case forestGold, creamSerif, deepRestGlow, somaticWave, spiralPattern
    }
}

// MARK: - Ecosystem Integration

struct ResonanceIntegration: Codable {
    var dailyFlowSync: Bool         // Sync practices with Daily Flow phases
    var resonanceCommsSync: Bool    // Share with Inner Circle
    var writerSync: Bool            // Export reflections to Writer
    var iPadProviderSync: Bool      // Coach/therapist integration
    var watchSync: Bool             // Somatic tracking on watch

    struct DailyFlowMapping: Codable {
        var ascendPractices: [UUID]     // Morning somatic practices
        var zenithReflections: [UUID]   // Midday check-ins
        var descentJournaling: [UUID]   // Evening journaling
        var restContemplation: [UUID]   // Night contemplative practices
    }

    struct ProviderIntegration: Codable {
        var coachId: String?
        var sharedAssessments: [UUID]
        var sharedJournalEntries: [UUID]
        var appointmentSync: Bool
        var progressReports: Bool
    }
}
