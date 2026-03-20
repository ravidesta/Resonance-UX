// Luminous Constructive Development™ Core Domain Models — Android/Kotlin
// Mirrors Swift models for cross-platform parity

package com.luminous.journey.domain.model

import java.util.UUID
import java.util.Date
import kotlinx.serialization.Serializable

// MARK: - Developmental Orders (Kegan's Five Orders of Consciousness)

@Serializable
enum class DevelopmentalOrder(val order: Int) {
    IMPULSIVE(1),
    IMPERIAL(2),
    SOCIALIZED(3),
    SELF_AUTHORING(4),
    SELF_TRANSFORMING(5);

    val displayName: String get() = when (this) {
        IMPULSIVE -> "Impulsive Mind"
        IMPERIAL -> "Imperial Mind"
        SOCIALIZED -> "Socialized Mind"
        SELF_AUTHORING -> "Self-Authoring Mind"
        SELF_TRANSFORMING -> "Self-Transforming Mind"
    }

    val description: String get() = when (this) {
        IMPULSIVE -> "Experience organized through immediate perceptions and impulses. Radical presence and sensory immediacy."
        IMPERIAL -> "Impulses coordinated into durable needs and interests. Foundation of purposeful action across time."
        SOCIALIZED -> "Deep capacity for empathy, loyalty, and relational attunement. Meaning drawn from the social surround."
        SELF_AUTHORING -> "Internal authority and self-generated values guide decisions. Capacity for principled autonomy."
        SELF_TRANSFORMING -> "Multiple frameworks held simultaneously. Comfort with paradox and the incomplete. Deepening wholeness."
    }

    val gifts: List<String> get() = when (this) {
        IMPULSIVE -> listOf("Radical presence", "Sensory aliveness", "Total absorption")
        IMPERIAL -> listOf("Purposeful action", "Self-direction", "Goal coordination")
        SOCIALIZED -> listOf("Deep empathy", "Loyalty", "Relational attunement", "Belonging")
        SELF_AUTHORING -> listOf("Principled autonomy", "Internal compass", "Moral courage", "Boundary setting")
        SELF_TRANSFORMING -> listOf("Paradox-friendliness", "Multi-perspective holding", "Compassionate presence")
    }

    val shadow: String get() = when (this) {
        IMPULSIVE -> "No stable self-reflection; impulse-driven"
        IMPERIAL -> "Others seen as instruments; limited genuine empathy"
        SOCIALIZED -> "Cannot author values independent of external validation"
        SELF_AUTHORING -> "Rigidity; ideology as identity; subtle contempt for dependency"
        SELF_TRANSFORMING -> "Paralysis of perspective; evasion of commitment; drift"
    }
}

// MARK: - Subject-Object Dynamics

@Serializable
enum class LifeDomain {
    PERSONAL, PROFESSIONAL, RELATIONAL, EMOTIONAL, SPIRITUAL, SOMATIC
}

@Serializable
data class SubjectObjectState(
    val id: String = UUID.randomUUID().toString(),
    val domain: LifeDomain,
    val currentSubject: String,
    val emergingObject: String? = null,
    val somaticSignature: String? = null,
    val reflectionNotes: String? = null,
    val timestamp: Long = System.currentTimeMillis()
)

// MARK: - Somatic Seasons

@Serializable
enum class SomaticSeason {
    COMPRESSION, TREMBLING, EMPTINESS, EMERGENCE, INTEGRATION;

    val displayName: String get() = name.lowercase().replaceFirstChar { it.uppercase() }

    val description: String get() = when (this) {
        COMPRESSION -> "Increasing tension. The old structure strains against life demands it cannot accommodate."
        TREMBLING -> "Instability between structures. Waves of emotion without clear trigger. The system is reorganizing."
        EMPTINESS -> "Surprising stillness. Formlessness. Waiting. Not-yet-knowing."
        EMERGENCE -> "New patterns taking shape — first in the body, before cognition catches up."
        INTEGRATION -> "The new structure consolidates. What was effortful becomes natural."
    }

    val bodyPrompt: String get() = when (this) {
        COMPRESSION -> "Where do you feel tightness or constriction right now?"
        TREMBLING -> "What sensations of instability or movement do you notice?"
        EMPTINESS -> "Where do you feel spaciousness or quiet in your body?"
        EMERGENCE -> "What new sensations or patterns are you beginning to notice?"
        INTEGRATION -> "Where does your body feel settled and at home?"
    }
}

// MARK: - Assessment

@Serializable
data class DomainAssessment(
    val id: String = UUID.randomUUID().toString(),
    val domain: LifeDomain,
    val primaryOrder: DevelopmentalOrder,
    val emergingOrder: DevelopmentalOrder? = null,
    val subjectTerritory: List<String>,
    val objectTerritory: List<String>,
    val growingEdge: String? = null,
    val confidence: Double = 0.5
)

@Serializable
data class DevelopmentalAssessment(
    val id: String = UUID.randomUUID().toString(),
    val userId: String,
    val date: Long = System.currentTimeMillis(),
    val domainAssessments: List<DomainAssessment>,
    val overallReflection: String? = null,
    val somaticSeason: SomaticSeason? = null,
    val guideNotes: String? = null
)

// MARK: - Journal

@Serializable
enum class JournalEntryType {
    FREE_WRITE, SUBJECT_SCAN, RELATIONAL_MIRROR, SOMATIC_WITNESS,
    SPIRAL_MAPPING, GRATITUDE_FOR_SELF, SEASON_INQUIRY, GUIDE_DIALOGUE
}

@Serializable
enum class Mood {
    SPACIOUS, TENDER, ACTIVATED, CONTRACTED, CURIOUS, GRIEVING, EMERGING, SETTLED
}

@Serializable
data class BodyLocation(
    val area: String,
    val sensation: String,
    val intensity: Double
)

@Serializable
data class JournalEntry(
    val id: String = UUID.randomUUID().toString(),
    val timestamp: Long = System.currentTimeMillis(),
    val type: JournalEntryType,
    val prompt: String? = null,
    val content: String,
    val somaticNotes: String? = null,
    val bodyLocations: List<BodyLocation>? = null,
    val developmentalOrder: DevelopmentalOrder? = null,
    val season: SomaticSeason? = null,
    val mood: Mood? = null,
    val isShareable: Boolean = false,
    val shareExcerpt: String? = null
)

// MARK: - Somatic Practices

@Serializable
enum class PracticeCategory {
    BODY_SCAN, BREATHWORK, MOVEMENT, SOMATIC_PAUSE, GROUNDING, NERVOUS_SYSTEM, RELATIONAL_SOMATIC
}

@Serializable
data class SomaticPractice(
    val id: String = UUID.randomUUID().toString(),
    val name: String,
    val description: String,
    val durationSeconds: Long,
    val category: PracticeCategory,
    val season: SomaticSeason? = null,
    val audioAssetKey: String? = null,
    val videoAssetKey: String? = null,
    val instructions: List<String>,
    val developmentalContext: String? = null,
    val isShareable: Boolean = false
)

// MARK: - eBook

@Serializable
data class EBookChapter(
    val id: String = UUID.randomUUID().toString(),
    val number: Int,
    val title: String,
    val epigraph: String? = null,
    val sections: List<EBookSection>,
    val wordCount: Int
)

@Serializable
data class EBookSection(
    val id: String = UUID.randomUUID().toString(),
    val title: String,
    val body: String,
    val type: String // prose, caseStudy, practice, reflection, luminousInvitation, pitfall, safetyNote
)

@Serializable
data class ReadingPosition(
    val chapterIndex: Int,
    val sectionIndex: Int,
    val paragraphIndex: Int,
    val scrollOffset: Double,
    val lastRead: Long = System.currentTimeMillis()
)

@Serializable
data class Highlight(
    val id: String = UUID.randomUUID().toString(),
    val chapterIndex: Int,
    val sectionIndex: Int,
    val startChar: Int,
    val endChar: Int,
    val text: String,
    val color: String,
    val note: String? = null,
    val isShareable: Boolean = false,
    val timestamp: Long = System.currentTimeMillis()
)

@Serializable
data class EBook(
    val id: String = UUID.randomUUID().toString(),
    val title: String,
    val subtitle: String,
    val author: String,
    val coverAssetKey: String,
    val chapters: List<EBookChapter>,
    val totalWordCount: Int,
    val estimatedReadingTimeSeconds: Long,
    var currentPosition: ReadingPosition? = null,
    val bookmarks: MutableList<ReadingPosition> = mutableListOf(),
    val highlights: MutableList<Highlight> = mutableListOf()
)

// MARK: - Audiobook

@Serializable
data class AudioChapter(
    val id: String = UUID.randomUUID().toString(),
    val number: Int,
    val title: String,
    val audioAssetKey: String,
    val durationSeconds: Long,
    val startTimeSeconds: Long
)

@Serializable
data class AudioPosition(
    val chapterIndex: Int,
    val timeOffsetSeconds: Long,
    val lastPlayed: Long = System.currentTimeMillis()
)

@Serializable
data class Audiobook(
    val id: String = UUID.randomUUID().toString(),
    val title: String,
    val narrator: String,
    val totalDurationSeconds: Long,
    val chapters: List<AudioChapter>,
    var currentPosition: AudioPosition? = null,
    var playbackSpeed: Double = 1.0,
    var sleepTimerMinutes: Int? = null
)

// MARK: - Guide / AI Tutor-Coach

@Serializable
enum class GuideSessionType {
    EXPLORATION, SOMATIC_GUIDANCE, REFLECTION_SUPPORT, ASSESSMENT_DEBRIEF,
    CRISIS_SUPPORT, PRACTICE_GUIDANCE, BOOK_DISCUSSION
}

@Serializable
enum class GuideMessageRole { USER, GUIDE, SYSTEM }

@Serializable
data class GuideMessage(
    val id: String = UUID.randomUUID().toString(),
    val role: GuideMessageRole,
    val content: String,
    val somaticPrompt: String? = null,
    val timestamp: Long = System.currentTimeMillis()
)

@Serializable
data class GuideSession(
    val id: String = UUID.randomUUID().toString(),
    val userId: String,
    val startTime: Long = System.currentTimeMillis(),
    val messages: MutableList<GuideMessage> = mutableListOf(),
    val sessionType: GuideSessionType
)

// MARK: - Social Sharing

@Serializable
enum class ShareType {
    QUOTE, HIGHLIGHT, REFLECTION, INSIGHT, PRACTICE_COMPLETION, MILESTONE
}

@Serializable
enum class BackgroundStyle {
    FOREST_GOLD, CREAM_SERIF, DEEP_REST_GLOW, SOMATIC_WAVE, SPIRAL_PATTERN
}

@Serializable
data class ShareableContent(
    val id: String = UUID.randomUUID().toString(),
    val type: ShareType,
    val title: String,
    val excerpt: String,
    val attributionLine: String = "From Luminous Constructive Development™",
    val backgroundStyle: BackgroundStyle,
    val sourceChapter: Int? = null,
    val generatedImageKey: String? = null,
    val deepLink: String
)

// MARK: - Community

@Serializable
enum class IntentionalStatus {
    REFLECTING, OPEN_TO_CONNECT, IN_PRACTICE, DEEP_WORK, RESTING
}

@Serializable
enum class PostType {
    REFLECTION, INSIGHT, QUESTION, SHARED_HIGHLIGHT, SHARED_PRACTICE, GRATITUDE
}

@Serializable
data class CommunityPost(
    val id: String = UUID.randomUUID().toString(),
    val authorId: String,
    val content: String,
    val type: PostType,
    val timestamp: Long = System.currentTimeMillis(),
    val resonanceCount: Int = 0
)
