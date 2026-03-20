package com.resonance.luminous.ui

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.staticCompositionLocalOf
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.Font
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

// ---------------------------------------------------------------------------
// Resonance colour palette
// ---------------------------------------------------------------------------

object Resonance {
    val green900 = Color(0xFF0A1C14)
    val green800 = Color(0xFF122E21)
    val green700 = Color(0xFF1B402E)
    val green600 = Color(0xFF2A5A42)
    val green500 = Color(0xFF3D7A5C)
    val green400 = Color(0xFF5A9E7A)
    val green300 = Color(0xFF8EC4A4)
    val green200 = Color(0xFFD1E0D7)
    val green100 = Color(0xFFE8F0EB)
    val green50  = Color(0xFFF4F8F5)

    val goldPrimary = Color(0xFFC5A059)
    val goldLight   = Color(0xFFE6D0A1)
    val goldDark    = Color(0xFF9A7A3A)
    val goldDeep    = Color(0xFF7A5F28)
    val goldMuted   = Color(0xFFD4BC83)
    val goldShimmer = Color(0xFFF0E4C8)

    val bgLight = Color(0xFFFAFAF8)
    val bgDark  = Color(0xFF05100B)

    val surfaceLight     = Color(0xFFFFFFFF)
    val surfaceDark      = Color(0xFF0D1F16)
    val surfaceVariantLt = Color(0xFFF0F2EF)
    val surfaceVariantDk = Color(0xFF152A1F)

    val error   = Color(0xFFB85C5C)
    val success = Color(0xFF5CB87A)
    val info    = Color(0xFF5C8CB8)
    val warning = Color(0xFFB8A25C)

    val textPrimaryLight   = Color(0xFF1A1A18)
    val textSecondaryLight = Color(0xFF4A4A46)
    val textPrimaryDark    = Color(0xFFF0EDE6)
    val textSecondaryDark  = Color(0xFFB0ADA6)
}

// ---------------------------------------------------------------------------
// Font families — fallback to default serif / sans-serif
// ---------------------------------------------------------------------------

val SerifFamily = FontFamily.Serif
val SansFamily  = FontFamily.SansSerif

// ---------------------------------------------------------------------------
// Typography
// ---------------------------------------------------------------------------

private val LuminousTypography = Typography(
    displayLarge = TextStyle(
        fontFamily = SerifFamily,
        fontWeight = FontWeight.Bold,
        fontSize = 57.sp,
        lineHeight = 64.sp,
        letterSpacing = (-0.25).sp,
    ),
    displayMedium = TextStyle(
        fontFamily = SerifFamily,
        fontWeight = FontWeight.Bold,
        fontSize = 45.sp,
        lineHeight = 52.sp,
    ),
    displaySmall = TextStyle(
        fontFamily = SerifFamily,
        fontWeight = FontWeight.SemiBold,
        fontSize = 36.sp,
        lineHeight = 44.sp,
    ),
    headlineLarge = TextStyle(
        fontFamily = SerifFamily,
        fontWeight = FontWeight.SemiBold,
        fontSize = 32.sp,
        lineHeight = 40.sp,
    ),
    headlineMedium = TextStyle(
        fontFamily = SerifFamily,
        fontWeight = FontWeight.SemiBold,
        fontSize = 28.sp,
        lineHeight = 36.sp,
    ),
    headlineSmall = TextStyle(
        fontFamily = SerifFamily,
        fontWeight = FontWeight.Medium,
        fontSize = 24.sp,
        lineHeight = 32.sp,
    ),
    titleLarge = TextStyle(
        fontFamily = SerifFamily,
        fontWeight = FontWeight.Medium,
        fontSize = 22.sp,
        lineHeight = 28.sp,
    ),
    titleMedium = TextStyle(
        fontFamily = SansFamily,
        fontWeight = FontWeight.SemiBold,
        fontSize = 16.sp,
        lineHeight = 24.sp,
        letterSpacing = 0.15.sp,
    ),
    titleSmall = TextStyle(
        fontFamily = SansFamily,
        fontWeight = FontWeight.Medium,
        fontSize = 14.sp,
        lineHeight = 20.sp,
        letterSpacing = 0.1.sp,
    ),
    bodyLarge = TextStyle(
        fontFamily = SansFamily,
        fontWeight = FontWeight.Normal,
        fontSize = 16.sp,
        lineHeight = 24.sp,
        letterSpacing = 0.5.sp,
    ),
    bodyMedium = TextStyle(
        fontFamily = SansFamily,
        fontWeight = FontWeight.Normal,
        fontSize = 14.sp,
        lineHeight = 20.sp,
        letterSpacing = 0.25.sp,
    ),
    bodySmall = TextStyle(
        fontFamily = SansFamily,
        fontWeight = FontWeight.Normal,
        fontSize = 12.sp,
        lineHeight = 16.sp,
        letterSpacing = 0.4.sp,
    ),
    labelLarge = TextStyle(
        fontFamily = SansFamily,
        fontWeight = FontWeight.Medium,
        fontSize = 14.sp,
        lineHeight = 20.sp,
        letterSpacing = 0.1.sp,
    ),
    labelMedium = TextStyle(
        fontFamily = SansFamily,
        fontWeight = FontWeight.Medium,
        fontSize = 12.sp,
        lineHeight = 16.sp,
        letterSpacing = 0.5.sp,
    ),
    labelSmall = TextStyle(
        fontFamily = SansFamily,
        fontWeight = FontWeight.Medium,
        fontSize = 11.sp,
        lineHeight = 16.sp,
        letterSpacing = 0.5.sp,
    ),
)

// ---------------------------------------------------------------------------
// Shapes
// ---------------------------------------------------------------------------

private val LuminousShapes = Shapes(
    extraSmall = RoundedCornerShape(4.dp),
    small      = RoundedCornerShape(8.dp),
    medium     = RoundedCornerShape(16.dp),
    large      = RoundedCornerShape(24.dp),
    extraLarge = RoundedCornerShape(32.dp),
)

// ---------------------------------------------------------------------------
// Light colour scheme
// ---------------------------------------------------------------------------

private val LightColorScheme = lightColorScheme(
    primary            = Resonance.green700,
    onPrimary          = Color.White,
    primaryContainer   = Resonance.green200,
    onPrimaryContainer = Resonance.green900,

    secondary            = Resonance.goldPrimary,
    onSecondary          = Color.White,
    secondaryContainer   = Resonance.goldLight,
    onSecondaryContainer = Resonance.goldDeep,

    tertiary            = Resonance.goldDark,
    onTertiary          = Color.White,
    tertiaryContainer   = Resonance.goldShimmer,
    onTertiaryContainer = Resonance.goldDeep,

    background   = Resonance.bgLight,
    onBackground = Resonance.textPrimaryLight,

    surface          = Resonance.surfaceLight,
    onSurface        = Resonance.textPrimaryLight,
    surfaceVariant   = Resonance.surfaceVariantLt,
    onSurfaceVariant = Resonance.textSecondaryLight,

    error   = Resonance.error,
    onError = Color.White,

    outline        = Resonance.green200,
    outlineVariant = Resonance.green100,
)

// ---------------------------------------------------------------------------
// Dark colour scheme
// ---------------------------------------------------------------------------

private val DarkColorScheme = darkColorScheme(
    primary            = Resonance.goldPrimary,
    onPrimary          = Resonance.green900,
    primaryContainer   = Resonance.green800,
    onPrimaryContainer = Resonance.goldLight,

    secondary            = Resonance.goldLight,
    onSecondary          = Resonance.green900,
    secondaryContainer   = Resonance.green700,
    onSecondaryContainer = Resonance.goldLight,

    tertiary            = Resonance.goldMuted,
    onTertiary          = Resonance.green900,
    tertiaryContainer   = Resonance.green800,
    onTertiaryContainer = Resonance.goldShimmer,

    background   = Resonance.bgDark,
    onBackground = Resonance.textPrimaryDark,

    surface          = Resonance.surfaceDark,
    onSurface        = Resonance.textPrimaryDark,
    surfaceVariant   = Resonance.surfaceVariantDk,
    onSurfaceVariant = Resonance.textSecondaryDark,

    error   = Resonance.error,
    onError = Color.White,

    outline        = Resonance.green700,
    outlineVariant = Resonance.green800,
)

// ---------------------------------------------------------------------------
// Extended colours — accessible via LocalResonanceColors
// ---------------------------------------------------------------------------

data class ResonanceExtendedColors(
    val goldPrimary: Color,
    val goldLight: Color,
    val goldDark: Color,
    val goldShimmer: Color,
    val glassSurface: Color,
    val glassBorder: Color,
    val blobPrimary: Color,
    val blobSecondary: Color,
    val blobTertiary: Color,
    val success: Color,
    val info: Color,
    val warning: Color,
)

val LocalResonanceColors = staticCompositionLocalOf {
    ResonanceExtendedColors(
        goldPrimary   = Resonance.goldPrimary,
        goldLight     = Resonance.goldLight,
        goldDark      = Resonance.goldDark,
        goldShimmer   = Resonance.goldShimmer,
        glassSurface  = Color.White.copy(alpha = .12f),
        glassBorder   = Color.White.copy(alpha = .18f),
        blobPrimary   = Resonance.green400.copy(alpha = .25f),
        blobSecondary = Resonance.goldPrimary.copy(alpha = .15f),
        blobTertiary  = Resonance.green300.copy(alpha = .20f),
        success       = Resonance.success,
        info          = Resonance.info,
        warning       = Resonance.warning,
    )
}

// ---------------------------------------------------------------------------
// Theme composable
// ---------------------------------------------------------------------------

@Composable
fun LuminousTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    content: @Composable () -> Unit,
) {
    val colorScheme = if (darkTheme) DarkColorScheme else LightColorScheme

    val extendedColors = if (darkTheme) {
        ResonanceExtendedColors(
            goldPrimary   = Resonance.goldPrimary,
            goldLight     = Resonance.goldLight,
            goldDark      = Resonance.goldDark,
            goldShimmer   = Resonance.goldShimmer,
            glassSurface  = Color.White.copy(alpha = .06f),
            glassBorder   = Color.White.copy(alpha = .10f),
            blobPrimary   = Resonance.green600.copy(alpha = .30f),
            blobSecondary = Resonance.goldDark.copy(alpha = .20f),
            blobTertiary  = Resonance.green500.copy(alpha = .18f),
            success       = Resonance.success,
            info          = Resonance.info,
            warning       = Resonance.warning,
        )
    } else {
        ResonanceExtendedColors(
            goldPrimary   = Resonance.goldPrimary,
            goldLight     = Resonance.goldLight,
            goldDark      = Resonance.goldDark,
            goldShimmer   = Resonance.goldShimmer,
            glassSurface  = Color.White.copy(alpha = .65f),
            glassBorder   = Color.White.copy(alpha = .40f),
            blobPrimary   = Resonance.green300.copy(alpha = .25f),
            blobSecondary = Resonance.goldLight.copy(alpha = .20f),
            blobTertiary  = Resonance.green200.copy(alpha = .30f),
            success       = Resonance.success,
            info          = Resonance.info,
            warning       = Resonance.warning,
        )
    }

    CompositionLocalProvider(LocalResonanceColors provides extendedColors) {
        MaterialTheme(
            colorScheme = colorScheme,
            typography  = LuminousTypography,
            shapes      = LuminousShapes,
            content     = content,
        )
    }
}

// Convenience accessor
object LuminousThemeExt {
    val colors: ResonanceExtendedColors
        @Composable get() = LocalResonanceColors.current
}
