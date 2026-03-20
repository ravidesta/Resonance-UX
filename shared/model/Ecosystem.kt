/**
 * Ecosystem & Community Domain Models
 *
 * Models that power the network-effect layer of the Luminous Integral
 * Architecture™ platform: user profiles with developmental tracking,
 * community spaces, cross-platform synchronisation, and a plugin
 * interface for connecting to the broader Luminous Prosperity app suite.
 *
 * All types are pure Kotlin Multiplatform data classes with no platform
 * dependencies.
 */
package com.luminous.resonance.model

// ──────────────────────────────────────────────
// User Profile & Developmental Tracking
// ──────────────────────────────────────────────

/**
 * Developmental stage based on integral theory altitude / colour codes.
 *
 * Each level represents a centre of gravity in the reader's developmental
 * unfolding, not a rigid label. Users may exhibit capacities across
 * multiple levels simultaneously.
 */
enum class DevelopmentalLevel {
    /** Infrared — archaic / sensorimotor. */
    INFRARED,
    /** Magenta — magical / animistic. */
    MAGENTA,
    /** Red — egocentric / power. */
    RED,
    /** Amber — mythic / conformist. */
    AMBER,
    /** Orange — rational / achiever. */
    ORANGE,
    /** Green — pluralistic / sensitive. */
    GREEN,
    /** Teal — integral / systemic. */
    TEAL,
    /** Turquoise — holistic / global. */
    TURQUOISE,
    /** Indigo — para-mind / super-integral. */
    INDIGO,
    /** Violet — meta-mind. */
    VIOLET,
    /** Ultraviolet — overmind. */
    ULTRAVIOLET,
    /** Clear Light — supermind. */
    CLEAR_LIGHT,
}

/**
 * A snapshot of a user's self-assessed or system-derived developmental profile.
 *
 * @property cognitiveLevel       Centre of gravity for cognitive development.
 * @property emotionalLevel       Centre of gravity for emotional intelligence.
 * @property somaticLevel         Centre of gravity for somatic / embodied awareness.
 * @property interpersonalLevel   Centre of gravity for relational / interpersonal skill.
 * @property assessmentDate       Epoch milliseconds of the last formal assessment.
 * @property notes                Freeform notes or AI-generated insights.
 */
data class DevelopmentalProfile(
    val cognitiveLevel: DevelopmentalLevel = DevelopmentalLevel.ORANGE,
    val emotionalLevel: DevelopmentalLevel = DevelopmentalLevel.ORANGE,
    val somaticLevel: DevelopmentalLevel = DevelopmentalLevel.ORANGE,
    val interpersonalLevel: DevelopmentalLevel = DevelopmentalLevel.ORANGE,
    val assessmentDate: Long? = null,
    val notes: String = "",
)

/**
 * Represents a user within the Luminous ecosystem.
 *
 * @property id                Unique user identifier.
 * @property displayName       Public display name.
 * @property email             Email address (used for auth, not displayed publicly).
 * @property avatarUrl         Profile image URL.
 * @property bio               Short biography / intention statement.
 * @property developmentalProfile  Current developmental tracking snapshot.
 * @property readingProgress   Per-book reading progress entries.
 * @property learningPaths     Active learning paths.
 * @property communityIds      IDs of joined [CommunitySpace] instances.
 * @property preferences       User-level preference overrides.
 * @property createdEpochMs    Account creation timestamp.
 * @property lastActiveEpochMs Last activity timestamp.
 */
data class UserProfile(
    val id: ContentId,
    val displayName: String,
    val email: String,
    val avatarUrl: String? = null,
    val bio: String = "",
    val developmentalProfile: DevelopmentalProfile = DevelopmentalProfile(),
    val readingProgress: List<ReadingProgress> = emptyList(),
    val learningPaths: List<LearningPath> = emptyList(),
    val communityIds: List<ContentId> = emptyList(),
    val preferences: UserPreferences = UserPreferences(),
    val createdEpochMs: Long = 0L,
    val lastActiveEpochMs: Long = 0L,
)

/**
 * User-configurable preference overrides.
 *
 * @property themeMode         Light, dark, or system-follow.
 * @property fontSizeScale     Multiplier applied to the base type scale (1.0 = default).
 * @property preferredCoachingMode  Default coaching modality.
 * @property notificationsEnabled   Whether push notifications are active.
 * @property audiobookSpeed    Narration speed multiplier (1.0 = normal).
 */
data class UserPreferences(
    val themeMode: ThemeMode = ThemeMode.SYSTEM,
    val fontSizeScale: Float = 1.0f,
    val preferredCoachingMode: CoachingMode = CoachingMode.TEXT_CHAT,
    val notificationsEnabled: Boolean = true,
    val audiobookSpeed: Float = 1.0f,
)

/**
 * Appearance mode selection.
 */
enum class ThemeMode {
    LIGHT,
    DARK,
    SYSTEM,
}

// ──────────────────────────────────────────────
// Community Spaces
// ──────────────────────────────────────────────

/**
 * The type of community gathering.
 */
enum class CommunityType {
    /** Open discussion forum. */
    FORUM,
    /** Small, focused study group. */
    STUDY_GROUP,
    /** Ongoing practice circle with regular meetings. */
    PRACTICE_CIRCLE,
    /** Cohort-based course or workshop. */
    COHORT,
}

/**
 * Membership role within a community space.
 */
enum class MemberRole {
    /** Read-only observer. */
    OBSERVER,
    /** Standard participating member. */
    MEMBER,
    /** Facilitator / moderator. */
    FACILITATOR,
    /** Community creator / admin. */
    ADMIN,
}

/**
 * A member entry within a community space.
 */
data class CommunityMember(
    val userId: ContentId,
    val role: MemberRole = MemberRole.MEMBER,
    val joinedEpochMs: Long,
)

/**
 * A community gathering space for shared learning and practice.
 *
 * @property id              Unique space identifier.
 * @property name            Display name of the community.
 * @property description     Purpose statement or charter.
 * @property type            Community format.
 * @property coverImageUrl   Banner image URL.
 * @property members         Current membership roster.
 * @property relatedContentIds  Book chapters or exercises central to this community.
 * @property isPublic        Whether the space is discoverable and joinable by anyone.
 * @property maxMembers      Capacity cap (0 = unlimited).
 * @property createdEpochMs  Timestamp of creation.
 */
data class CommunitySpace(
    val id: ContentId,
    val name: String,
    val description: String = "",
    val type: CommunityType = CommunityType.FORUM,
    val coverImageUrl: String? = null,
    val members: List<CommunityMember> = emptyList(),
    val relatedContentIds: List<ContentId> = emptyList(),
    val isPublic: Boolean = true,
    val maxMembers: Int = 0,
    val createdEpochMs: Long = 0L,
)

/**
 * A focused study group organized around specific book content.
 *
 * @property spaceId           Link to the parent [CommunitySpace].
 * @property currentChapterId  The chapter the group is currently studying.
 * @property schedule          Human-readable meeting schedule.
 * @property meetingUrl        Video call link for live sessions.
 * @property paceWeeksPerChapter  Suggested reading pace.
 */
data class StudyGroup(
    val spaceId: ContentId,
    val currentChapterId: ContentId? = null,
    val schedule: String = "",
    val meetingUrl: String? = null,
    val paceWeeksPerChapter: Int = 1,
)

/**
 * A practice circle focused on embodied / contemplative exercises.
 *
 * @property spaceId         Link to the parent [CommunitySpace].
 * @property practiceType    The kind of practice (meditation, somatic, etc.).
 * @property frequency       Human-readable meeting cadence.
 * @property guidedById      User ID of the primary facilitator.
 * @property nextSessionEpochMs  Timestamp of the next scheduled meeting.
 */
data class PracticeCircle(
    val spaceId: ContentId,
    val practiceType: String = "",
    val frequency: String = "",
    val guidedById: ContentId? = null,
    val nextSessionEpochMs: Long? = null,
)

// ──────────────────────────────────────────────
// Cross-Platform Sync
// ──────────────────────────────────────────────

/**
 * Synchronisation status between the local device and the cloud.
 */
enum class SyncStatus {
    /** All local changes have been pushed and remote changes pulled. */
    SYNCED,
    /** Local changes are queued for upload. */
    PENDING_UPLOAD,
    /** Remote changes are available for download. */
    PENDING_DOWNLOAD,
    /** Sync is actively in progress. */
    IN_PROGRESS,
    /** A conflict requires manual resolution. */
    CONFLICT,
    /** Sync failed — will retry automatically. */
    ERROR,
    /** Device is offline; sync will resume when connectivity returns. */
    OFFLINE,
}

/**
 * The type of entity being synchronised.
 */
enum class SyncEntityType {
    READING_PROGRESS,
    BOOKMARK,
    HIGHLIGHT,
    NOTE,
    COACH_SESSION,
    LEARNING_PATH,
    USER_PREFERENCES,
    VOICE_NOTE,
}

/**
 * Tracks the synchronisation state for a single entity.
 *
 * @property entityType       Category of the entity.
 * @property entityId         The entity's [ContentId].
 * @property localVersion     Monotonic local version counter.
 * @property remoteVersion    Last-known remote version counter.
 * @property status           Current sync state.
 * @property lastSyncEpochMs  Timestamp of the most recent successful sync.
 * @property errorMessage     Human-readable error description (if [status] is ERROR).
 */
data class SyncRecord(
    val entityType: SyncEntityType,
    val entityId: ContentId,
    val localVersion: Long = 0L,
    val remoteVersion: Long = 0L,
    val status: SyncStatus = SyncStatus.SYNCED,
    val lastSyncEpochMs: Long = 0L,
    val errorMessage: String? = null,
)

/**
 * Aggregate sync state for the entire device.
 *
 * @property overallStatus        Worst-case status across all records.
 * @property pendingUploadCount   Number of entities awaiting upload.
 * @property pendingDownloadCount Number of entities awaiting download.
 * @property conflictCount        Number of unresolved conflicts.
 * @property lastFullSyncEpochMs  Timestamp of the last complete sync cycle.
 * @property records              Individual entity sync records.
 */
data class CrossPlatformSyncState(
    val overallStatus: SyncStatus = SyncStatus.SYNCED,
    val pendingUploadCount: Int = 0,
    val pendingDownloadCount: Int = 0,
    val conflictCount: Int = 0,
    val lastFullSyncEpochMs: Long = 0L,
    val records: List<SyncRecord> = emptyList(),
)

// ──────────────────────────────────────────────
// Ecosystem Plugin Interface
// ──────────────────────────────────────────────

/**
 * Capability flags that an [EcosystemPlugin] may declare.
 */
enum class PluginCapability {
    /** Plugin can provide additional content (books, articles). */
    CONTENT_PROVIDER,
    /** Plugin can receive and display analytics / dashboards. */
    ANALYTICS,
    /** Plugin offers community or social features. */
    COMMUNITY,
    /** Plugin provides commerce / transaction services. */
    COMMERCE,
    /** Plugin offers coaching or assessment tools. */
    COACHING,
    /** Plugin provides notification or messaging services. */
    MESSAGING,
}

/**
 * Lifecycle state of an [EcosystemPlugin].
 */
enum class PluginState {
    /** Plugin is registered but not yet initialised. */
    REGISTERED,
    /** Plugin is initialised and ready. */
    ACTIVE,
    /** Plugin encountered an error and is inactive. */
    ERROR,
    /** Plugin has been explicitly disabled by the user. */
    DISABLED,
}

/**
 * Interface for connecting to other Luminous Prosperity applications.
 *
 * Each plugin represents an external app or service that integrates with
 * the Resonance reading ecosystem. Implementations are provided per
 * platform via `expect`/`actual` or dependency injection.
 *
 * Plugins communicate through a simple event bus: they receive [PluginEvent]
 * instances and may return [PluginResult] values.
 */
interface EcosystemPlugin {

    /** Unique identifier for this plugin. */
    val pluginId: String

    /** Human-readable display name. */
    val displayName: String

    /** Version string (semver recommended). */
    val version: String

    /** Capabilities this plugin provides. */
    val capabilities: Set<PluginCapability>

    /** Current lifecycle state. */
    val state: PluginState

    /**
     * Initialise the plugin with the given configuration.
     *
     * Called once when the host app starts or when the user enables the
     * plugin. Implementations should perform lightweight setup only;
     * heavy I/O should be deferred.
     *
     * @param config  Key-value configuration supplied by the host.
     * @return `true` if initialisation succeeded.
     */
    suspend fun initialize(config: Map<String, String>): Boolean

    /**
     * Handle an inbound event from the host ecosystem.
     *
     * @param event  The event payload.
     * @return An optional result to propagate back to the host.
     */
    suspend fun handleEvent(event: PluginEvent): PluginResult?

    /**
     * Release resources and transition to [PluginState.DISABLED].
     */
    suspend fun shutdown()
}

/**
 * An event dispatched to an [EcosystemPlugin].
 *
 * @property type     Dot-delimited event type (e.g. "reading.chapterCompleted").
 * @property payload  Serialised JSON payload.
 * @property sourcePluginId  The originating plugin (null if from the host).
 * @property timestampEpochMs  When the event was created.
 */
data class PluginEvent(
    val type: String,
    val payload: String = "{}",
    val sourcePluginId: String? = null,
    val timestampEpochMs: Long,
)

/**
 * A result returned by an [EcosystemPlugin] after processing a [PluginEvent].
 *
 * @property success  Whether the event was handled successfully.
 * @property data     Optional serialised JSON response data.
 * @property errorMessage  Human-readable error if [success] is `false`.
 */
data class PluginResult(
    val success: Boolean,
    val data: String? = null,
    val errorMessage: String? = null,
)
