package com.luminous.cosmic.ui.components

import androidx.compose.animation.core.*
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.*
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Rect
import androidx.compose.ui.graphics.*
import androidx.compose.ui.graphics.drawscope.*
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import kotlin.math.*

import com.luminous.cosmic.data.models.MoonPhase
import com.luminous.cosmic.ui.theme.ResonanceColors

@Composable
fun MoonPhaseIndicator(
    phase: MoonPhase,
    illumination: Float,
    modifier: Modifier = Modifier,
    size: Dp = 80.dp,
    showLabel: Boolean = true
) {
    val infiniteTransition = rememberInfiniteTransition(label = "moon_glow")
    val glowAlpha by infiniteTransition.animateFloat(
        initialValue = 0.15f,
        targetValue = 0.35f,
        animationSpec = infiniteRepeatable(
            animation = tween(3000, easing = FastOutSlowInEasing),
            repeatMode = RepeatMode.Reverse
        ),
        label = "moon_glow_alpha"
    )

    Column(
        modifier = modifier,
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Canvas(
            modifier = Modifier.size(size)
        ) {
            val cx = this.size.width / 2f
            val cy = this.size.height / 2f
            val radius = minOf(cx, cy) * 0.85f

            // Outer glow
            drawCircle(
                brush = Brush.radialGradient(
                    colors = listOf(
                        ResonanceColors.GoldLight.copy(alpha = glowAlpha * illumination),
                        ResonanceColors.GoldPrimary.copy(alpha = glowAlpha * 0.3f * illumination),
                        Color.Transparent
                    ),
                    center = Offset(cx, cy),
                    radius = radius * 1.6f
                ),
                radius = radius * 1.6f,
                center = Offset(cx, cy)
            )

            // Moon base (dark side)
            drawCircle(
                color = ResonanceColors.ForestDarkest.copy(alpha = 0.9f),
                radius = radius,
                center = Offset(cx, cy)
            )

            // Subtle surface texture via gradient
            drawCircle(
                brush = Brush.radialGradient(
                    colors = listOf(
                        Color.Transparent,
                        ResonanceColors.ForestDark.copy(alpha = 0.3f),
                        ResonanceColors.ForestDarkest.copy(alpha = 0.5f)
                    ),
                    center = Offset(cx - radius * 0.2f, cy - radius * 0.2f),
                    radius = radius
                ),
                radius = radius,
                center = Offset(cx, cy)
            )

            // Illuminated portion
            val path = Path()
            val illuminatedFraction = illumination

            // Determine which side is lit based on phase
            val isWaxing = phase.ordinal < 4

            // Build moon phase path using arcs
            path.addArc(
                oval = Rect(cx - radius, cy - radius, cx + radius, cy + radius),
                startAngleDegrees = -90f,
                sweepAngleDegrees = 180f
            )

            // Create the terminator curve
            val terminatorOffset = (illuminatedFraction * 2f - 1f) * radius
            val controlX = if (isWaxing) {
                cx - terminatorOffset
            } else {
                cx + terminatorOffset
            }

            if (isWaxing) {
                // Lit from right side
                path.cubicTo(
                    controlX, cy - radius,
                    controlX, cy + radius,
                    cx, cy + radius
                )
            } else {
                // Lit from left side
                path.cubicTo(
                    controlX, cy + radius,
                    controlX, cy - radius,
                    cx, cy - radius
                )
            }

            path.close()

            // Draw illuminated area
            val moonColor = if (illuminatedFraction > 0.05f) {
                Brush.radialGradient(
                    colors = listOf(
                        ResonanceColors.CreamBase.copy(alpha = 0.95f),
                        ResonanceColors.CreamWarm.copy(alpha = 0.85f),
                        ResonanceColors.GoldLight.copy(alpha = 0.6f)
                    ),
                    center = Offset(cx, cy),
                    radius = radius
                )
            } else {
                Brush.radialGradient(
                    colors = listOf(Color.Transparent, Color.Transparent),
                    center = Offset(cx, cy),
                    radius = radius
                )
            }

            clipPath(
                path = Path().apply {
                    addOval(Rect(cx - radius, cy - radius, cx + radius, cy + radius))
                }
            ) {
                drawPath(path = path, brush = moonColor)
            }

            // Rim highlight
            drawCircle(
                brush = Brush.sweepGradient(
                    colors = listOf(
                        ResonanceColors.GoldLight.copy(alpha = 0.3f),
                        Color.Transparent,
                        ResonanceColors.GoldLight.copy(alpha = 0.15f),
                        Color.Transparent
                    ),
                    center = Offset(cx, cy)
                ),
                radius = radius,
                center = Offset(cx, cy),
                style = Stroke(width = 1.5f)
            )
        }

        if (showLabel) {
            Spacer(modifier = Modifier.height(8.dp))
            Text(
                text = phase.displayName,
                style = MaterialTheme.typography.labelMedium,
                color = ResonanceColors.GoldPrimary
            )
            Text(
                text = "${(illumination * 100).toInt()}% illuminated",
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
    }
}
