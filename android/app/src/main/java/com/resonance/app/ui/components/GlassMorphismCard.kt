package com.resonance.app.ui.components

import android.os.Build
import androidx.compose.animation.core.FastOutSlowInEasing
import androidx.compose.animation.core.InfiniteTransition
import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.BlendMode
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.drawscope.rotate
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.resonance.app.data.models.EnergyLevel
import com.resonance.app.data.models.IntentionalStatus
import com.resonance.app.ui.theme.ResonanceColors
import com.resonance.app.ui.theme.ResonanceTheme
import kotlin.math.PI
import kotlin.math.cos
import kotlin.math.sin

// ─────────────────────────────────────────────
// GlassMorphismCard
// ─────────────────────────────────────────────

@Composable
fun GlassMorphismCard(
    modifier: Modifier = Modifier,
    cornerRadius: Dp = 20.dp,
    blurRadius: Dp = 16.dp,
    borderWidth: Dp = 1.dp,
    content: @Composable () -> Unit,
) {
    val extendedColors = ResonanceTheme.extendedColors
    val shape = RoundedCornerShape(cornerRadius)

    val glassModifier = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
        modifier
            .graphicsLayer {
                val blurPx = blurRadius.toPx()
                renderEffect = android.graphics.RenderEffect
                    .createBlurEffect(blurPx, blurPx, android.graphics.Shader.TileMode.CLAMP)
                    .let { android.graphics.RenderEffect.createBlurEffect(blurPx, blurPx, android.graphics.Shader.TileMode.CLAMP) }
            }
            .clip(shape)
            .background(extendedColors.glassSurface)
            .border(borderWidth, extendedColors.glassBorder, shape)
    } else {
        modifier
            .clip(shape)
            .background(extendedColors.glassSurface)
            .border(borderWidth, extendedColors.glassBorder, shape)
    }

    Box(modifier = glassModifier) {
        // Subtle gradient overlay for depth
        Box(
            modifier = Modifier
                .matchParentSize()
                .background(
                    Brush.verticalGradient(
                        colors = listOf(
                            Color.White.copy(alpha = 0.08f),
                            Color.Transparent,
                            Color.Black.copy(alpha = 0.02f),
                        )
                    )
                )
        )
        content()
    }
}

// ─────────────────────────────────────────────
// IntentionalStatusBadge
// ─────────────────────────────────────────────

@Composable
fun IntentionalStatusBadge(
    status: IntentionalStatus,
    modifier: Modifier = Modifier,
    showPulse: Boolean = true,
) {
    val infiniteTransition = rememberInfiniteTransition(label = "statusPulse")

    val pulseAlpha by infiniteTransition.animateFloat(
        initialValue = 0.3f,
        targetValue = 0.8f,
        animationSpec = infiniteRepeatable(
            animation = tween(2000, easing = FastOutSlowInEasing),
            repeatMode = RepeatMode.Reverse,
        ),
        label = "pulseAlpha"
    )

    val pulseScale by infiniteTransition.animateFloat(
        initialValue = 1f,
        targetValue = 1.4f,
        animationSpec = infiniteRepeatable(
            animation = tween(2000, easing = FastOutSlowInEasing),
            repeatMode = RepeatMode.Reverse,
        ),
        label = "pulseScale"
    )

    val dotColor = when (status) {
        is IntentionalStatus.OpenToConnect, is IntentionalStatus.Available ->
            ResonanceColors.Success
        is IntentionalStatus.DeepWork, is IntentionalStatus.InFlow ->
            ResonanceColors.Gold
        is IntentionalStatus.Recharging, is IntentionalStatus.Reflecting ->
            ResonanceColors.TextMuted
        is IntentionalStatus.Custom ->
            if (status.interruptible) ResonanceColors.Success else ResonanceColors.TextMuted
    }

    Row(
        modifier = modifier,
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(8.dp),
    ) {
        Box(contentAlignment = Alignment.Center) {
            // Pulse ring
            if (showPulse && status.allowsInterruption) {
                Box(
                    modifier = Modifier
                        .size(12.dp)
                        .graphicsLayer {
                            scaleX = pulseScale
                            scaleY = pulseScale
                            alpha = 1f - pulseAlpha
                        }
                        .background(dotColor.copy(alpha = 0.3f), CircleShape)
                )
            }

            // Status dot
            Box(
                modifier = Modifier
                    .size(8.dp)
                    .background(dotColor, CircleShape)
            )
        }

        Text(
            text = status.displayText,
            style = MaterialTheme.typography.labelSmall,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
        )
    }
}

// ─────────────────────────────────────────────
// EnergyLevelIndicator
// ─────────────────────────────────────────────

@Composable
fun EnergyLevelIndicator(
    level: EnergyLevel,
    modifier: Modifier = Modifier,
    barCount: Int = 4,
    barWidth: Dp = 4.dp,
    barSpacing: Dp = 3.dp,
    maxBarHeight: Dp = 20.dp,
    animated: Boolean = true,
) {
    val targetValue = level.value

    Row(
        modifier = modifier,
        horizontalArrangement = Arrangement.spacedBy(barSpacing),
        verticalAlignment = Alignment.Bottom,
    ) {
        for (i in 0 until barCount) {
            val isActive = i < targetValue
            val barFraction = (i + 1).toFloat() / barCount.toFloat()

            val animatedHeight by animateFloatAsState(
                targetValue = if (isActive) barFraction else 0.25f,
                animationSpec = tween(
                    durationMillis = if (animated) 400 else 0,
                    delayMillis = if (animated) i * 80 else 0,
                ),
                label = "barHeight$i"
            )

            val barColor = when {
                !isActive -> MaterialTheme.colorScheme.outline.copy(alpha = 0.3f)
                i == 0 -> ResonanceColors.EnergyDepleted
                i == 1 -> ResonanceColors.EnergyLow
                i == 2 -> ResonanceColors.EnergyModerate
                else -> ResonanceColors.EnergyPeak
            }

            Box(
                modifier = Modifier
                    .width(barWidth)
                    .height(maxBarHeight * animatedHeight)
                    .clip(RoundedCornerShape(barWidth / 2))
                    .background(barColor)
            )
        }
    }
}

// ─────────────────────────────────────────────
// WaveformVisualizer
// ─────────────────────────────────────────────

@Composable
fun WaveformVisualizer(
    waveformData: List<Float>,
    progress: Float = 0f,
    modifier: Modifier = Modifier,
    activeColor: Color = ResonanceColors.Gold,
    inactiveColor: Color = ResonanceColors.TextMuted.copy(alpha = 0.3f),
    barWidth: Float = 3f,
    barSpacing: Float = 2f,
    cornerRadius: Float = 1.5f,
) {
    Canvas(modifier = modifier) {
        if (waveformData.isEmpty()) return@Canvas

        val totalBars = waveformData.size
        val availableWidth = size.width
        val effectiveBarWidth = (availableWidth - (totalBars - 1) * barSpacing) / totalBars
        val actualBarWidth = effectiveBarWidth.coerceAtMost(barWidth)
        val centerY = size.height / 2f

        waveformData.forEachIndexed { index, amplitude ->
            val x = index * (actualBarWidth + barSpacing)
            val barHeight = (amplitude.coerceIn(0.05f, 1f) * size.height * 0.8f)
            val halfHeight = barHeight / 2f

            val normalizedIndex = index.toFloat() / totalBars
            val color = if (normalizedIndex <= progress) activeColor else inactiveColor

            drawRoundRect(
                color = color,
                topLeft = Offset(x, centerY - halfHeight),
                size = Size(actualBarWidth, barHeight),
                cornerRadius = CornerRadius(cornerRadius, cornerRadius),
            )
        }
    }
}

// ─────────────────────────────────────────────
// OrganicBlob (Breathe Animation)
// ─────────────────────────────────────────────

@Composable
fun OrganicBlob(
    modifier: Modifier = Modifier,
    baseColor: Color = ResonanceColors.Gold,
    blobCount: Int = 3,
    breathDurationMs: Int = 6000,
) {
    val infiniteTransition = rememberInfiniteTransition(label = "blobBreathe")

    val breathePhase by infiniteTransition.animateFloat(
        initialValue = 0f,
        targetValue = 1f,
        animationSpec = infiniteRepeatable(
            animation = tween(breathDurationMs, easing = FastOutSlowInEasing),
            repeatMode = RepeatMode.Reverse,
        ),
        label = "breathePhase"
    )

    val rotationAngle by infiniteTransition.animateFloat(
        initialValue = 0f,
        targetValue = 360f,
        animationSpec = infiniteRepeatable(
            animation = tween(breathDurationMs * 5, easing = LinearEasing),
            repeatMode = RepeatMode.Restart,
        ),
        label = "blobRotation"
    )

    Canvas(modifier = modifier) {
        val centerX = size.width / 2f
        val centerY = size.height / 2f
        val baseRadius = size.minDimension / 3f

        for (blobIndex in 0 until blobCount) {
            val phaseOffset = blobIndex * (2f * PI.toFloat() / blobCount)
            val blobAlpha = 0.15f - (blobIndex * 0.03f)
            val blobScale = 1f + breathePhase * 0.2f + (blobIndex * 0.08f)

            val path = Path()
            val points = 8
            val angleStep = (2f * PI / points).toFloat()

            for (i in 0..points) {
                val angle = i * angleStep + phaseOffset + (rotationAngle * PI.toFloat() / 180f)
                val radiusVariation = sin(angle * 2 + breathePhase * PI.toFloat() * 2) * 0.15f
                val radius = baseRadius * blobScale * (1f + radiusVariation)

                val x = centerX + cos(angle) * radius
                val y = centerY + sin(angle) * radius

                if (i == 0) path.moveTo(x, y) else path.lineTo(x, y)
            }
            path.close()

            drawPath(
                path = path,
                brush = Brush.radialGradient(
                    colors = listOf(
                        baseColor.copy(alpha = blobAlpha),
                        baseColor.copy(alpha = blobAlpha * 0.3f),
                        Color.Transparent,
                    ),
                    center = Offset(centerX, centerY),
                    radius = baseRadius * blobScale * 1.2f,
                ),
            )
        }
    }
}

// ─────────────────────────────────────────────
// SpaciousnessGauge
// ─────────────────────────────────────────────

@Composable
fun SpaciousnessGauge(
    value: Float, // 0.0 to 1.0
    modifier: Modifier = Modifier,
    size: Dp = 120.dp,
    strokeWidth: Dp = 8.dp,
    label: String = "Spaciousness",
    showLabel: Boolean = true,
) {
    val animatedValue by animateFloatAsState(
        targetValue = value.coerceIn(0f, 1f),
        animationSpec = tween(1000, easing = FastOutSlowInEasing),
        label = "gaugeValue"
    )

    val gaugeColor = when {
        value < 0.3f -> ResonanceColors.EnergyDepleted
        value < 0.5f -> ResonanceColors.EnergyLow
        value < 0.7f -> ResonanceColors.EnergyModerate
        else -> ResonanceColors.EnergyPeak
    }

    Column(
        modifier = modifier,
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        Box(
            modifier = Modifier.size(size),
            contentAlignment = Alignment.Center,
        ) {
            Canvas(modifier = Modifier.fillMaxSize()) {
                val sweepAngle = 270f
                val startAngle = 135f
                val strokePx = strokeWidth.toPx()
                val arcSize = Size(
                    this.size.width - strokePx,
                    this.size.height - strokePx
                )
                val topLeft = Offset(strokePx / 2, strokePx / 2)

                // Background track
                drawArc(
                    color = gaugeColor.copy(alpha = 0.12f),
                    startAngle = startAngle,
                    sweepAngle = sweepAngle,
                    useCenter = false,
                    topLeft = topLeft,
                    size = arcSize,
                    style = Stroke(strokePx, cap = StrokeCap.Round),
                )

                // Active arc
                drawArc(
                    brush = Brush.sweepGradient(
                        colors = listOf(
                            gaugeColor.copy(alpha = 0.6f),
                            gaugeColor,
                            gaugeColor.copy(alpha = 0.8f),
                        ),
                    ),
                    startAngle = startAngle,
                    sweepAngle = sweepAngle * animatedValue,
                    useCenter = false,
                    topLeft = topLeft,
                    size = arcSize,
                    style = Stroke(strokePx, cap = StrokeCap.Round),
                )

                // End dot
                val endAngleRad = Math.toRadians(
                    (startAngle + sweepAngle * animatedValue).toDouble()
                )
                val dotRadius = strokePx * 0.7f
                val dotCenter = Offset(
                    (this.size.width / 2 + (arcSize.width / 2) * cos(endAngleRad)).toFloat(),
                    (this.size.height / 2 + (arcSize.height / 2) * sin(endAngleRad)).toFloat(),
                )
                drawCircle(
                    color = gaugeColor,
                    radius = dotRadius,
                    center = dotCenter,
                )
            }

            // Center text
            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                Text(
                    text = "${(animatedValue * 100).toInt()}%",
                    style = MaterialTheme.typography.headlineSmall,
                    fontWeight = FontWeight.SemiBold,
                    color = MaterialTheme.colorScheme.onBackground,
                )
            }
        }

        if (showLabel) {
            Spacer(modifier = Modifier.height(8.dp))
            Text(
                text = label,
                style = MaterialTheme.typography.labelMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
            )
        }
    }
}

// ─────────────────────────────────────────────
// PhaseIndicator
// ─────────────────────────────────────────────

@Composable
fun PhaseIndicator(
    phases: List<String>,
    activePhaseIndex: Int,
    modifier: Modifier = Modifier,
) {
    val phaseColors = listOf(
        ResonanceColors.PhaseAscend,
        ResonanceColors.PhaseZenith,
        ResonanceColors.PhaseDescent,
        ResonanceColors.PhaseRest,
    )

    Row(
        modifier = modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.spacedBy(4.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        phases.forEachIndexed { index, phase ->
            val isActive = index == activePhaseIndex
            val isPast = index < activePhaseIndex

            val widthFraction by animateFloatAsState(
                targetValue = if (isActive) 2f else 1f,
                animationSpec = tween(400),
                label = "phaseWidth$index"
            )

            val color = phaseColors.getOrElse(index) { ResonanceColors.TextMuted }

            Column(
                modifier = Modifier.weight(widthFraction),
                horizontalAlignment = Alignment.CenterHorizontally,
            ) {
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(4.dp)
                        .clip(RoundedCornerShape(2.dp))
                        .background(
                            when {
                                isActive -> color
                                isPast -> color.copy(alpha = 0.4f)
                                else -> color.copy(alpha = 0.12f)
                            }
                        )
                )

                if (isActive) {
                    Spacer(modifier = Modifier.height(4.dp))
                    Text(
                        text = phase,
                        style = MaterialTheme.typography.labelSmall.copy(fontSize = 9.sp),
                        color = color,
                    )
                }
            }
        }
    }
}

// ─────────────────────────────────────────────
// BiomarkerChart (mini sparkline)
// ─────────────────────────────────────────────

@Composable
fun BiomarkerSparkline(
    dataPoints: List<Float>,
    modifier: Modifier = Modifier,
    lineColor: Color = ResonanceColors.Gold,
    fillColor: Color = ResonanceColors.Gold.copy(alpha = 0.1f),
    normalRangeLow: Float? = null,
    normalRangeHigh: Float? = null,
) {
    Canvas(modifier = modifier) {
        if (dataPoints.size < 2) return@Canvas

        val minVal = dataPoints.min()
        val maxVal = dataPoints.max()
        val range = (maxVal - minVal).coerceAtLeast(0.01f)

        val stepX = size.width / (dataPoints.size - 1)

        // Normal range band
        if (normalRangeLow != null && normalRangeHigh != null) {
            val lowY = size.height * (1f - (normalRangeLow - minVal) / range)
            val highY = size.height * (1f - (normalRangeHigh - minVal) / range)
            drawRect(
                color = ResonanceColors.Success.copy(alpha = 0.08f),
                topLeft = Offset(0f, highY.coerceAtLeast(0f)),
                size = Size(size.width, (lowY - highY).coerceAtLeast(0f)),
            )
        }

        // Line path
        val linePath = Path()
        val fillPath = Path()

        dataPoints.forEachIndexed { index, value ->
            val x = index * stepX
            val y = size.height * (1f - (value - minVal) / range)

            if (index == 0) {
                linePath.moveTo(x, y)
                fillPath.moveTo(x, size.height)
                fillPath.lineTo(x, y)
            } else {
                linePath.lineTo(x, y)
                fillPath.lineTo(x, y)
            }
        }

        fillPath.lineTo(size.width, size.height)
        fillPath.close()

        drawPath(path = fillPath, color = fillColor)
        drawPath(
            path = linePath,
            color = lineColor,
            style = Stroke(width = 2f, cap = StrokeCap.Round),
        )

        // End dot
        val lastX = (dataPoints.size - 1) * stepX
        val lastY = size.height * (1f - (dataPoints.last() - minVal) / range)
        drawCircle(color = lineColor, radius = 4f, center = Offset(lastX, lastY))
    }
}

// ─────────────────────────────────────────────
// BreathCircle (for breathwork exercises)
// ─────────────────────────────────────────────

@Composable
fun BreathCircle(
    phase: BreathPhase,
    progress: Float,
    modifier: Modifier = Modifier,
    primaryColor: Color = ResonanceColors.Gold,
) {
    val infiniteTransition = rememberInfiniteTransition(label = "breathGlow")
    val glowAlpha by infiniteTransition.animateFloat(
        initialValue = 0.2f,
        targetValue = 0.5f,
        animationSpec = infiniteRepeatable(
            animation = tween(2000),
            repeatMode = RepeatMode.Reverse,
        ),
        label = "glowAlpha"
    )

    val circleScale by animateFloatAsState(
        targetValue = when (phase) {
            BreathPhase.INHALE -> 1f
            BreathPhase.HOLD_IN -> 1f
            BreathPhase.EXHALE -> 0.6f
            BreathPhase.HOLD_OUT -> 0.6f
        },
        animationSpec = tween(
            durationMillis = when (phase) {
                BreathPhase.INHALE -> 4000
                BreathPhase.HOLD_IN -> 100
                BreathPhase.EXHALE -> 6000
                BreathPhase.HOLD_OUT -> 100
            }
        ),
        label = "circleScale"
    )

    Box(modifier = modifier, contentAlignment = Alignment.Center) {
        Canvas(modifier = Modifier.fillMaxSize()) {
            val center = Offset(size.width / 2, size.height / 2)
            val maxRadius = size.minDimension / 2 * 0.85f
            val currentRadius = maxRadius * circleScale

            // Outer glow
            drawCircle(
                brush = Brush.radialGradient(
                    colors = listOf(
                        primaryColor.copy(alpha = glowAlpha * 0.3f),
                        Color.Transparent,
                    ),
                    center = center,
                    radius = currentRadius * 1.5f,
                ),
            )

            // Main circle
            drawCircle(
                brush = Brush.radialGradient(
                    colors = listOf(
                        primaryColor.copy(alpha = 0.3f),
                        primaryColor.copy(alpha = 0.1f),
                    ),
                    center = center,
                    radius = currentRadius,
                ),
            )

            // Border
            drawCircle(
                color = primaryColor.copy(alpha = 0.5f),
                radius = currentRadius,
                center = center,
                style = Stroke(width = 2f),
            )
        }

        Column(horizontalAlignment = Alignment.CenterHorizontally) {
            Text(
                text = phase.displayName,
                style = MaterialTheme.typography.titleMedium,
                color = primaryColor,
            )
            Text(
                text = "${(progress * 100).toInt()}%",
                style = MaterialTheme.typography.bodySmall,
                color = primaryColor.copy(alpha = 0.7f),
            )
        }
    }
}

enum class BreathPhase(val displayName: String) {
    INHALE("Breathe In"),
    HOLD_IN("Hold"),
    EXHALE("Breathe Out"),
    HOLD_OUT("Rest"),
}
