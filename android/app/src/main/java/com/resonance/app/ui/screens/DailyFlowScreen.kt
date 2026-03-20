package com.resonance.app.ui.screens

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.Spring
import androidx.compose.animation.core.animateDpAsState
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.spring
import androidx.compose.animation.core.tween
import androidx.compose.animation.expandVertically
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.shrinkVertically
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.gestures.detectDragGesturesAfterLongPress
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.DragIndicator
import androidx.compose.material.icons.outlined.Bolt
import androidx.compose.material.icons.outlined.CheckCircleOutline
import androidx.compose.material.icons.outlined.Timer
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.FloatingActionButton
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.SwipeToDismissBox
import androidx.compose.material3.SwipeToDismissBoxValue
import androidx.compose.material3.Text
import androidx.compose.material3.rememberSwipeToDismissBoxState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.derivedStateOf
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableFloatStateOf
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateListOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.IntOffset
import androidx.compose.ui.unit.dp
import com.resonance.app.data.models.DailyPhase
import com.resonance.app.data.models.Domain
import com.resonance.app.data.models.EnergyLevel
import com.resonance.app.data.models.PhaseType
import com.resonance.app.data.models.Task
import com.resonance.app.data.models.TimelineEvent
import com.resonance.app.data.models.TimelineEventType
import com.resonance.app.ui.components.EnergyLevelIndicator
import com.resonance.app.ui.components.GlassMorphismCard
import com.resonance.app.ui.components.PhaseIndicator
import com.resonance.app.ui.components.SpaciousnessGauge
import com.resonance.app.ui.theme.ResonanceColors
import com.resonance.app.ui.theme.ResonanceTheme
import kotlinx.coroutines.launch
import java.time.LocalTime
import java.time.format.DateTimeFormatter
import kotlin.math.roundToInt

@Composable
fun DailyFlowScreen() {
    val spacing = ResonanceTheme.spacing
    val listState = rememberLazyListState()
    val scope = rememberCoroutineScope()
    val haptic = LocalHapticFeedback.current

    val currentHour = remember { LocalTime.now().hour }
    val activePhaseIndex = remember {
        when (currentHour) {
            in 5..10 -> 0
            in 11..14 -> 1
            in 15..19 -> 2
            else -> 3
        }
    }

    val phases = remember {
        listOf(
            DailyPhase(PhaseType.ASCEND, "06:00", "11:00", 3, 0.75f, activePhaseIndex == 0, 2, 4),
            DailyPhase(PhaseType.ZENITH, "11:00", "15:00", 4, 0.6f, activePhaseIndex == 1, 1, 3),
            DailyPhase(PhaseType.DESCENT, "15:00", "20:00", 2, 0.8f, activePhaseIndex == 2, 0, 3),
            DailyPhase(PhaseType.REST, "20:00", "06:00", 1, 0.9f, activePhaseIndex == 3, 0, 1),
        )
    }

    val tasks = remember {
        mutableStateListOf(
            Task(title = "Morning meditation", domain = Domain.HEALTH.name, energyCost = 1,
                assignedPhase = PhaseType.ASCEND.name, estimatedMinutes = 15, order = 0),
            Task(title = "Review design system tokens", domain = Domain.WORK.name, energyCost = 3,
                assignedPhase = PhaseType.ASCEND.name, estimatedMinutes = 45, order = 1),
            Task(title = "Write chapter outline", domain = Domain.CREATIVE.name, energyCost = 3,
                assignedPhase = PhaseType.ASCEND.name, estimatedMinutes = 60, order = 2),
            Task(title = "Deep focus: architecture review", domain = Domain.WORK.name, energyCost = 4,
                assignedPhase = PhaseType.ZENITH.name, estimatedMinutes = 90, order = 3),
            Task(title = "Team sync", domain = Domain.WORK.name, energyCost = 2,
                assignedPhase = PhaseType.ZENITH.name, estimatedMinutes = 30, order = 4),
            Task(title = "Respond to letters", domain = Domain.RELATIONSHIPS.name, energyCost = 2,
                assignedPhase = PhaseType.DESCENT.name, estimatedMinutes = 20, order = 5),
            Task(title = "Gentle walk", domain = Domain.HEALTH.name, energyCost = 1,
                assignedPhase = PhaseType.DESCENT.name, estimatedMinutes = 30, order = 6),
            Task(title = "Evening reflection", domain = Domain.PERSONAL.name, energyCost = 1,
                assignedPhase = PhaseType.REST.name, estimatedMinutes = 15, order = 7),
        )
    }

    var spaciousnessValue by remember { mutableFloatStateOf(0.72f) }
    var intentionText by remember { mutableStateOf("Move with clarity and calm") }

    val totalEnergy by remember {
        derivedStateOf {
            tasks.filter { !it.isCompleted }.sumOf { it.energyCost }
        }
    }

    val completedCount by remember {
        derivedStateOf { tasks.count { it.isCompleted } }
    }

    Box(modifier = Modifier.fillMaxSize()) {
        LazyColumn(
            state = listState,
            contentPadding = PaddingValues(bottom = 100.dp),
            modifier = Modifier.fillMaxSize(),
        ) {
            // Header: Intention & Spaciousness
            item(key = "header") {
                DailyFlowHeader(
                    intention = intentionText,
                    spaciousness = spaciousnessValue,
                    completedCount = completedCount,
                    totalCount = tasks.size,
                    totalEnergy = totalEnergy,
                )
            }

            // Phase indicator
            item(key = "phaseIndicator") {
                PhaseIndicator(
                    phases = PhaseType.entries.map { it.displayName },
                    activePhaseIndex = activePhaseIndex,
                    modifier = Modifier.padding(horizontal = spacing.screenPadding, vertical = spacing.md),
                )
            }

            // Phase sections with tasks
            PhaseType.entries.forEachIndexed { phaseIndex, phaseType ->
                val phaseTasks = tasks.filter { it.assignedPhase == phaseType.name }
                val phase = phases[phaseIndex]

                // Sticky phase header
                stickyHeader(key = "phase_${phaseType.name}") {
                    PhaseHeader(
                        phase = phase,
                        phaseType = phaseType,
                        taskCount = phaseTasks.size,
                        isActive = phaseIndex == activePhaseIndex,
                    )
                }

                // Tasks within this phase
                items(
                    items = phaseTasks,
                    key = { it.id }
                ) { task ->
                    TaskCard(
                        task = task,
                        onToggleComplete = {
                            val index = tasks.indexOfFirst { it.id == task.id }
                            if (index >= 0) {
                                haptic.performHapticFeedback(HapticFeedbackType.LongPress)
                                tasks[index] = task.copy(isCompleted = !task.isCompleted)
                            }
                        },
                        onDismiss = {
                            tasks.removeAll { it.id == task.id }
                        },
                        modifier = Modifier
                            .padding(horizontal = spacing.screenPadding, vertical = spacing.xs)
                            .animateItem(),
                    )
                }

                // Phase spacer
                item(key = "spacer_${phaseType.name}") {
                    Spacer(modifier = Modifier.height(spacing.lg))
                }
            }
        }

        // Floating Add Button
        FloatingActionButton(
            onClick = { haptic.performHapticFeedback(HapticFeedbackType.LongPress) },
            modifier = Modifier
                .align(Alignment.BottomEnd)
                .padding(spacing.screenPadding),
            containerColor = ResonanceColors.Gold,
            contentColor = ResonanceColors.Green900,
            shape = CircleShape,
        ) {
            Icon(Icons.Filled.Add, contentDescription = "Add task")
        }
    }
}

// ─────────────────────────────────────────────
// Daily Flow Header
// ─────────────────────────────────────────────

@Composable
private fun DailyFlowHeader(
    intention: String,
    spaciousness: Float,
    completedCount: Int,
    totalCount: Int,
    totalEnergy: Int,
) {
    val spacing = ResonanceTheme.spacing

    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = spacing.screenPadding)
            .padding(top = spacing.md),
    ) {
        // Intention
        GlassMorphismCard(
            modifier = Modifier.fillMaxWidth(),
        ) {
            Column(
                modifier = Modifier.padding(spacing.cardPadding),
            ) {
                Text(
                    text = "Today's Intention",
                    style = MaterialTheme.typography.labelMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                )
                Spacer(modifier = Modifier.height(spacing.xs))
                Text(
                    text = intention,
                    style = MaterialTheme.typography.headlineSmall,
                    color = MaterialTheme.colorScheme.onBackground,
                )
            }
        }

        Spacer(modifier = Modifier.height(spacing.lg))

        // Metrics row
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceEvenly,
            verticalAlignment = Alignment.CenterVertically,
        ) {
            // Spaciousness gauge
            SpaciousnessGauge(
                value = spaciousness,
                size = 100.dp,
                strokeWidth = 6.dp,
            )

            // Stats column
            Column(
                verticalArrangement = Arrangement.spacedBy(spacing.md),
            ) {
                MetricRow(
                    label = "Completed",
                    value = "$completedCount / $totalCount",
                    color = ResonanceColors.Success,
                )
                MetricRow(
                    label = "Energy Budget",
                    value = "$totalEnergy units",
                    color = ResonanceColors.Gold,
                )
                MetricRow(
                    label = "Focus Time",
                    value = "3h 15m",
                    color = ResonanceColors.Green600,
                )
            }
        }
    }
}

@Composable
private fun MetricRow(
    label: String,
    value: String,
    color: Color,
) {
    Row(verticalAlignment = Alignment.CenterVertically) {
        Box(
            modifier = Modifier
                .size(8.dp)
                .clip(CircleShape)
                .background(color)
        )
        Spacer(modifier = Modifier.width(8.dp))
        Column {
            Text(
                text = label,
                style = MaterialTheme.typography.labelSmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
            )
            Text(
                text = value,
                style = MaterialTheme.typography.titleSmall,
                color = MaterialTheme.colorScheme.onBackground,
            )
        }
    }
}

// ─────────────────────────────────────────────
// Phase Header
// ─────────────────────────────────────────────

@Composable
private fun PhaseHeader(
    phase: DailyPhase,
    phaseType: PhaseType,
    taskCount: Int,
    isActive: Boolean,
) {
    val spacing = ResonanceTheme.spacing
    val backgroundColor by animateColorAsState(
        targetValue = if (isActive)
            MaterialTheme.colorScheme.background
        else
            MaterialTheme.colorScheme.background.copy(alpha = 0.95f),
        label = "phaseHeaderBg"
    )

    val phaseColor = when (phaseType) {
        PhaseType.ASCEND -> ResonanceColors.PhaseAscend
        PhaseType.ZENITH -> ResonanceColors.PhaseZenith
        PhaseType.DESCENT -> ResonanceColors.PhaseDescent
        PhaseType.REST -> ResonanceColors.PhaseRest
    }

    val indicatorWidth by animateDpAsState(
        targetValue = if (isActive) 4.dp else 2.dp,
        label = "indicatorWidth"
    )

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .background(backgroundColor)
            .padding(horizontal = spacing.screenPadding, vertical = spacing.md),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        // Phase color indicator
        Box(
            modifier = Modifier
                .width(indicatorWidth)
                .height(32.dp)
                .clip(RoundedCornerShape(2.dp))
                .background(phaseColor)
        )

        Spacer(modifier = Modifier.width(spacing.md))

        Column(modifier = Modifier.weight(1f)) {
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(spacing.sm),
            ) {
                Text(
                    text = phaseType.displayName,
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = if (isActive) FontWeight.Bold else FontWeight.Medium,
                    color = if (isActive) phaseColor else MaterialTheme.colorScheme.onBackground,
                )

                if (isActive) {
                    Box(
                        modifier = Modifier
                            .clip(RoundedCornerShape(4.dp))
                            .background(phaseColor.copy(alpha = 0.12f))
                            .padding(horizontal = 8.dp, vertical = 2.dp)
                    ) {
                        Text(
                            text = "Active",
                            style = MaterialTheme.typography.labelSmall,
                            color = phaseColor,
                        )
                    }
                }
            }

            Text(
                text = "${phase.startTime} - ${phase.endTime} \u2022 $taskCount tasks",
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
            )
        }

        // Energy indicator
        EnergyLevelIndicator(
            level = EnergyLevel.fromValue(phase.energyLevel),
        )
    }
}

// ─────────────────────────────────────────────
// Task Card with Swipe Gestures
// ─────────────────────────────────────────────

@Composable
private fun TaskCard(
    task: Task,
    onToggleComplete: () -> Unit,
    onDismiss: () -> Unit,
    modifier: Modifier = Modifier,
) {
    val spacing = ResonanceTheme.spacing

    val dismissState = rememberSwipeToDismissBoxState(
        confirmValueChange = { value ->
            when (value) {
                SwipeToDismissBoxValue.EndToStart -> {
                    onDismiss()
                    true
                }
                SwipeToDismissBoxValue.StartToEnd -> {
                    onToggleComplete()
                    false
                }
                SwipeToDismissBoxValue.Settled -> false
            }
        }
    )

    val domain = remember(task.domain) {
        try { Domain.valueOf(task.domain) } catch (_: Exception) { Domain.PERSONAL }
    }

    val energyLevel = remember(task.energyCost) {
        EnergyLevel.fromValue(task.energyCost)
    }

    val completionAlpha by animateFloatAsState(
        targetValue = if (task.isCompleted) 0.5f else 1f,
        animationSpec = tween(300),
        label = "completionAlpha"
    )

    SwipeToDismissBox(
        state = dismissState,
        modifier = modifier,
        backgroundContent = {
            // Swipe background
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .clip(RoundedCornerShape(12.dp))
                    .background(
                        when (dismissState.targetValue) {
                            SwipeToDismissBoxValue.StartToEnd ->
                                ResonanceColors.Success.copy(alpha = 0.2f)
                            SwipeToDismissBoxValue.EndToStart ->
                                ResonanceColors.Error.copy(alpha = 0.2f)
                            else -> Color.Transparent
                        }
                    )
                    .padding(horizontal = 20.dp),
                contentAlignment = when (dismissState.targetValue) {
                    SwipeToDismissBoxValue.StartToEnd -> Alignment.CenterStart
                    else -> Alignment.CenterEnd
                }
            ) {
                Text(
                    text = when (dismissState.targetValue) {
                        SwipeToDismissBoxValue.StartToEnd ->
                            if (task.isCompleted) "Undo" else "Complete"
                        SwipeToDismissBoxValue.EndToStart -> "Remove"
                        else -> ""
                    },
                    style = MaterialTheme.typography.labelMedium,
                    color = MaterialTheme.colorScheme.onBackground,
                )
            }
        },
    ) {
        Card(
            modifier = Modifier
                .fillMaxWidth()
                .graphicsLayer { alpha = completionAlpha },
            shape = RoundedCornerShape(12.dp),
            colors = CardDefaults.cardColors(
                containerColor = MaterialTheme.colorScheme.surface,
            ),
            elevation = CardDefaults.cardElevation(defaultElevation = 1.dp),
        ) {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(spacing.cardPadding),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                // Drag handle
                Icon(
                    Icons.Filled.DragIndicator,
                    contentDescription = "Reorder",
                    modifier = Modifier.size(20.dp),
                    tint = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.3f),
                )

                Spacer(modifier = Modifier.width(spacing.sm))

                // Completion toggle
                IconButton(
                    onClick = onToggleComplete,
                    modifier = Modifier.size(24.dp),
                ) {
                    Icon(
                        imageVector = if (task.isCompleted)
                            Icons.Filled.CheckCircle
                        else
                            Icons.Outlined.CheckCircleOutline,
                        contentDescription = "Toggle complete",
                        tint = if (task.isCompleted)
                            ResonanceColors.Success
                        else
                            MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.4f),
                    )
                }

                Spacer(modifier = Modifier.width(spacing.md))

                // Task content
                Column(modifier = Modifier.weight(1f)) {
                    Text(
                        text = task.title,
                        style = MaterialTheme.typography.bodyLarge,
                        fontWeight = FontWeight.Medium,
                        color = MaterialTheme.colorScheme.onSurface,
                    )

                    Spacer(modifier = Modifier.height(spacing.xxs))

                    Row(
                        horizontalArrangement = Arrangement.spacedBy(spacing.sm),
                        verticalAlignment = Alignment.CenterVertically,
                    ) {
                        // Domain tag
                        Box(
                            modifier = Modifier
                                .clip(RoundedCornerShape(4.dp))
                                .background(Color(domain.colorHex).copy(alpha = 0.1f))
                                .padding(horizontal = 6.dp, vertical = 2.dp)
                        ) {
                            Text(
                                text = domain.displayName,
                                style = MaterialTheme.typography.labelSmall,
                                color = Color(domain.colorHex).copy(alpha = 0.8f),
                            )
                        }

                        // Duration
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Icon(
                                Icons.Outlined.Timer,
                                contentDescription = null,
                                modifier = Modifier.size(12.dp),
                                tint = MaterialTheme.colorScheme.onSurfaceVariant,
                            )
                            Spacer(modifier = Modifier.width(2.dp))
                            Text(
                                text = "${task.estimatedMinutes}m",
                                style = MaterialTheme.typography.labelSmall,
                                color = MaterialTheme.colorScheme.onSurfaceVariant,
                            )
                        }
                    }
                }

                // Energy cost indicator
                Column(
                    horizontalAlignment = Alignment.CenterHorizontally,
                ) {
                    EnergyLevelIndicator(
                        level = energyLevel,
                        barCount = 4,
                        barWidth = 3.dp,
                        maxBarHeight = 16.dp,
                    )
                    Spacer(modifier = Modifier.height(2.dp))
                    Icon(
                        Icons.Outlined.Bolt,
                        contentDescription = "Energy cost ${task.energyCost}",
                        modifier = Modifier.size(12.dp),
                        tint = ResonanceColors.Gold.copy(alpha = 0.6f),
                    )
                }
            }
        }
    }
}
