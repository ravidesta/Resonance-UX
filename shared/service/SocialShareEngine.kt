/**
 * Social Share Engine Service
 *
 * Cross-platform social sharing engine for the Luminous Integral
 * Architecture™ ecosystem. Generates beautiful, branded share cards
 * (quotes, milestones, reflections), handles deep-linking for viral
 * re-entry, tracks share analytics, and integrates with platform-native
 * share sheets.
 *
 * The [SocialShareEngine] interface is implemented per-platform while all
 * data types are pure common code. Image rendering is abstracted behind
 * the [ShareCardRenderer] interface and platform share APIs are handled
 * via [PlatformShareSession] expect/actual declarations.
 */
package com.luminous.resonance.service

import kotlinx.coroutines.flow.StateFlow
import kotlinx.serialization.Serializable

// ──────────────────────────────────────────────
// Shareable Content Type
// ──────────────────────────────────────────────

/**
 * Category of content that can be shared socially.
 *
 * Each type drives different visual templates and metadata in the
 * generated [ShareCard].
 */
@Serializable
enum class ShareableContentType {
    /** A highlighted or favourite book quote. */
    BOOK_QUOTE,

    /** An insight captured in the user's reflection journal. */
    REFLECTION_INSIGHT,

    /** Completion of a guided somatic or contemplative practice. */
    PRACTICE_COMPLETION,

    /** A reading milestone (e.g. finished a chapter or the entire book). */
    READING_MILESTONE,

    /** A result from the AQAL quadrant-map assessment. */
    QUADRANT_MAP_RESULT,

    /** Invitation to join the Luminous community. */
    COMMUNITY_INVITE,

    /** A notable insight surfaced during a coaching session. */
    COACH_INSIGHT,
}

// ──────────────────────────────────────────────
// Share Card Styling
// ──────────────────────────────────────────────

/**
 * Background style for a rendered [ShareCard].
 *
 * Each style maps to a branded palette in the Luminous design system.
 */
@Serializable
enum class ShareCardBackground {
    /** Deep green gradient evoking growth and nature. */
    FOREST_GREEN,

    /** Warm gold accent with cream undertones. */
    GOLD_ACCENT,

    /** Light cream / parchment for a clean, readable look. */
    CREAM_LIGHT,

    /** Dark mode with high-contrast typography. */
    NIGHT_MODE,

    /** Soft indigo-to-violet gradient for contemplative content. */
    INDIGO_GRADIENT,

    /** Sunrise warm tones for milestone celebrations. */
    SUNRISE_WARM,
}

/**
 * Typography preset for share card text rendering.
 *
 * Quote text always uses Cormorant Garamond; body text uses the
 * system's branded sans-serif.
 */
@Serializable
enum class ShareCardTypography {
    /** Cormorant Garamond — elegant serif for quotes. */
    CORMORANT_GARAMOND,

    /** Sans-serif body text. */
    BODY_SANS,
}

// ──────────────────────────────────────────────
// Share Card
// ──────────────────────────────────────────────

/**
 * A brandable, renderable card for social sharing.
 *
 * The [ShareCardRenderer] turns this data into a platform-appropriate
 * image or rich-media attachment.
 *
 * @property id              Unique card identifier.
 * @property contentType     Category of the shared content.
 * @property title           Headline text (e.g. "Chapter 4 Complete").
 * @property body            Supporting body text or reflection excerpt.
 * @property quoteText       The highlighted quote, if applicable.
 * @property attribution     Attribution line (e.g. author name, book title).
 * @property backgroundStyle Visual background preset.
 * @property quoteTypography Typography for the quote text (always Cormorant Garamond).
 * @property bodyTypography  Typography for the body text.
 * @property appDeepLink     Deep link URL that opens the app to related content.
 * @property hashtags        Suggested hashtags for social platforms.
 * @property imageUrl        Optional pre-rendered image URL, populated after rendering.
 * @property createdAtEpochMs Timestamp of card creation.
 */
@Serializable
data class ShareCard(
    val id: String,
    val contentType: ShareableContentType,
    val title: String,
    val body: String = "",
    val quoteText: String? = null,
    val attribution: String? = null,
    val backgroundStyle: ShareCardBackground = ShareCardBackground.CREAM_LIGHT,
    val quoteTypography: ShareCardTypography = ShareCardTypography.CORMORANT_GARAMOND,
    val bodyTypography: ShareCardTypography = ShareCardTypography.BODY_SANS,
    val appDeepLink: String = "",
    val hashtags: List<String> = emptyList(),
    val imageUrl: String? = null,
    val createdAtEpochMs: Long = 0L,
)

// ──────────────────────────────────────────────
// Share Target
// ──────────────────────────────────────────────

/**
 * Social platform or mechanism through which content can be shared.
 */
@Serializable
enum class ShareTarget {
    INSTAGRAM_STORY,
    INSTAGRAM_POST,
    TWITTER_X,
    FACEBOOK,
    LINKEDIN,
    THREADS,
    TIKTOK,
    WHATSAPP,
    TELEGRAM,
    IMESSAGE,
    EMAIL,
    PINTEREST,
    MASTODON,
    BLUESKY,
    /** Copy a shareable link to the clipboard. */
    COPY_LINK,
    /** Invoke the platform-native share sheet. */
    SYSTEM_SHARE,
}

// ──────────────────────────────────────────────
// Share Analytics
// ──────────────────────────────────────────────

/**
 * Analytics event recorded when a user shares content.
 *
 * @property shareId          Unique share event identifier.
 * @property target           Platform or mechanism used for sharing.
 * @property timestampEpochMs Epoch timestamp of the share event.
 * @property contentType      Category of the shared content.
 * @property cardId           Identifier of the [ShareCard] that was shared.
 * @property resultedInInstall Whether this share led to a new app install
 *                             (null if not yet determined).
 * @property referralCode     Referral code attached to this share, if any.
 */
@Serializable
data class ShareAnalytics(
    val shareId: String,
    val target: ShareTarget,
    val timestampEpochMs: Long,
    val contentType: ShareableContentType,
    val cardId: String = "",
    val resultedInInstall: Boolean? = null,
    val referralCode: String? = null,
)

// ──────────────────────────────────────────────
// Deep Links
// ──────────────────────────────────────────────

/**
 * A deep link into the Luminous app.
 *
 * Uses the `luminous://` scheme to route users to specific in-app
 * destinations. Universal / App Links are also supported for fallback.
 *
 * @property scheme   URL scheme (always "luminous").
 * @property path     Destination path (e.g. "/chapter", "/exercise", "/coach", "/community").
 * @property params   Query parameters providing context (e.g. chapterId, exerciseId).
 * @property fullUrl  The fully composed deep link URL string.
 */
@Serializable
data class DeepLink(
    val scheme: String = "luminous",
    val path: String,
    val params: Map<String, String> = emptyMap(),
    val fullUrl: String = "",
) {
    companion object {
        /** Path for opening a specific book chapter. */
        const val PATH_CHAPTER = "/chapter"

        /** Path for opening a guided exercise or practice. */
        const val PATH_EXERCISE = "/exercise"

        /** Path for opening the AI coach. */
        const val PATH_COACH = "/coach"

        /** Path for opening a community space. */
        const val PATH_COMMUNITY = "/community"

        /** Path for opening a study group. */
        const val PATH_STUDY_GROUP = "/study-group"

        /** Path for accepting a referral. */
        const val PATH_REFERRAL = "/referral"
    }
}

// ──────────────────────────────────────────────
// Share Templates
// ──────────────────────────────────────────────

/**
 * Preset share templates for common sharing scenarios.
 *
 * Each template pre-populates a [ShareCard] with appropriate styling,
 * hashtags, and copy for a specific sharing moment.
 */
@Serializable
enum class ShareTemplate {
    /** Template for sharing a favourite quote with Cormorant Garamond typography. */
    FAVOURITE_QUOTE,

    /** Template for celebrating completion of a chapter. */
    CHAPTER_COMPLETE,

    /** Template for celebrating completion of the entire book. */
    BOOK_COMPLETE,

    /** Template for sharing a guided-practice completion badge. */
    PRACTICE_BADGE,

    /** Template for sharing a developmental-assessment result. */
    ASSESSMENT_RESULT,

    /** Template for inviting a friend to a study group. */
    STUDY_GROUP_INVITE,

    /** Template for a general community invitation. */
    COMMUNITY_INVITE,

    /** Template for sharing a coach insight or "aha" moment. */
    COACH_AHA_MOMENT,
}

/**
 * Pre-built configuration for a [ShareTemplate].
 *
 * @property template       The template this configuration belongs to.
 * @property background     Default background style.
 * @property defaultHashtags  Hashtags automatically included.
 * @property titleFormat    Format string for the card title (use `%s` for dynamic content).
 * @property bodyFormat     Format string for the card body.
 */
@Serializable
data class ShareTemplateConfig(
    val template: ShareTemplate,
    val background: ShareCardBackground,
    val defaultHashtags: List<String> = listOf("#Luminous", "#IntegralLife"),
    val titleFormat: String = "",
    val bodyFormat: String = "",
)

// ──────────────────────────────────────────────
// Share Card Renderer
// ──────────────────────────────────────────────

/**
 * Platform-specific renderer that converts a [ShareCard] into an image.
 *
 * On iOS this may use Core Graphics or SwiftUI snapshotting; on Android
 * it uses Canvas / Bitmap rendering; on Web it produces an HTML canvas
 * or SVG export.
 */
interface ShareCardRenderer {

    /**
     * Render a [ShareCard] to an image and return the local file path
     * or data URI of the rendered image.
     *
     * @param card    The card to render.
     * @param widthPx Desired image width in pixels.
     * @param heightPx Desired image height in pixels.
     * @return Local file path or data URI of the rendered image.
     */
    suspend fun renderToImage(card: ShareCard, widthPx: Int = 1080, heightPx: Int = 1920): String

    /**
     * Render a [ShareCard] to raw image bytes (PNG).
     *
     * @param card    The card to render.
     * @param widthPx Desired image width in pixels.
     * @param heightPx Desired image height in pixels.
     * @return PNG image data.
     */
    suspend fun renderToBytes(card: ShareCard, widthPx: Int = 1080, heightPx: Int = 1920): ByteArray
}

// ──────────────────────────────────────────────
// Social Share Engine Interface
// ──────────────────────────────────────────────

/**
 * Engine for generating, distributing, and tracking social shares
 * of Luminous content.
 *
 * Handles the full sharing lifecycle: card generation with branded
 * visuals, deep-link creation for viral re-entry, platform-specific
 * share dispatch, and analytics tracking.
 *
 * Typical lifecycle:
 * 1. [generateShareCard] — create a branded share card for the content.
 * 2. [shareToTarget] or [shareViaSystemSheet] — distribute the card.
 * 3. [trackShare] — record the share event for analytics.
 * 4. [generateDeepLink] — create a deep link for the shared content.
 */
interface SocialShareEngine {

    /** Observable history of share events in the current session. */
    val shareHistory: StateFlow<List<ShareAnalytics>>

    // ── Card Generation ────────────────────────

    /**
     * Generate a branded share card for the given content.
     *
     * @param content  Category of the content being shared.
     * @param text     The primary text to display (quote, reflection, etc.).
     * @param chapter  Optional chapter title or identifier for attribution.
     * @return A fully populated [ShareCard] ready for rendering and sharing.
     */
    suspend fun generateShareCard(
        content: ShareableContentType,
        text: String,
        chapter: String? = null,
    ): ShareCard

    /**
     * Generate a share card from a preset template.
     *
     * @param template The template to use.
     * @param text     Dynamic content text.
     * @param chapter  Optional chapter attribution.
     * @return A [ShareCard] populated from the template configuration.
     */
    suspend fun generateFromTemplate(
        template: ShareTemplate,
        text: String,
        chapter: String? = null,
    ): ShareCard

    // ── Sharing ────────────────────────────────

    /**
     * Share a card to a specific social platform.
     *
     * The engine handles platform-specific formatting, image rendering,
     * and intent construction.
     *
     * @param card   The card to share.
     * @param target The social platform or mechanism.
     */
    suspend fun shareToTarget(card: ShareCard, target: ShareTarget)

    /**
     * Present the platform-native share sheet with the rendered card.
     *
     * @param card The card to share via the system share sheet.
     */
    suspend fun shareViaSystemSheet(card: ShareCard)

    // ── Deep Links ─────────────────────────────

    /**
     * Generate a deep link URL for a specific in-app destination.
     *
     * @param destination Path segment (e.g. [DeepLink.PATH_CHAPTER]).
     * @param params      Query parameters for the destination.
     * @return Fully composed deep link URL string.
     */
    fun generateDeepLink(destination: String, params: Map<String, String>): String

    // ── Analytics ──────────────────────────────

    /**
     * Record a share event for analytics and attribution tracking.
     *
     * @param analytics The share event to track.
     */
    fun trackShare(analytics: ShareAnalytics)

    /**
     * Retrieve all share events for the current user.
     *
     * @return Chronologically ordered list of [ShareAnalytics].
     */
    fun getShareHistory(): List<ShareAnalytics>

    // ── Referrals ──────────────────────────────

    /**
     * Generate a unique referral link for a user.
     *
     * The link includes a referral code for install attribution.
     *
     * @param userId Identifier of the referring user.
     * @return Referral URL string.
     */
    fun generateReferralLink(userId: String): String

    // ── Study Groups ───────────────────────────

    /**
     * Create a shareable invitation card for a study group.
     *
     * @param groupId Identifier of the study group.
     * @return A [ShareCard] configured as a study group invitation.
     */
    suspend fun createStudyGroupInvite(groupId: String): ShareCard
}

// ──────────────────────────────────────────────
// Platform Share Session (expect/actual)
// ──────────────────────────────────────────────

/**
 * Platform-specific share session management.
 *
 * On iOS this wraps `UIActivityViewController`; on Android it manages
 * `Intent.ACTION_SEND` and content-provider URIs; on desktop/web it
 * bridges to the Web Share API or clipboard.
 *
 * Implementations are provided via Kotlin Multiplatform `actual` declarations
 * in each platform source set.
 */
expect class PlatformShareSession() {

    /**
     * Present the system share sheet with the given text and optional image.
     *
     * @param text     Text content to share.
     * @param imageUri Local file URI of an image to attach, if any.
     * @param url      URL to include in the share, if any.
     */
    fun showShareSheet(text: String, imageUri: String? = null, url: String? = null)

    /**
     * Copy text to the system clipboard.
     *
     * @param text The text to copy.
     */
    fun copyToClipboard(text: String)

    /**
     * Check whether a specific share target is available on this device.
     *
     * @param target The share target to check.
     * @return `true` if the target app or mechanism is installed and available.
     */
    fun isTargetAvailable(target: ShareTarget): Boolean

    /**
     * Share directly to a specific target app via platform intents or URL schemes.
     *
     * @param target   The target platform.
     * @param text     Text content to share.
     * @param imageUri Local file URI of an image to attach, if any.
     * @param url      URL to include in the share, if any.
     */
    fun shareToTarget(target: ShareTarget, text: String, imageUri: String? = null, url: String? = null)
}
