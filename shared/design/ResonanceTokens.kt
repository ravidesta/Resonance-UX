/**
 * Resonance UX Design Tokens
 *
 * Canonical design token definitions for the Luminous Integral Architecture
 * multiplatform design system. These tokens drive every visual surface across
 * iOS, Android, Desktop, and Web targets.
 *
 * Palette is rooted in biophilic / nature-inspired hues with gold accents
 * and glass-morphism layering. Typography pairs Cormorant Garamond (editorial
 * serif) with Manrope (clean sans-serif UI face).
 */
package com.luminous.resonance.design

// ──────────────────────────────────────────────
// Color Primitives
// ──────────────────────────────────────────────

/**
 * A platform-agnostic color value stored as an ARGB [Long].
 *
 * Each platform module supplies an `actual` conversion to the native
 * color type (e.g. `androidx.compose.ui.graphics.Color`, `UIColor`).
 */
@JvmInline
value class TokenColor(val argb: Long)

/** Construct a [TokenColor] from 0–255 RGBA channels. */
fun rgba(r: Int, g: Int, b: Int, a: Int = 255): TokenColor =
    TokenColor(
        ((a.toLong() and 0xFF) shl 24) or
        ((r.toLong() and 0xFF) shl 16) or
        ((g.toLong() and 0xFF) shl 8) or
        (b.toLong() and 0xFF)
    )

/** Construct a [TokenColor] from a 0xRRGGBB hex literal (full opacity). */
fun hex(rgb: Long): TokenColor = TokenColor(0xFF000000L or (rgb and 0xFFFFFF))

// ──────────────────────────────────────────────
// Color Palette
// ──────────────────────────────────────────────

/**
 * Core green palette — derived from forest & moss tones.
 */
object GreenPalette {
    val green900: TokenColor = hex(0x0A1C14)
    val green800: TokenColor = hex(0x122E21)
    val green700: TokenColor = hex(0x1B402E)
    val green600: TokenColor = hex(0x27593F)
    val green500: TokenColor = hex(0x357A56)
    val green400: TokenColor = hex(0x5A9E78)
    val green300: TokenColor = hex(0x8FC0A2)
    val green200: TokenColor = hex(0xD1E0D7)
    val green100: TokenColor = hex(0xE8F0EB)
    val green50: TokenColor  = hex(0xF3F7F5)
}

/**
 * Gold accent palette — warmth & luminosity.
 */
object GoldPalette {
    val goldDark: TokenColor    = hex(0x9A7A3A)
    val goldPrimary: TokenColor = hex(0xC5A059)
    val goldLight: TokenColor   = hex(0xE6D0A1)
    val goldMuted: TokenColor   = hex(0xF2E8D4)
}

/**
 * Neutral / surface palette.
 */
object NeutralPalette {
    val white: TokenColor  = hex(0xFFFFFF)
    val baseLight: TokenColor = hex(0xFAFAF8)
    val baseDark: TokenColor  = hex(0x05100B)
    val black: TokenColor  = hex(0x000000)
}

// ──────────────────────────────────────────────
// Semantic Color Roles
// ──────────────────────────────────────────────

/**
 * Semantic color assignments for a single appearance mode.
 *
 * @property background         Primary canvas / page background.
 * @property surface            Card / panel surface.
 * @property surfaceGlass       Glass-morphism translucent panel.
 * @property textMain           Primary body text.
 * @property textMuted          Secondary / caption text.
 * @property textInverse        Text rendered on a dark fill.
 * @property accentPrimary      Primary interactive accent (gold).
 * @property accentSecondary    Secondary interactive accent (green).
 * @property border             Subtle divider / outline.
 * @property error              Destructive / error state.
 * @property success            Positive / success state.
 */
data class SemanticColors(
    val background: TokenColor,
    val surface: TokenColor,
    val surfaceGlass: TokenColor,
    val textMain: TokenColor,
    val textMuted: TokenColor,
    val textInverse: TokenColor,
    val accentPrimary: TokenColor,
    val accentSecondary: TokenColor,
    val border: TokenColor,
    val error: TokenColor,
    val success: TokenColor,
)

/** Light-mode semantic mapping. */
val LightColors = SemanticColors(
    background      = NeutralPalette.baseLight,
    surface         = NeutralPalette.white,
    surfaceGlass    = rgba(255, 255, 255, 178),   // white @ 70 %
    textMain        = GreenPalette.green800,        // #122E21
    textMuted       = hex(0x5C7065),
    textInverse     = NeutralPalette.baseLight,
    accentPrimary   = GoldPalette.goldPrimary,
    accentSecondary = GreenPalette.green700,
    border          = GreenPalette.green200,
    error           = hex(0xBF4040),
    success         = GreenPalette.green500,
)

/** Dark-mode semantic mapping. */
val DarkColors = SemanticColors(
    background      = NeutralPalette.baseDark,
    surface         = GreenPalette.green900,
    surfaceGlass    = rgba(10, 28, 20, 178),       // green-900 @ 70 %
    textMain        = NeutralPalette.baseLight,     // #FAFAF8
    textMuted       = hex(0x8A9C91),
    textInverse     = GreenPalette.green800,
    accentPrimary   = GoldPalette.goldLight,
    accentSecondary = GreenPalette.green400,
    border          = GreenPalette.green700,
    error           = hex(0xE57373),
    success         = GreenPalette.green400,
)

// ──────────────────────────────────────────────
// Typography
// ──────────────────────────────────────────────

/**
 * Font family identifiers used across platforms.
 *
 * Each platform module maps these to the concrete font files or system
 * font descriptors via `expect`/`actual` declarations.
 */
enum class FontFamily {
    /** Cormorant Garamond — editorial serif for headings & pull-quotes. */
    SERIF,

    /** Manrope — geometric sans-serif for body & UI elements. */
    SANS,
}

/**
 * A single typographic style specification.
 *
 * Sizes are in *scale-independent pixels* (sp on Android, pt on iOS).
 */
data class TypeStyle(
    val family: FontFamily,
    val weightName: String,
    val sizeSp: Float,
    val lineHeightSp: Float,
    val letterSpacingSp: Float = 0f,
)

/**
 * Complete typographic scale for the Resonance system.
 */
object TypographyScale {

    // ── Editorial / Serif ───────────────────────
    val displayLarge  = TypeStyle(FontFamily.SERIF, "Bold",       48f, 56f, -0.5f)
    val displayMedium = TypeStyle(FontFamily.SERIF, "Bold",       40f, 48f, -0.25f)
    val displaySmall  = TypeStyle(FontFamily.SERIF, "SemiBold",   34f, 42f,  0f)

    val headlineLarge  = TypeStyle(FontFamily.SERIF, "SemiBold",  28f, 36f,  0f)
    val headlineMedium = TypeStyle(FontFamily.SERIF, "Medium",    24f, 32f,  0f)
    val headlineSmall  = TypeStyle(FontFamily.SERIF, "Medium",    20f, 28f,  0.15f)

    // ── Sans-serif / UI ─────────────────────────
    val titleLarge  = TypeStyle(FontFamily.SANS, "Bold",     22f, 28f,  0f)
    val titleMedium = TypeStyle(FontFamily.SANS, "SemiBold", 18f, 24f,  0.1f)
    val titleSmall  = TypeStyle(FontFamily.SANS, "SemiBold", 16f, 22f,  0.1f)

    val bodyLarge  = TypeStyle(FontFamily.SANS, "Regular", 17f, 26f, 0.15f)
    val bodyMedium = TypeStyle(FontFamily.SANS, "Regular", 15f, 22f, 0.15f)
    val bodySmall  = TypeStyle(FontFamily.SANS, "Regular", 13f, 18f, 0.2f)

    val labelLarge  = TypeStyle(FontFamily.SANS, "Medium", 14f, 20f, 0.5f)
    val labelMedium = TypeStyle(FontFamily.SANS, "Medium", 12f, 16f, 0.5f)
    val labelSmall  = TypeStyle(FontFamily.SANS, "Medium", 10f, 14f, 0.5f)

    val caption = TypeStyle(FontFamily.SANS, "Regular", 12f, 16f, 0.4f)
    val overline = TypeStyle(FontFamily.SANS, "SemiBold", 11f, 16f, 1.5f)

    /** Pull-quote / block-quote style — large italic serif. */
    val pullQuote = TypeStyle(FontFamily.SERIF, "Italic", 22f, 32f, 0f)
}

// ──────────────────────────────────────────────
// Spacing
// ──────────────────────────────────────────────

/**
 * 4-point grid spacing scale (dp / pt).
 */
object Spacing {
    const val xxs: Float =  2f
    const val xs: Float  =  4f
    const val sm: Float  =  8f
    const val md: Float  = 12f
    const val base: Float = 16f
    const val lg: Float  = 24f
    const val xl: Float  = 32f
    const val xxl: Float = 48f
    const val xxxl: Float = 64f
    const val huge: Float = 96f
}

/**
 * Standard corner-radius values (dp / pt).
 */
object CornerRadius {
    const val none: Float   = 0f
    const val xs: Float     = 4f
    const val sm: Float     = 8f
    const val md: Float     = 12f
    const val lg: Float     = 16f
    const val xl: Float     = 24f
    const val pill: Float   = 999f
}

// ──────────────────────────────────────────────
// Animation Curves & Durations
// ──────────────────────────────────────────────

/**
 * Cubic-bezier control points.
 *
 * Platform `actual` implementations map these to `CubicBezierEasing`,
 * `CAMediaTimingFunction`, or CSS `cubic-bezier()`.
 */
data class BezierCurve(
    val x1: Float,
    val y1: Float,
    val x2: Float,
    val y2: Float,
)

/**
 * Motion / animation tokens for the organic "breathing" feel.
 */
object Motion {

    // ── Easing curves ───────────────────────────
    /** Gentle ease-out for entrances. */
    val curveDecelerate = BezierCurve(0.0f, 0.0f, 0.2f, 1.0f)

    /** Standard ease-in-out for transitions. */
    val curveStandard   = BezierCurve(0.4f, 0.0f, 0.2f, 1.0f)

    /** Organic "breathing" curve — slow start, gentle peak, slow end. */
    val curveBreathing  = BezierCurve(0.45f, 0.05f, 0.15f, 0.95f)

    /** Snappy spring-like overshoot. */
    val curveSpring     = BezierCurve(0.34f, 1.56f, 0.64f, 1.0f)

    // ── Durations (milliseconds) ────────────────
    const val durationInstant: Long  = 100
    const val durationFast: Long     = 200
    const val durationMedium: Long   = 350
    const val durationSlow: Long     = 500
    const val durationBreathing: Long = 4000   // one full breathing cycle
    const val durationPageTurn: Long = 600

    // ── Breathing animation parameters ──────────
    /** Scale range for subtle "inhale/exhale" pulsing on ambient elements. */
    const val breatheScaleMin: Float = 0.97f
    const val breatheScaleMax: Float = 1.03f
    /** Opacity range for ambient glow. */
    const val breatheAlphaMin: Float = 0.6f
    const val breatheAlphaMax: Float = 1.0f
}

// ──────────────────────────────────────────────
// Elevation & Glass Morphism
// ──────────────────────────────────────────────

/**
 * Elevation levels modelled as shadow + blur parameters.
 *
 * @property shadowOffsetY  Vertical shadow offset (dp).
 * @property shadowBlur     Shadow blur radius (dp).
 * @property shadowSpread   Shadow spread (dp, may be unsupported on some platforms).
 * @property shadowAlpha    Shadow color alpha (0 – 1).
 */
data class ElevationLevel(
    val shadowOffsetY: Float,
    val shadowBlur: Float,
    val shadowSpread: Float = 0f,
    val shadowAlpha: Float = 0.08f,
)

object Elevation {
    val none   = ElevationLevel(0f, 0f, 0f, 0f)
    val low    = ElevationLevel(1f, 3f, 0f, 0.06f)
    val medium = ElevationLevel(2f, 8f, 1f, 0.08f)
    val high   = ElevationLevel(4f, 16f, 2f, 0.12f)
    val overlay = ElevationLevel(8f, 32f, 4f, 0.16f)
}

/**
 * Glass-morphism panel style.
 *
 * @property backgroundAlpha  Fill opacity (0 – 1).
 * @property blurRadius       Backdrop blur radius (dp / pt).
 * @property borderAlpha      Border stroke opacity.
 * @property borderWidth      Border stroke width (dp / pt).
 */
data class GlassLevel(
    val backgroundAlpha: Float,
    val blurRadius: Float,
    val borderAlpha: Float,
    val borderWidth: Float,
)

object Glass {
    /** Subtle frosted glass — reader chrome overlays. */
    val subtle  = GlassLevel(backgroundAlpha = 0.55f, blurRadius = 12f, borderAlpha = 0.10f, borderWidth = 0.5f)

    /** Standard glass — cards, sheets. */
    val standard = GlassLevel(backgroundAlpha = 0.70f, blurRadius = 20f, borderAlpha = 0.15f, borderWidth = 0.5f)

    /** Heavy glass — modals, coaching panel. */
    val heavy   = GlassLevel(backgroundAlpha = 0.85f, blurRadius = 32f, borderAlpha = 0.20f, borderWidth = 1f)

    /** Opaque glass — fallback for platforms without blur support. */
    val opaque  = GlassLevel(backgroundAlpha = 0.95f, blurRadius = 0f, borderAlpha = 0.12f, borderWidth = 1f)
}

// ──────────────────────────────────────────────
// Icon Sizing
// ──────────────────────────────────────────────

/**
 * Standard icon sizes (dp / pt).
 */
object IconSize {
    const val xs: Float   = 16f
    const val sm: Float   = 20f
    const val md: Float   = 24f
    const val lg: Float   = 32f
    const val xl: Float   = 40f
    const val xxl: Float  = 56f
}

// ──────────────────────────────────────────────
// Breakpoints (responsive layout)
// ──────────────────────────────────────────────

/**
 * Width breakpoints for adaptive layout (dp).
 */
object Breakpoint {
    /** Compact phone portrait. */
    const val compact: Int = 0
    /** Medium — large phone landscape / small tablet. */
    const val medium: Int  = 600
    /** Expanded — tablet / small desktop window. */
    const val expanded: Int = 840
    /** Large — desktop / wide tablet landscape. */
    const val large: Int   = 1200
}
