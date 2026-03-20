// MARK: - Luminous Journey™ Android Design System
// Resonance-UX tokens mapped to Jetpack Compose Material 3

package com.luminous.journey.ui.theme

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.Font
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.sp
import com.luminous.journey.R

// ─── Color Palette (Resonance-UX unified) ────────────────────────────────

object LuminousColors {
    // Forest
    val ForestDeepest = Color(0xFF0A1C14)
    val ForestDeep = Color(0xFF122E21)
    val ForestBase = Color(0xFF1B402E)
    val ForestMuted = Color(0xFF2A5A42)
    val ForestLight = Color(0xFF3A7A5A)

    // Gold
    val GoldPrimary = Color(0xFFC5A059)
    val GoldMuted = Color(0xFF9A7A3A)
    val GoldLight = Color(0xFFD4B878)
    val GoldGlow = Color(0x26C5A059) // 15% opacity

    // Earth
    val Cream = Color(0xFFFAFAF8)
    val WarmEarth = Color(0xFFF5F0E8)
    val Sand = Color(0xFFE8DFD0)
    val Stone = Color(0xFFD4C9B8)

    // Text
    val TextPrimary = Color(0xFF1B402E)
    val TextSecondary = Color(0xFF8A9C91)
    val TextMuted = Color(0xFFA8B5AD)
    val TextOnDark = Color(0xFFFAFAF8)
    val TextGold = Color(0xFFC5A059)

    // Semantic (developmental orders)
    val OrderImpulsive = Color(0xFFE8A87C)
    val OrderImperial = Color(0xFFD4956B)
    val OrderSocialized = Color(0xFF5A8AB0)
    val OrderSelfAuthoring = Color(0xFF4A9A6A)
    val OrderSelfTransforming = Color(0xFF8B6BB0)

    // Somatic seasons
    val SeasonCompression = Color(0xFF8A5A4A)
    val SeasonTrembling = Color(0xFFB07A5A)
    val SeasonEmptiness = Color(0xFFA8B5AD)
    val SeasonEmergence = Color(0xFF4A9A6A)
    val SeasonIntegration = Color(0xFFC5A059)

    // Glass
    val GlassLight = Color(0xB8FAFAF8)    // 72%
    val GlassDark = Color(0xD90A1C14)     // 85%
    val GlassBorder = Color(0x1FC5A059)   // 12%

    // Deep Rest mode
    val DeepRestBackground = Color(0xFF050E09)
    val DeepRestSurface = Color(0xFF0A1C14)
    val DeepRestCard = Color(0x99122E21)  // 60%
    val DeepRestText = Color(0xFFC8D4CC)
}

// ─── Typography ──────────────────────────────────────────────────────────

val CormorantGaramond = FontFamily(
    Font(R.font.cormorant_garamond_light, FontWeight.Light),
    Font(R.font.cormorant_garamond_regular, FontWeight.Normal),
    Font(R.font.cormorant_garamond_medium, FontWeight.Medium),
    Font(R.font.cormorant_garamond_semibold, FontWeight.SemiBold),
)

val Manrope = FontFamily(
    Font(R.font.manrope_regular, FontWeight.Normal),
    Font(R.font.manrope_medium, FontWeight.Medium),
    Font(R.font.manrope_semibold, FontWeight.SemiBold),
    Font(R.font.manrope_bold, FontWeight.Bold),
)

val LuminousTypography = Typography(
    displayLarge = TextStyle(
        fontFamily = CormorantGaramond,
        fontWeight = FontWeight.Light,
        fontSize = 48.sp,
        lineHeight = 52.sp,
    ),
    headlineLarge = TextStyle(
        fontFamily = CormorantGaramond,
        fontWeight = FontWeight.Normal,
        fontSize = 36.sp,
        lineHeight = 43.sp,
    ),
    headlineMedium = TextStyle(
        fontFamily = CormorantGaramond,
        fontWeight = FontWeight.Normal,
        fontSize = 28.sp,
        lineHeight = 35.sp,
    ),
    headlineSmall = TextStyle(
        fontFamily = CormorantGaramond,
        fontWeight = FontWeight.Medium,
        fontSize = 22.sp,
        lineHeight = 28.sp,
    ),
    bodyLarge = TextStyle(
        fontFamily = Manrope,
        fontWeight = FontWeight.Normal,
        fontSize = 17.sp,
        lineHeight = 27.sp,
    ),
    bodyMedium = TextStyle(
        fontFamily = Manrope,
        fontWeight = FontWeight.Normal,
        fontSize = 15.sp,
        lineHeight = 22.sp,
    ),
    bodySmall = TextStyle(
        fontFamily = Manrope,
        fontWeight = FontWeight.Normal,
        fontSize = 13.sp,
        lineHeight = 18.sp,
    ),
    labelLarge = TextStyle(
        fontFamily = Manrope,
        fontWeight = FontWeight.SemiBold,
        fontSize = 13.sp,
        lineHeight = 17.sp,
        letterSpacing = 0.5.sp,
    ),
    labelSmall = TextStyle(
        fontFamily = Manrope,
        fontWeight = FontWeight.SemiBold,
        fontSize = 11.sp,
        lineHeight = 14.sp,
        letterSpacing = 0.5.sp,
    ),
)

// ─── Color Schemes ───────────────────────────────────────────────────────

private val LightColorScheme = lightColorScheme(
    primary = LuminousColors.ForestBase,
    onPrimary = LuminousColors.Cream,
    primaryContainer = LuminousColors.ForestMuted,
    secondary = LuminousColors.GoldPrimary,
    onSecondary = LuminousColors.ForestDeepest,
    tertiary = LuminousColors.OrderSelfTransforming,
    background = LuminousColors.Cream,
    onBackground = LuminousColors.TextPrimary,
    surface = Color.White,
    onSurface = LuminousColors.TextPrimary,
    surfaceVariant = LuminousColors.WarmEarth,
    onSurfaceVariant = LuminousColors.TextSecondary,
    outline = LuminousColors.GlassBorder,
)

private val DeepRestColorScheme = darkColorScheme(
    primary = LuminousColors.GoldMuted,
    onPrimary = LuminousColors.DeepRestText,
    primaryContainer = LuminousColors.ForestDeep,
    secondary = LuminousColors.GoldMuted,
    onSecondary = LuminousColors.DeepRestText,
    tertiary = LuminousColors.OrderSelfTransforming,
    background = LuminousColors.DeepRestBackground,
    onBackground = LuminousColors.DeepRestText,
    surface = LuminousColors.DeepRestSurface,
    onSurface = LuminousColors.DeepRestText,
    surfaceVariant = LuminousColors.DeepRestCard,
    onSurfaceVariant = LuminousColors.TextSecondary,
    outline = LuminousColors.GlassBorder,
)

// ─── Theme Composable ────────────────────────────────────────────────────

@Composable
fun LuminousJourneyTheme(
    deepRest: Boolean = false,
    content: @Composable () -> Unit
) {
    val colorScheme = if (deepRest) DeepRestColorScheme else LightColorScheme

    MaterialTheme(
        colorScheme = colorScheme,
        typography = LuminousTypography,
        content = content
    )
}
