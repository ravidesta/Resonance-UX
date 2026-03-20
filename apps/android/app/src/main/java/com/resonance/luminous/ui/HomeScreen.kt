package com.resonance.luminous.ui

import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.*
import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.outlined.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.*
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.*
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import kotlinx.coroutines.delay
import kotlin.math.*

// ---------------------------------------------------------------------------
// Home screen
// ---------------------------------------------------------------------------

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun HomeScreen(
    isDark: Boolean,
    onToggleTheme: () -> Unit,
    onNavigateToShare: () -> Unit,
) {
    val scrollState = rememberScrollState()
    var selectedMood by remember { mutableIntStateOf(-1) }
    var breathingActive by remember { mutableStateOf(false) }
    var breathPhase by remember { mutableStateOf("Tap to begin") }
    var streakDays by remember { mutableIntStateOf(12) }

    val dailyInsight = remember {
        DailyInsight(
            quote = "The wound is the place where the Light enters you.",
            author = "Rumi",
            reflection = "Consider today how your most painful experiences have opened doors to deeper understanding.",
            chapter = "Chapter 4: Embracing Shadow",
        )
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(scrollState)
            .padding(horizontal = 20.dp),
    ) {
        Spacer(Modifier.height(16.dp))

        // ---------- Header ----------
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Column {
                Text(
                    text = "Good ${timeOfDayGreeting()}",
                    style = MaterialTheme.typography.headlineMedium,
                    color = MaterialTheme.colorScheme.onBackground,
                )
                Text(
                    text = "Day $streakDays of your journey",
                    style = MaterialTheme.typography.bodyMedium,
                    color = Resonance.goldPrimary,
                )
            }
            IconButton(onClick = onToggleTheme) {
                Icon(
                    imageVector = if (isDark) Icons.Filled.LightMode else Icons.Filled.DarkMode,
                    contentDescription = "Toggle theme",
                    tint = Resonance.goldPrimary,
                )
            }
        }

        Spacer(Modifier.height(24.dp))

        // ---------- Daily Insight Card ----------
        DailyInsightCard(
            insight = dailyInsight,
            isDark = isDark,
            onShare = onNavigateToShare,
        )

        Spacer(Modifier.height(24.dp))

        // ---------- Mood Check-in ----------
        MoodCheckInCard(
            selectedMood = selectedMood,
            onMoodSelected = { selectedMood = it },
            isDark = isDark,
            onShare = onNavigateToShare,
        )

        Spacer(Modifier.height(24.dp))

        // ---------- Breathing Widget ----------
        BreathingWidget(
            isActive = breathingActive,
            phase = breathPhase,
            isDark = isDark,
            onToggle = {
                breathingActive = !breathingActive
                if (breathingActive) breathPhase = "Inhale..."
            },
            onPhaseChange = { breathPhase = it },
        )

        Spacer(Modifier.height(24.dp))

        // ---------- Stats ----------
        StatsRow(streakDays = streakDays, isDark = isDark)

        Spacer(Modifier.height(24.dp))

        // ---------- Quick Share ----------
        SharePromptBanner(isDark = isDark, onTap = onNavigateToShare)

        Spacer(Modifier.height(32.dp))
    }
}

// ---------------------------------------------------------------------------
// Data
// ---------------------------------------------------------------------------

data class DailyInsight(
    val quote: String,
    val author: String,
    val reflection: String,
    val chapter: String,
)

// ---------------------------------------------------------------------------
// Organic blob background modifier
// ---------------------------------------------------------------------------

@Composable
fun Modifier.organicBlobBackground(isDark: Boolean): Modifier {
    val infiniteTransition = rememberInfiniteTransition(label = "blob")
    val phase by infiniteTransition.animateFloat(
        initialValue = 0f,
        targetValue = 2f * PI.toFloat(),
        animationSpec = infiniteRepeatable(
            animation = tween(12_000, easing = LinearEasing),
            repeatMode = RepeatMode.Restart,
        ),
        label = "blobPhase",
    )

    val ext = LuminousThemeExt.colors

    return this.drawBehind {
        val cx1 = size.width * 0.25f + sin(phase) * 30f
        val cy1 = size.height * 0.3f + cos(phase * 0.7f) * 20f
        val cx2 = size.width * 0.75f + cos(phase * 1.2f) * 25f
        val cy2 = size.height * 0.65f + sin(phase * 0.9f) * 18f

        drawCircle(
            brush = Brush.radialGradient(
                colors = listOf(ext.blobPrimary, Color.Transparent),
                center = Offset(cx1, cy1),
                radius = size.minDimension * 0.45f,
            ),
            radius = size.minDimension * 0.45f,
            center = Offset(cx1, cy1),
        )
        drawCircle(
            brush = Brush.radialGradient(
                colors = listOf(ext.blobSecondary, Color.Transparent),
                center = Offset(cx2, cy2),
                radius = size.minDimension * 0.35f,
            ),
            radius = size.minDimension * 0.35f,
            center = Offset(cx2, cy2),
        )
    }
}

// ---------------------------------------------------------------------------
// Glass card wrapper
// ---------------------------------------------------------------------------

@Composable
fun GlassCard(
    modifier: Modifier = Modifier,
    isDark: Boolean,
    content: @Composable ColumnScope.() -> Unit,
) {
    val ext = LuminousThemeExt.colors
    Card(
        modifier = modifier,
        shape = RoundedCornerShape(24.dp),
        colors = CardDefaults.cardColors(
            containerColor = ext.glassSurface,
        ),
        border = BorderStroke(1.dp, ext.glassBorder),
        elevation = CardDefaults.cardElevation(defaultElevation = 0.dp),
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .organicBlobBackground(isDark)
                .padding(20.dp),
            content = content,
        )
    }
}

// ---------------------------------------------------------------------------
// Daily Insight Card
// ---------------------------------------------------------------------------

@Composable
fun DailyInsightCard(
    insight: DailyInsight,
    isDark: Boolean,
    onShare: () -> Unit,
) {
    GlassCard(isDark = isDark) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Text(
                text = "Daily Insight",
                style = MaterialTheme.typography.labelLarge,
                color = Resonance.goldPrimary,
            )
            Text(
                text = insight.chapter,
                style = MaterialTheme.typography.labelSmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
            )
        }

        Spacer(Modifier.height(16.dp))

        // Gold accent line
        Box(
            modifier = Modifier
                .width(40.dp)
                .height(2.dp)
                .background(
                    Brush.horizontalGradient(
                        listOf(Resonance.goldDark, Resonance.goldPrimary, Resonance.goldLight)
                    ),
                    RoundedCornerShape(1.dp),
                ),
        )

        Spacer(Modifier.height(12.dp))

        Text(
            text = "\u201C${insight.quote}\u201D",
            style = MaterialTheme.typography.headlineSmall.copy(
                fontStyle = FontStyle.Italic,
                lineHeight = 32.sp,
            ),
            color = MaterialTheme.colorScheme.onSurface,
        )

        Spacer(Modifier.height(8.dp))

        Text(
            text = "\u2014 ${insight.author}",
            style = MaterialTheme.typography.bodyMedium,
            color = Resonance.goldPrimary,
        )

        Spacer(Modifier.height(16.dp))

        Text(
            text = insight.reflection,
            style = MaterialTheme.typography.bodyLarge,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
        )

        Spacer(Modifier.height(16.dp))

        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.End,
        ) {
            FilledTonalButton(
                onClick = onShare,
                colors = ButtonDefaults.filledTonalButtonColors(
                    containerColor = Resonance.goldPrimary.copy(alpha = .15f),
                    contentColor = Resonance.goldPrimary,
                ),
                shape = RoundedCornerShape(12.dp),
            ) {
                Icon(Icons.Filled.Share, contentDescription = null, modifier = Modifier.size(16.dp))
                Spacer(Modifier.width(6.dp))
                Text("Share this insight")
            }
        }
    }
}

// ---------------------------------------------------------------------------
// Mood Check-in
// ---------------------------------------------------------------------------

private val moodEmojis = listOf(
    "\uD83D\uDE14" to "Low",
    "\uD83D\uDE10" to "Flat",
    "\uD83D\uDE42" to "Calm",
    "\uD83D\uDE0A" to "Good",
    "\u2728"       to "Radiant",
)

@Composable
fun MoodCheckInCard(
    selectedMood: Int,
    onMoodSelected: (Int) -> Unit,
    isDark: Boolean,
    onShare: () -> Unit,
) {
    GlassCard(isDark = isDark) {
        Text(
            text = "How are you feeling?",
            style = MaterialTheme.typography.titleMedium,
            color = MaterialTheme.colorScheme.onSurface,
        )

        Spacer(Modifier.height(16.dp))

        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceEvenly,
        ) {
            moodEmojis.forEachIndexed { idx, (emoji, label) ->
                val isSelected = idx == selectedMood
                val bgColor by animateColorAsState(
                    if (isSelected) Resonance.goldPrimary.copy(alpha = .2f) else Color.Transparent,
                    label = "moodBg$idx",
                )
                Column(
                    horizontalAlignment = Alignment.CenterHorizontally,
                    modifier = Modifier
                        .clip(RoundedCornerShape(16.dp))
                        .background(bgColor)
                        .clickable { onMoodSelected(idx) }
                        .padding(12.dp),
                ) {
                    Text(text = emoji, fontSize = 28.sp)
                    Spacer(Modifier.height(4.dp))
                    Text(
                        text = label,
                        style = MaterialTheme.typography.labelSmall,
                        color = if (isSelected) Resonance.goldPrimary
                        else MaterialTheme.colorScheme.onSurfaceVariant,
                    )
                }
            }
        }

        if (selectedMood >= 0) {
            Spacer(Modifier.height(12.dp))
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.End,
            ) {
                TextButton(onClick = onShare) {
                    Icon(Icons.Outlined.Share, contentDescription = null, modifier = Modifier.size(14.dp))
                    Spacer(Modifier.width(4.dp))
                    Text("Share mood", style = MaterialTheme.typography.labelSmall)
                }
            }
        }
    }
}

// ---------------------------------------------------------------------------
// Breathing Widget
// ---------------------------------------------------------------------------

@Composable
fun BreathingWidget(
    isActive: Boolean,
    phase: String,
    isDark: Boolean,
    onToggle: () -> Unit,
    onPhaseChange: (String) -> Unit,
) {
    // Animate the breathing circle
    val infiniteTransition = rememberInfiniteTransition(label = "breath")
    val scale by infiniteTransition.animateFloat(
        initialValue = 0.6f,
        targetValue = 1f,
        animationSpec = infiniteRepeatable(
            animation = tween(4000, easing = EaseInOutCubic),
            repeatMode = RepeatMode.Reverse,
        ),
        label = "breathScale",
    )

    // Cycle phases
    LaunchedEffect(isActive) {
        if (!isActive) return@LaunchedEffect
        val phases = listOf("Inhale..." to 4000L, "Hold..." to 4000L, "Exhale..." to 6000L)
        while (isActive) {
            for ((name, dur) in phases) {
                onPhaseChange(name)
                delay(dur)
            }
        }
    }

    GlassCard(isDark = isDark) {
        Text(
            text = "Breathing Space",
            style = MaterialTheme.typography.titleMedium,
            color = MaterialTheme.colorScheme.onSurface,
        )
        Spacer(Modifier.height(16.dp))

        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(160.dp),
            contentAlignment = Alignment.Center,
        ) {
            // Outer glow
            if (isActive) {
                Box(
                    modifier = Modifier
                        .size((120 * scale).dp)
                        .clip(CircleShape)
                        .background(
                            Brush.radialGradient(
                                listOf(
                                    Resonance.goldPrimary.copy(alpha = .15f),
                                    Color.Transparent,
                                )
                            )
                        ),
                )
            }

            // Main circle
            Box(
                modifier = Modifier
                    .size(if (isActive) (80 * scale).dp else 80.dp)
                    .clip(CircleShape)
                    .background(
                        Brush.radialGradient(
                            listOf(
                                Resonance.goldPrimary.copy(alpha = .6f),
                                Resonance.green700.copy(alpha = .4f),
                            )
                        )
                    )
                    .clickable(onClick = onToggle),
                contentAlignment = Alignment.Center,
            ) {
                if (!isActive) {
                    Icon(
                        Icons.Filled.PlayArrow,
                        contentDescription = "Start breathing",
                        tint = Color.White,
                        modifier = Modifier.size(32.dp),
                    )
                }
            }
        }

        Text(
            text = if (isActive) phase else "Tap to begin",
            style = MaterialTheme.typography.bodyLarge,
            color = Resonance.goldPrimary,
            textAlign = TextAlign.Center,
            modifier = Modifier.fillMaxWidth(),
        )

        if (isActive) {
            Spacer(Modifier.height(8.dp))
            TextButton(
                onClick = onToggle,
                modifier = Modifier.align(Alignment.CenterHorizontally),
            ) {
                Text("Stop")
            }
        }
    }
}

// ---------------------------------------------------------------------------
// Stats row
// ---------------------------------------------------------------------------

@Composable
fun StatsRow(streakDays: Int, isDark: Boolean) {
    val stats = listOf(
        Triple(Icons.Filled.LocalFireDepartment, "$streakDays days", "Streak"),
        Triple(Icons.Filled.MenuBook, "4 / 12", "Chapters"),
        Triple(Icons.Filled.EditNote, "23", "Entries"),
        Triple(Icons.Filled.Forum, "8", "Sessions"),
    )

    LazyRow(
        horizontalArrangement = Arrangement.spacedBy(12.dp),
    ) {
        items(stats) { (icon, value, label) ->
            Card(
                shape = RoundedCornerShape(16.dp),
                colors = CardDefaults.cardColors(
                    containerColor = LuminousThemeExt.colors.glassSurface,
                ),
                border = BorderStroke(1.dp, LuminousThemeExt.colors.glassBorder),
            ) {
                Column(
                    modifier = Modifier.padding(16.dp),
                    horizontalAlignment = Alignment.CenterHorizontally,
                ) {
                    Icon(
                        icon, contentDescription = label,
                        tint = Resonance.goldPrimary,
                        modifier = Modifier.size(24.dp),
                    )
                    Spacer(Modifier.height(8.dp))
                    Text(
                        text = value,
                        style = MaterialTheme.typography.titleMedium,
                        fontWeight = FontWeight.Bold,
                        color = MaterialTheme.colorScheme.onSurface,
                    )
                    Text(
                        text = label,
                        style = MaterialTheme.typography.labelSmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                    )
                }
            }
        }
    }
}

// ---------------------------------------------------------------------------
// Share prompt banner
// ---------------------------------------------------------------------------

@Composable
fun SharePromptBanner(isDark: Boolean, onTap: () -> Unit) {
    Card(
        onClick = onTap,
        shape = RoundedCornerShape(20.dp),
        colors = CardDefaults.cardColors(
            containerColor = if (isDark)
                Resonance.goldDark.copy(alpha = .15f)
            else
                Resonance.goldLight.copy(alpha = .35f),
        ),
        border = BorderStroke(
            1.dp,
            Brush.horizontalGradient(
                listOf(Resonance.goldDark.copy(alpha = .3f), Resonance.goldPrimary.copy(alpha = .3f))
            ),
        ),
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Icon(
                Icons.Filled.AutoAwesome,
                contentDescription = null,
                tint = Resonance.goldPrimary,
                modifier = Modifier.size(28.dp),
            )
            Spacer(Modifier.width(12.dp))
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = "Share your light",
                    style = MaterialTheme.typography.titleSmall,
                    color = Resonance.goldPrimary,
                )
                Text(
                    text = "Create beautiful cards from your journey to inspire others",
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                )
            }
            Icon(
                Icons.Filled.ArrowForward,
                contentDescription = null,
                tint = Resonance.goldPrimary,
                modifier = Modifier.size(20.dp),
            )
        }
    }
}

// ---------------------------------------------------------------------------
// Utility
// ---------------------------------------------------------------------------

private fun timeOfDayGreeting(): String {
    val hour = java.util.Calendar.getInstance().get(java.util.Calendar.HOUR_OF_DAY)
    return when {
        hour < 12 -> "morning"
        hour < 17 -> "afternoon"
        else      -> "evening"
    }
}
