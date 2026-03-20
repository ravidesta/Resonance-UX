package com.resonance.automotive

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.core.FastOutSlowInEasing
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.FavoriteBorder
import androidx.compose.material.icons.filled.Mic
import androidx.compose.material.icons.filled.MicOff
import androidx.compose.material.icons.filled.Pause
import androidx.compose.material.icons.filled.PlayArrow
import androidx.compose.material.icons.filled.SelfImprovement
import androidx.compose.material.icons.filled.SkipNext
import androidx.compose.material.icons.filled.SkipPrevious
import androidx.compose.material.icons.outlined.Air
import androidx.compose.material.icons.outlined.Audiotrack
import androidx.compose.material.icons.outlined.DirectionsCar
import androidx.compose.material.icons.outlined.MonitorHeart
import androidx.compose.material.icons.outlined.Person
import androidx.compose.material.icons.outlined.SelfImprovement
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableFloatStateOf
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import kotlinx.coroutines.delay

// ─────────────────────────────────────────────
// Auto Colors (High contrast for automotive)
// ─────────────────────────────────────────────

private object AutoColors {
    val Background = Color(0xFF05100B)
    val Surface = Color(0xFF0A1C14)
    val SurfaceElevated = Color(0xFF122E21)
    val Gold = Color(0xFFC5A059)
    val GoldBright = Color(0xFFD4B878)
    val Green500 = Color(0xFF3D7A5F)
    val TextPrimary = Color(0xFFFAFAF8)
    val TextSecondary = Color(0xFFA0B5A8)
    val TextMuted = Color(0xFF5C7065)
    val Success = Color(0xFF6BBF8A)
    val HeartRate = Color(0xFFFF6B6B)
    val Divider = Color(0xFF1A3525)
}

// ─────────────────────────────────────────────
// Activity
// ─────────────────────────────────────────────

class ResonanceAutoActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            ResonanceAutoApp()
        }
    }
}

// ─────────────────────────────────────────────
// Main Auto App
// ─────────────────────────────────────────────

@Composable
fun ResonanceAutoApp() {
    var selectedSection by remember { mutableIntStateOf(0) }

    Row(
        modifier = Modifier
            .fillMaxSize()
            .background(AutoColors.Background),
    ) {
        // Left rail navigation (large tap targets for auto)
        AutoNavigationRail(
            selectedIndex = selectedSection,
            onSelect = { selectedSection = it },
            modifier = Modifier.fillMaxHeight(),
        )

        // Content area
        Box(
            modifier = Modifier
                .weight(1f)
                .fillMaxHeight()
                .padding(24.dp),
        ) {
            when (selectedSection) {
                0 -> VoiceStatusSection()
                1 -> CalmPlaybookSection()
                2 -> GuidedBreathworkSection()
                3 -> VitalCheckSection()
            }
        }
    }
}

// ─────────────────────────────────────────────
// Navigation Rail (Auto-sized tap targets)
// ─────────────────────────────────────────────

@Composable
private fun AutoNavigationRail(
    selectedIndex: Int,
    onSelect: (Int) -> Unit,
    modifier: Modifier = Modifier,
) {
    val items = remember {
        listOf(
            AutoNavItem("Status", Icons.Outlined.Person),
            AutoNavItem("Audio", Icons.Outlined.Audiotrack),
            AutoNavItem("Breathe", Icons.Outlined.Air),
            AutoNavItem("Vitals", Icons.Outlined.MonitorHeart),
        )
    }

    Surface(
        modifier = modifier.width(100.dp),
        color = AutoColors.Surface,
    ) {
        Column(
            modifier = Modifier
                .fillMaxHeight()
                .padding(vertical = 32.dp),
            verticalArrangement = Arrangement.SpaceEvenly,
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            items.forEachIndexed { index, item ->
                AutoNavButton(
                    item = item,
                    isSelected = index == selectedIndex,
                    onClick = { onSelect(index) },
                )
            }
        }
    }
}

data class AutoNavItem(val label: String, val icon: ImageVector)

@Composable
private fun AutoNavButton(
    item: AutoNavItem,
    isSelected: Boolean,
    onClick: () -> Unit,
) {
    val bgAlpha by animateFloatAsState(
        targetValue = if (isSelected) 0.15f else 0f,
        animationSpec = tween(200),
        label = "navBg"
    )

    Column(
        modifier = Modifier
            .size(80.dp)
            .clip(RoundedCornerShape(16.dp))
            .background(AutoColors.Gold.copy(alpha = bgAlpha))
            .clickable(onClick = onClick),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center,
    ) {
        Icon(
            imageVector = item.icon,
            contentDescription = item.label,
            modifier = Modifier.size(28.dp),
            tint = if (isSelected) AutoColors.Gold else AutoColors.TextMuted,
        )
        Spacer(modifier = Modifier.height(4.dp))
        Text(
            text = item.label,
            fontSize = 11.sp,
            fontWeight = if (isSelected) FontWeight.SemiBold else FontWeight.Normal,
            color = if (isSelected) AutoColors.Gold else AutoColors.TextMuted,
            textAlign = TextAlign.Center,
        )
    }
}

// ─────────────────────────────────────────────
// Voice-Driven Status Updates
// ─────────────────────────────────────────────

@Composable
private fun VoiceStatusSection() {
    var isListening by remember { mutableStateOf(false) }
    var currentStatus by remember { mutableStateOf("Open to connect") }
    var lastVoiceCommand by remember { mutableStateOf("") }

    val infiniteTransition = rememberInfiniteTransition(label = "voicePulse")
    val pulseAlpha by infiniteTransition.animateFloat(
        initialValue = 0.3f,
        targetValue = 0.8f,
        animationSpec = infiniteRepeatable(
            animation = tween(1000),
            repeatMode = RepeatMode.Reverse,
        ),
        label = "pulseAlpha"
    )

    Column(
        modifier = Modifier.fillMaxSize(),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.SpaceBetween,
    ) {
        // Current status display
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            modifier = Modifier.padding(top = 16.dp),
        ) {
            Text(
                text = "Your Status",
                fontSize = 14.sp,
                color = AutoColors.TextSecondary,
            )
            Spacer(modifier = Modifier.height(8.dp))
            Text(
                text = currentStatus,
                fontSize = 28.sp,
                fontWeight = FontWeight.SemiBold,
                color = AutoColors.TextPrimary,
            )
            Spacer(modifier = Modifier.height(4.dp))

            // Phase context
            Text(
                text = "Descent Phase \u2022 Moderate Energy",
                fontSize = 13.sp,
                color = AutoColors.Gold.copy(alpha = 0.8f),
            )
        }

        // Large voice activation button (auto-safe)
        Box(
            modifier = Modifier
                .size(120.dp)
                .clip(CircleShape)
                .background(
                    if (isListening) AutoColors.Gold.copy(alpha = pulseAlpha * 0.2f)
                    else AutoColors.SurfaceElevated
                )
                .clickable { isListening = !isListening },
            contentAlignment = Alignment.Center,
        ) {
            if (isListening) {
                // Listening animation
                Canvas(modifier = Modifier.size(100.dp)) {
                    val center = Offset(size.width / 2, size.height / 2)
                    drawCircle(
                        color = AutoColors.Gold.copy(alpha = pulseAlpha * 0.3f),
                        radius = size.minDimension / 2 * pulseAlpha,
                        center = center,
                    )
                }
            }
            Icon(
                imageVector = if (isListening) Icons.Filled.Mic else Icons.Filled.MicOff,
                contentDescription = if (isListening) "Listening" else "Tap to speak",
                modifier = Modifier.size(48.dp),
                tint = if (isListening) AutoColors.Gold else AutoColors.TextSecondary,
            )
        }

        // Quick status options (large tap targets)
        Column(
            modifier = Modifier.padding(bottom = 16.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp),
        ) {
            Text(
                text = "Say or tap to update:",
                fontSize = 12.sp,
                color = AutoColors.TextMuted,
                modifier = Modifier.padding(start = 8.dp),
            )

            val statuses = listOf(
                "Deep work phase",
                "Open to connect",
                "Recharging",
                "In flow",
            )

            statuses.forEach { status ->
                StatusOption(
                    text = status,
                    isSelected = status == currentStatus,
                    onClick = { currentStatus = status },
                )
            }
        }
    }
}

@Composable
private fun StatusOption(
    text: String,
    isSelected: Boolean,
    onClick: () -> Unit,
) {
    Surface(
        modifier = Modifier
            .fillMaxWidth()
            .height(56.dp)
            .clip(RoundedCornerShape(12.dp))
            .clickable(onClick = onClick),
        color = if (isSelected) AutoColors.Gold.copy(alpha = 0.12f)
        else AutoColors.Surface,
        shape = RoundedCornerShape(12.dp),
    ) {
        Row(
            modifier = Modifier
                .fillMaxSize()
                .padding(horizontal = 20.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Box(
                modifier = Modifier
                    .size(10.dp)
                    .clip(CircleShape)
                    .background(
                        if (isSelected) AutoColors.Gold
                        else AutoColors.TextMuted.copy(alpha = 0.3f)
                    ),
            )
            Spacer(modifier = Modifier.width(16.dp))
            Text(
                text = text,
                fontSize = 16.sp,
                fontWeight = if (isSelected) FontWeight.SemiBold else FontWeight.Normal,
                color = if (isSelected) AutoColors.Gold else AutoColors.TextPrimary,
            )
        }
    }
}

// ─────────────────────────────────────────────
// Calm Audio Playbook Navigation
// ─────────────────────────────────────────────

@Composable
private fun CalmPlaybookSection() {
    var isPlaying by remember { mutableStateOf(false) }
    var currentTrackIndex by remember { mutableIntStateOf(0) }

    val playbook = remember {
        listOf(
            AudioTrack("Morning Intention Setting", "Guided Meditation", "8:30"),
            AudioTrack("Ocean Breath", "Ambient Soundscape", "12:00"),
            AudioTrack("Afternoon Reset", "Micro-Meditation", "3:00"),
            AudioTrack("Evening Wind Down", "Body Scan", "15:00"),
            AudioTrack("Sleep Preparation", "Guided Relaxation", "20:00"),
            AudioTrack("Rain on Leaves", "Nature Sounds", "45:00"),
        )
    }

    Column(modifier = Modifier.fillMaxSize()) {
        // Now playing
        Card(
            modifier = Modifier.fillMaxWidth(),
            shape = RoundedCornerShape(16.dp),
            colors = CardDefaults.cardColors(containerColor = AutoColors.Surface),
        ) {
            Column(
                modifier = Modifier.padding(20.dp),
                horizontalAlignment = Alignment.CenterHorizontally,
            ) {
                Text(
                    text = "Now Playing",
                    fontSize = 11.sp,
                    color = AutoColors.TextMuted,
                )
                Spacer(modifier = Modifier.height(8.dp))
                Text(
                    text = playbook[currentTrackIndex].title,
                    fontSize = 22.sp,
                    fontWeight = FontWeight.SemiBold,
                    color = AutoColors.TextPrimary,
                    textAlign = TextAlign.Center,
                )
                Text(
                    text = playbook[currentTrackIndex].category,
                    fontSize = 13.sp,
                    color = AutoColors.Gold,
                )
                Spacer(modifier = Modifier.height(16.dp))

                // Large playback controls
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceEvenly,
                    verticalAlignment = Alignment.CenterVertically,
                ) {
                    IconButton(
                        onClick = {
                            if (currentTrackIndex > 0) currentTrackIndex--
                        },
                        modifier = Modifier.size(56.dp),
                    ) {
                        Icon(
                            Icons.Filled.SkipPrevious,
                            contentDescription = "Previous",
                            modifier = Modifier.size(32.dp),
                            tint = AutoColors.TextSecondary,
                        )
                    }

                    Box(
                        modifier = Modifier
                            .size(72.dp)
                            .clip(CircleShape)
                            .background(AutoColors.Gold.copy(alpha = 0.15f))
                            .clickable { isPlaying = !isPlaying },
                        contentAlignment = Alignment.Center,
                    ) {
                        Icon(
                            imageVector = if (isPlaying) Icons.Filled.Pause else Icons.Filled.PlayArrow,
                            contentDescription = if (isPlaying) "Pause" else "Play",
                            modifier = Modifier.size(40.dp),
                            tint = AutoColors.Gold,
                        )
                    }

                    IconButton(
                        onClick = {
                            if (currentTrackIndex < playbook.lastIndex) currentTrackIndex++
                        },
                        modifier = Modifier.size(56.dp),
                    ) {
                        Icon(
                            Icons.Filled.SkipNext,
                            contentDescription = "Next",
                            modifier = Modifier.size(32.dp),
                            tint = AutoColors.TextSecondary,
                        )
                    }
                }

                Spacer(modifier = Modifier.height(8.dp))
                Text(
                    text = playbook[currentTrackIndex].duration,
                    fontSize = 12.sp,
                    color = AutoColors.TextMuted,
                )
            }
        }

        Spacer(modifier = Modifier.height(16.dp))

        // Playlist
        Text(
            text = "Calm Playbook",
            fontSize = 14.sp,
            color = AutoColors.TextSecondary,
            modifier = Modifier.padding(horizontal = 4.dp),
        )
        Spacer(modifier = Modifier.height(8.dp))

        LazyColumn(
            verticalArrangement = Arrangement.spacedBy(8.dp),
        ) {
            items(playbook.size) { index ->
                val track = playbook[index]
                val isCurrent = index == currentTrackIndex

                Surface(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(56.dp)
                        .clickable { currentTrackIndex = index },
                    color = if (isCurrent) AutoColors.Gold.copy(alpha = 0.08f)
                    else Color.Transparent,
                    shape = RoundedCornerShape(10.dp),
                ) {
                    Row(
                        modifier = Modifier
                            .fillMaxSize()
                            .padding(horizontal = 16.dp),
                        verticalAlignment = Alignment.CenterVertically,
                    ) {
                        Text(
                            text = track.title,
                            fontSize = 15.sp,
                            fontWeight = if (isCurrent) FontWeight.SemiBold else FontWeight.Normal,
                            color = if (isCurrent) AutoColors.Gold else AutoColors.TextPrimary,
                            modifier = Modifier.weight(1f),
                        )
                        Text(
                            text = track.duration,
                            fontSize = 12.sp,
                            color = AutoColors.TextMuted,
                        )
                    }
                }
            }
        }
    }
}

data class AudioTrack(val title: String, val category: String, val duration: String)

// ─────────────────────────────────────────────
// Guided Breathwork (Hands-Free)
// ─────────────────────────────────────────────

@Composable
private fun GuidedBreathworkSection() {
    var isActive by remember { mutableStateOf(false) }
    var phase by remember { mutableStateOf("Ready") }
    var cycleCount by remember { mutableIntStateOf(0) }
    var progress by remember { mutableFloatStateOf(0f) }

    val circleScale by animateFloatAsState(
        targetValue = when (phase) {
            "Inhale" -> 1f
            "Hold" -> 1f
            "Exhale" -> 0.4f
            else -> 0.6f
        },
        animationSpec = tween(
            when (phase) {
                "Inhale" -> 4000
                "Hold" -> 4000
                "Exhale" -> 6000
                else -> 500
            }
        ),
        label = "autoBreathScale"
    )

    LaunchedEffect(isActive) {
        if (isActive) {
            while (isActive) {
                phase = "Inhale"
                for (i in 0..40) { progress = i / 40f; delay(100) }
                phase = "Hold"
                for (i in 0..40) { progress = i / 40f; delay(100) }
                phase = "Exhale"
                for (i in 0..60) { progress = i / 60f; delay(100) }
                phase = "Rest"
                for (i in 0..20) { progress = i / 20f; delay(100) }
                cycleCount++
            }
        } else {
            phase = "Ready"
            progress = 0f
        }
    }

    Column(
        modifier = Modifier.fillMaxSize(),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center,
    ) {
        // Large breathwork circle
        Box(
            modifier = Modifier
                .size(200.dp)
                .clickable { isActive = !isActive },
            contentAlignment = Alignment.Center,
        ) {
            Canvas(modifier = Modifier.fillMaxSize()) {
                val center = Offset(size.width / 2, size.height / 2)
                val maxRadius = size.minDimension / 2 * 0.85f
                val currentRadius = maxRadius * circleScale

                // Glow ring
                drawCircle(
                    brush = Brush.radialGradient(
                        colors = listOf(
                            AutoColors.Gold.copy(alpha = 0.15f),
                            Color.Transparent,
                        ),
                        center = center,
                        radius = currentRadius * 1.4f,
                    ),
                )

                // Main circle
                drawCircle(
                    brush = Brush.radialGradient(
                        colors = listOf(
                            AutoColors.Gold.copy(alpha = 0.2f),
                            AutoColors.Gold.copy(alpha = 0.05f),
                        ),
                        center = center,
                        radius = currentRadius,
                    ),
                )

                // Border
                drawCircle(
                    color = AutoColors.Gold.copy(alpha = 0.4f),
                    radius = currentRadius,
                    center = center,
                    style = Stroke(width = 2f),
                )

                // Progress ring
                if (isActive) {
                    drawArc(
                        color = AutoColors.Gold.copy(alpha = 0.6f),
                        startAngle = -90f,
                        sweepAngle = 360f * progress,
                        useCenter = false,
                        style = Stroke(width = 3f, cap = StrokeCap.Round),
                        topLeft = Offset(
                            center.x - currentRadius,
                            center.y - currentRadius,
                        ),
                        size = androidx.compose.ui.geometry.Size(
                            currentRadius * 2,
                            currentRadius * 2,
                        ),
                    )
                }
            }

            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                Text(
                    text = if (isActive) phase else "Tap to Begin",
                    fontSize = 20.sp,
                    fontWeight = FontWeight.SemiBold,
                    color = AutoColors.Gold,
                )
                if (isActive) {
                    Text(
                        text = "Cycle $cycleCount",
                        fontSize = 12.sp,
                        color = AutoColors.TextMuted,
                    )
                }
            }
        }

        Spacer(modifier = Modifier.height(24.dp))

        // Pattern info
        Text(
            text = "4-4-6-2 Calming Breath",
            fontSize = 14.sp,
            color = AutoColors.TextSecondary,
        )
        Text(
            text = "Hands-free \u2022 Voice: \"Start breathing\" / \"Stop\"",
            fontSize = 11.sp,
            color = AutoColors.TextMuted,
        )
    }
}

// ─────────────────────────────────────────────
// Simplified Vital Check Display
// ─────────────────────────────────────────────

@Composable
private fun VitalCheckSection() {
    val vitals = remember {
        listOf(
            VitalDisplay("Heart Rate", "72", "bpm", AutoColors.HeartRate, isNormal = true),
            VitalDisplay("HRV", "42", "ms", AutoColors.Gold, isNormal = true),
            VitalDisplay("Stress", "Low", "", AutoColors.Success, isNormal = true),
            VitalDisplay("Sleep", "78%", "quality", AutoColors.Green500, isNormal = true),
        )
    }

    Column(
        modifier = Modifier.fillMaxSize(),
        verticalArrangement = Arrangement.spacedBy(16.dp),
    ) {
        Text(
            text = "Vital Signs",
            fontSize = 14.sp,
            color = AutoColors.TextSecondary,
        )

        // Large, glanceable vital cards
        vitals.forEach { vital ->
            Card(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(80.dp),
                shape = RoundedCornerShape(16.dp),
                colors = CardDefaults.cardColors(containerColor = AutoColors.Surface),
            ) {
                Row(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(horizontal = 20.dp),
                    verticalAlignment = Alignment.CenterVertically,
                ) {
                    // Status dot
                    Box(
                        modifier = Modifier
                            .size(12.dp)
                            .clip(CircleShape)
                            .background(vital.color.copy(alpha = if (vital.isNormal) 1f else 0.6f)),
                    )

                    Spacer(modifier = Modifier.width(16.dp))

                    Column(modifier = Modifier.weight(1f)) {
                        Text(
                            text = vital.label,
                            fontSize = 13.sp,
                            color = AutoColors.TextSecondary,
                        )
                    }

                    Row(verticalAlignment = Alignment.Bottom) {
                        Text(
                            text = vital.value,
                            fontSize = 28.sp,
                            fontWeight = FontWeight.Bold,
                            color = vital.color,
                        )
                        if (vital.unit.isNotEmpty()) {
                            Spacer(modifier = Modifier.width(4.dp))
                            Text(
                                text = vital.unit,
                                fontSize = 13.sp,
                                color = AutoColors.TextMuted,
                                modifier = Modifier.padding(bottom = 4.dp),
                            )
                        }
                    }
                }
            }
        }

        Spacer(modifier = Modifier.weight(1f))

        Text(
            text = "Last synced from watch: 2 min ago",
            fontSize = 11.sp,
            color = AutoColors.TextMuted,
            textAlign = TextAlign.Center,
            modifier = Modifier.fillMaxWidth(),
        )
    }
}

data class VitalDisplay(
    val label: String,
    val value: String,
    val unit: String,
    val color: Color,
    val isNormal: Boolean,
)
