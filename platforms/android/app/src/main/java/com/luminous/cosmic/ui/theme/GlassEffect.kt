package com.luminous.cosmic.ui.theme

import androidx.compose.animation.core.*
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.composed
import androidx.compose.ui.draw.BlurredEdgeTreatment
import androidx.compose.ui.draw.blur
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.*
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp

// ─────────────────────────────────────────────
// Glass Surface Composable
// ─────────────────────────────────────────────

@Composable
fun GlassSurface(
    modifier: Modifier = Modifier,
    cornerRadius: Dp = 20.dp,
    blurRadius: Dp = 16.dp,
    glassAlpha: Float = 0.12f,
    borderAlpha: Float = 0.18f,
    content: @Composable BoxScope.() -> Unit
) {
    val shape = RoundedCornerShape(cornerRadius)
    val extColors = ResonanceThemeAccess.extendedColors
    val surfaceColor = MaterialTheme.colorScheme.surface

    Box(
        modifier = modifier
            .clip(shape)
            .background(
                brush = Brush.verticalGradient(
                    colors = listOf(
                        Color.White.copy(alpha = glassAlpha),
                        Color.White.copy(alpha = glassAlpha * 0.4f)
                    )
                ),
                shape = shape
            )
            .border(
                width = 1.dp,
                brush = Brush.linearGradient(
                    colors = listOf(
                        Color.White.copy(alpha = borderAlpha),
                        Color.White.copy(alpha = borderAlpha * 0.3f)
                    ),
                    start = Offset.Zero,
                    end = Offset(0f, Float.POSITIVE_INFINITY)
                ),
                shape = shape
            ),
        content = content
    )
}

@Composable
fun GlassCard(
    modifier: Modifier = Modifier,
    cornerRadius: Dp = 20.dp,
    content: @Composable BoxScope.() -> Unit
) {
    val isDark = MaterialTheme.colorScheme.background == ResonanceColors.NightDarkest

    GlassSurface(
        modifier = modifier,
        cornerRadius = cornerRadius,
        glassAlpha = if (isDark) 0.06f else 0.14f,
        borderAlpha = if (isDark) 0.12f else 0.22f,
        content = content
    )
}

// ─────────────────────────────────────────────
// Gold Glow Modifier
// ─────────────────────────────────────────────

fun Modifier.goldGlow(
    glowRadius: Dp = 16.dp,
    glowAlpha: Float = 0.15f,
    cornerRadius: Dp = 20.dp
): Modifier = this.drawBehind {
    val glowColor = ResonanceColors.GoldPrimary.copy(alpha = glowAlpha)
    drawRoundRect(
        color = glowColor,
        cornerRadius = CornerRadius(cornerRadius.toPx()),
        size = size.copy(
            width = size.width + glowRadius.toPx() * 2,
            height = size.height + glowRadius.toPx() * 2
        ),
        topLeft = Offset(-glowRadius.toPx(), -glowRadius.toPx())
    )
}

// ─────────────────────────────────────────────
// Warm Shadow Modifier
// ─────────────────────────────────────────────

fun Modifier.warmShadow(
    elevation: Dp = 8.dp,
    cornerRadius: Dp = 20.dp
): Modifier = this.drawBehind {
    val shadowColor = ResonanceColors.GoldDark.copy(alpha = 0.12f)
    drawRoundRect(
        color = shadowColor,
        topLeft = Offset(0f, elevation.toPx() * 0.5f),
        size = size,
        cornerRadius = CornerRadius(cornerRadius.toPx())
    )
}

// ─────────────────────────────────────────────
// Shimmer Effect
// ─────────────────────────────────────────────

fun Modifier.goldShimmer(): Modifier = composed {
    val transition = rememberInfiniteTransition(label = "shimmer")
    val shimmerProgress by transition.animateFloat(
        initialValue = 0f,
        targetValue = 1f,
        animationSpec = infiniteRepeatable(
            animation = tween(3000, easing = LinearEasing),
            repeatMode = RepeatMode.Restart
        ),
        label = "shimmerOffset"
    )

    drawBehind {
        val shimmerWidth = size.width * 0.4f
        val start = -shimmerWidth + (size.width + shimmerWidth * 2) * shimmerProgress

        drawRect(
            brush = Brush.horizontalGradient(
                colors = listOf(
                    Color.Transparent,
                    ResonanceColors.GoldLight.copy(alpha = 0.15f),
                    Color.Transparent
                ),
                startX = start,
                endX = start + shimmerWidth
            ),
            size = size
        )
    }
}

// ─────────────────────────────────────────────
// Gradient Definitions
// ─────────────────────────────────────────────

object ResonanceGradients {
    val forestGradient = Brush.verticalGradient(
        colors = listOf(
            ResonanceColors.ForestDarkest,
            ResonanceColors.ForestDark,
            ResonanceColors.ForestMedium
        )
    )

    val nightGradient = Brush.verticalGradient(
        colors = listOf(
            ResonanceColors.NightDarkest,
            ResonanceColors.NightDark,
            ResonanceColors.NightSurface
        )
    )

    val goldGradient = Brush.horizontalGradient(
        colors = listOf(
            ResonanceColors.GoldDark,
            ResonanceColors.GoldPrimary,
            ResonanceColors.GoldLight,
            ResonanceColors.GoldPrimary,
            ResonanceColors.GoldDark
        )
    )

    val creamGradient = Brush.verticalGradient(
        colors = listOf(
            ResonanceColors.CreamBase,
            ResonanceColors.CreamWarm,
            ResonanceColors.CreamSoft
        )
    )

    fun cosmicRadial(center: Offset = Offset.Unspecified) = Brush.radialGradient(
        colors = listOf(
            ResonanceColors.ForestMedium.copy(alpha = 0.3f),
            ResonanceColors.ForestDark.copy(alpha = 0.6f),
            ResonanceColors.ForestDarkest
        ),
        center = center,
        radius = 800f
    )
}
