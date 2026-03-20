// MARK: - Luminous Journey™ Android Home Screen
// Jetpack Compose • Material 3 • Resonance-UX Design

package com.luminous.journey.ui.home

import androidx.compose.animation.core.*
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.outlined.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.blur
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.luminous.journey.ui.theme.LuminousColors
import com.luminous.journey.ui.theme.CormorantGaramond
import com.luminous.journey.ui.theme.Manrope

@Composable
fun HomeScreen(
    onNavigateToLearn: () -> Unit = {},
    onNavigateToListen: () -> Unit = {},
    onNavigateToPractice: () -> Unit = {},
    onNavigateToJournal: () -> Unit = {},
    onNavigateToGuide: () -> Unit = {},
    onNavigateToCommunity: () -> Unit = {},
) {
    // Breathing animation
    val infiniteTransition = rememberInfiniteTransition(label = "breathe")
    val breathScale by infiniteTransition.animateFloat(
        initialValue = 1f,
        targetValue = 1.15f,
        animationSpec = infiniteRepeatable(
            animation = tween(durationMillis = 9000, easing = EaseInOut),
            repeatMode = RepeatMode.Reverse
        ),
        label = "breathScale"
    )

    LazyColumn(
        modifier = Modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background),
        contentPadding = PaddingValues(horizontal = 20.dp, vertical = 24.dp),
        verticalArrangement = Arrangement.spacedBy(24.dp)
    ) {
        // Header with breathing blob
        item {
            Box(
                modifier = Modifier.fillMaxWidth(),
                contentAlignment = Alignment.Center
            ) {
                // Organic breathing blob
                Box(
                    modifier = Modifier
                        .size(240.dp)
                        .scale(breathScale)
                        .blur(40.dp)
                        .clip(CircleShape)
                        .background(
                            Brush.radialGradient(
                                colors = listOf(
                                    LuminousColors.GoldPrimary.copy(alpha = 0.15f),
                                    LuminousColors.ForestBase.copy(alpha = 0.05f),
                                    Color.Transparent,
                                )
                            )
                        )
                )

                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Text(
                        text = "Luminous Journey",
                        style = MaterialTheme.typography.headlineLarge,
                        color = MaterialTheme.colorScheme.onBackground,
                    )
                    Spacer(modifier = Modifier.height(4.dp))
                    Text(
                        text = "Season of Emergence",
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                    )
                }
            }
        }

        // Somatic Check-In Card
        item {
            GlassCard {
                Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                    SectionLabel(icon = Icons.Outlined.Waves, text = "SOMATIC CHECK-IN")

                    Text(
                        text = "What new sensations or patterns are you beginning to notice?",
                        style = MaterialTheme.typography.headlineSmall,
                        color = MaterialTheme.colorScheme.onBackground,
                    )

                    Button(
                        onClick = onNavigateToJournal,
                        colors = ButtonDefaults.buttonColors(
                            containerColor = LuminousColors.ForestBase,
                            contentColor = LuminousColors.Cream,
                        ),
                        shape = RoundedCornerShape(24.dp),
                    ) {
                        Text("Reflect", style = MaterialTheme.typography.bodyMedium)
                    }
                }
            }
        }

        // Continue Reading/Listening
        item {
            GlassCard {
                Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                    SectionLabel(icon = Icons.Outlined.Bookmark, text = "CONTINUE")

                    ContinueRow(
                        icon = Icons.Outlined.Book,
                        title = "Chapter 2: Subject-Object Dynamics",
                        subtitle = "42% complete",
                        onClick = onNavigateToLearn,
                    )

                    ContinueRow(
                        icon = Icons.Outlined.Headphones,
                        title = "Ch. 1: Theoretical Foundations",
                        subtitle = "1h 23m remaining",
                        onClick = onNavigateToListen,
                        trailing = {
                            Icon(
                                Icons.Filled.PlayCircleFilled,
                                contentDescription = "Play",
                                tint = LuminousColors.GoldPrimary,
                                modifier = Modifier.size(28.dp)
                            )
                        }
                    )
                }
            }
        }

        // Today's Practice
        item {
            GlassCard {
                Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                    SectionLabel(icon = Icons.Outlined.SelfImprovement, text = "TODAY'S PRACTICE")

                    Text(
                        text = "Body Listening",
                        style = MaterialTheme.typography.headlineSmall,
                        color = MaterialTheme.colorScheme.onBackground,
                    )
                    Text(
                        text = "8 minutes · Body Scan · Season of Emergence",
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                    )
                    Text(
                        text = "Tuning into the new patterns that are beginning to take shape in the body.",
                        style = MaterialTheme.typography.bodyMedium,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                    )
                }
            }
        }

        // Guide Invitation
        item {
            GlassCard(
                modifier = Modifier.clickable(onClick = onNavigateToGuide)
            ) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(16.dp),
                    verticalAlignment = Alignment.CenterVertically,
                ) {
                    Icon(
                        Icons.Outlined.Forum,
                        contentDescription = null,
                        tint = LuminousColors.GoldPrimary,
                        modifier = Modifier.size(32.dp)
                    )

                    Column(modifier = Modifier.weight(1f)) {
                        Text(
                            text = "Talk with your Guide",
                            style = MaterialTheme.typography.headlineSmall,
                            color = MaterialTheme.colorScheme.onBackground,
                        )
                        Text(
                            text = "Explore what's alive in you right now",
                            style = MaterialTheme.typography.bodyMedium,
                            color = MaterialTheme.colorScheme.onSurfaceVariant,
                        )
                    }

                    Icon(
                        Icons.Filled.ChevronRight,
                        contentDescription = null,
                        tint = LuminousColors.TextMuted,
                    )
                }
            }
        }

        // Ecosystem Connections
        item {
            GlassCard {
                Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                    SectionLabel(icon = Icons.Outlined.Link, text = "RESONANCE ECOSYSTEM")

                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceEvenly,
                    ) {
                        EcosystemChip("Daily Flow", Icons.Outlined.Schedule, connected = true)
                        EcosystemChip("Resonance", Icons.Outlined.Message, connected = true)
                        EcosystemChip("Writer", Icons.Outlined.Edit, connected = false)
                        EcosystemChip("Provider", Icons.Outlined.MedicalServices, connected = false)
                    }
                }
            }
        }
    }
}

// ─── Reusable Components ─────────────────────────────────────────────────

@Composable
fun GlassCard(
    modifier: Modifier = Modifier,
    content: @Composable ColumnScope.() -> Unit
) {
    Card(
        modifier = modifier.fillMaxWidth(),
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.surface.copy(alpha = 0.72f),
        ),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp),
        border = CardDefaults.outlinedCardBorder().takeIf { false }, // subtle gold border
    ) {
        Column(
            modifier = Modifier.padding(20.dp),
            content = content
        )
    }
}

@Composable
fun SectionLabel(icon: ImageVector, text: String) {
    Row(
        horizontalArrangement = Arrangement.spacedBy(6.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Icon(
            icon,
            contentDescription = null,
            tint = LuminousColors.GoldPrimary,
            modifier = Modifier.size(16.dp)
        )
        Text(
            text = text,
            style = MaterialTheme.typography.labelLarge,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
        )
    }
}

@Composable
fun ContinueRow(
    icon: ImageVector,
    title: String,
    subtitle: String,
    onClick: () -> Unit,
    trailing: @Composable (() -> Unit)? = null,
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clickable(onClick = onClick),
        horizontalArrangement = Arrangement.spacedBy(12.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Icon(icon, contentDescription = null, tint = LuminousColors.ForestBase)
        Column(modifier = Modifier.weight(1f)) {
            Text(title, style = MaterialTheme.typography.bodyMedium, color = MaterialTheme.colorScheme.onBackground)
            Text(subtitle, style = MaterialTheme.typography.bodySmall, color = MaterialTheme.colorScheme.onSurfaceVariant)
        }
        trailing?.invoke() ?: Icon(Icons.Filled.ChevronRight, contentDescription = null, tint = LuminousColors.TextMuted)
    }
}

@Composable
fun EcosystemChip(name: String, icon: ImageVector, connected: Boolean) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Icon(
            icon,
            contentDescription = name,
            tint = if (connected) LuminousColors.GoldPrimary else LuminousColors.TextMuted,
            modifier = Modifier.size(20.dp)
        )
        Spacer(modifier = Modifier.height(4.dp))
        Text(
            text = name,
            style = MaterialTheme.typography.labelSmall,
            color = if (connected) MaterialTheme.colorScheme.onSurfaceVariant else LuminousColors.TextMuted,
        )
        Spacer(modifier = Modifier.height(4.dp))
        Box(
            modifier = Modifier
                .size(6.dp)
                .clip(CircleShape)
                .background(if (connected) LuminousColors.GoldPrimary else LuminousColors.TextMuted.copy(alpha = 0.3f))
        )
    }
}
