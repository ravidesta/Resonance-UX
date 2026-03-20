package com.resonance.wear

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.animation.core.FastOutSlowInEasing
import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.focusable
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
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableFloatStateOf
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.focus.FocusRequester
import androidx.compose.ui.focus.focusRequester
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.drawscope.rotate
import androidx.compose.ui.input.rotary.onRotaryScrollEvent
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.wear.compose.foundation.lazy.ScalingLazyColumn
import androidx.wear.compose.foundation.lazy.rememberScalingLazyListState
import androidx.wear.compose.material.Button
import androidx.wear.compose.material.ButtonDefaults
import androidx.wear.compose.material.Card
import androidx.wear.compose.material.Chip
import androidx.wear.compose.material.ChipDefaults
import androidx.wear.compose.material.MaterialTheme
import androidx.wear.compose.material.Scaffold
import androidx.wear.compose.material.Text
import androidx.wear.compose.material.TimeText
import androidx.wear.compose.material.Vignette
import androidx.wear.compose.material.VignettePosition
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import java.time.LocalTime
import kotlin.math.PI
import kotlin.math.cos
import kotlin.math.sin

// ─────────────────────────────────────────────
// Colors (Resonance Wear Palette)
// ─────────────────────────────────────────────

private object WearColors {
    val DeepRestBase = Color(0xFF05100B)
    val DeepRestSurface = Color(0xFF0A1C14)
    val Gold = Color(0xFFC5A059)
    val GoldDim = Color(0xFF8A7040)
    val Green700 = Color(0xFF1A4032)
    val Green500 = Color(0xFF3D7A5F)
    val TextPrimary = Color(0xFFFAFAF8)
    val TextMuted = Color(0xFFA0B5A8)
    val Error = Color(0xFFFF8A80)
    val Success = Color(0xFF6BBF8A)
    val HeartRate = Color(0xFFFF6B6B)
}

// ─────────────────────────────────────────────
// Activity
// ─────────────────────────────────────────────

class ResonanceWearActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            ResonanceWearApp()
        }
    }
}

// ─────────────────────────────────────────────
// Main Wear App
// ─────────────────────────────────────────────

@Composable
fun ResonanceWearApp() {
    val listState = rememberScalingLazyListState()
    val focusRequester = remember { FocusRequester() }
    val coroutineScope = rememberCoroutineScope()

    var isAmbientMode by remember { mutableStateOf(false) }

    MaterialTheme {
        Scaffold(
            timeText = { TimeText() },
            vignette = { Vignette(vignettePosition = VignettePosition.TopAndBottom) },
        ) {
            ScalingLazyColumn(
                state = listState,
                modifier = Modifier
                    .fillMaxSize()
                    .background(WearColors.DeepRestBase)
                    .onRotaryScrollEvent { event ->
                        coroutineScope.launch {
                            listState.scrollBy(event.verticalScrollPixels)
                        }
                        true
                    }
                    .focusRequester(focusRequester)
                    .focusable(),
            ) {
                // Current Frequency Display
                item {
                    FrequencyComplication(
                        modifier = Modifier.fillMaxWidth(),
                    )
                }

                // Vital Signs Glanceable
                item {
                    VitalSignsGlanceable(
                        heartRate = 72,
                        hrv = 42f,
                        sleepQuality = 0.78f,
                        modifier = Modifier.fillMaxWidth(),
                    )
                }

                // Daily Phase Navigator
                item {
                    DailyPhaseChip(
                        modifier = Modifier.fillMaxWidth(),
                    )
                }

                // RSD Lightning Protocol
                item {
                    RsdLightningChip(
                        modifier = Modifier.fillMaxWidth(),
                    )
                }

                // Breathwork Tile
                item {
                    BreathworkTile(
                        modifier = Modifier.fillMaxWidth(),
                    )
                }

                // Spaciousness Metric
                item {
                    SpaciousnessComplication(
                        value = 0.72f,
                        modifier = Modifier.fillMaxWidth(),
                    )
                }
            }

            LaunchedEffect(Unit) {
                focusRequester.requestFocus()
            }
        }
    }
}

// ─────────────────────────────────────────────
// Frequency Complication (Watch Face)
// ─────────────────────────────────────────────

@Composable
private fun FrequencyComplication(modifier: Modifier = Modifier) {
    val currentPhase = remember {
        val hour = LocalTime.now().hour
        when (hour) {
            in 5..10 -> "Ascend"
            in 11..14 -> "Zenith"
            in 15..19 -> "Descent"
            else -> "Rest"
        }
    }

    val phaseColor = when (currentPhase) {
        "Ascend" -> WearColors.Gold
        "Zenith" -> WearColors.Green500
        "Descent" -> WearColors.GoldDim
        else -> WearColors.Green700
    }

    val infiniteTransition = rememberInfiniteTransition(label = "freqPulse")
    val pulseAlpha by infiniteTransition.animateFloat(
        initialValue = 0.5f,
        targetValue = 1f,
        animationSpec = infiniteRepeatable(
            animation = tween(3000, easing = FastOutSlowInEasing),
            repeatMode = RepeatMode.Reverse,
        ),
        label = "pulseAlpha"
    )

    Card(
        onClick = { },
        modifier = modifier,
        backgroundPainter = CardDefaults.cardBackgroundPainter(
            startBackgroundColor = WearColors.DeepRestSurface,
            endBackgroundColor = WearColors.DeepRestBase,
        ),
    ) {
        Column(
            modifier = Modifier.padding(12.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            // Phase ring
            Box(
                modifier = Modifier.size(48.dp),
                contentAlignment = Alignment.Center,
            ) {
                Canvas(modifier = Modifier.fillMaxSize()) {
                    // Background ring
                    drawArc(
                        color = phaseColor.copy(alpha = 0.2f),
                        startAngle = 0f,
                        sweepAngle = 360f,
                        useCenter = false,
                        style = Stroke(width = 4f, cap = StrokeCap.Round),
                    )

                    // Active ring segment
                    val progress = when (currentPhase) {
                        "Ascend" -> 0.6f
                        "Zenith" -> 0.4f
                        "Descent" -> 0.3f
                        else -> 0.8f
                    }
                    drawArc(
                        color = phaseColor.copy(alpha = pulseAlpha),
                        startAngle = -90f,
                        sweepAngle = 360f * progress,
                        useCenter = false,
                        style = Stroke(width = 4f, cap = StrokeCap.Round),
                    )
                }

                Text(
                    text = currentPhase.first().toString(),
                    fontSize = 18.sp,
                    fontWeight = FontWeight.Bold,
                    color = phaseColor,
                )
            }

            Spacer(modifier = Modifier.height(4.dp))

            Text(
                text = currentPhase,
                fontSize = 14.sp,
                fontWeight = FontWeight.Medium,
                color = WearColors.TextPrimary,
            )

            Text(
                text = "phase",
                fontSize = 10.sp,
                color = WearColors.TextMuted,
            )
        }
    }
}

// ─────────────────────────────────────────────
// Vital Signs Glanceable
// ─────────────────────────────────────────────

@Composable
private fun VitalSignsGlanceable(
    heartRate: Int,
    hrv: Float,
    sleepQuality: Float,
    modifier: Modifier = Modifier,
) {
    val infiniteTransition = rememberInfiniteTransition(label = "heartbeat")
    val heartScale by infiniteTransition.animateFloat(
        initialValue = 1f,
        targetValue = 1.15f,
        animationSpec = infiniteRepeatable(
            animation = tween(600),
            repeatMode = RepeatMode.Reverse,
        ),
        label = "heartScale"
    )

    Card(
        onClick = { },
        modifier = modifier,
        backgroundPainter = CardDefaults.cardBackgroundPainter(
            startBackgroundColor = WearColors.DeepRestSurface,
            endBackgroundColor = WearColors.DeepRestBase,
        ),
    ) {
        Column(modifier = Modifier.padding(12.dp)) {
            Text(
                text = "Vitals",
                fontSize = 10.sp,
                color = WearColors.TextMuted,
            )
            Spacer(modifier = Modifier.height(6.dp))

            // Heart Rate
            Row(verticalAlignment = Alignment.CenterVertically) {
                Canvas(modifier = Modifier.size(16.dp)) {
                    // Simple heart icon
                    val scale = heartScale
                    val cx = size.width / 2
                    val cy = size.height / 2
                    drawCircle(
                        color = WearColors.HeartRate,
                        radius = 4f * scale,
                        center = Offset(cx - 3f, cy - 2f),
                    )
                    drawCircle(
                        color = WearColors.HeartRate,
                        radius = 4f * scale,
                        center = Offset(cx + 3f, cy - 2f),
                    )
                }
                Spacer(modifier = Modifier.width(8.dp))
                Text(
                    text = "$heartRate",
                    fontSize = 20.sp,
                    fontWeight = FontWeight.Bold,
                    color = WearColors.HeartRate,
                )
                Text(
                    text = " bpm",
                    fontSize = 10.sp,
                    color = WearColors.TextMuted,
                )
            }

            Spacer(modifier = Modifier.height(6.dp))

            // HRV
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
            ) {
                Column {
                    Text(text = "HRV", fontSize = 9.sp, color = WearColors.TextMuted)
                    Text(
                        text = "${hrv.toInt()}ms",
                        fontSize = 14.sp,
                        fontWeight = FontWeight.Medium,
                        color = WearColors.TextPrimary,
                    )
                }
                Column(horizontalAlignment = Alignment.End) {
                    Text(text = "Sleep", fontSize = 9.sp, color = WearColors.TextMuted)
                    Text(
                        text = "${(sleepQuality * 100).toInt()}%",
                        fontSize = 14.sp,
                        fontWeight = FontWeight.Medium,
                        color = WearColors.Success,
                    )
                }
            }
        }
    }
}

// ─────────────────────────────────────────────
// Daily Phase Chip (Rotary scrollable)
// ─────────────────────────────────────────────

@Composable
private fun DailyPhaseChip(modifier: Modifier = Modifier) {
    val phases = remember { listOf("Ascend", "Zenith", "Descent", "Rest") }
    val currentIndex = remember {
        val hour = LocalTime.now().hour
        when (hour) {
            in 5..10 -> 0
            in 11..14 -> 1
            in 15..19 -> 2
            else -> 3
        }
    }
    var selectedPhaseIndex by remember { mutableIntStateOf(currentIndex) }

    val phaseColors = listOf(WearColors.Gold, WearColors.Green500, WearColors.GoldDim, WearColors.Green700)

    Chip(
        onClick = {
            selectedPhaseIndex = (selectedPhaseIndex + 1) % phases.size
        },
        modifier = modifier,
        label = {
            Text(
                text = phases[selectedPhaseIndex],
                fontSize = 14.sp,
                fontWeight = FontWeight.Medium,
            )
        },
        secondaryLabel = {
            val timeRange = when (selectedPhaseIndex) {
                0 -> "6:00 AM - 11:00 AM"
                1 -> "11:00 AM - 3:00 PM"
                2 -> "3:00 PM - 8:00 PM"
                else -> "8:00 PM - 6:00 AM"
            }
            Text(text = timeRange, fontSize = 10.sp)
        },
        icon = {
            Box(
                modifier = Modifier
                    .size(24.dp)
                    .clip(CircleShape)
                    .background(phaseColors[selectedPhaseIndex]),
                contentAlignment = Alignment.Center,
            ) {
                Text(
                    text = phases[selectedPhaseIndex].first().toString(),
                    fontSize = 12.sp,
                    fontWeight = FontWeight.Bold,
                    color = WearColors.DeepRestBase,
                )
            }
        },
        colors = ChipDefaults.chipColors(
            backgroundColor = WearColors.DeepRestSurface,
            contentColor = WearColors.TextPrimary,
        ),
    )
}

// ─────────────────────────────────────────────
// RSD Lightning Protocol (1-Tap Crisis)
// ─────────────────────────────────────────────

@Composable
private fun RsdLightningChip(modifier: Modifier = Modifier) {
    var isActive by remember { mutableStateOf(false) }
    var currentStep by remember { mutableIntStateOf(0) }
    var stepProgress by remember { mutableFloatStateOf(0f) }

    val steps = remember {
        listOf(
            "Ground" to 15,
            "Breathe" to 60,
            "Label" to 20,
            "Reframe" to 20,
            "Act" to 15,
        )
    }

    val progressAnimation by animateFloatAsState(
        targetValue = stepProgress,
        animationSpec = tween(500),
        label = "rsdProgress"
    )

    LaunchedEffect(isActive) {
        if (isActive) {
            for (stepIdx in steps.indices) {
                currentStep = stepIdx
                val duration = steps[stepIdx].second
                val stepMillis = duration * 1000L
                val updateIntervalMs = 100L
                val totalUpdates = stepMillis / updateIntervalMs

                for (tick in 0..totalUpdates) {
                    stepProgress = tick.toFloat() / totalUpdates
                    delay(updateIntervalMs)
                }
            }
            isActive = false
            currentStep = 0
            stepProgress = 0f
        }
    }

    if (isActive) {
        Card(
            onClick = { isActive = false },
            modifier = modifier,
            backgroundPainter = CardDefaults.cardBackgroundPainter(
                startBackgroundColor = WearColors.Gold.copy(alpha = 0.15f),
                endBackgroundColor = WearColors.DeepRestBase,
            ),
        ) {
            Column(
                modifier = Modifier.padding(12.dp),
                horizontalAlignment = Alignment.CenterHorizontally,
            ) {
                Text(
                    text = steps[currentStep].first,
                    fontSize = 16.sp,
                    fontWeight = FontWeight.Bold,
                    color = WearColors.Gold,
                )

                Spacer(modifier = Modifier.height(8.dp))

                // Circular progress
                Box(
                    modifier = Modifier.size(40.dp),
                    contentAlignment = Alignment.Center,
                ) {
                    Canvas(modifier = Modifier.fillMaxSize()) {
                        drawArc(
                            color = WearColors.Gold.copy(alpha = 0.2f),
                            startAngle = -90f,
                            sweepAngle = 360f,
                            useCenter = false,
                            style = Stroke(width = 4f, cap = StrokeCap.Round),
                        )
                        drawArc(
                            color = WearColors.Gold,
                            startAngle = -90f,
                            sweepAngle = 360f * progressAnimation,
                            useCenter = false,
                            style = Stroke(width = 4f, cap = StrokeCap.Round),
                        )
                    }

                    val remaining = ((1f - stepProgress) * steps[currentStep].second).toInt()
                    Text(
                        text = "${remaining}s",
                        fontSize = 11.sp,
                        color = WearColors.TextPrimary,
                    )
                }

                Spacer(modifier = Modifier.height(4.dp))

                // Step indicators
                Row(horizontalArrangement = Arrangement.spacedBy(4.dp)) {
                    steps.forEachIndexed { index, _ ->
                        Box(
                            modifier = Modifier
                                .size(6.dp)
                                .clip(CircleShape)
                                .background(
                                    when {
                                        index < currentStep -> WearColors.Gold
                                        index == currentStep -> WearColors.Gold.copy(alpha = 0.6f)
                                        else -> WearColors.Green700
                                    }
                                )
                        )
                    }
                }

                Text(
                    text = "Step ${currentStep + 1} of ${steps.size}",
                    fontSize = 9.sp,
                    color = WearColors.TextMuted,
                )
            }
        }
    } else {
        Button(
            onClick = { isActive = true },
            modifier = modifier.height(48.dp),
            colors = ButtonDefaults.buttonColors(
                backgroundColor = WearColors.Error.copy(alpha = 0.2f),
                contentColor = WearColors.Error,
            ),
        ) {
            Text(
                text = "\u26A1 RSD Protocol",
                fontSize = 12.sp,
                fontWeight = FontWeight.SemiBold,
            )
        }
    }
}

// ─────────────────────────────────────────────
// Breathwork Tile with Haptic Sync
// ─────────────────────────────────────────────

@Composable
private fun BreathworkTile(modifier: Modifier = Modifier) {
    var isBreathing by remember { mutableStateOf(false) }
    var breathPhase by remember { mutableStateOf("Inhale") }
    var breathProgress by remember { mutableFloatStateOf(0f) }

    val infiniteTransition = rememberInfiniteTransition(label = "breathGlow")
    val glowAlpha by infiniteTransition.animateFloat(
        initialValue = 0.2f,
        targetValue = 0.6f,
        animationSpec = infiniteRepeatable(
            animation = tween(4000, easing = FastOutSlowInEasing),
            repeatMode = RepeatMode.Reverse,
        ),
        label = "glowAlpha"
    )

    val circleScale by animateFloatAsState(
        targetValue = when (breathPhase) {
            "Inhale" -> 1f
            "Hold" -> 1f
            "Exhale" -> 0.5f
            else -> 0.5f
        },
        animationSpec = tween(
            durationMillis = when (breathPhase) {
                "Inhale" -> 4000
                "Exhale" -> 6000
                else -> 300
            }
        ),
        label = "breathScale"
    )

    LaunchedEffect(isBreathing) {
        if (isBreathing) {
            while (isBreathing) {
                breathPhase = "Inhale"
                for (i in 0..40) { breathProgress = i / 40f; delay(100) }
                breathPhase = "Hold"
                for (i in 0..40) { breathProgress = i / 40f; delay(100) }
                breathPhase = "Exhale"
                for (i in 0..60) { breathProgress = i / 60f; delay(100) }
                breathPhase = "Rest"
                for (i in 0..20) { breathProgress = i / 20f; delay(100) }
            }
        }
    }

    Card(
        onClick = { isBreathing = !isBreathing },
        modifier = modifier,
        backgroundPainter = CardDefaults.cardBackgroundPainter(
            startBackgroundColor = WearColors.DeepRestSurface,
            endBackgroundColor = WearColors.DeepRestBase,
        ),
    ) {
        Column(
            modifier = Modifier.padding(12.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            if (isBreathing) {
                // Breathing circle
                Box(
                    modifier = Modifier.size(60.dp),
                    contentAlignment = Alignment.Center,
                ) {
                    Canvas(modifier = Modifier.fillMaxSize()) {
                        val center = Offset(size.width / 2, size.height / 2)
                        val maxRadius = size.minDimension / 2 * 0.9f
                        val currentRadius = maxRadius * circleScale

                        // Glow
                        drawCircle(
                            brush = Brush.radialGradient(
                                colors = listOf(
                                    WearColors.Gold.copy(alpha = glowAlpha * 0.3f),
                                    Color.Transparent,
                                ),
                                center = center,
                                radius = currentRadius * 1.3f,
                            ),
                        )

                        // Main circle
                        drawCircle(
                            color = WearColors.Gold.copy(alpha = 0.2f),
                            radius = currentRadius,
                            center = center,
                        )
                        drawCircle(
                            color = WearColors.Gold.copy(alpha = 0.5f),
                            radius = currentRadius,
                            center = center,
                            style = Stroke(width = 2f),
                        )
                    }

                    Text(
                        text = breathPhase,
                        fontSize = 10.sp,
                        fontWeight = FontWeight.Medium,
                        color = WearColors.Gold,
                        textAlign = TextAlign.Center,
                    )
                }

                Text(
                    text = "Tap to stop",
                    fontSize = 9.sp,
                    color = WearColors.TextMuted,
                )
            } else {
                Text(
                    text = "Breathwork",
                    fontSize = 14.sp,
                    fontWeight = FontWeight.Medium,
                    color = WearColors.TextPrimary,
                )
                Spacer(modifier = Modifier.height(4.dp))
                Text(
                    text = "4-4-6-2 pattern",
                    fontSize = 10.sp,
                    color = WearColors.TextMuted,
                )
                Text(
                    text = "Tap to begin",
                    fontSize = 9.sp,
                    color = WearColors.Gold.copy(alpha = 0.7f),
                )
            }
        }
    }
}

// ─────────────────────────────────────────────
// Spaciousness Complication
// ─────────────────────────────────────────────

@Composable
private fun SpaciousnessComplication(
    value: Float,
    modifier: Modifier = Modifier,
) {
    val animatedValue by animateFloatAsState(
        targetValue = value,
        animationSpec = tween(1000, easing = FastOutSlowInEasing),
        label = "spaciousness"
    )

    Card(
        onClick = { },
        modifier = modifier,
        backgroundPainter = CardDefaults.cardBackgroundPainter(
            startBackgroundColor = WearColors.DeepRestSurface,
            endBackgroundColor = WearColors.DeepRestBase,
        ),
    ) {
        Row(
            modifier = Modifier.padding(12.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            // Mini gauge
            Box(modifier = Modifier.size(36.dp)) {
                Canvas(modifier = Modifier.fillMaxSize()) {
                    val strokePx = 4f
                    val arcSize = Size(size.width - strokePx, size.height - strokePx)
                    val topLeft = Offset(strokePx / 2, strokePx / 2)

                    drawArc(
                        color = WearColors.Green700,
                        startAngle = 135f,
                        sweepAngle = 270f,
                        useCenter = false,
                        topLeft = topLeft,
                        size = arcSize,
                        style = Stroke(strokePx, cap = StrokeCap.Round),
                    )
                    drawArc(
                        color = WearColors.Gold,
                        startAngle = 135f,
                        sweepAngle = 270f * animatedValue,
                        useCenter = false,
                        topLeft = topLeft,
                        size = arcSize,
                        style = Stroke(strokePx, cap = StrokeCap.Round),
                    )
                }
            }

            Spacer(modifier = Modifier.width(10.dp))

            Column {
                Text(
                    text = "Spaciousness",
                    fontSize = 10.sp,
                    color = WearColors.TextMuted,
                )
                Text(
                    text = "${(animatedValue * 100).toInt()}%",
                    fontSize = 18.sp,
                    fontWeight = FontWeight.Bold,
                    color = WearColors.Gold,
                )
            }
        }
    }
}

// ─────────────────────────────────────────────
// Ambient Mode Support
// ─────────────────────────────────────────────

@Composable
fun AmbientDisplay(
    heartRate: Int,
    phase: String,
    spaciousness: Float,
) {
    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(Color.Black),
        contentAlignment = Alignment.Center,
    ) {
        Column(horizontalAlignment = Alignment.CenterHorizontally) {
            // Phase with minimal rendering
            Text(
                text = phase,
                fontSize = 14.sp,
                color = Color.White.copy(alpha = 0.6f),
            )
            Spacer(modifier = Modifier.height(4.dp))

            // Heart rate (most important glanceable)
            Text(
                text = "$heartRate",
                fontSize = 32.sp,
                fontWeight = FontWeight.Light,
                color = Color.White.copy(alpha = 0.8f),
            )
            Text(
                text = "bpm",
                fontSize = 10.sp,
                color = Color.White.copy(alpha = 0.4f),
            )

            Spacer(modifier = Modifier.height(8.dp))

            // Spaciousness as simple bar
            Box(
                modifier = Modifier
                    .width(40.dp)
                    .height(3.dp)
                    .clip(RoundedCornerShape(1.5.dp))
                    .background(Color.White.copy(alpha = 0.1f)),
            ) {
                Box(
                    modifier = Modifier
                        .fillMaxWidth(spaciousness)
                        .height(3.dp)
                        .clip(RoundedCornerShape(1.5.dp))
                        .background(Color.White.copy(alpha = 0.5f)),
                )
            }
        }
    }
}
