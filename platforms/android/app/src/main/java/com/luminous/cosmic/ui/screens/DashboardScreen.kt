package com.luminous.cosmic.ui.screens

import androidx.compose.animation.*
import androidx.compose.animation.core.*
import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import java.time.LocalDate
import java.time.format.DateTimeFormatter

import com.luminous.cosmic.data.models.*
import com.luminous.cosmic.ui.components.*
import com.luminous.cosmic.ui.theme.*

@Composable
fun DashboardScreen(
    chart: NatalChart,
    dailyInsight: DailyInsight,
    isDarkTheme: Boolean,
    onToggleTheme: () -> Unit,
    onNavigateToChart: () -> Unit,
    onNavigateToReflection: () -> Unit,
    onNavigateToMeditation: () -> Unit,
    onNavigateToLibrary: () -> Unit
) {
    val moonIllumination = remember { ChartCalculator.calculateMoonIllumination() }
    val scrollState = rememberScrollState()

    CosmicBackground(isDarkTheme = isDarkTheme) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .statusBarsPadding()
                .navigationBarsPadding()
                .verticalScroll(scrollState)
        ) {
            // ── Top Bar ──
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 20.dp, vertical = 16.dp),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column {
                    Text(
                        text = "Welcome back,",
                        style = MaterialTheme.typography.bodyMedium,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                    Text(
                        text = chart.birthData.name.ifBlank { "Cosmic Traveler" },
                        style = MaterialTheme.typography.headlineSmall,
                        color = ResonanceColors.GoldPrimary,
                        fontWeight = FontWeight.Light
                    )
                }

                // Theme toggle
                IconButton(
                    onClick = onToggleTheme,
                    modifier = Modifier
                        .size(44.dp)
                        .clip(CircleShape)
                        .background(ResonanceColors.GoldPrimary.copy(alpha = 0.1f))
                ) {
                    Text(
                        text = if (isDarkTheme) "\u2600\uFE0F" else "\uD83C\uDF19",
                        fontSize = 20.sp
                    )
                }
            }

            // ── Date ──
            Text(
                text = LocalDate.now().format(DateTimeFormatter.ofPattern("EEEE, MMMM d, yyyy")),
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                modifier = Modifier.padding(horizontal = 20.dp)
            )

            Spacer(modifier = Modifier.height(24.dp))

            // ── Big Three Summary ──
            GlassCard(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 20.dp),
                cornerRadius = 24.dp
            ) {
                Column(
                    modifier = Modifier.padding(20.dp)
                ) {
                    Text(
                        text = "Your Cosmic Signature",
                        style = MaterialTheme.typography.titleSmall,
                        color = ResonanceColors.GoldPrimary,
                        fontWeight = FontWeight.SemiBold
                    )
                    Spacer(modifier = Modifier.height(16.dp))

                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceEvenly
                    ) {
                        BigThreeItem(
                            label = "Sun",
                            sign = chart.sunSign,
                            symbol = "\u2609"
                        )
                        BigThreeItem(
                            label = "Moon",
                            sign = chart.moonSign,
                            symbol = "\u263D"
                        )
                        BigThreeItem(
                            label = "Rising",
                            sign = chart.risingSign,
                            symbol = "ASC"
                        )
                    }
                }
            }

            Spacer(modifier = Modifier.height(20.dp))

            // ── Daily Insight Card ──
            GlassCard(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 20.dp),
                cornerRadius = 24.dp
            ) {
                Column(
                    modifier = Modifier.padding(20.dp)
                ) {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.SpaceBetween,
                        modifier = Modifier.fillMaxWidth()
                    ) {
                        Column {
                            Text(
                                text = dailyInsight.title,
                                style = MaterialTheme.typography.titleMedium,
                                color = ResonanceColors.GoldPrimary,
                                fontWeight = FontWeight.SemiBold
                            )
                            Text(
                                text = "Focus: ${dailyInsight.focusArea}",
                                style = MaterialTheme.typography.labelSmall,
                                color = MaterialTheme.colorScheme.onSurfaceVariant
                            )
                        }

                        MoonPhaseIndicator(
                            phase = dailyInsight.moonPhase,
                            illumination = moonIllumination,
                            size = 56.dp,
                            showLabel = false
                        )
                    }

                    Spacer(modifier = Modifier.height(14.dp))

                    Text(
                        text = dailyInsight.body,
                        style = MaterialTheme.typography.bodyMedium,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                        lineHeight = 22.sp
                    )

                    Spacer(modifier = Modifier.height(16.dp))

                    // Affirmation
                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .clip(RoundedCornerShape(12.dp))
                            .background(ResonanceColors.GoldPrimary.copy(alpha = 0.08f))
                            .padding(14.dp)
                    ) {
                        Text(
                            text = "\u201C${dailyInsight.affirmation}\u201D",
                            style = MaterialTheme.typography.bodyMedium,
                            color = ResonanceColors.GoldPrimary,
                            fontStyle = FontStyle.Italic,
                            textAlign = TextAlign.Center,
                            modifier = Modifier.fillMaxWidth()
                        )
                    }
                }
            }

            Spacer(modifier = Modifier.height(20.dp))

            // ── Moon Phase ──
            GlassCard(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 20.dp),
                cornerRadius = 24.dp
            ) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(20.dp),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    Column(modifier = Modifier.weight(1f)) {
                        Text(
                            text = "Current Moon",
                            style = MaterialTheme.typography.titleSmall,
                            color = ResonanceColors.GoldPrimary,
                            fontWeight = FontWeight.SemiBold
                        )
                        Spacer(modifier = Modifier.height(6.dp))
                        Text(
                            text = dailyInsight.moonPhase.displayName,
                            style = MaterialTheme.typography.headlineSmall,
                            color = MaterialTheme.colorScheme.onSurface,
                            fontWeight = FontWeight.Light
                        )
                        Spacer(modifier = Modifier.height(4.dp))
                        Text(
                            text = "${(moonIllumination * 100).toInt()}% illuminated",
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }

                    MoonPhaseIndicator(
                        phase = dailyInsight.moonPhase,
                        illumination = moonIllumination,
                        size = 72.dp,
                        showLabel = false
                    )
                }
            }

            Spacer(modifier = Modifier.height(20.dp))

            // ── Active Transits ──
            if (dailyInsight.transits.isNotEmpty()) {
                Text(
                    text = "Active Transits",
                    style = MaterialTheme.typography.titleSmall,
                    color = ResonanceColors.GoldPrimary,
                    fontWeight = FontWeight.SemiBold,
                    modifier = Modifier.padding(horizontal = 20.dp)
                )
                Spacer(modifier = Modifier.height(12.dp))

                dailyInsight.transits.take(3).forEach { transit ->
                    TransitCard(
                        transit = transit,
                        modifier = Modifier.padding(horizontal = 20.dp, vertical = 4.dp)
                    )
                }
            }

            Spacer(modifier = Modifier.height(24.dp))

            // ── Quick Actions Grid ──
            Text(
                text = "Explore",
                style = MaterialTheme.typography.titleSmall,
                color = ResonanceColors.GoldPrimary,
                fontWeight = FontWeight.SemiBold,
                modifier = Modifier.padding(horizontal = 20.dp)
            )
            Spacer(modifier = Modifier.height(12.dp))

            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 20.dp),
                horizontalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                QuickActionCard(
                    title = "Natal Chart",
                    icon = Icons.Outlined.Star,
                    modifier = Modifier.weight(1f),
                    onClick = onNavigateToChart
                )
                QuickActionCard(
                    title = "Reflections",
                    icon = Icons.Outlined.Edit,
                    modifier = Modifier.weight(1f),
                    onClick = onNavigateToReflection
                )
            }
            Spacer(modifier = Modifier.height(12.dp))
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 20.dp),
                horizontalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                QuickActionCard(
                    title = "Meditate",
                    icon = Icons.Outlined.Spa,
                    modifier = Modifier.weight(1f),
                    onClick = onNavigateToMeditation
                )
                QuickActionCard(
                    title = "Library",
                    icon = Icons.Outlined.MenuBook,
                    modifier = Modifier.weight(1f),
                    onClick = onNavigateToLibrary
                )
            }

            Spacer(modifier = Modifier.height(32.dp))
        }
    }
}

@Composable
private fun BigThreeItem(
    label: String,
    sign: ZodiacSign,
    symbol: String
) {
    Column(
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        val elementColor = when (sign.element) {
            Element.FIRE -> ResonanceColors.FireElement
            Element.EARTH -> ResonanceColors.EarthElement
            Element.AIR -> ResonanceColors.AirElement
            Element.WATER -> ResonanceColors.WaterElement
        }

        Box(
            modifier = Modifier
                .size(56.dp)
                .clip(CircleShape)
                .background(elementColor.copy(alpha = 0.12f)),
            contentAlignment = Alignment.Center
        ) {
            Text(
                text = sign.unicode,
                fontSize = 24.sp,
                color = elementColor
            )
        }
        Spacer(modifier = Modifier.height(8.dp))
        Text(
            text = label,
            style = MaterialTheme.typography.labelSmall,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
        Text(
            text = sign.symbol,
            style = MaterialTheme.typography.titleSmall,
            color = MaterialTheme.colorScheme.onSurface,
            fontWeight = FontWeight.SemiBold
        )
    }
}

@Composable
private fun QuickActionCard(
    title: String,
    icon: ImageVector,
    modifier: Modifier = Modifier,
    onClick: () -> Unit
) {
    GlassCard(
        modifier = modifier
            .height(100.dp)
            .clickable(onClick = onClick),
        cornerRadius = 18.dp
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(16.dp),
            verticalArrangement = Arrangement.Center,
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Icon(
                imageVector = icon,
                contentDescription = title,
                tint = ResonanceColors.GoldPrimary,
                modifier = Modifier.size(28.dp)
            )
            Spacer(modifier = Modifier.height(8.dp))
            Text(
                text = title,
                style = MaterialTheme.typography.labelMedium,
                color = MaterialTheme.colorScheme.onSurface,
                fontWeight = FontWeight.Medium
            )
        }
    }
}
