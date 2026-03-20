package com.luminous.cosmic.ui.theme

import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.Font
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

// ─────────────────────────────────────────────
// Resonance Color Palette
// ─────────────────────────────────────────────

object ResonanceColors {
    // Deep Forest Greens
    val ForestDarkest = Color(0xFF0A1C14)
    val ForestDark = Color(0xFF122E21)
    val ForestMedium = Color(0xFF1B402E)
    val ForestLight = Color(0xFF2A5A42)
    val ForestMist = Color(0xFF3D7A5C)

    // Gold Accents
    val GoldPrimary = Color(0xFFC5A059)
    val GoldLight = Color(0xFFE6D0A1)
    val GoldDark = Color(0xFF9A7A3A)
    val GoldShimmer = Color(0xFFD4B876)
    val GoldMuted = Color(0xFFB8975A)

    // Cream / Light Base
    val CreamBase = Color(0xFFFAFAF8)
    val CreamWarm = Color(0xFFF5F4EE)
    val CreamSoft = Color(0xFFEFEDE5)
    val CreamDark = Color(0xFFE5E3DA)

    // Muted Green Text
    val TextMutedGreen = Color(0xFF5C7065)
    val TextSage = Color(0xFF8A9C91)
    val TextForest = Color(0xFF3A5245)

    // Night Mode
    val NightDarkest = Color(0xFF05100B)
    val NightDark = Color(0xFF0A1C14)
    val NightSurface = Color(0xFF0F261A)
    val NightSurfaceElevated = Color(0xFF143020)
    val NightOverlay = Color(0xFF1A3828)

    // Functional
    val Error = Color(0xFFCF6679)
    val ErrorDark = Color(0xFFB3445B)
    val Success = Color(0xFF4CAF50)

    // Zodiac Element Colors
    val FireElement = Color(0xFFC75B39)
    val EarthElement = Color(0xFF7A8B5A)
    val AirElement = Color(0xFF7AACB5)
    val WaterElement = Color(0xFF5A7AB8)

    // Aspect Colors
    val AspectHarmonious = Color(0xFF6BAF7A)
    val AspectChallenging = Color(0xFFCF7A6A)
    val AspectNeutral = Color(0xFFC5A059)

    // Glass Effects
    val GlassLight = Color(0x26FFFFFF)
    val GlassMedium = Color(0x40FFFFFF)
    val GlassDark = Color(0x1AFFFFFF)
    val GlassStroke = Color(0x33FFFFFF)
    val GlassNightLight = Color(0x1AFFFFFF)
    val GlassNightStroke = Color(0x26C5A059)
}

// ─────────────────────────────────────────────
// Color Scheme Definition
// ─────────────────────────────────────────────

private val LightColorScheme = lightColorScheme(
    primary = ResonanceColors.GoldPrimary,
    onPrimary = ResonanceColors.ForestDarkest,
    primaryContainer = ResonanceColors.GoldLight,
    onPrimaryContainer = ResonanceColors.ForestDark,
    secondary = ResonanceColors.ForestMedium,
    onSecondary = ResonanceColors.CreamBase,
    secondaryContainer = ResonanceColors.ForestLight,
    onSecondaryContainer = ResonanceColors.CreamWarm,
    tertiary = ResonanceColors.TextMutedGreen,
    onTertiary = ResonanceColors.CreamBase,
    tertiaryContainer = ResonanceColors.TextSage,
    onTertiaryContainer = ResonanceColors.ForestDarkest,
    background = ResonanceColors.CreamBase,
    onBackground = ResonanceColors.ForestDarkest,
    surface = ResonanceColors.CreamWarm,
    onSurface = ResonanceColors.ForestDarkest,
    surfaceVariant = ResonanceColors.CreamSoft,
    onSurfaceVariant = ResonanceColors.TextMutedGreen,
    error = ResonanceColors.Error,
    onError = Color.White,
    outline = ResonanceColors.CreamDark,
    outlineVariant = ResonanceColors.TextSage,
)

private val DarkColorScheme = darkColorScheme(
    primary = ResonanceColors.GoldPrimary,
    onPrimary = ResonanceColors.NightDarkest,
    primaryContainer = ResonanceColors.GoldDark,
    onPrimaryContainer = ResonanceColors.GoldLight,
    secondary = ResonanceColors.ForestMedium,
    onSecondary = ResonanceColors.CreamBase,
    secondaryContainer = ResonanceColors.NightSurfaceElevated,
    onSecondaryContainer = ResonanceColors.GoldLight,
    tertiary = ResonanceColors.TextSage,
    onTertiary = ResonanceColors.NightDarkest,
    tertiaryContainer = ResonanceColors.ForestDark,
    onTertiaryContainer = ResonanceColors.GoldLight,
    background = ResonanceColors.NightDarkest,
    onBackground = ResonanceColors.CreamWarm,
    surface = ResonanceColors.NightDark,
    onSurface = ResonanceColors.CreamWarm,
    surfaceVariant = ResonanceColors.NightSurface,
    onSurfaceVariant = ResonanceColors.TextSage,
    error = ResonanceColors.Error,
    onError = ResonanceColors.NightDarkest,
    outline = ResonanceColors.NightOverlay,
    outlineVariant = ResonanceColors.ForestDark,
)

// ─────────────────────────────────────────────
// Typography
// ─────────────────────────────────────────────

// Using system serif/sans-serif families; replace with custom fonts via res/font
val SerifFamily = FontFamily.Serif
val SansSerifFamily = FontFamily.SansSerif

val ResonanceTypography = Typography(
    // Display
    displayLarge = TextStyle(
        fontFamily = SerifFamily,
        fontWeight = FontWeight.Light,
        fontSize = 57.sp,
        lineHeight = 64.sp,
        letterSpacing = (-0.25).sp
    ),
    displayMedium = TextStyle(
        fontFamily = SerifFamily,
        fontWeight = FontWeight.Light,
        fontSize = 45.sp,
        lineHeight = 52.sp,
        letterSpacing = 0.sp
    ),
    displaySmall = TextStyle(
        fontFamily = SerifFamily,
        fontWeight = FontWeight.Normal,
        fontSize = 36.sp,
        lineHeight = 44.sp,
        letterSpacing = 0.sp
    ),
    // Headlines
    headlineLarge = TextStyle(
        fontFamily = SerifFamily,
        fontWeight = FontWeight.Normal,
        fontSize = 32.sp,
        lineHeight = 40.sp,
        letterSpacing = 0.sp
    ),
    headlineMedium = TextStyle(
        fontFamily = SerifFamily,
        fontWeight = FontWeight.Normal,
        fontSize = 28.sp,
        lineHeight = 36.sp,
        letterSpacing = 0.sp
    ),
    headlineSmall = TextStyle(
        fontFamily = SerifFamily,
        fontWeight = FontWeight.Normal,
        fontSize = 24.sp,
        lineHeight = 32.sp,
        letterSpacing = 0.sp
    ),
    // Titles
    titleLarge = TextStyle(
        fontFamily = SerifFamily,
        fontWeight = FontWeight.Medium,
        fontSize = 22.sp,
        lineHeight = 28.sp,
        letterSpacing = 0.sp
    ),
    titleMedium = TextStyle(
        fontFamily = SansSerifFamily,
        fontWeight = FontWeight.Medium,
        fontSize = 16.sp,
        lineHeight = 24.sp,
        letterSpacing = 0.15.sp
    ),
    titleSmall = TextStyle(
        fontFamily = SansSerifFamily,
        fontWeight = FontWeight.Medium,
        fontSize = 14.sp,
        lineHeight = 20.sp,
        letterSpacing = 0.1.sp
    ),
    // Body
    bodyLarge = TextStyle(
        fontFamily = SansSerifFamily,
        fontWeight = FontWeight.Normal,
        fontSize = 16.sp,
        lineHeight = 24.sp,
        letterSpacing = 0.5.sp
    ),
    bodyMedium = TextStyle(
        fontFamily = SansSerifFamily,
        fontWeight = FontWeight.Normal,
        fontSize = 14.sp,
        lineHeight = 20.sp,
        letterSpacing = 0.25.sp
    ),
    bodySmall = TextStyle(
        fontFamily = SansSerifFamily,
        fontWeight = FontWeight.Normal,
        fontSize = 12.sp,
        lineHeight = 16.sp,
        letterSpacing = 0.4.sp
    ),
    // Labels
    labelLarge = TextStyle(
        fontFamily = SansSerifFamily,
        fontWeight = FontWeight.Medium,
        fontSize = 14.sp,
        lineHeight = 20.sp,
        letterSpacing = 0.1.sp
    ),
    labelMedium = TextStyle(
        fontFamily = SansSerifFamily,
        fontWeight = FontWeight.Medium,
        fontSize = 12.sp,
        lineHeight = 16.sp,
        letterSpacing = 0.5.sp
    ),
    labelSmall = TextStyle(
        fontFamily = SansSerifFamily,
        fontWeight = FontWeight.Medium,
        fontSize = 11.sp,
        lineHeight = 16.sp,
        letterSpacing = 0.5.sp
    )
)

// ─────────────────────────────────────────────
// Shapes
// ─────────────────────────────────────────────

val ResonanceShapes = Shapes(
    extraSmall = androidx.compose.foundation.shape.RoundedCornerShape(4.dp),
    small = androidx.compose.foundation.shape.RoundedCornerShape(8.dp),
    medium = androidx.compose.foundation.shape.RoundedCornerShape(16.dp),
    large = androidx.compose.foundation.shape.RoundedCornerShape(24.dp),
    extraLarge = androidx.compose.foundation.shape.RoundedCornerShape(32.dp),
)

// ─────────────────────────────────────────────
// Extended Color Access
// ─────────────────────────────────────────────

data class ResonanceExtendedColors(
    val goldShimmer: Color,
    val goldMuted: Color,
    val forestMist: Color,
    val fireElement: Color,
    val earthElement: Color,
    val airElement: Color,
    val waterElement: Color,
    val aspectHarmonious: Color,
    val aspectChallenging: Color,
    val aspectNeutral: Color,
    val glassBackground: Color,
    val glassStroke: Color,
    val warmShadow: Color
)

val LocalResonanceColors = staticCompositionLocalOf {
    ResonanceExtendedColors(
        goldShimmer = ResonanceColors.GoldShimmer,
        goldMuted = ResonanceColors.GoldMuted,
        forestMist = ResonanceColors.ForestMist,
        fireElement = ResonanceColors.FireElement,
        earthElement = ResonanceColors.EarthElement,
        airElement = ResonanceColors.AirElement,
        waterElement = ResonanceColors.WaterElement,
        aspectHarmonious = ResonanceColors.AspectHarmonious,
        aspectChallenging = ResonanceColors.AspectChallenging,
        aspectNeutral = ResonanceColors.AspectNeutral,
        glassBackground = ResonanceColors.GlassLight,
        glassStroke = ResonanceColors.GlassStroke,
        warmShadow = Color(0x33C5A059)
    )
}

// ─────────────────────────────────────────────
// Theme Composable
// ─────────────────────────────────────────────

@Composable
fun ResonanceTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    content: @Composable () -> Unit
) {
    val colorScheme = if (darkTheme) DarkColorScheme else LightColorScheme

    val extendedColors = if (darkTheme) {
        ResonanceExtendedColors(
            goldShimmer = ResonanceColors.GoldShimmer,
            goldMuted = ResonanceColors.GoldMuted,
            forestMist = ResonanceColors.ForestMist,
            fireElement = ResonanceColors.FireElement,
            earthElement = ResonanceColors.EarthElement,
            airElement = ResonanceColors.AirElement,
            waterElement = ResonanceColors.WaterElement,
            aspectHarmonious = ResonanceColors.AspectHarmonious,
            aspectChallenging = ResonanceColors.AspectChallenging,
            aspectNeutral = ResonanceColors.AspectNeutral,
            glassBackground = ResonanceColors.GlassNightLight,
            glassStroke = ResonanceColors.GlassNightStroke,
            warmShadow = Color(0x1AC5A059)
        )
    } else {
        ResonanceExtendedColors(
            goldShimmer = ResonanceColors.GoldShimmer,
            goldMuted = ResonanceColors.GoldMuted,
            forestMist = ResonanceColors.ForestMist,
            fireElement = ResonanceColors.FireElement,
            earthElement = ResonanceColors.EarthElement,
            airElement = ResonanceColors.AirElement,
            waterElement = ResonanceColors.WaterElement,
            aspectHarmonious = ResonanceColors.AspectHarmonious,
            aspectChallenging = ResonanceColors.AspectChallenging,
            aspectNeutral = ResonanceColors.AspectNeutral,
            glassBackground = ResonanceColors.GlassLight,
            glassStroke = ResonanceColors.GlassStroke,
            warmShadow = Color(0x33C5A059)
        )
    }

    CompositionLocalProvider(
        LocalResonanceColors provides extendedColors
    ) {
        MaterialTheme(
            colorScheme = colorScheme,
            typography = ResonanceTypography,
            shapes = ResonanceShapes,
            content = content
        )
    }
}

// Convenience accessor
object ResonanceThemeAccess {
    val extendedColors: ResonanceExtendedColors
        @Composable
        get() = LocalResonanceColors.current
}
