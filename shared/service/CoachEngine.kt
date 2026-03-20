/**
 * Coach Engine Service
 *
 * Cross-platform AI coaching, tutoring, and guided-practice engine for the
 * Luminous Integral Architecture™ ecosystem. Provides text chat, voice
 * interaction, developmental assessments, and step-by-step somatic /
 * contemplative guided practices.
 *
 * The [CoachEngine] interface is implemented per-platform while all data
 * types are pure common code. Voice I/O is abstracted behind the
 * [VoicePipeline] interface and [PlatformVoiceSession] expect/actual
 * declarations.
 */
package com.luminous.resonance.service

import kotlinx.coroutines.flow.StateFlow
import kotlinx.serialization.Serializable

// ──────────────────────────────────────────────
// Coach Personality
// ──────────────────────────────────────────────

/**
 * Personality archetype that shapes the tone, pacing, and pedagogical
 * approach of the AI coach.
 *
 * Personalities are not mutually exclusive — the engine may blend traits —
 * but selecting one sets the dominant style.
 */
@Serializable
enum class CoachPersonality {
    /** Asks probing questions to draw out the learner's own insights. */
    SOCRATIC,

    /** Warm, affirming tone focused on encouragement and emotional safety. */
    SUPPORTIVE,

    /** Direct, high-expectation style that pushes the learner's edge. */
    CHALLENGING,

    /** Reflective, meditative tone aligned with contemplative traditions. */
    CONTEMPLATIVE,

    /** Narrative wayfinder that contextualises content within the larger journey. */
    GUIDE,
}

// ──────────────────────────────────────────────
// Coach Mode
// ──────────────────────────────────────────────

/**
 * The interaction modality for a coaching session.
 */
@Serializable
enum class CoachMode {
    /** Real-time text-based conversation. */
    TEXT_CHAT,

    /** Live voice call with speech-to-text and text-to-speech pipeline. */
    VOICE_CALL,

    /** Step-by-step guided somatic or contemplative practice. */
    GUIDED_PRACTICE,

    /** Structured developmental assessment or quiz. */
    ASSESSMENT,

    /** Free-form content exploration with AI commentary. */
    EXPLORATION,
}

// ──────────────────────────────────────────────
// Conversation Context
// ──────────────────────────────────────────────

/**
 * Contextual snapshot supplied to the coach so it can personalise responses.
 *
 * Updated whenever the user's reading state, progress, or focus changes.
 *
 * @property currentChapterId    Chapter the user is currently reading or listening to.
 * @property currentChapterTitle Display title of the current chapter.
 * @property chaptersRead        Set of chapter IDs the user has completed.
 * @property highlightedPassages Passages the user has highlighted, keyed by chapter ID.
 * @property overallProgress     Reading progress as a fraction (0.0 – 1.0).
 * @property userNotes           Recent free-form notes the user has taken.
 * @property developmentalLevel  Estimated developmental altitude of the reader.
 * @property recentTopics        Topics the user has recently engaged with.
 * @property sessionHistory      Summary strings from prior coaching sessions.
 * @property customMetadata      Arbitrary key-value pairs for extension.
 */
@Serializable
data class ConversationContext(
    val currentChapterId: String = "",
    val currentChapterTitle: String = "",
    val chaptersRead: Set<String> = emptySet(),
    val highlightedPassages: Map<String, List<String>> = emptyMap(),
    val overallProgress: Float = 0f,
    val userNotes: List<String> = emptyList(),
    val developmentalLevel: String? = null,
    val recentTopics: List<String> = emptyList(),
    val sessionHistory: List<String> = emptyList(),
    val customMetadata: Map<String, String> = emptyMap(),
)

// ──────────────────────────────────────────────
// Assessment
// ──────────────────────────────────────────────

/**
 * Mastery level assigned after scoring an assessment.
 */
@Serializable
enum class MasteryLevel {
    /** Minimal engagement; foundational gaps remain. */
    NOVICE,

    /** Emerging understanding with room for depth. */
    DEVELOPING,

    /** Solid comprehension with some nuance. */
    PROFICIENT,

    /** Deep, integrated understanding. */
    ADVANCED,

    /** Integral-level synthesis across multiple dimensions. */
    MASTERY,
}

/**
 * Result of a scored developmental assessment.
 *
 * @property assessmentId   Identifier of the assessment that was scored.
 * @property score          Numeric score (0 – 100).
 * @property masteryLevel   Categorical mastery classification.
 * @property areasOfStrength  Topics or dimensions where the user excels.
 * @property areasForGrowth   Topics or dimensions needing further exploration.
 * @property nextSteps        Recommended actions or content for continued growth.
 * @property feedback         Personalised narrative feedback from the coach.
 * @property scoredAtEpochMs  Timestamp when the assessment was scored.
 */
@Serializable
data class AssessmentResult(
    val assessmentId: String,
    val score: Int,
    val masteryLevel: MasteryLevel,
    val areasOfStrength: List<String> = emptyList(),
    val areasForGrowth: List<String> = emptyList(),
    val nextSteps: List<String> = emptyList(),
    val feedback: String = "",
    val scoredAtEpochMs: Long = 0L,
)

// ──────────────────────────────────────────────
// Learning Milestones
// ──────────────────────────────────────────────

/**
 * A developmental milestone the user has achieved.
 *
 * Milestones are awarded by the coach when the user demonstrates sustained
 * engagement, comprehension, or practice completion.
 *
 * @property id            Unique milestone identifier.
 * @property title         Short display name (e.g. "Shadow Integration I").
 * @property description   Longer explanation of what was achieved.
 * @property category      Grouping category (e.g. "Reading", "Practice", "Assessment").
 * @property awardedAtEpochMs  Timestamp of award.
 * @property iconToken     Design-system icon token for badge rendering.
 */
@Serializable
data class LearningMilestone(
    val id: String,
    val title: String,
    val description: String = "",
    val category: String = "",
    val awardedAtEpochMs: Long = 0L,
    val iconToken: String = "",
)

// ──────────────────────────────────────────────
// Guided Practice
// ──────────────────────────────────────────────

/**
 * Haptic feedback pattern for somatic cues during guided practice.
 */
@Serializable
enum class HapticPattern {
    /** No haptic feedback. */
    NONE,

    /** Single gentle tap. */
    SOFT_TAP,

    /** Double tap to signal a transition. */
    DOUBLE_TAP,

    /** Slow, rhythmic pulse (e.g. to pace breathing). */
    BREATHING_PULSE,

    /** Strong buzz to draw attention. */
    ALERT,
}

/**
 * A single step within a guided somatic or contemplative practice.
 *
 * Steps are presented sequentially; the coach engine advances through
 * them based on duration or user acknowledgement.
 *
 * @property id              Unique step identifier.
 * @property ordinal         Zero-based order within the practice sequence.
 * @property instruction     Display text guiding the user through this step.
 * @property durationSeconds Duration to hold or perform this step.
 * @property hapticPattern   Haptic feedback cue to accompany this step.
 * @property audioUrl        Optional ambient audio or narration URL for this step.
 * @property imageUrl        Optional illustration or body-map image for this step.
 * @property isRestStep      Whether this step is a pause / integration rest.
 */
@Serializable
data class GuidedPracticeStep(
    val id: String,
    val ordinal: Int,
    val instruction: String,
    val durationSeconds: Int = 30,
    val hapticPattern: HapticPattern = HapticPattern.NONE,
    val audioUrl: String? = null,
    val imageUrl: String? = null,
    val isRestStep: Boolean = false,
)

// ──────────────────────────────────────────────
// Coach Messages
// ──────────────────────────────────────────────

/**
 * Role of the entity that authored a [CoachMessage].
 */
@Serializable
enum class CoachMessageRole {
    /** The human user / reader. */
    USER,

    /** The AI coach. */
    COACH,

    /** System-level context injection. */
    SYSTEM,
}

/**
 * A single message in a coaching conversation.
 *
 * @property id             Unique message identifier.
 * @property role           Who authored this message.
 * @property text           Plain-text or Markdown body.
 * @property createdAtEpochMs Timestamp of creation.
 * @property metadata       Arbitrary key-value pairs (e.g. cited chapter, mood tag).
 */
@Serializable
data class CoachMessage(
    val id: String,
    val role: CoachMessageRole,
    val text: String,
    val createdAtEpochMs: Long = 0L,
    val metadata: Map<String, String> = emptyMap(),
)

// ──────────────────────────────────────────────
// Suggested Action
// ──────────────────────────────────────────────

/**
 * Category of action the coach may suggest.
 */
@Serializable
enum class SuggestedActionType {
    /** Continue reading the next chapter. */
    READ_NEXT,

    /** Review a previously read chapter. */
    REVIEW,

    /** Perform a guided practice or exercise. */
    PRACTICE,

    /** Take a developmental assessment. */
    ASSESSMENT,

    /** Explore a topic with the coach. */
    EXPLORE,

    /** Engage with a community discussion. */
    COMMUNITY,
}

/**
 * A recommended next action produced by the coach based on user progress.
 *
 * @property type        Category of the suggested action.
 * @property title       Short display title.
 * @property description Explanation of why this action is recommended.
 * @property contentId   Optional reference to a content node.
 * @property priority    Relative priority (higher = more recommended).
 */
@Serializable
data class SuggestedAction(
    val type: SuggestedActionType,
    val title: String,
    val description: String = "",
    val contentId: String? = null,
    val priority: Int = 0,
)

// ──────────────────────────────────────────────
// Voice Pipeline
// ──────────────────────────────────────────────

/**
 * Transcription result from the voice pipeline.
 *
 * @property text        Recognised text.
 * @property confidence  Recognition confidence (0.0 – 1.0).
 * @property languageTag BCP 47 language tag of the recognised speech.
 */
@Serializable
data class TranscriptionResult(
    val text: String,
    val confidence: Float = 1.0f,
    val languageTag: String = "en-US",
)

/**
 * Combined result of processing voice input: transcription plus coach reply.
 *
 * @property transcription  Transcribed user speech.
 * @property response       AI coach response message.
 */
@Serializable
data class VoiceInteractionResult(
    val transcription: TranscriptionResult,
    val response: CoachMessage,
)

/**
 * Abstraction over platform speech-recognition and text-to-speech APIs.
 *
 * Implementations bridge to platform-native voice services
 * (e.g. Android `SpeechRecognizer`, iOS `SFSpeechRecognizer`,
 * Web `SpeechRecognition` API).
 */
interface VoicePipeline {

    /** Whether the pipeline is currently recording / listening. */
    val isListening: StateFlow<Boolean>

    /**
     * Begin listening for speech input.
     *
     * @param languageTag BCP 47 language tag for recognition (e.g. "en-US").
     */
    fun startListening(languageTag: String = "en-US")

    /** Stop listening and finalise the transcription. */
    fun stopListening()

    /**
     * Transcribe a pre-recorded audio buffer.
     *
     * @param audioData Raw audio bytes (PCM / WAV / AAC depending on platform).
     * @return Transcription result.
     */
    suspend fun transcribe(audioData: ByteArray): TranscriptionResult

    /**
     * Synthesise speech from text and play it through the device speaker.
     *
     * @param text     Text to speak.
     * @param voiceId  Optional platform voice identifier.
     * @param speed    Speech rate multiplier (1.0 = normal).
     */
    suspend fun speak(text: String, voiceId: String? = null, speed: Float = 1.0f)

    /** Cancel any in-progress speech synthesis. */
    fun stopSpeaking()
}

// ──────────────────────────────────────────────
// Coach Engine Interface
// ──────────────────────────────────────────────

/**
 * AI coaching engine for personalised tutoring across all platforms.
 *
 * The coach adapts its personality, depth, and recommendations based on
 * the reader's developmental context, reading progress, and interaction
 * history. It supports multiple modalities: text chat, live voice,
 * guided somatic practice, and structured developmental assessments.
 *
 * Typical lifecycle:
 * 1. [updateContext] — supply the user's current reading state.
 * 2. [setPersonality] — choose a coaching style.
 * 3. [sendMessage] or [startVoiceSession] — begin interaction.
 * 4. [generateAssessment] / [scoreAssessment] — evaluate comprehension.
 * 5. [startGuidedPractice] — lead the user through a somatic exercise.
 * 6. [suggestNextAction] — recommend what the user should do next.
 */
interface CoachEngine {

    /** Observable stream of messages in the current conversation. */
    val conversationFlow: StateFlow<List<CoachMessage>>

    /** Observable current coaching mode. */
    val currentMode: StateFlow<CoachMode>

    /** Observable active personality. */
    val activePersonality: StateFlow<CoachPersonality>

    // ── Context ────────────────────────────────

    /**
     * Update the conversational context so the coach can personalise responses.
     *
     * Call this whenever the user's reading position, highlights, or progress
     * changes.
     *
     * @param context Snapshot of the user's current state.
     */
    fun updateContext(context: ConversationContext)

    /**
     * Set the coaching personality archetype.
     *
     * @param personality Desired personality style.
     */
    fun setPersonality(personality: CoachPersonality)

    // ── Text Chat ──────────────────────────────

    /**
     * Send a text message and receive the coach's reply.
     *
     * @param text User message text.
     * @return The coach's response message.
     */
    suspend fun sendMessage(text: String): CoachMessage

    /**
     * Retrieve the full conversation history for the current session.
     *
     * @return Chronologically ordered list of [CoachMessage].
     */
    fun getConversationHistory(): List<CoachMessage>

    // ── Voice ──────────────────────────────────

    /**
     * Begin a live voice coaching session.
     *
     * Activates the [VoicePipeline] for continuous speech recognition
     * and spoken coach responses.
     */
    suspend fun startVoiceSession()

    /**
     * End the current voice coaching session and return to text mode.
     */
    fun endVoiceSession()

    /**
     * Process a pre-recorded voice input, transcribe it, and generate
     * a coach response.
     *
     * @param audioData Raw audio bytes from the user's microphone.
     * @return Combined transcription and coach response.
     */
    suspend fun processVoiceInput(audioData: ByteArray): VoiceInteractionResult

    // ── Assessment ─────────────────────────────

    /**
     * Generate a developmental assessment for a specific chapter.
     *
     * The assessment is tailored to the user's progress and the
     * chapter's key themes.
     *
     * @param chapterId Identifier of the chapter to assess.
     * @return List of assessment question identifiers.
     */
    suspend fun generateAssessment(chapterId: String): List<String>

    /**
     * Score user answers to an assessment and produce a result.
     *
     * @param answers Map of question ID to the user's answer text.
     * @return Scored [AssessmentResult] with feedback and next steps.
     */
    suspend fun scoreAssessment(answers: Map<String, String>): AssessmentResult

    // ── Guided Practice ────────────────────────

    /**
     * Start a guided somatic or contemplative practice.
     *
     * Returns the ordered sequence of steps; the UI should advance
     * through them based on each step's duration or user tap.
     *
     * @param practiceId Identifier of the practice to begin.
     * @return Ordered list of [GuidedPracticeStep].
     */
    suspend fun startGuidedPractice(practiceId: String): List<GuidedPracticeStep>

    // ── Learning Path ──────────────────────────

    /**
     * Retrieve the personalised learning path — an ordered sequence of
     * content and exercises tailored to the user's developmental level.
     *
     * @return Ordered list of content and exercise identifiers with metadata.
     */
    suspend fun getLearningPath(): List<SuggestedAction>

    // ── Suggestions ────────────────────────────

    /**
     * Suggest the next action the user should take based on their
     * overall progress, recent activity, and developmental context.
     *
     * @return The most relevant [SuggestedAction].
     */
    suspend fun suggestNextAction(): SuggestedAction
}

// ──────────────────────────────────────────────
// Platform Voice Session (expect/actual)
// ──────────────────────────────────────────────

/**
 * Platform-specific voice session management.
 *
 * On iOS this wraps `SFSpeechRecognizer` and `AVSpeechSynthesizer`;
 * on Android it manages `SpeechRecognizer` and `TextToSpeech`;
 * on desktop/web it bridges to the appropriate speech APIs.
 *
 * Implementations are provided via Kotlin Multiplatform `actual` declarations
 * in each platform source set.
 */
expect class PlatformVoiceSession() {

    /** Request microphone and speech-recognition permissions. */
    fun requestPermissions(): Boolean

    /**
     * Begin continuous speech recognition.
     *
     * @param languageTag BCP 47 language code (e.g. "en-US").
     * @param onPartialResult Callback invoked with interim transcription text.
     */
    fun startRecognition(languageTag: String, onPartialResult: (String) -> Unit)

    /** Stop recognition and finalise the transcript. */
    fun stopRecognition()

    /**
     * Speak text aloud using platform TTS.
     *
     * @param text    Text to synthesise.
     * @param voiceId Optional platform-specific voice identifier.
     */
    fun speak(text: String, voiceId: String? = null)

    /** Cancel any in-progress speech output. */
    fun stopSpeaking()

    /** Release all voice resources. */
    fun release()
}
