/**
 * Coach / Tutor Domain Models
 *
 * Data structures powering the AI-driven coaching and tutoring experience
 * within the Luminous Integral Architecture™ ecosystem. Supports text chat,
 * voice interaction, guided somatic practices, and developmental assessments.
 *
 * Designed for Kotlin Multiplatform — all types are pure data classes with
 * no platform dependencies.
 */
package com.luminous.resonance.model

// ──────────────────────────────────────────────
// Coaching Mode
// ──────────────────────────────────────────────

/**
 * The interaction modality for a coaching session.
 */
enum class CoachingMode {
    /** Real-time text-based conversation. */
    TEXT_CHAT,

    /** Voice call with speech-to-text / text-to-speech pipeline. */
    VOICE_CALL,

    /** Step-by-step guided somatic or contemplative practice. */
    GUIDED_PRACTICE,

    /** Structured developmental assessment or quiz. */
    ASSESSMENT,
}

// ──────────────────────────────────────────────
// Session & Conversation
// ──────────────────────────────────────────────

/**
 * The lifecycle state of a [CoachSession].
 */
enum class SessionStatus {
    /** Session created but not yet started. */
    PENDING,
    /** Session is actively in progress. */
    ACTIVE,
    /** Session has been paused by the user. */
    PAUSED,
    /** Session completed normally. */
    COMPLETED,
    /** Session was cancelled by the user. */
    CANCELLED,
}

/**
 * A single coaching or tutoring session.
 *
 * @property id                Unique session identifier.
 * @property userId            Owner of the session.
 * @property mode              Interaction modality.
 * @property status            Current lifecycle state.
 * @property thread            The conversation thread for this session.
 * @property relatedContentId  Optional link to a book chapter or exercise that
 *                             triggered this session.
 * @property learningPathId    Optional link to the active [LearningPath].
 * @property startedEpochMs    Timestamp when the session began.
 * @property endedEpochMs      Timestamp when the session ended (null if ongoing).
 * @property summaryNotes      AI-generated summary of the session upon completion.
 */
data class CoachSession(
    val id: ContentId,
    val userId: ContentId,
    val mode: CoachingMode,
    val status: SessionStatus = SessionStatus.PENDING,
    val thread: ConversationThread = ConversationThread(),
    val relatedContentId: ContentId? = null,
    val learningPathId: ContentId? = null,
    val startedEpochMs: Long = 0L,
    val endedEpochMs: Long? = null,
    val summaryNotes: String? = null,
)

/**
 * An ordered conversation thread containing [Message] entries.
 *
 * @property messages  Chronologically ordered list of messages.
 * @property metadata  Arbitrary key-value pairs for conversation context
 *                     (e.g. current chapter, user mood).
 */
data class ConversationThread(
    val messages: List<Message> = emptyList(),
    val metadata: Map<String, String> = emptyMap(),
)

// ──────────────────────────────────────────────
// Messages
// ──────────────────────────────────────────────

/**
 * The role of the entity that authored a [Message].
 */
enum class MessageRole {
    /** The human user / reader. */
    USER,
    /** The AI coach / tutor. */
    COACH,
    /** System-level instructions or context injections. */
    SYSTEM,
}

/**
 * A single message within a [ConversationThread].
 *
 * A message may carry text, a voice note, or both (e.g. a voice message
 * with its transcription).
 *
 * @property id              Unique message identifier.
 * @property role            Who sent the message.
 * @property text            Plain-text or Markdown body.
 * @property voiceNote       Attached voice recording, if any.
 * @property attachments     Optional file or image attachments.
 * @property referencedContentId  Link to a specific book paragraph or exercise
 *                                being discussed.
 * @property createdEpochMs  Timestamp of creation.
 */
data class Message(
    val id: ContentId,
    val role: MessageRole,
    val text: String,
    val voiceNote: VoiceNote? = null,
    val attachments: List<MessageAttachment> = emptyList(),
    val referencedContentId: ContentId? = null,
    val createdEpochMs: Long,
)

/**
 * A file or image attached to a [Message].
 */
data class MessageAttachment(
    val id: ContentId,
    val fileName: String,
    val mimeType: String,
    val url: String,
    val fileSizeBytes: Long = 0L,
)

// ──────────────────────────────────────────────
// Voice Notes
// ──────────────────────────────────────────────

/**
 * Transcription status for a [VoiceNote].
 */
enum class TranscriptionStatus {
    /** Transcription has not been requested. */
    NONE,
    /** Transcription is in progress. */
    PROCESSING,
    /** Transcription completed successfully. */
    COMPLETED,
    /** Transcription failed. */
    FAILED,
}

/**
 * A recorded voice note with optional transcription.
 *
 * @property id                  Unique voice note identifier.
 * @property audioUrl            URL or local path to the audio file.
 * @property durationMs          Recording duration in milliseconds.
 * @property mimeType            Audio MIME type (e.g. "audio/aac").
 * @property transcription       Plain-text transcription of the audio.
 * @property transcriptionStatus Current state of the transcription pipeline.
 * @property waveformSamples     Normalised amplitude samples (0.0 – 1.0) for
 *                               rendering a waveform visualisation.
 */
data class VoiceNote(
    val id: ContentId,
    val audioUrl: String,
    val durationMs: Long,
    val mimeType: String = "audio/aac",
    val transcription: String? = null,
    val transcriptionStatus: TranscriptionStatus = TranscriptionStatus.NONE,
    val waveformSamples: List<Float> = emptyList(),
)

// ──────────────────────────────────────────────
// Tutor Prompts & Assessment
// ──────────────────────────────────────────────

/**
 * The difficulty or depth tier of a tutor interaction.
 */
enum class TutorDifficulty {
    INTRODUCTORY,
    INTERMEDIATE,
    ADVANCED,
    INTEGRAL,
}

/**
 * A structured prompt used by the tutor to initiate discussion or inquiry.
 *
 * @property id              Unique prompt identifier.
 * @property question        The prompt text presented to the user.
 * @property context         Background context supplied to the AI model.
 * @property relatedContentIds  Content nodes relevant to this prompt.
 * @property difficulty      Expected depth of engagement.
 * @property tags            Topical tags for filtering (e.g. "AQAL", "somatic").
 */
data class TutorPrompt(
    val id: ContentId,
    val question: String,
    val context: String = "",
    val relatedContentIds: List<ContentId> = emptyList(),
    val difficulty: TutorDifficulty = TutorDifficulty.INTRODUCTORY,
    val tags: List<String> = emptyList(),
)

/**
 * The format of an [AssessmentQuestion].
 */
enum class QuestionFormat {
    /** Free-text / open-ended response. */
    OPEN_ENDED,
    /** Single-choice from a list of options. */
    SINGLE_CHOICE,
    /** Multiple-choice (select all that apply). */
    MULTIPLE_CHOICE,
    /** Likert-scale rating (e.g. 1–7). */
    SCALE,
    /** Drag-and-drop ordering or matching. */
    RANKING,
}

/**
 * A single question within a developmental assessment.
 *
 * @property options     Answer options for choice-based questions.
 * @property scaleMin    Minimum value for SCALE questions.
 * @property scaleMax    Maximum value for SCALE questions.
 * @property scaleLabels Labels for the low and high ends of the scale.
 * @property scoringRubric  Guidance the AI uses to evaluate an open-ended response.
 */
data class AssessmentQuestion(
    val id: ContentId,
    val ordinal: Int,
    val question: String,
    val format: QuestionFormat = QuestionFormat.OPEN_ENDED,
    val options: List<String> = emptyList(),
    val scaleMin: Int = 1,
    val scaleMax: Int = 7,
    val scaleLabels: Pair<String, String>? = null,
    val scoringRubric: String = "",
    val tags: List<String> = emptyList(),
)

/**
 * A user's response to an [AssessmentQuestion].
 */
data class AssessmentResponse(
    val questionId: ContentId,
    val textAnswer: String? = null,
    val selectedOptions: List<Int> = emptyList(),
    val scaleValue: Int? = null,
    val ranking: List<Int> = emptyList(),
    val answeredEpochMs: Long,
)

// ──────────────────────────────────────────────
// Learning Path
// ──────────────────────────────────────────────

/**
 * Completion state for a [LearningPathStep].
 */
enum class StepStatus {
    LOCKED,
    AVAILABLE,
    IN_PROGRESS,
    COMPLETED,
    SKIPPED,
}

/**
 * A single step in a [LearningPath].
 *
 * @property contentRef     The content node to engage with (chapter, exercise, etc.).
 * @property assessmentIds  Assessments to complete at this step.
 */
data class LearningPathStep(
    val id: ContentId,
    val ordinal: Int,
    val title: String,
    val description: String = "",
    val status: StepStatus = StepStatus.LOCKED,
    val contentRef: ContentId? = null,
    val assessmentIds: List<ContentId> = emptyList(),
    val completedEpochMs: Long? = null,
)

/**
 * A curated sequence of learning activities forming a developmental journey.
 *
 * @property id              Unique path identifier.
 * @property title           Human-readable path name.
 * @property description     Overview of what the path covers.
 * @property steps           Ordered learning steps.
 * @property estimatedHours  Total estimated time investment.
 * @property currentStepIndex  Zero-based index of the active step.
 */
data class LearningPath(
    val id: ContentId,
    val title: String,
    val description: String = "",
    val steps: List<LearningPathStep> = emptyList(),
    val estimatedHours: Float = 0f,
    val currentStepIndex: Int = 0,
)
