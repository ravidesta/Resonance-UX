package com.resonance.tv

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.core.FastOutSlowInEasing
import androidx.compose.animation.core.LinearEasing
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
import androidx.compose.foundation.focusable
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
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.FamilyRestroom
import androidx.compose.material.icons.filled.Pause
import androidx.compose.material.icons.filled.PlayArrow
import androidx.compose.material.icons.outlined.Air
import androidx.compose.material.icons.outlined.Audiotrack
import androidx.compose.material.icons.outlined.Explore
import androidx.compose.material.icons.outlined.FamilyRestroom
import androidx.compose.material.icons.outlined.Landscape
import androidx.compose.material.icons.outlined.MonitorHeart
import androidx.compose.material.icons.outlined.SelfImprovement
import androidx.compose.material.icons.outlined.Spa
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
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.focus.onFocusChanged
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.input.key.Key
import androidx.compose.ui.input.key.KeyEventType
import androidx.compose.ui.input.key.key
import androidx.compose.ui.input.key.onKeyEvent
import androidx.compose.ui.input.key.type
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.tv.foundation.lazy.list.TvLazyColumn
import androidx.tv.foundation.lazy.list.TvLazyRow
import androidx.tv.material3.Card
import androidx.tv.material3.CardDefaults
import androidx.tv.material3.ExperimentalTvMaterial3Api
import androidx.tv.material3.Icon
import androidx.tv.material3.MaterialTheme
import androidx.tv.material3.NavigationDrawer
import androidx.tv.material3.NavigationDrawerItem
import androidx.tv.material3.Surface
import androidx.tv.material3.Text
import kotlinx.coroutines.delay
import kotlin.math.PI
import kotlin.math.cos
import kotlin.math.sin

// ─────────────────────────────────────────────
// TV Colors
// ─────────────────────────────────────────────

private object TvColors {
    val Background = Color(0xFF05100B)
    val Surface = Color(0xFF0A1C14)
    val SurfaceElevated = Color(0xFF122E21)
    val Gold = Color(0xFFC5A059)
    val GoldBright = Color(0xFFD4B878)
    val Green700 = Color(0xFF1A4032)
    val Green500 = Color(0xFF3D7A5F)
    val Green400 = Color(0xFF4D9A7F)
    val TextPrimary = Color(0xFFFAFAF8)
    val TextSecondary = Color(0xFFA0B5A8)
    val TextMuted = Color(0xFF5C7065)
    val Success = Color(0xFF6BBF8A)
    val CardFocused = Color(0xFF1A4032)
}

// ─────────────────────────────────────────────
// Activity
// ─────────────────────────────────────────────

class ResonanceTVActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            ResonanceTVApp()
        }
    }
}

// ─────────────────────────────────────────────
// Main TV App (Leanback navigation)
// ─────────────────────────────────────────────

@OptIn(ExperimentalTvMaterial3Api::class)
@Composable
fun ResonanceTVApp() {
    var selectedSection by remember { mutableIntStateOf(0) }

    val sections = remember {
        listOf(
            TvSection("Ambient", Icons.Outlined.Landscape),
            TvSection("Retreats", Icons.Outlined.Spa),
            TvSection("Breathwork", Icons.Outlined.Air),
            TvSection("Family", Icons.Outlined.FamilyRestroom),
        )
    }

    Row(
        modifier = Modifier
            .fillMaxSize()
            .background(TvColors.Background),
    ) {
        // Navigation drawer
        TvNavigationDrawer(
            sections = sections,
            selectedIndex = selectedSection,
            onSelect = { selectedSection = it },
        )

        // Content area
        Box(
            modifier = Modifier
                .weight(1f)
                .fillMaxHeight()
                .padding(start = 24.dp, top = 48.dp, end = 48.dp, bottom = 48.dp),
        ) {
            when (selectedSection) {
                0 -> AmbientWellnessDisplay()
                1 -> RetreatContentBrowser()
                2 -> TvGuidedBreathwork()
                3 -> FamilyWellnessDashboard()
            }
        }
    }
}

data class TvSection(val title: String, val icon: ImageVector)

// ─────────────────────────────────────────────
// TV Navigation Drawer (Leanback pattern)
// ─────────────────────────────────────────────

@OptIn(ExperimentalTvMaterial3Api::class)
@Composable
private fun TvNavigationDrawer(
    sections: List<TvSection>,
    selectedIndex: Int,
    onSelect: (Int) -> Unit,
) {
    Surface(
        modifier = Modifier
            .width(80.dp)
            .fillMaxHeight(),
        shape = RoundedCornerShape(0.dp),
        colors = androidx.tv.material3.SurfaceDefaults.colors(
            containerColor = TvColors.Surface,
        ),
    ) {
        Column(
            modifier = Modifier
                .fillMaxHeight()
                .padding(vertical = 48.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            // Logo / brand mark
            Box(
                modifier = Modifier
                    .size(40.dp)
                    .drawBehind {
                        drawCircle(
                            brush = Brush.radialGradient(
                                colors = listOf(
                                    TvColors.Gold.copy(alpha = 0.3f),
                                    Color.Transparent,
                                )
                            ),
                        )
                    },
                contentAlignment = Alignment.Center,
            ) {
                Text(
                    text = "R",
                    fontSize = 18.sp,
                    fontWeight = FontWeight.Bold,
                    color = TvColors.Gold,
                )
            }

            Spacer(modifier = Modifier.height(32.dp))

            sections.forEachIndexed { index, section ->
                val isSelected = index == selectedIndex
                var isFocused by remember { mutableStateOf(false) }

                val bgAlpha by animateFloatAsState(
                    targetValue = when {
                        isSelected -> 0.2f
                        isFocused -> 0.1f
                        else -> 0f
                    },
                    label = "navItemBg"
                )

                Box(
                    modifier = Modifier
                        .size(56.dp)
                        .clip(RoundedCornerShape(12.dp))
                        .background(TvColors.Gold.copy(alpha = bgAlpha))
                        .onFocusChanged { isFocused = it.isFocused }
                        .focusable()
                        .onKeyEvent { event ->
                            if (event.type == KeyEventType.KeyDown && event.key == Key.DirectionCenter) {
                                onSelect(index)
                                true
                            } else false
                        },
                    contentAlignment = Alignment.Center,
                ) {
                    Icon(
                        imageVector = section.icon,
                        contentDescription = section.title,
                        modifier = Modifier.size(24.dp),
                        tint = if (isSelected || isFocused) TvColors.Gold else TvColors.TextMuted,
                    )
                }
            }
        }
    }
}

// ─────────────────────────────────────────────
// Ambient Wellness Display (Organic Blob Art)
// ─────────────────────────────────────────────

@OptIn(ExperimentalTvMaterial3Api::class)
@Composable
private fun AmbientWellnessDisplay() {
    val infiniteTransition = rememberInfiniteTransition(label = "ambientBlobs")

    val breathPhase by infiniteTransition.animateFloat(
        initialValue = 0f,
        targetValue = 1f,
        animationSpec = infiniteRepeatable(
            animation = tween(8000, easing = FastOutSlowInEasing),
            repeatMode = RepeatMode.Reverse,
        ),
        label = "breathPhase"
    )

    val rotation by infiniteTransition.animateFloat(
        initialValue = 0f,
        targetValue = 360f,
        animationSpec = infiniteRepeatable(
            animation = tween(60000, easing = LinearEasing),
            repeatMode = RepeatMode.Restart,
        ),
        label = "blobRotation"
    )

    val colorShift by infiniteTransition.animateFloat(
        initialValue = 0f,
        targetValue = 1f,
        animationSpec = infiniteRepeatable(
            animation = tween(20000, easing = FastOutSlowInEasing),
            repeatMode = RepeatMode.Reverse,
        ),
        label = "colorShift"
    )

    Box(modifier = Modifier.fillMaxSize()) {
        // Full-screen organic blob animation
        Canvas(modifier = Modifier.fillMaxSize()) {
            val centerX = size.width / 2
            val centerY = size.height / 2
            val baseRadius = size.minDimension / 3f

            // Multiple layered blobs
            for (layer in 0 until 4) {
                val layerOffset = layer * 0.3f
                val layerScale = 1f + layer * 0.15f + breathPhase * 0.1f
                val layerAlpha = 0.06f - layer * 0.012f

                val color = when (layer % 3) {
                    0 -> TvColors.Gold
                    1 -> TvColors.Green500
                    else -> TvColors.Green400
                }

                val path = Path()
                val points = 12
                val angleStep = (2f * PI / points).toFloat()

                for (i in 0..points) {
                    val angle = i * angleStep +
                            (rotation + layer * 30f) * PI.toFloat() / 180f
                    val noiseA = sin(angle * 3 + breathPhase * PI.toFloat() * 2 + layerOffset) * 0.2f
                    val noiseB = cos(angle * 2 - breathPhase * PI.toFloat() + layerOffset) * 0.1f
                    val r = baseRadius * layerScale * (1f + noiseA + noiseB)

                    val x = centerX + cos(angle) * r
                    val y = centerY + sin(angle) * r

                    if (i == 0) path.moveTo(x, y) else path.lineTo(x, y)
                }
                path.close()

                drawPath(
                    path = path,
                    brush = Brush.radialGradient(
                        colors = listOf(
                            color.copy(alpha = layerAlpha * (1f + colorShift * 0.5f)),
                            color.copy(alpha = layerAlpha * 0.2f),
                            Color.Transparent,
                        ),
                        center = Offset(centerX, centerY),
                        radius = baseRadius * layerScale * 1.3f,
                    ),
                )
            }
        }

        // Wellness info overlay (bottom)
        Column(
            modifier = Modifier
                .align(Alignment.BottomStart)
                .padding(48.dp),
        ) {
            Text(
                text = "Ambient Wellness",
                fontSize = 28.sp,
                fontWeight = FontWeight.Light,
                color = TvColors.TextPrimary.copy(alpha = 0.8f),
            )
            Spacer(modifier = Modifier.height(8.dp))
            Row(horizontalArrangement = Arrangement.spacedBy(24.dp)) {
                AmbientMetric("Spaciousness", "72%", TvColors.Gold)
                AmbientMetric("HRV", "42ms", TvColors.Green500)
                AmbientMetric("Phase", "Descent", TvColors.GoldBright)
            }
        }

        // Time display (top right)
        Text(
            text = "7:42 PM",
            fontSize = 20.sp,
            fontWeight = FontWeight.Light,
            color = TvColors.TextPrimary.copy(alpha = 0.5f),
            modifier = Modifier
                .align(Alignment.TopEnd)
                .padding(48.dp),
        )
    }
}

@Composable
private fun AmbientMetric(label: String, value: String, color: Color) {
    Column {
        Text(
            text = value,
            fontSize = 22.sp,
            fontWeight = FontWeight.SemiBold,
            color = color.copy(alpha = 0.9f),
        )
        Text(
            text = label,
            fontSize = 12.sp,
            color = TvColors.TextMuted,
        )
    }
}

// ─────────────────────────────────────────────
// Immersive Retreat Content Browser
// ─────────────────────────────────────────────

@OptIn(ExperimentalTvMaterial3Api::class)
@Composable
private fun RetreatContentBrowser() {
    val categories = remember {
        listOf(
            RetreatCategory("Featured Retreats", listOf(
                RetreatItem("Mountain Silence", "7-day meditation retreat", "Quiet Mountain, CO", "4.9"),
                RetreatItem("Ocean Resonance", "Breathwork & cold exposure", "Big Sur, CA", "4.8"),
                RetreatItem("Forest Bathing", "Sensory immersion in nature", "Asheville, NC", "4.7"),
            )),
            RetreatCategory("Guided Experiences", listOf(
                RetreatItem("Nervous System Reset", "90-min guided regulation", "At Home", "4.9"),
                RetreatItem("Deep Rest Yoga Nidra", "45-min guided sleep", "At Home", "4.8"),
                RetreatItem("Morning Ascend Ritual", "30-min energizing flow", "At Home", "4.7"),
                RetreatItem("Evening Descent", "60-min wind down", "At Home", "4.6"),
            )),
            RetreatCategory("Nature Soundscapes", listOf(
                RetreatItem("Rain on Canopy", "Tropical forest ambiance", "3h 00m", "4.9"),
                RetreatItem("Coastal Dawn", "Waves and seabirds", "2h 30m", "4.8"),
                RetreatItem("Mountain Stream", "Alpine water and wind", "4h 00m", "4.7"),
            )),
        )
    }

    LazyColumn(
        verticalArrangement = Arrangement.spacedBy(32.dp),
    ) {
        items(categories) { category ->
            Column {
                Text(
                    text = category.title,
                    fontSize = 20.sp,
                    fontWeight = FontWeight.SemiBold,
                    color = TvColors.TextPrimary,
                )
                Spacer(modifier = Modifier.height(12.dp))

                LazyRow(
                    horizontalArrangement = Arrangement.spacedBy(16.dp),
                ) {
                    items(category.items) { item ->
                        RetreatCard(item = item)
                    }
                }
            }
        }
    }
}

data class RetreatCategory(val title: String, val items: List<RetreatItem>)
data class RetreatItem(val title: String, val subtitle: String, val location: String, val rating: String)

@OptIn(ExperimentalTvMaterial3Api::class)
@Composable
private fun RetreatCard(item: RetreatItem) {
    var isFocused by remember { mutableStateOf(false) }

    val scale by animateFloatAsState(
        targetValue = if (isFocused) 1.05f else 1f,
        animationSpec = tween(200),
        label = "cardScale"
    )

    Card(
        onClick = { },
        modifier = Modifier
            .width(280.dp)
            .height(180.dp)
            .graphicsLayer {
                scaleX = scale
                scaleY = scale
            }
            .onFocusChanged { isFocused = it.isFocused },
        colors = CardDefaults.colors(
            containerColor = if (isFocused) TvColors.CardFocused else TvColors.Surface,
        ),
        shape = CardDefaults.shape(RoundedCornerShape(16.dp)),
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(20.dp),
            verticalArrangement = Arrangement.SpaceBetween,
        ) {
            Column {
                Text(
                    text = item.title,
                    fontSize = 18.sp,
                    fontWeight = FontWeight.SemiBold,
                    color = if (isFocused) TvColors.Gold else TvColors.TextPrimary,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                )
                Spacer(modifier = Modifier.height(4.dp))
                Text(
                    text = item.subtitle,
                    fontSize = 13.sp,
                    color = TvColors.TextSecondary,
                    maxLines = 2,
                    overflow = TextOverflow.Ellipsis,
                )
            }

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically,
            ) {
                Text(
                    text = item.location,
                    fontSize = 11.sp,
                    color = TvColors.TextMuted,
                )
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Text(
                        text = "\u2605 ",
                        fontSize = 12.sp,
                        color = TvColors.Gold,
                    )
                    Text(
                        text = item.rating,
                        fontSize = 12.sp,
                        color = TvColors.Gold,
                    )
                }
            }
        }
    }
}

// ─────────────────────────────────────────────
// Guided Breathwork (Remote Navigation)
// ─────────────────────────────────────────────

@OptIn(ExperimentalTvMaterial3Api::class)
@Composable
private fun TvGuidedBreathwork() {
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
        label = "tvBreathScale"
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
    ) {
        Text(
            text = "Guided Breathwork",
            fontSize = 24.sp,
            fontWeight = FontWeight.Light,
            color = TvColors.TextPrimary,
        )
        Text(
            text = "4-4-6-2 Calming Pattern",
            fontSize = 14.sp,
            color = TvColors.TextSecondary,
        )

        Spacer(modifier = Modifier.height(48.dp))

        // Large breathing circle
        Box(
            modifier = Modifier
                .size(300.dp)
                .focusable()
                .onKeyEvent { event ->
                    if (event.type == KeyEventType.KeyDown && event.key == Key.DirectionCenter) {
                        isActive = !isActive
                        true
                    } else false
                },
            contentAlignment = Alignment.Center,
        ) {
            Canvas(modifier = Modifier.fillMaxSize()) {
                val center = Offset(size.width / 2, size.height / 2)
                val maxRadius = size.minDimension / 2 * 0.85f
                val currentRadius = maxRadius * circleScale

                // Outer glow layers
                for (i in 0 until 3) {
                    val glowRadius = currentRadius * (1.1f + i * 0.15f)
                    val glowAlpha = 0.05f - i * 0.015f
                    drawCircle(
                        brush = Brush.radialGradient(
                            colors = listOf(
                                TvColors.Gold.copy(alpha = glowAlpha),
                                Color.Transparent,
                            ),
                            center = center,
                            radius = glowRadius,
                        ),
                    )
                }

                // Main circle
                drawCircle(
                    brush = Brush.radialGradient(
                        colors = listOf(
                            TvColors.Gold.copy(alpha = 0.15f),
                            TvColors.Gold.copy(alpha = 0.03f),
                        ),
                        center = center,
                        radius = currentRadius,
                    ),
                )

                // Ring
                drawCircle(
                    color = TvColors.Gold.copy(alpha = 0.3f),
                    radius = currentRadius,
                    center = center,
                    style = Stroke(width = 2f),
                )

                // Progress arc
                if (isActive) {
                    drawArc(
                        color = TvColors.Gold.copy(alpha = 0.7f),
                        startAngle = -90f,
                        sweepAngle = 360f * progress,
                        useCenter = false,
                        style = Stroke(width = 4f, cap = StrokeCap.Round),
                        topLeft = Offset(center.x - currentRadius, center.y - currentRadius),
                        size = androidx.compose.ui.geometry.Size(currentRadius * 2, currentRadius * 2),
                    )
                }
            }

            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                Text(
                    text = if (isActive) phase else "Press Select",
                    fontSize = 28.sp,
                    fontWeight = FontWeight.Medium,
                    color = TvColors.Gold,
                )
                if (isActive) {
                    Text(
                        text = "Cycle $cycleCount",
                        fontSize = 14.sp,
                        color = TvColors.TextMuted,
                    )
                } else {
                    Text(
                        text = "to begin",
                        fontSize = 14.sp,
                        color = TvColors.TextMuted,
                    )
                }
            }
        }

        Spacer(modifier = Modifier.height(32.dp))

        // Instructions
        Row(
            horizontalArrangement = Arrangement.spacedBy(32.dp),
        ) {
            BreathPhaseInfo("Inhale", "4s", TvColors.Gold)
            BreathPhaseInfo("Hold", "4s", TvColors.Green500)
            BreathPhaseInfo("Exhale", "6s", TvColors.GoldBright)
            BreathPhaseInfo("Rest", "2s", TvColors.Green700)
        }
    }
}

@Composable
private fun BreathPhaseInfo(label: String, duration: String, color: Color) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Box(
            modifier = Modifier
                .size(8.dp)
                .clip(CircleShape)
                .background(color),
        )
        Spacer(modifier = Modifier.height(4.dp))
        Text(text = label, fontSize = 12.sp, color = TvColors.TextSecondary)
        Text(text = duration, fontSize = 14.sp, fontWeight = FontWeight.Medium, color = color)
    }
}

// ─────────────────────────────────────────────
// Family Wellness Dashboard
// ─────────────────────────────────────────────

@OptIn(ExperimentalTvMaterial3Api::class)
@Composable
private fun FamilyWellnessDashboard() {
    val familyMembers = remember {
        listOf(
            FamilyMember("You", "Descent Phase", 0.72f, 72, "Available", TvColors.Gold),
            FamilyMember("Elena", "Rest Phase", 0.85f, 65, "Recharging", TvColors.Green500),
            FamilyMember("Marcus", "Zenith Phase", 0.58f, 80, "In flow", TvColors.GoldBright),
            FamilyMember("Aria", "Ascend Phase", 0.68f, 70, "Open to connect", TvColors.Green400),
        )
    }

    Column(modifier = Modifier.fillMaxSize()) {
        Text(
            text = "Family Wellness",
            fontSize = 24.sp,
            fontWeight = FontWeight.Light,
            color = TvColors.TextPrimary,
        )
        Text(
            text = "Everyone's rhythm at a glance",
            fontSize = 14.sp,
            color = TvColors.TextSecondary,
        )

        Spacer(modifier = Modifier.height(32.dp))

        // Grid of family member cards
        LazyRow(
            horizontalArrangement = Arrangement.spacedBy(20.dp),
        ) {
            items(familyMembers) { member ->
                FamilyMemberCard(member = member)
            }
        }

        Spacer(modifier = Modifier.height(32.dp))

        // Family insights
        Surface(
            modifier = Modifier.fillMaxWidth(),
            shape = RoundedCornerShape(16.dp),
            colors = androidx.tv.material3.SurfaceDefaults.colors(
                containerColor = TvColors.Surface,
            ),
        ) {
            Column(modifier = Modifier.padding(24.dp)) {
                Text(
                    text = "Family Insights",
                    fontSize = 16.sp,
                    fontWeight = FontWeight.Medium,
                    color = TvColors.TextPrimary,
                )
                Spacer(modifier = Modifier.height(12.dp))

                InsightRow("Average spaciousness today:", "71%", TvColors.Gold)
                InsightRow("Family members in rest:", "1 of 4", TvColors.Green500)
                InsightRow("Shared breathwork sessions:", "2 this week", TvColors.GoldBright)
                InsightRow("Family wellness streak:", "12 days", TvColors.Success)
            }
        }
    }
}

data class FamilyMember(
    val name: String,
    val phase: String,
    val spaciousness: Float,
    val heartRate: Int,
    val status: String,
    val color: Color,
)

@OptIn(ExperimentalTvMaterial3Api::class)
@Composable
private fun FamilyMemberCard(member: FamilyMember) {
    var isFocused by remember { mutableStateOf(false) }

    val scale by animateFloatAsState(
        targetValue = if (isFocused) 1.05f else 1f,
        label = "memberScale"
    )

    Card(
        onClick = { },
        modifier = Modifier
            .width(220.dp)
            .height(240.dp)
            .graphicsLayer { scaleX = scale; scaleY = scale }
            .onFocusChanged { isFocused = it.isFocused },
        colors = CardDefaults.colors(
            containerColor = if (isFocused) TvColors.CardFocused else TvColors.Surface,
        ),
        shape = CardDefaults.shape(RoundedCornerShape(16.dp)),
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(20.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            // Avatar
            Box(
                modifier = Modifier
                    .size(48.dp)
                    .clip(CircleShape)
                    .background(member.color.copy(alpha = 0.15f)),
                contentAlignment = Alignment.Center,
            ) {
                Text(
                    text = member.name.first().toString(),
                    fontSize = 20.sp,
                    fontWeight = FontWeight.SemiBold,
                    color = member.color,
                )
            }

            Spacer(modifier = Modifier.height(8.dp))

            Text(
                text = member.name,
                fontSize = 16.sp,
                fontWeight = FontWeight.SemiBold,
                color = TvColors.TextPrimary,
            )
            Text(
                text = member.status,
                fontSize = 11.sp,
                color = member.color.copy(alpha = 0.8f),
            )

            Spacer(modifier = Modifier.height(12.dp))

            // Mini spaciousness gauge
            Box(modifier = Modifier.size(50.dp)) {
                Canvas(modifier = Modifier.fillMaxSize()) {
                    val strokePx = 4f
                    drawArc(
                        color = member.color.copy(alpha = 0.15f),
                        startAngle = 135f,
                        sweepAngle = 270f,
                        useCenter = false,
                        style = Stroke(strokePx, cap = StrokeCap.Round),
                    )
                    drawArc(
                        color = member.color,
                        startAngle = 135f,
                        sweepAngle = 270f * member.spaciousness,
                        useCenter = false,
                        style = Stroke(strokePx, cap = StrokeCap.Round),
                    )
                }
            }

            Spacer(modifier = Modifier.height(4.dp))

            Text(
                text = member.phase,
                fontSize = 10.sp,
                color = TvColors.TextMuted,
            )
            Text(
                text = "${member.heartRate} bpm",
                fontSize = 12.sp,
                color = TvColors.TextSecondary,
            )
        }
    }
}

@Composable
private fun InsightRow(label: String, value: String, color: Color) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 4.dp),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Text(
            text = label,
            fontSize = 13.sp,
            color = TvColors.TextSecondary,
        )
        Text(
            text = value,
            fontSize = 14.sp,
            fontWeight = FontWeight.SemiBold,
            color = color,
        )
    }
}
