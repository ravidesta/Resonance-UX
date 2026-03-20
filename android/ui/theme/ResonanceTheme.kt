package com.luminous.resonance.ui.theme

import androidx.compose.animation.core.*
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.BlurredEdgeTreatment
import androidx.compose.ui.draw.blur
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.*
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.Font
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.luminous.resonance.R
import kotlin.math.cos
import kotlin.math.sin

// ---------------------------------------------------------------------------
// Resonance Color Palette
// ---------------------------------------------------------------------------

object ResonanceColors {
    // Backgrounds
    val BgBaseLight = Color(0xFFFAFAF8)
    val BgBaseDark = Color(0xFF05100B)

    // Greens
    val Green900 = Color(0xFF0A1C14)
    val Green800 = Color(0xFF122E21)
    val Green700 = Color(0xFF1B402E)
    val Green600 = Color(0xFF27573E)
    val Green500 = Color(0xFF347050)
    val Green400 = Color(0xFF5C9A7A)
    val Green300 = Color(0xFF8DBEA4)
    val Green200 = Color(0xFFD1E0D7)
    val Green100 = Color(0xFFECF3EF)
    val Green50 = Color(0xFFF5F9F7)

    // Golds
    val GoldPrimary = Color(0xFFC5A059)
    val GoldLight = Color(0xFFE6D0A1)
    val GoldDark = Color(0xFF9A7A3A)
    val GoldMuted = Color(0xFFD4BC83)
    val GoldSubtle = Color(0xFFF0E6CE)

    // Neutrals
    val Neutral50 = Color(0xFFF8F8F6)
    val Neutral100 = Color(0xFFEFEFEB)
    val Neutral200 = Color(0xFFDEDED8)
    val Neutral300 = Color(0xFFC4C4BC)
    val Neutral400 = Color(0xFFA0A098)
    val Neutral500 = Color(0xFF7A7A72)
    val Neutral600 = Color(0xFF5C5C56)
    val Neutral700 = Color(0xFF3E3E3A)
    val Neutral800 = Color(0xFF24241F)
    val Neutral900 = Color(0xFF141410)

    // Semantic
    val ErrorLight = Color(0xFFD44848)
    val ErrorDark = Color(0xFFEF6B6B)
    val WarningLight = Color(0xFFC5A059)
    val WarningDark = Color(0xFFE6D0A1)
    val SuccessLight = Color(0xFF347050)
    val SuccessDark = Color(0xFF5C9A7A)

    // Glass
    val GlassLight = Color(0x33FFFFFF)
    val GlassDark = Color(0x1AFFFFFF)
    val GlassBorderLight = Color(0x33FFFFFF)
    val GlassBorderDark = Color(0x1AFFFFFF)
}

// ---------------------------------------------------------------------------
// Material3 Color Schemes
// ---------------------------------------------------------------------------

private val LightColorScheme = lightColorScheme(
    primary = ResonanceColors.Green700,
    onPrimary = Color.White,
    primaryContainer = ResonanceColors.Green200,
    onPrimaryContainer = ResonanceColors.Green900,
    secondary = ResonanceColors.GoldPrimary,
    onSecondary = Color.White,
    secondaryContainer = ResonanceColors.GoldSubtle,
    onSecondaryContainer = ResonanceColors.GoldDark,
    tertiary = ResonanceColors.Green500,
    onTertiary = Color.White,
    tertiaryContainer = ResonanceColors.Green100,
    onTertiaryContainer = ResonanceColors.Green800,
    background = ResonanceColors.BgBaseLight,
    onBackground = ResonanceColors.Green900,
    surface = ResonanceColors.BgBaseLight,
    onSurface = ResonanceColors.Green900,
    surfaceVariant = ResonanceColors.Neutral100,
    onSurfaceVariant = ResonanceColors.Neutral600,
    outline = ResonanceColors.Neutral300,
    outlineVariant = ResonanceColors.Neutral200,
    error = ResonanceColors.ErrorLight,
    onError = Color.White,
    inverseSurface = ResonanceColors.Green900,
    inverseOnSurface = ResonanceColors.Neutral50,
    inversePrimary = ResonanceColors.Green300,
    surfaceTint = ResonanceColors.Green700,
)

private val DarkColorScheme = darkColorScheme(
    primary = ResonanceColors.Green400,
    onPrimary = ResonanceColors.Green900,
    primaryContainer = ResonanceColors.Green800,
    onPrimaryContainer = ResonanceColors.Green200,
    secondary = ResonanceColors.GoldLight,
    onSecondary = ResonanceColors.Green900,
    secondaryContainer = ResonanceColors.GoldDark,
    onSecondaryContainer = ResonanceColors.GoldSubtle,
    tertiary = ResonanceColors.Green300,
    onTertiary = ResonanceColors.Green900,
    tertiaryContainer = ResonanceColors.Green700,
    onTertiaryContainer = ResonanceColors.Green100,
    background = ResonanceColors.BgBaseDark,
    onBackground = ResonanceColors.Neutral100,
    surface = ResonanceColors.BgBaseDark,
    onSurface = ResonanceColors.Neutral100,
    surfaceVariant = ResonanceColors.Green900,
    onSurfaceVariant = ResonanceColors.Neutral400,
    outline = ResonanceColors.Neutral600,
    outlineVariant = ResonanceColors.Neutral700,
    error = ResonanceColors.ErrorDark,
    onError = ResonanceColors.Green900,
    inverseSurface = ResonanceColors.Neutral100,
    inverseOnSurface = ResonanceColors.Green900,
    inversePrimary = ResonanceColors.Green700,
    surfaceTint = ResonanceColors.Green400,
)

// ---------------------------------------------------------------------------
// Typography
// ---------------------------------------------------------------------------

/**
 * Font families used throughout the Resonance design system.
 *
 * Cormorant Garamond is a refined serif face used for headings and body
 * text in reading contexts, evoking literary depth.
 *
 * Manrope is a geometric sans-serif used for interface text, controls,
 * and navigation, offering clarity at small sizes.
 *
 * Place the corresponding .ttf / .otf files in res/font/ and create
 * font resource XML declarations matching the names below.
 */
val CormorantGaramond = FontFamily(
    Font(R.font.cormorant_garamond_regular, FontWeight.Normal),
    Font(R.font.cormorant_garamond_medium, FontWeight.Medium),
    Font(R.font.cormorant_garamond_semibold, FontWeight.SemiBold),
    Font(R.font.cormorant_garamond_bold, FontWeight.Bold),
    Font(R.font.cormorant_garamond_light, FontWeight.Light),
)

val Manrope = FontFamily(
    Font(R.font.manrope_regular, FontWeight.Normal),
    Font(R.font.manrope_medium, FontWeight.Medium),
    Font(R.font.manrope_semibold, FontWeight.SemiBold),
    Font(R.font.manrope_bold, FontWeight.Bold),
    Font(R.font.manrope_light, FontWeight.Light),
    Font(R.font.manrope_extrabold, FontWeight.ExtraBold),
)

val ResonanceTypography = Typography(
    displayLarge = TextStyle(
        fontFamily = CormorantGaramond,
        fontWeight = FontWeight.Bold,
        fontSize = 57.sp,
        lineHeight = 64.sp,
        letterSpacing = (-0.25).sp,
    ),
    displayMedium = TextStyle(
        fontFamily = CormorantGaramond,
        fontWeight = FontWeight.SemiBold,
        fontSize = 45.sp,
        lineHeight = 52.sp,
    ),
    displaySmall = TextStyle(
        fontFamily = CormorantGaramond,
        fontWeight = FontWeight.SemiBold,
        fontSize = 36.sp,
        lineHeight = 44.sp,
    ),
    headlineLarge = TextStyle(
        fontFamily = CormorantGaramond,
        fontWeight = FontWeight.SemiBold,
        fontSize = 32.sp,
        lineHeight = 40.sp,
    ),
    headlineMedium = TextStyle(
        fontFamily = CormorantGaramond,
        fontWeight = FontWeight.Medium,
        fontSize = 28.sp,
        lineHeight = 36.sp,
    ),
    headlineSmall = TextStyle(
        fontFamily = CormorantGaramond,
        fontWeight = FontWeight.Medium,
        fontSize = 24.sp,
        lineHeight = 32.sp,
    ),
    titleLarge = TextStyle(
        fontFamily = Manrope,
        fontWeight = FontWeight.SemiBold,
        fontSize = 22.sp,
        lineHeight = 28.sp,
    ),
    titleMedium = TextStyle(
        fontFamily = Manrope,
        fontWeight = FontWeight.SemiBold,
        fontSize = 16.sp,
        lineHeight = 24.sp,
        letterSpacing = 0.15.sp,
    ),
    titleSmall = TextStyle(
        fontFamily = Manrope,
        fontWeight = FontWeight.Medium,
        fontSize = 14.sp,
        lineHeight = 20.sp,
        letterSpacing = 0.1.sp,
    ),
    bodyLarge = TextStyle(
        fontFamily = CormorantGaramond,
        fontWeight = FontWeight.Normal,
        fontSize = 18.sp,
        lineHeight = 28.sp,
        letterSpacing = 0.15.sp,
    ),
    bodyMedium = TextStyle(
        fontFamily = Manrope,
        fontWeight = FontWeight.Normal,
        fontSize = 14.sp,
        lineHeight = 20.sp,
        letterSpacing = 0.25.sp,
    ),
    bodySmall = TextStyle(
        fontFamily = Manrope,
        fontWeight = FontWeight.Normal,
        fontSize = 12.sp,
        lineHeight = 16.sp,
        letterSpacing = 0.4.sp,
    ),
    labelLarge = TextStyle(
        fontFamily = Manrope,
        fontWeight = FontWeight.SemiBold,
        fontSize = 14.sp,
        lineHeight = 20.sp,
        letterSpacing = 0.1.sp,
    ),
    labelMedium = TextStyle(
        fontFamily = Manrope,
        fontWeight = FontWeight.Medium,
        fontSize = 12.sp,
        lineHeight = 16.sp,
        letterSpacing = 0.5.sp,
    ),
    labelSmall = TextStyle(
        fontFamily = Manrope,
        fontWeight = FontWeight.Medium,
        fontSize = 11.sp,
        lineHeight = 16.sp,
        letterSpacing = 0.5.sp,
    ),
)

// ---------------------------------------------------------------------------
// Shape System
// ---------------------------------------------------------------------------

val ResonanceShapes = Shapes(
    extraSmall = RoundedCornerShape(4.dp),
    small = RoundedCornerShape(8.dp),
    medium = RoundedCornerShape(16.dp),
    large = RoundedCornerShape(24.dp),
    extraLarge = RoundedCornerShape(32.dp),
)

// ---------------------------------------------------------------------------
// Local Composition – Extended Design Tokens
// ---------------------------------------------------------------------------

/**
 * Extended color palette accessible anywhere inside [ResonanceTheme].
 */
@Immutable
data class ResonanceExtendedColors(
    val gold: Color,
    val goldLight: Color,
    val goldDark: Color,
    val glassSurface: Color,
    val glassBorder: Color,
    val green700: Color,
    val green200: Color,
)

val LocalResonanceColors = staticCompositionLocalOf {
    ResonanceExtendedColors(
        gold = ResonanceColors.GoldPrimary,
        goldLight = ResonanceColors.GoldLight,
        goldDark = ResonanceColors.GoldDark,
        glassSurface = ResonanceColors.GlassLight,
        glassBorder = ResonanceColors.GlassBorderLight,
        green700 = ResonanceColors.Green700,
        green200 = ResonanceColors.Green200,
    )
}

// ---------------------------------------------------------------------------
// Glass Morphism Surface
// ---------------------------------------------------------------------------

/**
 * A composable that renders a frosted-glass card surface with blur,
 * translucent background, and subtle border.
 *
 * On API 31+ the RenderEffect-based blur is used; on older APIs the
 * [Modifier.blur] approximation applies. The visual result is a
 * luminous, organic glass panel consistent with the Resonance aesthetic.
 *
 * @param modifier        Modifier applied to the outer container.
 * @param blurRadius      Radius of the background blur.
 * @param shape           Shape of the glass panel.
 * @param borderWidth     Width of the subtle border.
 * @param content         Composable content rendered inside the panel.
 */
@Composable
fun GlassSurface(
    modifier: Modifier = Modifier,
    blurRadius: Dp = 24.dp,
    shape: Shape = ResonanceShapes.large,
    borderWidth: Dp = 0.5.dp,
    content: @Composable BoxScope.() -> Unit,
) {
    val extended = LocalResonanceColors.current
    val colors = MaterialTheme.colorScheme

    Box(
        modifier = modifier
            .clip(shape)
            .blur(
                radius = blurRadius,
                edgeTreatment = BlurredEdgeTreatment.Unbounded,
            )
            .background(extended.glassSurface, shape)
            .drawBehind {
                // Subtle inner border
                drawRoundRect(
                    color = extended.glassBorder,
                    size = size,
                    cornerRadius = androidx.compose.ui.geometry.CornerRadius(24.dp.toPx()),
                    style = androidx.compose.ui.graphics.drawscope.Stroke(
                        width = borderWidth.toPx()
                    ),
                )
            }
            .padding(1.dp), // inset so border doesn't clip
    ) {
        content()
    }
}

// ---------------------------------------------------------------------------
// Organic Blob Background
// ---------------------------------------------------------------------------

/**
 * An ambient background layer that renders slowly pulsating organic blobs,
 * evoking biophilic nature patterns. The blobs breathe with an infinite
 * animation, shifting position and scale to create a living, contemplative
 * atmosphere behind content.
 *
 * @param modifier      Modifier for the Canvas.
 * @param blobCount     Number of independent blobs.
 * @param baseColor     Primary tint of the blobs.
 * @param accentColor   Secondary tint blended into alternate blobs.
 * @param breathDuration Duration of one full breath cycle in ms.
 */
@Composable
fun OrganicBlobBackground(
    modifier: Modifier = Modifier,
    blobCount: Int = 4,
    baseColor: Color = ResonanceColors.Green700.copy(alpha = 0.12f),
    accentColor: Color = ResonanceColors.GoldPrimary.copy(alpha = 0.08f),
    breathDuration: Int = 8_000,
) {
    val infiniteTransition = rememberInfiniteTransition(label = "blob_breath")

    // Each blob has its own phase-offset breathing animation.
    val phases = (0 until blobCount).map { index ->
        infiniteTransition.animateFloat(
            initialValue = 0f,
            targetValue = 1f,
            animationSpec = infiniteRepeatable(
                animation = tween(
                    durationMillis = breathDuration + index * 800,
                    easing = FastOutSlowInEasing,
                ),
                repeatMode = RepeatMode.Reverse,
            ),
            label = "blob_phase_$index",
        )
    }

    val scaleFactors = (0 until blobCount).map { index ->
        infiniteTransition.animateFloat(
            initialValue = 0.85f,
            targetValue = 1.15f,
            animationSpec = infiniteRepeatable(
                animation = tween(
                    durationMillis = breathDuration + index * 1_200,
                    easing = EaseInOutCubic,
                ),
                repeatMode = RepeatMode.Reverse,
            ),
            label = "blob_scale_$index",
        )
    }

    Canvas(modifier = modifier.fillMaxSize()) {
        val w = size.width
        val h = size.height

        for (i in 0 until blobCount) {
            val phase = phases[i].value
            val scale = scaleFactors[i].value

            // Distribute blobs across the canvas with organic drift
            val cx = w * (0.2f + 0.6f * ((i.toFloat() / blobCount) + 0.05f * sin(phase * Math.PI.toFloat() * 2)))
            val cy = h * (0.25f + 0.5f * ((i.toFloat() / blobCount).let { it * 0.8f + 0.1f } + 0.04f * cos(phase * Math.PI.toFloat() * 2)))
            val radius = (w.coerceAtMost(h) * 0.28f) * scale

            val color = if (i % 2 == 0) baseColor else accentColor

            drawCircle(
                brush = Brush.radialGradient(
                    colors = listOf(color, color.copy(alpha = 0f)),
                    center = Offset(cx, cy),
                    radius = radius,
                ),
                radius = radius,
                center = Offset(cx, cy),
            )
        }
    }
}

// ---------------------------------------------------------------------------
// Breathing Animation Helper
// ---------------------------------------------------------------------------

/**
 * Returns an infinitely-animated float that oscillates between [min] and
 * [max] over the given [durationMs], simulating a calm breathing rhythm.
 * Useful for somatic practice timers and ambient UI pulses.
 */
@Composable
fun rememberBreathingAnimation(
    min: Float = 0.9f,
    max: Float = 1.1f,
    durationMs: Int = 4_000,
): State<Float> {
    val transition = rememberInfiniteTransition(label = "breathing")
    return transition.animateFloat(
        initialValue = min,
        targetValue = max,
        animationSpec = infiniteRepeatable(
            animation = tween(durationMs, easing = EaseInOutCubic),
            repeatMode = RepeatMode.Reverse,
        ),
        label = "breath_scale",
    )
}

// ---------------------------------------------------------------------------
// Theme Composable
// ---------------------------------------------------------------------------

/**
 * Root theme composable for the Luminous Integral Architecture app.
 *
 * Wraps [MaterialTheme] with the Resonance color scheme, typography, and
 * shapes, and provides extended design tokens via [LocalResonanceColors].
 */
@Composable
fun ResonanceTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    content: @Composable () -> Unit,
) {
    val colorScheme = if (darkTheme) DarkColorScheme else LightColorScheme

    val extendedColors = if (darkTheme) {
        ResonanceExtendedColors(
            gold = ResonanceColors.GoldPrimary,
            goldLight = ResonanceColors.GoldLight,
            goldDark = ResonanceColors.GoldDark,
            glassSurface = ResonanceColors.GlassDark,
            glassBorder = ResonanceColors.GlassBorderDark,
            green700 = ResonanceColors.Green700,
            green200 = ResonanceColors.Green200,
        )
    } else {
        ResonanceExtendedColors(
            gold = ResonanceColors.GoldPrimary,
            goldLight = ResonanceColors.GoldLight,
            goldDark = ResonanceColors.GoldDark,
            glassSurface = ResonanceColors.GlassLight,
            glassBorder = ResonanceColors.GlassBorderLight,
            green700 = ResonanceColors.Green700,
            green200 = ResonanceColors.Green200,
        )
    }

    CompositionLocalProvider(LocalResonanceColors provides extendedColors) {
        MaterialTheme(
            colorScheme = colorScheme,
            typography = ResonanceTypography,
            shapes = ResonanceShapes,
            content = content,
        )
    }
}

/**
 * Convenience accessor for the extended Resonance color palette.
 */
object ResonanceTheme {
    val extendedColors: ResonanceExtendedColors
        @Composable
        @ReadOnlyComposable
        get() = LocalResonanceColors.current
}
