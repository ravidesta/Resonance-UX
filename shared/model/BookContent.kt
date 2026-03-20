/**
 * Book Content Domain Models
 *
 * Structured data models for the ebook content hierarchy within the
 * Luminous Integral Architecture™ ecosystem. Supports rich text rendering,
 * audiobook narration synchronisation, interactive exercises, and reader
 * annotation workflows.
 *
 * All identifiers use deterministic UUIDs so that cross-platform sync
 * can reconcile content references without a network round-trip.
 */
package com.luminous.resonance.model

import kotlin.jvm.JvmInline

// ──────────────────────────────────────────────
// Identifiers
// ──────────────────────────────────────────────

/**
 * Opaque content identifier.
 *
 * Wraps a UUID string so that the type system prevents accidental mixing
 * of content IDs with other string values.
 */
@JvmInline
value class ContentId(val value: String)

// ──────────────────────────────────────────────
// Core Content Hierarchy
// ──────────────────────────────────────────────

/**
 * Top-level book container.
 *
 * @property id          Unique book identifier.
 * @property title       Full title (e.g. "Luminous Integral Architecture™").
 * @property subtitle    Optional subtitle or tagline.
 * @property authors     Ordered list of author names.
 * @property coverImageUrl  URL or asset path for the cover artwork.
 * @property isbn        ISBN-13 string, if published.
 * @property parts       Major structural divisions of the book.
 * @property glossary    End-of-book glossary terms.
 * @property appendices  Supplemental appendix sections.
 * @property totalAudioDurationMs  Aggregate audiobook duration in milliseconds.
 */
data class Book(
    val id: ContentId,
    val title: String,
    val subtitle: String? = null,
    val authors: List<String>,
    val coverImageUrl: String? = null,
    val isbn: String? = null,
    val parts: List<Part>,
    val glossary: List<GlossaryTerm> = emptyList(),
    val appendices: List<Appendix> = emptyList(),
    val totalAudioDurationMs: Long = 0L,
)

/**
 * A major division of the book (e.g. "Part I: Foundations").
 *
 * A book with no formal parts may contain a single implicit [Part] that
 * holds all chapters.
 */
data class Part(
    val id: ContentId,
    val number: Int,
    val title: String,
    val epigraph: String? = null,
    val chapters: List<Chapter>,
)

/**
 * A single chapter within a [Part].
 *
 * @property audioSegmentId  Links to the [AudioSegment] that narrates this chapter.
 * @property estimatedReadingTimeMinutes  Algorithmic estimate for silent reading.
 */
data class Chapter(
    val id: ContentId,
    val number: Int,
    val title: String,
    val subtitle: String? = null,
    val epigraph: String? = null,
    val sections: List<Section>,
    val exercises: List<InteractiveExercise> = emptyList(),
    val audioSegmentId: ContentId? = null,
    val estimatedReadingTimeMinutes: Int = 0,
)

/**
 * A titled section within a chapter.
 *
 * Sections may be nested one level deep via [subsections].
 */
data class Section(
    val id: ContentId,
    val heading: String,
    val paragraphs: List<Paragraph>,
    val subsections: List<Section> = emptyList(),
    val audioSegmentId: ContentId? = null,
)

// ──────────────────────────────────────────────
// Paragraph & Inline Content
// ──────────────────────────────────────────────

/**
 * The type of a paragraph block, enabling distinct rendering.
 */
enum class ParagraphType {
    /** Standard body text. */
    BODY,
    /** Block quotation or epigraph. */
    BLOCK_QUOTE,
    /** Pull-quote / callout. */
    PULL_QUOTE,
    /** Bulleted list item. */
    BULLET,
    /** Numbered list item. */
    NUMBERED,
    /** Code or technical snippet. */
    CODE,
    /** Image or figure with optional caption. */
    FIGURE,
    /** Callout box / sidebar. */
    CALLOUT,
}

/**
 * A single paragraph (or block-level element) within a [Section].
 *
 * @property spans       Inline runs that compose the paragraph text.
 * @property imageUrl    Asset path when [type] is [ParagraphType.FIGURE].
 * @property caption     Figure caption or callout title.
 * @property audioStartMs  Narration start offset in milliseconds for text-sync.
 * @property audioEndMs    Narration end offset.
 */
data class Paragraph(
    val id: ContentId,
    val type: ParagraphType = ParagraphType.BODY,
    val spans: List<TextSpan> = emptyList(),
    val imageUrl: String? = null,
    val caption: String? = null,
    val audioStartMs: Long? = null,
    val audioEndMs: Long? = null,
)

/**
 * Inline text styling applied to a contiguous run of characters.
 */
enum class SpanStyle {
    PLAIN,
    BOLD,
    ITALIC,
    BOLD_ITALIC,
    SUPERSCRIPT,
    SMALL_CAPS,
    /** Hyperlink — [TextSpan.linkUrl] supplies the target. */
    LINK,
    /** Glossary cross-reference — [TextSpan.glossaryTermId] supplies the target. */
    GLOSSARY_REF,
}

/**
 * An inline run of text with a uniform style.
 */
data class TextSpan(
    val text: String,
    val style: SpanStyle = SpanStyle.PLAIN,
    val linkUrl: String? = null,
    val glossaryTermId: ContentId? = null,
)

// ──────────────────────────────────────────────
// Glossary
// ──────────────────────────────────────────────

/**
 * A glossary term with its definition and optional cross-references.
 *
 * @property term        The canonical term (e.g. "AQAL").
 * @property definition  Plain-text definition.
 * @property relatedTermIds  IDs of related [GlossaryTerm] entries.
 * @property sourceChapterId First chapter in which the term appears.
 */
data class GlossaryTerm(
    val id: ContentId,
    val term: String,
    val definition: String,
    val relatedTermIds: List<ContentId> = emptyList(),
    val sourceChapterId: ContentId? = null,
)

// ──────────────────────────────────────────────
// Appendix
// ──────────────────────────────────────────────

/**
 * A supplemental appendix section (e.g. Key Figures, Further Reading).
 */
data class Appendix(
    val id: ContentId,
    val title: String,
    val sections: List<Section>,
)

/**
 * An entry in the "Key Figures" appendix.
 */
data class KeyFigure(
    val name: String,
    val lifespan: String? = null,
    val contribution: String,
    val relatedChapterIds: List<ContentId> = emptyList(),
)

// ──────────────────────────────────────────────
// Audio Narration
// ──────────────────────────────────────────────

/**
 * An audiobook narration segment tied to a content node.
 *
 * @property contentRef        [ContentId] of the chapter, section, or paragraph.
 * @property audioFileUrl      URL or local asset path to the audio file.
 * @property startMs           Start offset within the audio file (ms).
 * @property endMs             End offset within the audio file (ms).
 * @property wordTimestamps    Per-word timing for karaoke-style text highlighting.
 */
data class AudioSegment(
    val id: ContentId,
    val contentRef: ContentId,
    val audioFileUrl: String,
    val startMs: Long,
    val endMs: Long,
    val wordTimestamps: List<WordTimestamp> = emptyList(),
)

/**
 * A single word's timing within an [AudioSegment], enabling precise
 * text-to-speech highlight synchronisation.
 */
data class WordTimestamp(
    val word: String,
    val startMs: Long,
    val endMs: Long,
)

// ──────────────────────────────────────────────
// Interactive Exercises
// ──────────────────────────────────────────────

/**
 * The category of an interactive exercise embedded in the reading flow.
 */
enum class ExerciseType {
    /** Open-ended journaling or reflection. */
    REFLECTION_QUESTION,
    /** Body-awareness / somatic practice. */
    SOMATIC_PRACTICE,
    /** AQAL Quadrant Mapping exercise. */
    QUADRANT_MAPPING,
    /** Self-assessment inventory. */
    SELF_ASSESSMENT,
    /** Guided meditation or breathwork. */
    GUIDED_MEDITATION,
}

/**
 * An interactive exercise that appears inline within a chapter.
 *
 * @property prompt        Instruction or question text.
 * @property guidedSteps   Ordered steps for somatic or guided practices.
 * @property quadrantMapping  Pre-populated quadrant data (for QUADRANT_MAPPING type).
 * @property audioGuideId  Optional audio-guided version of this exercise.
 * @property estimatedDurationMinutes  Suggested time investment.
 */
data class InteractiveExercise(
    val id: ContentId,
    val type: ExerciseType,
    val title: String,
    val prompt: String,
    val guidedSteps: List<GuidedStep> = emptyList(),
    val quadrantMapping: QuadrantMapping? = null,
    val audioGuideId: ContentId? = null,
    val estimatedDurationMinutes: Int = 5,
)

/**
 * A single step in a guided somatic practice or meditation.
 *
 * @property durationSeconds  Recommended time to hold this step (0 = untimed).
 */
data class GuidedStep(
    val ordinal: Int,
    val instruction: String,
    val durationSeconds: Int = 0,
)

/**
 * Data model for an AQAL Quadrant Mapping exercise.
 *
 * Each quadrant contains a list of prompts or pre-filled observations
 * that the reader can extend with their own reflections.
 *
 * @property upperLeft   "I" — Interior Individual (intentional / subjective).
 * @property upperRight  "IT" — Exterior Individual (behavioural / objective).
 * @property lowerLeft   "WE" — Interior Collective (cultural / intersubjective).
 * @property lowerRight  "ITS" — Exterior Collective (social / interobjective).
 * @property topic       The design or life situation being mapped.
 */
data class QuadrantMapping(
    val topic: String,
    val upperLeft: List<String> = emptyList(),
    val upperRight: List<String> = emptyList(),
    val lowerLeft: List<String> = emptyList(),
    val lowerRight: List<String> = emptyList(),
)

// ──────────────────────────────────────────────
// Reader State & Annotations
// ──────────────────────────────────────────────

/**
 * Tracks the reader's progress through the book.
 *
 * @property bookId                The book being read.
 * @property currentChapterId      Last-opened chapter.
 * @property currentParagraphId    Last-visible paragraph (scroll anchor).
 * @property percentComplete       Derived overall progress (0.0 – 1.0).
 * @property chaptersCompleted     Set of chapter IDs the reader has finished.
 * @property totalReadingTimeMs    Accumulated reading session time.
 * @property lastAccessedEpochMs   Timestamp of last reading session.
 */
data class ReadingProgress(
    val bookId: ContentId,
    val currentChapterId: ContentId? = null,
    val currentParagraphId: ContentId? = null,
    val percentComplete: Float = 0f,
    val chaptersCompleted: Set<ContentId> = emptySet(),
    val totalReadingTimeMs: Long = 0L,
    val lastAccessedEpochMs: Long = 0L,
)

/**
 * A reader-created bookmark.
 *
 * @property label  Optional user-supplied label.
 */
data class Bookmark(
    val id: ContentId,
    val bookId: ContentId,
    val chapterId: ContentId,
    val paragraphId: ContentId,
    val label: String? = null,
    val createdEpochMs: Long,
)

/**
 * The visual colour assigned to a highlight.
 */
enum class HighlightColor {
    GOLD,
    GREEN,
    BLUE,
    ROSE,
    LAVENDER,
}

/**
 * A text highlight spanning one or more [TextSpan] ranges.
 *
 * @property startSpanIndex  Index of the first highlighted span in the paragraph.
 * @property startCharOffset Character offset within the first span.
 * @property endSpanIndex    Index of the last highlighted span.
 * @property endCharOffset   Character offset within the last span.
 */
data class Highlight(
    val id: ContentId,
    val bookId: ContentId,
    val paragraphId: ContentId,
    val startSpanIndex: Int,
    val startCharOffset: Int,
    val endSpanIndex: Int,
    val endCharOffset: Int,
    val color: HighlightColor = HighlightColor.GOLD,
    val createdEpochMs: Long,
)

/**
 * A reader-authored note attached to a paragraph or highlight.
 *
 * @property highlightId  Optional link to a [Highlight]; `null` if the note
 *                        is attached directly to the paragraph.
 */
data class Note(
    val id: ContentId,
    val bookId: ContentId,
    val paragraphId: ContentId,
    val highlightId: ContentId? = null,
    val text: String,
    val createdEpochMs: Long,
    val updatedEpochMs: Long,
)

/**
 * An annotation aggregation — the union of all reader markings for a paragraph.
 */
data class Annotation(
    val paragraphId: ContentId,
    val highlights: List<Highlight> = emptyList(),
    val notes: List<Note> = emptyList(),
    val bookmarks: List<Bookmark> = emptyList(),
)
