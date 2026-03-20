package com.luminous.cosmic.ui.screens

import androidx.compose.animation.*
import androidx.compose.animation.core.*
import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import kotlinx.coroutines.delay

import com.luminous.cosmic.data.models.*
import com.luminous.cosmic.ui.components.CosmicBackground
import com.luminous.cosmic.ui.theme.*

@Composable
fun MeditationScreen(
    isDarkTheme: Boolean,
    onBack: () -> Unit
) {
    val meditations = remember { ChartCalculator.getSampleMeditations() }
    var activeMeditation by remember { mutableStateOf<Meditation?>(null) }
    var activeStepIndex by remember { mutableIntStateOf(0) }
    var isPlaying by remember { mutableStateOf(false) }

    CosmicBackground(isDarkTheme = isDarkTheme) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .statusBarsPadding()
                .navigationBarsPadding()
        ) {
            // Top bar
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 8.dp, vertical = 8.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                IconButton(onClick = {
                    if (activeMeditation != null) {
                        activeMeditation = null
                        isPlaying = false
                        activeStepIndex = 0
                    } else {
                        onBack()
                    }
                }) {
                    Icon(
                        Icons.Outlined.ArrowBack,
                        contentDescription = "Back",
                        tint = ResonanceColors.GoldPrimary
                    )
                }
                Text(
                    text = if (activeMeditation != null) activeMeditation!!.title
                    else "Guided Meditations",
                    style = MaterialTheme.typography.titleLarge,
                    color = ResonanceColors.GoldPrimary,
                    fontWeight = FontWeight.Light,
                    modifier = Modifier.weight(1f)
                )
            }

            if (activeMeditation != null) {
                MeditationPlayer(
                    meditation = activeMeditation!!,
                    currentStepIndex = activeStepIndex,
                    isPlaying = isPlaying,
                    onPlayPause = { isPlaying = !isPlaying },
                    onNextStep = {
                        if (activeStepIndex < activeMeditation!!.steps.lastIndex) {
                            activeStepIndex++
                        } else {
                            isPlaying = false
                        }
                    },
                    onPrevStep = {
                        if (activeStepIndex > 0) activeStepIndex--
                    }
                )
            } else {
                // Meditation list
                LazyColumn(
                    contentPadding = PaddingValues(horizontal = 20.dp, vertical = 8.dp),
                    verticalArrangement = Arrangement.spacedBy(14.dp)
                ) {
                    item {
                        Text(
                            text = "Attune to the celestial rhythms through guided meditation. " +
                                "Each practice is designed to deepen your connection with " +
                                "your cosmic architecture.",
                            style = MaterialTheme.typography.bodyMedium,
                            color = MaterialTheme.colorScheme.onSurfaceVariant,
                            lineHeight = 22.sp
                        )
                        Spacer(modifier = Modifier.height(8.dp))
                    }

                    items(meditations) { meditation ->
                        MeditationCard(
                            meditation = meditation,
                            onClick = {
                                activeMeditation = meditation
                                activeStepIndex = 0
                                isPlaying = false
                            }
                        )
                    }

                    item { Spacer(modifier = Modifier.height(24.dp)) }
                }
            }
        }
    }
}

@Composable
private fun MeditationCard(
    meditation: Meditation,
    onClick: () -> Unit
) {
    val categoryIcon = when (meditation.category) {
        MeditationCategory.STARGAZER -> "\u2B50"
        MeditationCategory.LUNAR -> "\uD83C\uDF19"
        MeditationCategory.ELEMENTAL -> "\uD83C\uDF0D"
        MeditationCategory.PLANETARY -> "\u2609"
    }

    GlassCard(
        modifier = Modifier
            .fillMaxWidth()
            .clickable(onClick = onClick),
        cornerRadius = 20.dp
    ) {
        Column(modifier = Modifier.padding(20.dp)) {
            Row(
                verticalAlignment = Alignment.CenterVertically,
                modifier = Modifier.fillMaxWidth()
            ) {
                Box(
                    modifier = Modifier
                        .size(48.dp)
                        .clip(CircleShape)
                        .background(
                            Brush.radialGradient(
                                colors = listOf(
                                    ResonanceColors.GoldPrimary.copy(alpha = 0.2f),
                                    ResonanceColors.GoldDark.copy(alpha = 0.05f)
                                )
                            )
                        ),
                    contentAlignment = Alignment.Center
                ) {
                    Text(text = categoryIcon, fontSize = 22.sp)
                }

                Spacer(modifier = Modifier.width(14.dp))

                Column(modifier = Modifier.weight(1f)) {
                    Text(
                        text = meditation.title,
                        style = MaterialTheme.typography.titleSmall,
                        color = MaterialTheme.colorScheme.onSurface,
                        fontWeight = FontWeight.SemiBold
                    )
                    Text(
                        text = meditation.subtitle,
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }

                Column(horizontalAlignment = Alignment.End) {
                    Text(
                        text = "${meditation.durationMinutes} min",
                        style = MaterialTheme.typography.labelMedium,
                        color = ResonanceColors.GoldPrimary,
                        fontWeight = FontWeight.Medium
                    )
                    Text(
                        text = "${meditation.steps.size} steps",
                        style = MaterialTheme.typography.labelSmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
            }

            Spacer(modifier = Modifier.height(12.dp))

            Text(
                text = meditation.description,
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                lineHeight = 18.sp
            )
        }
    }
}

@Composable
private fun MeditationPlayer(
    meditation: Meditation,
    currentStepIndex: Int,
    isPlaying: Boolean,
    onPlayPause: () -> Unit,
    onNextStep: () -> Unit,
    onPrevStep: () -> Unit
) {
    val currentStep = meditation.steps[currentStepIndex]

    // Breathing animation
    val breathTransition = rememberInfiniteTransition(label = "breath")
    val breathPattern = currentStep.breathPattern

    val breathScale by if (isPlaying && breathPattern != null) {
        val totalDuration = (breathPattern.inhaleSeconds + breathPattern.holdSeconds +
            breathPattern.exhaleSeconds) * 1000
        breathTransition.animateFloat(
            initialValue = 0.7f,
            targetValue = 1.3f,
            animationSpec = infiniteRepeatable(
                animation = keyframes {
                    durationMillis = totalDuration
                    0.7f at 0 using FastOutSlowInEasing
                    1.3f at breathPattern.inhaleSeconds * 1000 using LinearEasing
                    1.3f at (breathPattern.inhaleSeconds + breathPattern.holdSeconds) * 1000 using FastOutSlowInEasing
                    0.7f at totalDuration using FastOutSlowInEasing
                },
                repeatMode = RepeatMode.Restart
            ),
            label = "breath_scale"
        )
    } else {
        remember { mutableFloatStateOf(1f) }
    }

    // Timer
    var elapsedSeconds by remember { mutableIntStateOf(0) }
    LaunchedEffect(isPlaying) {
        if (isPlaying) {
            while (true) {
                delay(1000)
                elapsedSeconds++
                if (elapsedSeconds >= currentStep.durationSeconds) {
                    onNextStep()
                    elapsedSeconds = 0
                }
            }
        }
    }

    // Reset timer on step change
    LaunchedEffect(currentStepIndex) {
        elapsedSeconds = 0
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(horizontal = 20.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Spacer(modifier = Modifier.height(20.dp))

        // Breathing orb
        Box(
            modifier = Modifier
                .size(200.dp)
                .scale(breathScale),
            contentAlignment = Alignment.Center
        ) {
            // Outer glow
            Canvas(modifier = Modifier.fillMaxSize()) {
                drawCircle(
                    brush = Brush.radialGradient(
                        colors = listOf(
                            ResonanceColors.GoldPrimary.copy(alpha = 0.15f),
                            ResonanceColors.GoldPrimary.copy(alpha = 0.05f),
                            Color.Transparent
                        )
                    ),
                    radius = size.minDimension / 2f
                )
                drawCircle(
                    brush = Brush.radialGradient(
                        colors = listOf(
                            ResonanceColors.ForestMedium.copy(alpha = 0.3f),
                            ResonanceColors.ForestDark.copy(alpha = 0.15f),
                            ResonanceColors.GoldPrimary.copy(alpha = 0.08f)
                        )
                    ),
                    radius = size.minDimension / 3f
                )
            }

            // Breath instruction
            if (isPlaying && breathPattern != null) {
                val phase = when {
                    elapsedSeconds % (breathPattern.inhaleSeconds + breathPattern.holdSeconds + breathPattern.exhaleSeconds) < breathPattern.inhaleSeconds -> "Breathe In"
                    elapsedSeconds % (breathPattern.inhaleSeconds + breathPattern.holdSeconds + breathPattern.exhaleSeconds) < breathPattern.inhaleSeconds + breathPattern.holdSeconds -> "Hold"
                    else -> "Breathe Out"
                }
                Text(
                    text = phase,
                    style = MaterialTheme.typography.titleMedium,
                    color = ResonanceColors.GoldPrimary,
                    fontWeight = FontWeight.Light
                )
            }
        }

        Spacer(modifier = Modifier.height(20.dp))

        // Step progress
        Row(
            horizontalArrangement = Arrangement.Center,
            modifier = Modifier.fillMaxWidth()
        ) {
            meditation.steps.forEachIndexed { index, _ ->
                Box(
                    modifier = Modifier
                        .padding(horizontal = 3.dp)
                        .size(if (index == currentStepIndex) 10.dp else 6.dp)
                        .clip(CircleShape)
                        .background(
                            if (index <= currentStepIndex) ResonanceColors.GoldPrimary
                            else ResonanceColors.GoldPrimary.copy(alpha = 0.2f)
                        )
                )
            }
        }

        Spacer(modifier = Modifier.height(24.dp))

        // Step title
        Text(
            text = "Step ${currentStepIndex + 1}: ${currentStep.title}",
            style = MaterialTheme.typography.headlineSmall,
            color = ResonanceColors.GoldPrimary,
            fontWeight = FontWeight.Light,
            textAlign = TextAlign.Center
        )

        Spacer(modifier = Modifier.height(16.dp))

        // Step instruction
        GlassCard(
            modifier = Modifier.fillMaxWidth(),
            cornerRadius = 20.dp
        ) {
            Column(modifier = Modifier.padding(20.dp)) {
                Text(
                    text = currentStep.instruction,
                    style = MaterialTheme.typography.bodyLarge,
                    color = MaterialTheme.colorScheme.onSurface,
                    lineHeight = 26.sp,
                    textAlign = TextAlign.Center,
                    modifier = Modifier.fillMaxWidth()
                )

                if (breathPattern != null) {
                    Spacer(modifier = Modifier.height(16.dp))
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceEvenly
                    ) {
                        BreathLabel("In", "${breathPattern.inhaleSeconds}s")
                        BreathLabel("Hold", "${breathPattern.holdSeconds}s")
                        BreathLabel("Out", "${breathPattern.exhaleSeconds}s")
                    }
                }
            }
        }

        Spacer(modifier = Modifier.height(12.dp))

        // Timer
        val progress = elapsedSeconds.toFloat() / currentStep.durationSeconds
        LinearProgressIndicator(
            progress = { progress },
            modifier = Modifier
                .fillMaxWidth()
                .height(4.dp)
                .clip(RoundedCornerShape(2.dp)),
            color = ResonanceColors.GoldPrimary,
            trackColor = ResonanceColors.GoldPrimary.copy(alpha = 0.1f)
        )

        Spacer(modifier = Modifier.height(6.dp))

        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            Text(
                text = formatTime(elapsedSeconds),
                style = MaterialTheme.typography.labelSmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
            Text(
                text = formatTime(currentStep.durationSeconds),
                style = MaterialTheme.typography.labelSmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }

        Spacer(modifier = Modifier.height(24.dp))

        // Playback controls
        Row(
            horizontalArrangement = Arrangement.spacedBy(20.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            IconButton(
                onClick = onPrevStep,
                enabled = currentStepIndex > 0,
                modifier = Modifier
                    .size(48.dp)
                    .clip(CircleShape)
                    .background(ResonanceColors.GoldPrimary.copy(alpha = 0.1f))
            ) {
                Icon(
                    Icons.Outlined.SkipPrevious,
                    contentDescription = "Previous",
                    tint = if (currentStepIndex > 0) ResonanceColors.GoldPrimary
                    else ResonanceColors.GoldPrimary.copy(alpha = 0.3f)
                )
            }

            IconButton(
                onClick = onPlayPause,
                modifier = Modifier
                    .size(64.dp)
                    .clip(CircleShape)
                    .background(ResonanceColors.GoldPrimary)
            ) {
                Icon(
                    if (isPlaying) Icons.Outlined.Pause else Icons.Outlined.PlayArrow,
                    contentDescription = if (isPlaying) "Pause" else "Play",
                    tint = ResonanceColors.ForestDarkest,
                    modifier = Modifier.size(32.dp)
                )
            }

            IconButton(
                onClick = onNextStep,
                enabled = currentStepIndex < meditation.steps.lastIndex,
                modifier = Modifier
                    .size(48.dp)
                    .clip(CircleShape)
                    .background(ResonanceColors.GoldPrimary.copy(alpha = 0.1f))
            ) {
                Icon(
                    Icons.Outlined.SkipNext,
                    contentDescription = "Next",
                    tint = if (currentStepIndex < meditation.steps.lastIndex) ResonanceColors.GoldPrimary
                    else ResonanceColors.GoldPrimary.copy(alpha = 0.3f)
                )
            }
        }

        Spacer(modifier = Modifier.height(32.dp))
    }
}

@Composable
private fun BreathLabel(label: String, value: String) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Text(
            text = label,
            style = MaterialTheme.typography.labelSmall,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
        Text(
            text = value,
            style = MaterialTheme.typography.titleSmall,
            color = ResonanceColors.GoldPrimary,
            fontWeight = FontWeight.SemiBold
        )
    }
}

private fun formatTime(seconds: Int): String {
    val m = seconds / 60
    val s = seconds % 60
    return "%d:%02d".format(m, s)
}
