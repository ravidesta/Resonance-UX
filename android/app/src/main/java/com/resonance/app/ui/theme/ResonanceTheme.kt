package com.resonance.app.ui.theme

import android.app.Activity
import android.os.Build
import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.Spring
import androidx.compose.animation.core.spring
import androidx.compose.animation.core.tween
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.ColorScheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Shapes
import androidx.compose.material3.Typography
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.dynamicDarkColorScheme
import androidx.compose.material3.dynamicLightColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.Immutable
import androidx.compose.runtime.SideEffect
import androidx.compose.runtime.Stable
import androidx.compose.runtime.compositionLocalOf
import androidx.compose.runtime.getValue
import androidx.compose.runtime.staticCompositionLocalOf
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalView
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.Font
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.googlefonts.Font
import androidx.compose.ui.text.googlefonts.GoogleFont
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.core.view.WindowCompat

// ─────────────────────────────────────────────
// Color Palette
// ─────────────────────────────────────────────

object ResonanceColors {
    // Light theme
    val Base = Color(0xFFFAFAF8)
    val Surface = Color(0xFFFFFFFF)
    val SurfaceVariant = Color(0xFFF2F2EE)
    val Green900 = Color(0xFF0A1C14)
    val Green800 = Color(0xFF122E21)
    val Green700 = Color(0xFF1A4032)
    val Green600 = Color(0xFF2D5A3F)
    val Green500 = Color(0xFF3D7A5F)
    val Gold = Color(0xFFC5A059)
    val GoldLight = Color(0xFFD4B878)
    val GoldDark = Color(0xFFA88640)
    val TextMuted = Color(0xFF5C7065)
    val TextSubtle = Color(0xFF8A9E90)
    val Divider = Color(0xFFE0E5E1)
    val Error = Color(0xFFB33A3A)
    val ErrorLight = Color(0xFFFDE8E8)
    val Success = Color(0xFF2D7A4F)
    val Warning = Color(0xFFC5A059)

    // Deep Rest (dark) theme
    val DeepRestBase = Color(0xFF05100B)
    val DeepRestSurface = Color(0xFF0A1C14)
    val DeepRestSurfaceElevated = Color(0xFF122E21)
    val DeepRestText = Color(0xFFFAFAF8)
    val DeepRestTextMuted = Color(0xFFA0B5A8)
    val DeepRestDivider = Color(0xFF1A3525)

    // Energy level colors
    val EnergyDepleted = Color(0xFF8A4040)
    val EnergyLow = Color(0xFFC5A059)
    val EnergyModerate = Color(0xFF6B9E7A)
    val EnergyHigh = Color(0xFF3D7A5F)
    val EnergyPeak = Color(0xFF2D5A3F)

    // Phase colors
    val PhaseAscend = Color(0xFFC5A059)
    val PhaseZenith = Color(0xFF3D7A5F)
    val PhaseDescent = Color(0xFF6B9E7A)
    val PhaseRest = Color(0xFF2D4A3F)
}

// ─────────────────────────────────────────────
// Material3 Color Schemes
// ─────────────────────────────────────────────

val ResonanceLightColorScheme = lightColorScheme(
    primary = ResonanceColors.Green800,
    onPrimary = ResonanceColors.Base,
    primaryContainer = ResonanceColors.Green600,
    onPrimaryContainer = ResonanceColors.Base,
    secondary = ResonanceColors.Gold,
    onSecondary = ResonanceColors.Green900,
    secondaryContainer = ResonanceColors.GoldLight,
    onSecondaryContainer = ResonanceColors.Green900,
    tertiary = ResonanceColors.Green500,
    onTertiary = ResonanceColors.Base,
    background = ResonanceColors.Base,
    onBackground = ResonanceColors.Green900,
    surface = ResonanceColors.Surface,
    onSurface = ResonanceColors.Green900,
    surfaceVariant = ResonanceColors.SurfaceVariant,
    onSurfaceVariant = ResonanceColors.TextMuted,
    outline = ResonanceColors.Divider,
    outlineVariant = ResonanceColors.TextSubtle,
    error = ResonanceColors.Error,
    onError = Color.White,
    errorContainer = ResonanceColors.ErrorLight,
    onErrorContainer = ResonanceColors.Error,
    inverseSurface = ResonanceColors.Green900,
    inverseOnSurface = ResonanceColors.Base,
    inversePrimary = ResonanceColors.GoldLight,
    scrim = Color(0x66000000),
    surfaceTint = ResonanceColors.Green800,
)

val ResonanceDeepRestColorScheme = darkColorScheme(
    primary = ResonanceColors.Gold,
    onPrimary = ResonanceColors.DeepRestBase,
    primaryContainer = ResonanceColors.GoldDark,
    onPrimaryContainer = ResonanceColors.DeepRestText,
    secondary = ResonanceColors.Green500,
    onSecondary = ResonanceColors.DeepRestBase,
    secondaryContainer = ResonanceColors.Green700,
    onSecondaryContainer = ResonanceColors.DeepRestText,
    tertiary = ResonanceColors.GoldLight,
    onTertiary = ResonanceColors.DeepRestBase,
    background = ResonanceColors.DeepRestBase,
    onBackground = ResonanceColors.DeepRestText,
    surface = ResonanceColors.DeepRestSurface,
    onSurface = ResonanceColors.DeepRestText,
    surfaceVariant = ResonanceColors.DeepRestSurfaceElevated,
    onSurfaceVariant = ResonanceColors.DeepRestTextMuted,
    outline = ResonanceColors.DeepRestDivider,
    outlineVariant = ResonanceColors.DeepRestDivider,
    error = Color(0xFFFF8A80),
    onError = Color(0xFF5C1010),
    errorContainer = Color(0xFF7A2020),
    onErrorContainer = Color(0xFFFFDAD6),
    inverseSurface = ResonanceColors.Base,
    inverseOnSurface = ResonanceColors.DeepRestBase,
    inversePrimary = ResonanceColors.Green800,
    scrim = Color(0x99000000),
    surfaceTint = ResonanceColors.Gold,
)

// ─────────────────────────────────────────────
// Typography
// ─────────────────────────────────────────────

private val googleFontProvider = GoogleFont.Provider(
    providerAuthority = "com.google.android.gms.fonts",
    providerPackage = "com.google.android.gms",
    certificates = emptyList() // In production, add proper certificates
)

private val cormorantGaramond = GoogleFont("Cormorant Garamond")
private val manrope = GoogleFont("Manrope")

val CormorantGaramondFamily = FontFamily(
    Font(googleFont = cormorantGaramond, fontProvider = googleFontProvider, weight = FontWeight.Light),
    Font(googleFont = cormorantGaramond, fontProvider = googleFontProvider, weight = FontWeight.Normal),
    Font(googleFont = cormorantGaramond, fontProvider = googleFontProvider, weight = FontWeight.Medium),
    Font(googleFont = cormorantGaramond, fontProvider = googleFontProvider, weight = FontWeight.SemiBold),
    Font(googleFont = cormorantGaramond, fontProvider = googleFontProvider, weight = FontWeight.Bold),
    Font(googleFont = cormorantGaramond, fontProvider = googleFontProvider, weight = FontWeight.Normal, style = FontStyle.Italic),
    Font(googleFont = cormorantGaramond, fontProvider = googleFontProvider, weight = FontWeight.Medium, style = FontStyle.Italic),
)

val ManropeFamily = FontFamily(
    Font(googleFont = manrope, fontProvider = googleFontProvider, weight = FontWeight.ExtraLight),
    Font(googleFont = manrope, fontProvider = googleFontProvider, weight = FontWeight.Light),
    Font(googleFont = manrope, fontProvider = googleFontProvider, weight = FontWeight.Normal),
    Font(googleFont = manrope, fontProvider = googleFontProvider, weight = FontWeight.Medium),
    Font(googleFont = manrope, fontProvider = googleFontProvider, weight = FontWeight.SemiBold),
    Font(googleFont = manrope, fontProvider = googleFontProvider, weight = FontWeight.Bold),
    Font(googleFont = manrope, fontProvider = googleFontProvider, weight = FontWeight.ExtraBold),
)

val ResonanceTypography = Typography(
    displayLarge = TextStyle(
        fontFamily = CormorantGaramondFamily,
        fontWeight = FontWeight.Light,
        fontSize = 57.sp,
        lineHeight = 64.sp,
        letterSpacing = (-0.25).sp,
    ),
    displayMedium = TextStyle(
        fontFamily = CormorantGaramondFamily,
        fontWeight = FontWeight.Normal,
        fontSize = 45.sp,
        lineHeight = 52.sp,
        letterSpacing = 0.sp,
    ),
    displaySmall = TextStyle(
        fontFamily = CormorantGaramondFamily,
        fontWeight = FontWeight.Normal,
        fontSize = 36.sp,
        lineHeight = 44.sp,
        letterSpacing = 0.sp,
    ),
    headlineLarge = TextStyle(
        fontFamily = CormorantGaramondFamily,
        fontWeight = FontWeight.Medium,
        fontSize = 32.sp,
        lineHeight = 40.sp,
        letterSpacing = 0.sp,
    ),
    headlineMedium = TextStyle(
        fontFamily = CormorantGaramondFamily,
        fontWeight = FontWeight.Medium,
        fontSize = 28.sp,
        lineHeight = 36.sp,
        letterSpacing = 0.sp,
    ),
    headlineSmall = TextStyle(
        fontFamily = CormorantGaramondFamily,
        fontWeight = FontWeight.SemiBold,
        fontSize = 24.sp,
        lineHeight = 32.sp,
        letterSpacing = 0.sp,
    ),
    titleLarge = TextStyle(
        fontFamily = ManropeFamily,
        fontWeight = FontWeight.Medium,
        fontSize = 22.sp,
        lineHeight = 28.sp,
        letterSpacing = 0.sp,
    ),
    titleMedium = TextStyle(
        fontFamily = ManropeFamily,
        fontWeight = FontWeight.Medium,
        fontSize = 16.sp,
        lineHeight = 24.sp,
        letterSpacing = 0.15.sp,
    ),
    titleSmall = TextStyle(
        fontFamily = ManropeFamily,
        fontWeight = FontWeight.SemiBold,
        fontSize = 14.sp,
        lineHeight = 20.sp,
        letterSpacing = 0.1.sp,
    ),
    bodyLarge = TextStyle(
        fontFamily = ManropeFamily,
        fontWeight = FontWeight.Normal,
        fontSize = 16.sp,
        lineHeight = 24.sp,
        letterSpacing = 0.5.sp,
    ),
    bodyMedium = TextStyle(
        fontFamily = ManropeFamily,
        fontWeight = FontWeight.Normal,
        fontSize = 14.sp,
        lineHeight = 20.sp,
        letterSpacing = 0.25.sp,
    ),
    bodySmall = TextStyle(
        fontFamily = ManropeFamily,
        fontWeight = FontWeight.Normal,
        fontSize = 12.sp,
        lineHeight = 16.sp,
        letterSpacing = 0.4.sp,
    ),
    labelLarge = TextStyle(
        fontFamily = ManropeFamily,
        fontWeight = FontWeight.Medium,
        fontSize = 14.sp,
        lineHeight = 20.sp,
        letterSpacing = 0.1.sp,
    ),
    labelMedium = TextStyle(
        fontFamily = ManropeFamily,
        fontWeight = FontWeight.Medium,
        fontSize = 12.sp,
        lineHeight = 16.sp,
        letterSpacing = 0.5.sp,
    ),
    labelSmall = TextStyle(
        fontFamily = ManropeFamily,
        fontWeight = FontWeight.Medium,
        fontSize = 11.sp,
        lineHeight = 16.sp,
        letterSpacing = 0.5.sp,
    ),
)

// Prose typography for the Writer
val ProseTypography = TextStyle(
    fontFamily = CormorantGaramondFamily,
    fontWeight = FontWeight.Normal,
    fontSize = 20.sp,
    lineHeight = 32.sp,
    letterSpacing = 0.15.sp,
)

val ProseHeading = TextStyle(
    fontFamily = CormorantGaramondFamily,
    fontWeight = FontWeight.SemiBold,
    fontSize = 28.sp,
    lineHeight = 36.sp,
    letterSpacing = (-0.1).sp,
)

// ─────────────────────────────────────────────
// Shapes
// ─────────────────────────────────────────────

val ResonanceShapes = Shapes(
    extraSmall = RoundedCornerShape(4.dp),
    small = RoundedCornerShape(8.dp),
    medium = RoundedCornerShape(12.dp),
    large = RoundedCornerShape(16.dp),
    extraLarge = RoundedCornerShape(24.dp),
)

val GlassShape = RoundedCornerShape(20.dp)
val PillShape = RoundedCornerShape(50)
val CardShape = RoundedCornerShape(16.dp)
val BottomSheetShape = RoundedCornerShape(topStart = 24.dp, topEnd = 24.dp)

// ─────────────────────────────────────────────
// Spacing System
// ─────────────────────────────────────────────

@Immutable
data class ResonanceSpacing(
    val none: Dp = 0.dp,
    val xxs: Dp = 2.dp,
    val xs: Dp = 4.dp,
    val sm: Dp = 8.dp,
    val md: Dp = 12.dp,
    val base: Dp = 16.dp,
    val lg: Dp = 20.dp,
    val xl: Dp = 24.dp,
    val xxl: Dp = 32.dp,
    val xxxl: Dp = 40.dp,
    val huge: Dp = 48.dp,
    val massive: Dp = 64.dp,
    val screenPadding: Dp = 20.dp,
    val cardPadding: Dp = 16.dp,
    val sectionGap: Dp = 32.dp,
)

val LocalResonanceSpacing = staticCompositionLocalOf { ResonanceSpacing() }

// ─────────────────────────────────────────────
// Elevation System
// ─────────────────────────────────────────────

@Immutable
data class ResonanceElevation(
    val none: Dp = 0.dp,
    val subtle: Dp = 1.dp,
    val low: Dp = 2.dp,
    val medium: Dp = 4.dp,
    val high: Dp = 8.dp,
    val overlay: Dp = 16.dp,
)

val LocalResonanceElevation = staticCompositionLocalOf { ResonanceElevation() }

// ─────────────────────────────────────────────
// Animation Specs
// ─────────────────────────────────────────────

object ResonanceMotion {
    val smoothSpring = spring<Float>(
        dampingRatio = Spring.DampingRatioMediumBouncy,
        stiffness = Spring.StiffnessLow,
    )

    val gentleSpring = spring<Float>(
        dampingRatio = Spring.DampingRatioNoBouncy,
        stiffness = Spring.StiffnessVeryLow,
    )

    val calmTween = tween<Float>(durationMillis = 600)
    val quickTween = tween<Float>(durationMillis = 300)
    val breathTween = tween<Float>(durationMillis = 4000)

    val pageTransitionDuration = 400
    val phaseTransitionDuration = 800
    val microInteractionDuration = 200

    fun <T> colorTransitionSpec() = spring<T>(
        dampingRatio = Spring.DampingRatioNoBouncy,
        stiffness = Spring.StiffnessVeryLow,
    )
}

// ─────────────────────────────────────────────
// Extended Theme Properties
// ─────────────────────────────────────────────

@Immutable
data class ResonanceExtendedColors(
    val gold: Color = ResonanceColors.Gold,
    val goldLight: Color = ResonanceColors.GoldLight,
    val goldDark: Color = ResonanceColors.GoldDark,
    val textMuted: Color = ResonanceColors.TextMuted,
    val textSubtle: Color = ResonanceColors.TextSubtle,
    val divider: Color = ResonanceColors.Divider,
    val success: Color = ResonanceColors.Success,
    val warning: Color = ResonanceColors.Warning,
    val energyDepleted: Color = ResonanceColors.EnergyDepleted,
    val energyLow: Color = ResonanceColors.EnergyLow,
    val energyModerate: Color = ResonanceColors.EnergyModerate,
    val energyHigh: Color = ResonanceColors.EnergyHigh,
    val energyPeak: Color = ResonanceColors.EnergyPeak,
    val phaseAscend: Color = ResonanceColors.PhaseAscend,
    val phaseZenith: Color = ResonanceColors.PhaseZenith,
    val phaseDescent: Color = ResonanceColors.PhaseDescent,
    val phaseRest: Color = ResonanceColors.PhaseRest,
    val glassSurface: Color = Color.White.copy(alpha = 0.08f),
    val glassBorder: Color = Color.White.copy(alpha = 0.12f),
)

val LightExtendedColors = ResonanceExtendedColors(
    textMuted = ResonanceColors.TextMuted,
    textSubtle = ResonanceColors.TextSubtle,
    divider = ResonanceColors.Divider,
    glassSurface = Color.White.copy(alpha = 0.7f),
    glassBorder = Color.White.copy(alpha = 0.4f),
)

val DeepRestExtendedColors = ResonanceExtendedColors(
    textMuted = ResonanceColors.DeepRestTextMuted,
    textSubtle = ResonanceColors.DeepRestTextMuted.copy(alpha = 0.6f),
    divider = ResonanceColors.DeepRestDivider,
    glassSurface = Color.White.copy(alpha = 0.05f),
    glassBorder = Color.White.copy(alpha = 0.08f),
)

val LocalResonanceExtendedColors = staticCompositionLocalOf { LightExtendedColors }

// ─────────────────────────────────────────────
// Theme Accessor
// ─────────────────────────────────────────────

object ResonanceTheme {
    val spacing: ResonanceSpacing
        @Composable get() = LocalResonanceSpacing.current

    val elevation: ResonanceElevation
        @Composable get() = LocalResonanceElevation.current

    val extendedColors: ResonanceExtendedColors
        @Composable get() = LocalResonanceExtendedColors.current
}

// ─────────────────────────────────────────────
// Theme Composable
// ─────────────────────────────────────────────

@Composable
fun ResonanceTheme(
    deepRestMode: Boolean = isSystemInDarkTheme(),
    dynamicColor: Boolean = true,
    content: @Composable () -> Unit
) {
    val context = LocalContext.current

    val colorScheme: ColorScheme = when {
        dynamicColor && Build.VERSION.SDK_INT >= Build.VERSION_CODES.S -> {
            if (deepRestMode) {
                dynamicDarkColorScheme(context).copy(
                    background = ResonanceColors.DeepRestBase,
                    surface = ResonanceColors.DeepRestSurface,
                )
            } else {
                dynamicLightColorScheme(context).copy(
                    background = ResonanceColors.Base,
                    surface = ResonanceColors.Surface,
                )
            }
        }
        deepRestMode -> ResonanceDeepRestColorScheme
        else -> ResonanceLightColorScheme
    }

    val extendedColors = if (deepRestMode) DeepRestExtendedColors else LightExtendedColors

    // Animate color transitions for Deep Rest toggle
    val animatedBackground by animateColorAsState(
        targetValue = colorScheme.background,
        animationSpec = tween(ResonanceMotion.phaseTransitionDuration),
        label = "backgroundTransition"
    )
    val animatedSurface by animateColorAsState(
        targetValue = colorScheme.surface,
        animationSpec = tween(ResonanceMotion.phaseTransitionDuration),
        label = "surfaceTransition"
    )
    val animatedPrimary by animateColorAsState(
        targetValue = colorScheme.primary,
        animationSpec = tween(ResonanceMotion.phaseTransitionDuration),
        label = "primaryTransition"
    )
    val animatedOnBackground by animateColorAsState(
        targetValue = colorScheme.onBackground,
        animationSpec = tween(ResonanceMotion.phaseTransitionDuration),
        label = "onBackgroundTransition"
    )

    val animatedColorScheme = colorScheme.copy(
        background = animatedBackground,
        surface = animatedSurface,
        primary = animatedPrimary,
        onBackground = animatedOnBackground,
    )

    val view = LocalView.current
    if (!view.isInEditMode) {
        SideEffect {
            val window = (view.context as Activity).window
            window.statusBarColor = Color.Transparent.toArgb()
            window.navigationBarColor = Color.Transparent.toArgb()
            val controller = WindowCompat.getInsetsController(window, view)
            controller.isAppearanceLightStatusBars = !deepRestMode
            controller.isAppearanceLightNavigationBars = !deepRestMode
        }
    }

    CompositionLocalProvider(
        LocalResonanceSpacing provides ResonanceSpacing(),
        LocalResonanceElevation provides ResonanceElevation(),
        LocalResonanceExtendedColors provides extendedColors,
    ) {
        MaterialTheme(
            colorScheme = animatedColorScheme,
            typography = ResonanceTypography,
            shapes = ResonanceShapes,
            content = content,
        )
    }
}
