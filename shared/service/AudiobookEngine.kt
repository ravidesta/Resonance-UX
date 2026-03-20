/**
 * Audiobook Engine Service
 *
 * Cross-platform audio playback engine for the Luminous Integral Architecture™
 * ebook/audiobook experience. Handles chapter-based navigation, narration-sync
 * highlighting, bookmarking, sleep timers, and text-to-speech fallback when
 * human narration is unavailable.
 *
 * Designed for Kotlin Multiplatform — the [AudiobookEngine] interface is
 * implemented per-platform, while all data types are pure common code.
 * Platform audio session management is handled via [PlatformAudioSession]
 * expect/actual declarations.
 */
package com.luminous.resonance.service

import kotlinx.coroutines.flow.StateFlow

// ──────────────────────────────────────────────
// Playback State
// ──────────────────────────────────────────────

/**
 * Playback state for the audiobook player.
 *
 * Emitted as a [StateFlow] from [AudiobookEngine.playbackState] so that
 * UI layers can observe real-time changes reactively.
 *
 * @property chapterId               Identifier of the currently loaded chapter.
 * @property chapterTitle            Display title of the current chapter.
 * @property chapterIndex            Zero-based index of the current chapter.
 * @property totalChapters           Total number of chapters in the book.
 * @property positionMs              Current playback position in milliseconds.
 * @property durationMs              Total duration of the current chapter (ms).
 * @property playbackSpeed           Speed multiplier (e.g. 1.0 = normal, 1.5 = 1.5x).
 * @property isPlaying               Whether audio is currently playing.
 * @property sleepTimerRemainingMs   Remaining time on sleep timer, or `null` if inactive.
 * @property isSyncHighlightEnabled  Whether follow-along text highlighting is active.
 */
data class AudioPlaybackState(
    val chapterId: String = "",
    val chapterTitle: String = "",
    val chapterIndex: Int = 0,
    val totalChapters: Int = 0,
    val positionMs: Long = 0L,
    val durationMs: Long = 0L,
    val playbackSpeed: Float = 1.0f,
    val isPlaying: Boolean = false,
    val sleepTimerRemainingMs: Long? = null,
    val isSyncHighlightEnabled: Boolean = false,
)

// ──────────────────────────────────────────────
// Narration Sync
// ──────────────────────────────────────────────

/**
 * Maps a text range to an audio timestamp range for follow-along highlighting.
 *
 * The reader UI uses these sync points to highlight the sentence or phrase
 * currently being narrated, enabling a karaoke-style reading experience.
 *
 * @property textOffset   Character offset from the start of the section text.
 * @property textLength   Number of characters in this sync segment.
 * @property audioStartMs Audio timestamp where this text segment begins (ms).
 * @property audioEndMs   Audio timestamp where this text segment ends (ms).
 * @property sectionId    Identifier of the content section containing this text.
 */
data class NarrationSyncPoint(
    val textOffset: Int,
    val textLength: Int,
    val audioStartMs: Long,
    val audioEndMs: Long,
    val sectionId: String,
)

// ──────────────────────────────────────────────
// Bookmarks
// ──────────────────────────────────────────────

/**
 * A bookmark at a specific audio position within a chapter.
 *
 * Audio bookmarks are distinct from reading bookmarks — they capture
 * a playback position rather than a paragraph/scroll anchor.
 *
 * @property id         Unique bookmark identifier.
 * @property chapterId  Chapter in which the bookmark was placed.
 * @property positionMs Audio position in milliseconds.
 * @property note       Optional user-supplied annotation.
 * @property createdAt  Epoch timestamp of creation (ms).
 */
data class AudioBookmark(
    val id: String,
    val chapterId: String,
    val positionMs: Long,
    val note: String = "",
    val createdAt: Long = 0L,
)

// ──────────────────────────────────────────────
// Chapters
// ──────────────────────────────────────────────

/**
 * Chapter metadata for the audiobook table of contents.
 *
 * @property id         Unique chapter identifier.
 * @property title      Display title of the chapter.
 * @property durationMs Total audio duration of the chapter (ms).
 * @property index      Zero-based chapter index within the book.
 * @property partTitle  Title of the book part this chapter belongs to, if any.
 */
data class AudioChapter(
    val id: String,
    val title: String,
    val durationMs: Long,
    val index: Int,
    val partTitle: String? = null,
)

// ──────────────────────────────────────────────
// Text-to-Speech Voices
// ──────────────────────────────────────────────

/**
 * Available text-to-speech voice for TTS fallback narration.
 *
 * When a book does not have human narration, the engine can fall back
 * to TTS. This data class describes a single available voice option.
 *
 * @property id        Platform-specific voice identifier.
 * @property name      Human-readable voice name (e.g. "Samantha").
 * @property language  BCP 47 language tag (e.g. "en-US").
 * @property isNeural  Whether this is a neural / high-quality voice.
 * @property sampleUrl URL to an audio sample for previewing the voice, if available.
 */
data class TTSVoice(
    val id: String,
    val name: String,
    val language: String,
    val isNeural: Boolean = false,
    val sampleUrl: String? = null,
)

// ──────────────────────────────────────────────
// Audiobook Engine Interface
// ──────────────────────────────────────────────

/**
 * Audio engine for audiobook playback across all platforms.
 *
 * Platform implementations handle the actual media player integration
 * (e.g. ExoPlayer on Android, AVAudioPlayer on iOS, HTML5 Audio on Web).
 * All playback state is exposed via [playbackState] as a reactive [StateFlow].
 *
 * Typical lifecycle:
 * 1. [loadBook] — prepare chapters, load sync points.
 * 2. [play] / [pause] / [togglePlayPause] — standard transport controls.
 * 3. [seekTo], [skipForward], [skipBack] — position adjustments.
 * 4. [goToChapter], [nextChapter], [previousChapter] — chapter navigation.
 * 5. [setFollowAlongMode] — enable narration-sync text highlighting.
 */
interface AudiobookEngine {

    /** Observable playback state — UI layers collect this flow. */
    val playbackState: StateFlow<AudioPlaybackState>

    /** Observable narration sync points for the currently loaded chapter. */
    val syncPoints: StateFlow<List<NarrationSyncPoint>>

    // ── Loading ─────────────────────────────────

    /**
     * Load a book and prepare its audio assets for playback.
     *
     * This suspending call may download or cache chapter audio files.
     * After completion, [playbackState] reflects the first chapter.
     *
     * @param bookId Identifier of the book to load.
     */
    suspend fun loadBook(bookId: String)

    // ── Transport Controls ──────────────────────

    /** Start or resume playback. */
    fun play()

    /** Pause playback. */
    fun pause()

    /** Toggle between play and pause states. */
    fun togglePlayPause()

    /**
     * Seek to an absolute position within the current chapter.
     *
     * @param positionMs Target position in milliseconds.
     */
    fun seekTo(positionMs: Long)

    /**
     * Skip forward by the given number of seconds.
     *
     * @param seconds Seconds to skip (default 30).
     */
    fun skipForward(seconds: Int = 30)

    /**
     * Skip backward by the given number of seconds.
     *
     * @param seconds Seconds to skip back (default 15).
     */
    fun skipBack(seconds: Int = 15)

    /**
     * Set the playback speed multiplier.
     *
     * @param speed Speed factor (e.g. 0.75, 1.0, 1.25, 1.5, 2.0).
     */
    fun setSpeed(speed: Float)

    // ── Sleep Timer ─────────────────────────────

    /**
     * Set or cancel the sleep timer.
     *
     * When the timer expires, playback pauses automatically.
     *
     * @param durationMs Timer duration in milliseconds, or `null` to cancel.
     */
    fun setSleepTimer(durationMs: Long?)

    // ── Chapter Navigation ──────────────────────

    /**
     * Jump to a specific chapter by its zero-based index.
     *
     * @param index Target chapter index.
     */
    fun goToChapter(index: Int)

    /** Advance to the next chapter, if available. */
    fun nextChapter()

    /** Return to the previous chapter, if available. */
    fun previousChapter()

    // ── Follow-Along ────────────────────────────

    /**
     * Enable or disable narration-sync text highlighting.
     *
     * When enabled, the reader UI scrolls and highlights text in sync
     * with the audio narration using the [syncPoints] data.
     *
     * @param enabled Whether to enable follow-along mode.
     */
    fun setFollowAlongMode(enabled: Boolean)

    /**
     * Retrieve the complete chapter list for the loaded book.
     *
     * @return Ordered list of [AudioChapter] metadata.
     */
    fun getChapters(): List<AudioChapter>

    // ── Bookmarking ─────────────────────────────

    /**
     * Add a bookmark at the current playback position.
     *
     * @param note Optional annotation text for the bookmark.
     * @return The newly created [AudioBookmark].
     */
    fun addBookmark(note: String = ""): AudioBookmark

    /**
     * Remove a bookmark by its identifier.
     *
     * @param id The bookmark identifier to remove.
     */
    fun removeBookmark(id: String)

    /**
     * Retrieve all bookmarks for the currently loaded book.
     *
     * @return List of [AudioBookmark] sorted by chapter and position.
     */
    fun getBookmarks(): List<AudioBookmark>

    // ── TTS Fallback ────────────────────────────

    /**
     * Enable text-to-speech fallback narration for books without
     * human-recorded audio.
     *
     * @param voice Optional voice identifier. If `null`, the platform default is used.
     */
    fun enableTextToSpeech(voice: String? = null)

    /**
     * Change the active TTS voice.
     *
     * @param voiceId Platform-specific voice identifier (see [TTSVoice.id]).
     */
    fun setTTSVoice(voiceId: String)

    /**
     * Query the platform for available TTS voices.
     *
     * @return List of [TTSVoice] options available on this device.
     */
    fun getAvailableTTSVoices(): List<TTSVoice>
}

// ──────────────────────────────────────────────
// Platform Audio Session (expect/actual)
// ──────────────────────────────────────────────

/**
 * Platform-specific audio session management.
 *
 * On iOS this wraps `AVAudioSession` configuration; on Android it manages
 * `AudioFocus` and `MediaSession`; on desktop/web it handles the
 * platform-appropriate audio lifecycle.
 *
 * Implementations are provided via Kotlin Multiplatform `actual` declarations
 * in each platform source set.
 */
expect class PlatformAudioSession() {

    /** Activate the audio session, requesting system audio focus. */
    fun activate()

    /** Deactivate the audio session, releasing system audio focus. */
    fun deactivate()

    /** Configure the session for long-form spoken-word playback. */
    fun configureForPlayback()

    /**
     * Update the system now-playing / lock-screen metadata.
     *
     * @param title    Track or chapter title.
     * @param artist   Author or narrator name.
     * @param duration Total duration in milliseconds.
     * @param position Current playback position in milliseconds.
     */
    fun updateNowPlayingInfo(title: String, artist: String, duration: Long, position: Long)
}
