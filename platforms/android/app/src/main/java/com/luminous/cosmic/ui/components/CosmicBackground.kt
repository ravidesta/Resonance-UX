package com.luminous.cosmic.ui.components

import androidx.compose.animation.core.*
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxScope
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.*
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.platform.LocalDensity
import kotlin.math.*
import kotlin.random.Random

import com.luminous.cosmic.ui.theme.ResonanceColors

// ─────────────────────────────────────────────
// Cosmic Animated Background
// ─────────────────────────────────────────────

private data class CosmicBlob(
    val baseX: Float,
    val baseY: Float,
    val radius: Float,
    val color: Color,
    val speedMultiplier: Float,
    val phaseOffset: Float
)

private data class StarParticle(
    val x: Float,
    val y: Float,
    val size: Float,
    val alpha: Float,
    val twinkleSpeed: Float,
    val twinkleOffset: Float
)

@Composable
fun CosmicBackground(
    modifier: Modifier = Modifier,
    isDarkTheme: Boolean = true,
    showStars: Boolean = true,
    showBlobs: Boolean = true,
    blobCount: Int = 5,
    starCount: Int = 80,
    content: @Composable BoxScope.() -> Unit
) {
    val infiniteTransition = rememberInfiniteTransition(label = "cosmic_bg")

    val time by infiniteTransition.animateFloat(
        initialValue = 0f,
        targetValue = 2f * PI.toFloat(),
        animationSpec = infiniteRepeatable(
            animation = tween(durationMillis = 20000, easing = LinearEasing),
            repeatMode = RepeatMode.Restart
        ),
        label = "cosmic_time"
    )

    val twinkleTime by infiniteTransition.animateFloat(
        initialValue = 0f,
        targetValue = 2f * PI.toFloat(),
        animationSpec = infiniteRepeatable(
            animation = tween(durationMillis = 4000, easing = LinearEasing),
            repeatMode = RepeatMode.Restart
        ),
        label = "twinkle_time"
    )

    val blobs = remember {
        val rng = Random(42)
        val blobColors = if (isDarkTheme) listOf(
            ResonanceColors.ForestMedium.copy(alpha = 0.25f),
            ResonanceColors.ForestLight.copy(alpha = 0.15f),
            ResonanceColors.GoldDark.copy(alpha = 0.08f),
            ResonanceColors.ForestDark.copy(alpha = 0.2f),
            ResonanceColors.GoldPrimary.copy(alpha = 0.05f)
        ) else listOf(
            ResonanceColors.ForestMedium.copy(alpha = 0.08f),
            ResonanceColors.ForestLight.copy(alpha = 0.06f),
            ResonanceColors.GoldLight.copy(alpha = 0.1f),
            ResonanceColors.CreamDark.copy(alpha = 0.15f),
            ResonanceColors.GoldPrimary.copy(alpha = 0.04f)
        )
        List(blobCount) { i ->
            CosmicBlob(
                baseX = rng.nextFloat(),
                baseY = rng.nextFloat(),
                radius = 0.15f + rng.nextFloat() * 0.25f,
                color = blobColors[i % blobColors.size],
                speedMultiplier = 0.5f + rng.nextFloat() * 1.0f,
                phaseOffset = rng.nextFloat() * 2f * PI.toFloat()
            )
        }
    }

    val stars = remember {
        val rng = Random(137)
        List(starCount) {
            StarParticle(
                x = rng.nextFloat(),
                y = rng.nextFloat(),
                size = 0.5f + rng.nextFloat() * 2f,
                alpha = 0.2f + rng.nextFloat() * 0.6f,
                twinkleSpeed = 0.5f + rng.nextFloat() * 2f,
                twinkleOffset = rng.nextFloat() * 2f * PI.toFloat()
            )
        }
    }

    val bgColor = if (isDarkTheme) ResonanceColors.NightDarkest else ResonanceColors.CreamBase

    Box(modifier = modifier.fillMaxSize()) {
        Canvas(modifier = Modifier.fillMaxSize()) {
            // Base background
            drawRect(color = bgColor)

            // Animated blobs
            if (showBlobs) {
                blobs.forEach { blob ->
                    val dx = sin(time * blob.speedMultiplier + blob.phaseOffset) * size.width * 0.08f
                    val dy = cos(time * blob.speedMultiplier * 0.7f + blob.phaseOffset) * size.height * 0.06f

                    val center = Offset(
                        x = blob.baseX * size.width + dx,
                        y = blob.baseY * size.height + dy
                    )
                    val radius = blob.radius * minOf(size.width, size.height)

                    drawCircle(
                        brush = Brush.radialGradient(
                            colors = listOf(
                                blob.color,
                                blob.color.copy(alpha = blob.color.alpha * 0.3f),
                                Color.Transparent
                            ),
                            center = center,
                            radius = radius
                        ),
                        radius = radius,
                        center = center
                    )
                }
            }

            // Stars
            if (showStars && isDarkTheme) {
                stars.forEach { star ->
                    val twinkle = (sin(twinkleTime * star.twinkleSpeed + star.twinkleOffset) + 1f) / 2f
                    val currentAlpha = star.alpha * (0.3f + 0.7f * twinkle)

                    drawCircle(
                        color = ResonanceColors.CreamBase.copy(alpha = currentAlpha),
                        radius = star.size,
                        center = Offset(star.x * size.width, star.y * size.height)
                    )
                }
            }

            // Subtle vignette
            drawRect(
                brush = Brush.radialGradient(
                    colors = listOf(
                        Color.Transparent,
                        bgColor.copy(alpha = 0.5f)
                    ),
                    center = Offset(size.width / 2f, size.height / 2f),
                    radius = maxOf(size.width, size.height) * 0.7f
                )
            )
        }

        content()
    }
}

// ─────────────────────────────────────────────
// Floating Orb (Standalone)
// ─────────────────────────────────────────────

@Composable
fun FloatingOrb(
    modifier: Modifier = Modifier,
    color: Color = ResonanceColors.GoldPrimary.copy(alpha = 0.15f),
    radius: Float = 100f
) {
    val infiniteTransition = rememberInfiniteTransition(label = "orb")
    val offsetY by infiniteTransition.animateFloat(
        initialValue = -10f,
        targetValue = 10f,
        animationSpec = infiniteRepeatable(
            animation = tween(3000, easing = FastOutSlowInEasing),
            repeatMode = RepeatMode.Reverse
        ),
        label = "orb_float"
    )
    val scale by infiniteTransition.animateFloat(
        initialValue = 0.95f,
        targetValue = 1.05f,
        animationSpec = infiniteRepeatable(
            animation = tween(4000, easing = FastOutSlowInEasing),
            repeatMode = RepeatMode.Reverse
        ),
        label = "orb_scale"
    )

    Canvas(modifier = modifier) {
        val center = Offset(size.width / 2f, size.height / 2f + offsetY)
        val r = radius * scale
        drawCircle(
            brush = Brush.radialGradient(
                colors = listOf(color, color.copy(alpha = 0f)),
                center = center,
                radius = r
            ),
            radius = r,
            center = center
        )
    }
}
