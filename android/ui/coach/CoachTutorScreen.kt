package com.luminous.resonance.ui.coach

import androidx.compose.animation.*
import androidx.compose.animation.core.*
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.automirrored.filled.Send
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.semantics.*
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.luminous.resonance.ui.theme.*
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlin.math.sin

// ---------------------------------------------------------------------------
// Data Models
// ---------------------------------------------------------------------------

data class CoachState(
    val messages: List<ChatMessage> = emptyList(),
    val isTyping: Boolean = false,
    val mode: CoachMode = CoachMode.TEXT_CHAT,
    val isRecording: Boolean = false,
    val learningPath: LearningPath? = null,
    val activeSomaticOverlay: SomaticOverlay? = null,
)

sealed class ChatMessage(
    open val id: String,
    open val timestamp: Long,
) {
    data class UserText(
        override val id: String,
        override val timestamp: Long,
        val text: String,
    ) : ChatMessage(id, timestamp)

    data class CoachText(
        override val id: String,
        override val timestamp: Long,
        val text: String,
    ) : ChatMessage(id, timestamp)

    data class AssessmentCard(
        override val id: String,
        override val timestamp: Long,
        val question: String,
        val options: List<String>,
        val selectedIndex: Int? = null,
    ) : ChatMessage(id, timestamp)

    data class QuizCard(
        override val id: String,
        override val timestamp: Long,
        val question: String,
        val options: List<String>,
        val correctIndex: Int,
        val selectedIndex: Int? = null,
    ) : ChatMessage(id, timestamp)
}

enum class CoachMode { TEXT_CHAT, VOICE_CALL }

data class LearningPath(
    val title: String,
    val steps: List<LearningStep>,
    val currentStepIndex: Int,
)

data class LearningStep(
    val title: String,
    val description: String,
    val isCompleted: Boolean,
)

data class SomaticOverlay(
    val title: String,
    val instruction: String,
    val breathDurationMs: Int = 4_000,
    val totalCycles: Int = 4,
    val useHaptics: Boolean = true,
)

// ---------------------------------------------------------------------------
// Coach/Tutor Screen
// ---------------------------------------------------------------------------

/**
 * AI coach and tutor interface with glass-morphism message bubbles,
 * voice recording with waveform, inline assessment/quiz cards,
 * learning path progress, and guided somatic practice overlay.
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CoachTutorScreen(
    state: CoachState,
    onSendMessage: (String) -> Unit,
    onStartRecording: () -> Unit,
    onStopRecording: () -> Unit,
    onAssessmentAnswer: (messageId: String, optionIndex: Int) -> Unit,
    onQuizAnswer: (messageId: String, optionIndex: Int) -> Unit,
    onToggleMode: () -> Unit,
    onDismissSomaticOverlay: () -> Unit,
    onNavigateBack: () -> Unit,
    modifier: Modifier = Modifier,
) {
    val scope = rememberCoroutineScope()
    val listState = rememberLazyListState()

    // Auto-scroll to bottom when new messages arrive
    LaunchedEffect(state.messages.size) {
        if (state.messages.isNotEmpty()) {
            listState.animateScrollToItem(state.messages.lastIndex)
        }
    }

    Box(modifier = modifier.fillMaxSize()) {
        OrganicBlobBackground(
            blobCount = 2,
            baseColor = ResonanceColors.Green200.copy(alpha = 0.04f),
            accentColor = ResonanceColors.GoldPrimary.copy(alpha = 0.03f),
        )

        Scaffold(
            containerColor = MaterialTheme.colorScheme.background.copy(alpha = 0.85f),
            topBar = {
                CoachTopBar(
                    mode = state.mode,
                    onNavigateBack = onNavigateBack,
                    onToggleMode = onToggleMode,
                )
            },
            bottomBar = {
                ChatInputBar(
                    mode = state.mode,
                    isRecording = state.isRecording,
                    onSendMessage = onSendMessage,
                    onStartRecording = onStartRecording,
                    onStopRecording = onStopRecording,
                )
            },
        ) { padding ->
            Column(
                modifier = Modifier
                    .padding(padding)
                    .fillMaxSize(),
            ) {
                // Learning path progress (collapsible)
                state.learningPath?.let { path ->
                    LearningPathProgress(path = path)
                    HorizontalDivider(
                        modifier = Modifier.padding(horizontal = 16.dp),
                        color = MaterialTheme.colorScheme.outlineVariant.copy(alpha = 0.5f),
                    )
                }

                // Chat messages
                LazyColumn(
                    state = listState,
                    modifier = Modifier
                        .weight(1f)
                        .fillMaxWidth(),
                    contentPadding = PaddingValues(horizontal = 16.dp, vertical = 8.dp),
                    verticalArrangement = Arrangement.spacedBy(8.dp),
                ) {
                    items(
                        items = state.messages,
                        key = { it.id },
                    ) { message ->
                        ChatMessageItem(
                            message = message,
                            onAssessmentAnswer = onAssessmentAnswer,
                            onQuizAnswer = onQuizAnswer,
                        )
                    }

                    // Typing indicator
                    if (state.isTyping) {
                        item(key = "typing_indicator") {
                            TypingIndicator()
                        }
                    }
                }
            }
        }

        // Somatic practice overlay
        state.activeSomaticOverlay?.let { overlay ->
            SomaticPracticeOverlay(
                overlay = overlay,
                onDismiss = onDismissSomaticOverlay,
            )
        }
    }
}

// ---------------------------------------------------------------------------
// Top Bar
// ---------------------------------------------------------------------------

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun CoachTopBar(
    mode: CoachMode,
    onNavigateBack: () -> Unit,
    onToggleMode: () -> Unit,
) {
    TopAppBar(
        title = {
            Column {
                Text(
                    text = "Luminous Coach",
                    style = MaterialTheme.typography.titleMedium,
                )
                Text(
                    text = if (mode == CoachMode.TEXT_CHAT) "Text Chat" else "Voice Call",
                    style = MaterialTheme.typography.labelSmall,
                    color = ResonanceTheme.extendedColors.gold,
                )
            }
        },
        navigationIcon = {
            IconButton(
                onClick = onNavigateBack,
                modifier = Modifier.semantics { contentDescription = "Navigate back" },
            ) {
                Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = null)
            }
        },
        actions = {
            IconButton(
                onClick = onToggleMode,
                modifier = Modifier.semantics {
                    contentDescription = if (mode == CoachMode.TEXT_CHAT) {
                        "Switch to voice mode"
                    } else {
                        "Switch to text mode"
                    }
                },
            ) {
                Icon(
                    imageVector = if (mode == CoachMode.TEXT_CHAT) {
                        Icons.Default.Call
                    } else {
                        Icons.Default.Chat
                    },
                    contentDescription = null,
                )
            }
        },
        colors = TopAppBarDefaults.topAppBarColors(
            containerColor = MaterialTheme.colorScheme.surface.copy(alpha = 0.92f),
        ),
    )
}

// ---------------------------------------------------------------------------
// Chat Message Items
// ---------------------------------------------------------------------------

@Composable
private fun ChatMessageItem(
    message: ChatMessage,
    onAssessmentAnswer: (String, Int) -> Unit,
    onQuizAnswer: (String, Int) -> Unit,
) {
    when (message) {
        is ChatMessage.UserText -> UserBubble(text = message.text)
        is ChatMessage.CoachText -> CoachBubble(text = message.text)
        is ChatMessage.AssessmentCard -> AssessmentCardBubble(
            card = message,
            onAnswer = { onAssessmentAnswer(message.id, it) },
        )
        is ChatMessage.QuizCard -> QuizCardBubble(
            card = message,
            onAnswer = { onQuizAnswer(message.id, it) },
        )
    }
}

@Composable
private fun UserBubble(text: String) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.End,
    ) {
        Surface(
            color = ResonanceColors.Green700,
            shape = RoundedCornerShape(
                topStart = 16.dp,
                topEnd = 16.dp,
                bottomStart = 16.dp,
                bottomEnd = 4.dp,
            ),
            modifier = Modifier
                .widthIn(max = 300.dp)
                .semantics { contentDescription = "You said: $text" },
        ) {
            Text(
                text = text,
                style = MaterialTheme.typography.bodyMedium,
                color = ResonanceColors.Green50,
                modifier = Modifier.padding(12.dp),
            )
        }
    }
}

@Composable
private fun CoachBubble(text: String) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.Start,
    ) {
        GlassSurface(
            modifier = Modifier
                .widthIn(max = 300.dp)
                .semantics { contentDescription = "Coach said: $text" },
            shape = RoundedCornerShape(
                topStart = 4.dp,
                topEnd = 16.dp,
                bottomStart = 16.dp,
                bottomEnd = 16.dp,
            ),
            blurRadius = 16.dp,
        ) {
            Text(
                text = text,
                style = MaterialTheme.typography.bodyMedium,
                modifier = Modifier.padding(12.dp),
            )
        }
    }
}

// ---------------------------------------------------------------------------
// Assessment Card Bubble
// ---------------------------------------------------------------------------

@Composable
private fun AssessmentCardBubble(
    card: ChatMessage.AssessmentCard,
    onAnswer: (Int) -> Unit,
) {
    GlassSurface(
        modifier = Modifier.fillMaxWidth(),
        shape = ResonanceShapes.medium,
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Icon(
                    Icons.Default.Assessment,
                    contentDescription = null,
                    tint = ResonanceTheme.extendedColors.gold,
                    modifier = Modifier.size(18.dp),
                )
                Spacer(Modifier.width(8.dp))
                Text(
                    text = "Self-Assessment",
                    style = MaterialTheme.typography.labelLarge,
                    color = ResonanceTheme.extendedColors.gold,
                )
            }
            Spacer(Modifier.height(12.dp))
            Text(
                text = card.question,
                style = MaterialTheme.typography.bodyMedium,
            )
            Spacer(Modifier.height(12.dp))

            card.options.forEachIndexed { index, option ->
                val isSelected = card.selectedIndex == index
                OutlinedButton(
                    onClick = { onAnswer(index) },
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(vertical = 2.dp),
                    colors = ButtonDefaults.outlinedButtonColors(
                        containerColor = if (isSelected) {
                            ResonanceColors.Green200.copy(alpha = 0.3f)
                        } else {
                            MaterialTheme.colorScheme.surface.copy(alpha = 0.01f)
                        },
                    ),
                    border = ButtonDefaults.outlinedButtonBorder(enabled = true),
                ) {
                    Text(
                        text = option,
                        style = MaterialTheme.typography.bodySmall,
                    )
                }
            }
        }
    }
}

// ---------------------------------------------------------------------------
// Quiz Card Bubble
// ---------------------------------------------------------------------------

@Composable
private fun QuizCardBubble(
    card: ChatMessage.QuizCard,
    onAnswer: (Int) -> Unit,
) {
    val answered = card.selectedIndex != null

    GlassSurface(
        modifier = Modifier.fillMaxWidth(),
        shape = ResonanceShapes.medium,
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Icon(
                    Icons.Default.Quiz,
                    contentDescription = null,
                    tint = ResonanceColors.Green500,
                    modifier = Modifier.size(18.dp),
                )
                Spacer(Modifier.width(8.dp))
                Text(
                    text = "Knowledge Check",
                    style = MaterialTheme.typography.labelLarge,
                    color = ResonanceColors.Green500,
                )
            }
            Spacer(Modifier.height(12.dp))
            Text(
                text = card.question,
                style = MaterialTheme.typography.bodyMedium,
            )
            Spacer(Modifier.height(12.dp))

            card.options.forEachIndexed { index, option ->
                val isSelected = card.selectedIndex == index
                val isCorrect = index == card.correctIndex
                val containerColor = when {
                    !answered -> MaterialTheme.colorScheme.surface.copy(alpha = 0.01f)
                    isCorrect -> ResonanceColors.Green200.copy(alpha = 0.4f)
                    isSelected -> ResonanceColors.ErrorLight.copy(alpha = 0.15f)
                    else -> MaterialTheme.colorScheme.surface.copy(alpha = 0.01f)
                }

                OutlinedButton(
                    onClick = { if (!answered) onAnswer(index) },
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(vertical = 2.dp),
                    enabled = !answered,
                    colors = ButtonDefaults.outlinedButtonColors(containerColor = containerColor),
                ) {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically,
                    ) {
                        Text(option, style = MaterialTheme.typography.bodySmall)
                        if (answered && isCorrect) {
                            Icon(
                                Icons.Default.CheckCircle,
                                contentDescription = "Correct",
                                tint = ResonanceColors.Green500,
                                modifier = Modifier.size(16.dp),
                            )
                        }
                    }
                }
            }
        }
    }
}

// ---------------------------------------------------------------------------
// Typing Indicator
// ---------------------------------------------------------------------------

@Composable
private fun TypingIndicator() {
    val infiniteTransition = rememberInfiniteTransition(label = "typing_dots")

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(start = 4.dp),
        horizontalArrangement = Arrangement.Start,
        verticalAlignment = Alignment.CenterVertically,
    ) {
        GlassSurface(
            shape = RoundedCornerShape(12.dp),
            blurRadius = 12.dp,
        ) {
            Row(
                modifier = Modifier.padding(horizontal = 16.dp, vertical = 12.dp),
                horizontalArrangement = Arrangement.spacedBy(4.dp),
            ) {
                repeat(3) { index ->
                    val animatedAlpha by infiniteTransition.animateFloat(
                        initialValue = 0.3f,
                        targetValue = 1f,
                        animationSpec = infiniteRepeatable(
                            animation = tween(600, delayMillis = index * 200),
                            repeatMode = RepeatMode.Reverse,
                        ),
                        label = "dot_$index",
                    )
                    Box(
                        modifier = Modifier
                            .size(8.dp)
                            .graphicsLayer { alpha = animatedAlpha }
                            .clip(CircleShape)
                            .background(
                                MaterialTheme.colorScheme.onSurfaceVariant,
                                CircleShape,
                            ),
                    )
                }
            }
        }
    }
}

// ---------------------------------------------------------------------------
// Chat Input Bar
// ---------------------------------------------------------------------------

@Composable
private fun ChatInputBar(
    mode: CoachMode,
    isRecording: Boolean,
    onSendMessage: (String) -> Unit,
    onStartRecording: () -> Unit,
    onStopRecording: () -> Unit,
) {
    var inputText by rememberSaveable { mutableStateOf("") }

    Surface(
        color = MaterialTheme.colorScheme.surface.copy(alpha = 0.95f),
        tonalElevation = 2.dp,
    ) {
        when (mode) {
            CoachMode.TEXT_CHAT -> {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 12.dp, vertical = 8.dp)
                        .imePadding(),
                    verticalAlignment = Alignment.Bottom,
                ) {
                    OutlinedTextField(
                        value = inputText,
                        onValueChange = { inputText = it },
                        modifier = Modifier
                            .weight(1f)
                            .semantics { contentDescription = "Message input" },
                        placeholder = {
                            Text(
                                "Ask your coach...",
                                style = MaterialTheme.typography.bodyMedium,
                            )
                        },
                        shape = RoundedCornerShape(24.dp),
                        maxLines = 4,
                    )
                    Spacer(Modifier.width(8.dp))

                    // Microphone button for voice messages
                    IconButton(
                        onClick = {
                            if (isRecording) onStopRecording() else onStartRecording()
                        },
                        modifier = Modifier.semantics {
                            contentDescription =
                                if (isRecording) "Stop recording" else "Start voice recording"
                        },
                    ) {
                        Icon(
                            imageVector = if (isRecording) Icons.Default.Stop else Icons.Default.Mic,
                            contentDescription = null,
                            tint = if (isRecording) {
                                ResonanceColors.ErrorLight
                            } else {
                                MaterialTheme.colorScheme.onSurface
                            },
                        )
                    }

                    // Send button
                    IconButton(
                        onClick = {
                            if (inputText.isNotBlank()) {
                                onSendMessage(inputText.trim())
                                inputText = ""
                            }
                        },
                        enabled = inputText.isNotBlank(),
                        modifier = Modifier.semantics { contentDescription = "Send message" },
                    ) {
                        Icon(
                            Icons.AutoMirrored.Filled.Send,
                            contentDescription = null,
                            tint = if (inputText.isNotBlank()) {
                                ResonanceTheme.extendedColors.gold
                            } else {
                                MaterialTheme.colorScheme.onSurfaceVariant
                            },
                        )
                    }
                }
            }

            CoachMode.VOICE_CALL -> {
                VoiceCallControls(
                    isRecording = isRecording,
                    onStartRecording = onStartRecording,
                    onStopRecording = onStopRecording,
                )
            }
        }
    }
}

// ---------------------------------------------------------------------------
// Voice Call Controls
// ---------------------------------------------------------------------------

@Composable
private fun VoiceCallControls(
    isRecording: Boolean,
    onStartRecording: () -> Unit,
    onStopRecording: () -> Unit,
) {
    val haptic = LocalHapticFeedback.current

    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(24.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        // Animated waveform when recording
        AnimatedVisibility(
            visible = isRecording,
            enter = fadeIn() + expandVertically(),
            exit = fadeOut() + shrinkVertically(),
        ) {
            VoiceWaveform(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(48.dp)
                    .padding(bottom = 16.dp),
            )
        }

        // Large record/stop button
        val breathScale by rememberBreathingAnimation(
            min = 0.95f,
            max = 1.05f,
            durationMs = 2_000,
        )

        FilledIconButton(
            onClick = {
                haptic.performHapticFeedback(HapticFeedbackType.LongPress)
                if (isRecording) onStopRecording() else onStartRecording()
            },
            modifier = Modifier
                .size(72.dp)
                .graphicsLayer {
                    if (isRecording) {
                        scaleX = breathScale
                        scaleY = breathScale
                    }
                }
                .semantics {
                    contentDescription = if (isRecording) "Stop speaking" else "Start speaking"
                    role = Role.Button
                },
            colors = IconButtonDefaults.filledIconButtonColors(
                containerColor = if (isRecording) {
                    ResonanceColors.ErrorLight
                } else {
                    ResonanceTheme.extendedColors.gold
                },
                contentColor = if (isRecording) {
                    MaterialTheme.colorScheme.onError
                } else {
                    ResonanceColors.Green900
                },
            ),
        ) {
            Icon(
                imageVector = if (isRecording) Icons.Default.Stop else Icons.Default.Mic,
                contentDescription = null,
                modifier = Modifier.size(32.dp),
            )
        }

        Spacer(Modifier.height(8.dp))
        Text(
            text = if (isRecording) "Listening..." else "Tap to speak",
            style = MaterialTheme.typography.labelMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
        )
    }
}

// ---------------------------------------------------------------------------
// Voice Waveform
// ---------------------------------------------------------------------------

@Composable
private fun VoiceWaveform(modifier: Modifier = Modifier) {
    val infiniteTransition = rememberInfiniteTransition(label = "waveform")
    val barCount = 24

    Row(
        modifier = modifier,
        horizontalArrangement = Arrangement.spacedBy(2.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        repeat(barCount) { index ->
            val animatedHeight by infiniteTransition.animateFloat(
                initialValue = 0.2f,
                targetValue = 1f,
                animationSpec = infiniteRepeatable(
                    animation = tween(
                        durationMillis = 400 + (index % 5) * 100,
                        easing = EaseInOutCubic,
                    ),
                    repeatMode = RepeatMode.Reverse,
                ),
                label = "bar_$index",
            )

            Box(
                modifier = Modifier
                    .weight(1f)
                    .fillMaxHeight(animatedHeight)
                    .clip(RoundedCornerShape(2.dp))
                    .background(
                        ResonanceTheme.extendedColors.gold.copy(
                            alpha = 0.4f + animatedHeight * 0.6f,
                        ),
                    ),
            )
        }
    }
}

// ---------------------------------------------------------------------------
// Learning Path Progress
// ---------------------------------------------------------------------------

@Composable
private fun LearningPathProgress(path: LearningPath) {
    var isExpanded by rememberSaveable { mutableStateOf(false) }

    Column(
        modifier = Modifier
            .fillMaxWidth()
            .clickable { isExpanded = !isExpanded }
            .padding(horizontal = 16.dp, vertical = 12.dp),
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Text(
                text = path.title,
                style = MaterialTheme.typography.titleSmall,
            )
            Row(verticalAlignment = Alignment.CenterVertically) {
                Text(
                    text = "${path.currentStepIndex + 1}/${path.steps.size}",
                    style = MaterialTheme.typography.labelSmall,
                    color = ResonanceTheme.extendedColors.gold,
                )
                Spacer(Modifier.width(4.dp))
                Icon(
                    imageVector = if (isExpanded) Icons.Default.ExpandLess else Icons.Default.ExpandMore,
                    contentDescription = if (isExpanded) "Collapse" else "Expand",
                    modifier = Modifier.size(20.dp),
                )
            }
        }

        // Progress bar
        val progress = (path.currentStepIndex + 1).toFloat() / path.steps.size
        LinearProgressIndicator(
            progress = { progress },
            modifier = Modifier
                .fillMaxWidth()
                .padding(top = 8.dp)
                .height(4.dp)
                .clip(RoundedCornerShape(2.dp)),
            color = ResonanceTheme.extendedColors.gold,
            trackColor = MaterialTheme.colorScheme.surfaceVariant,
        )

        AnimatedVisibility(visible = isExpanded) {
            Column(modifier = Modifier.padding(top = 12.dp)) {
                path.steps.forEachIndexed { index, step ->
                    LearningStepItem(
                        step = step,
                        stepNumber = index + 1,
                        isCurrent = index == path.currentStepIndex,
                        isCompleted = step.isCompleted,
                    )
                }
            }
        }
    }
}

@Composable
private fun LearningStepItem(
    step: LearningStep,
    stepNumber: Int,
    isCurrent: Boolean,
    isCompleted: Boolean,
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 4.dp),
        verticalAlignment = Alignment.Top,
    ) {
        // Step indicator
        Box(
            modifier = Modifier
                .size(24.dp)
                .clip(CircleShape)
                .background(
                    color = when {
                        isCompleted -> ResonanceColors.Green500
                        isCurrent -> ResonanceTheme.extendedColors.gold
                        else -> MaterialTheme.colorScheme.surfaceVariant
                    },
                    shape = CircleShape,
                ),
            contentAlignment = Alignment.Center,
        ) {
            if (isCompleted) {
                Icon(
                    Icons.Default.Check,
                    contentDescription = "Completed",
                    modifier = Modifier.size(14.dp),
                    tint = MaterialTheme.colorScheme.onPrimary,
                )
            } else {
                Text(
                    text = "$stepNumber",
                    style = MaterialTheme.typography.labelSmall,
                    color = if (isCurrent) {
                        ResonanceColors.Green900
                    } else {
                        MaterialTheme.colorScheme.onSurfaceVariant
                    },
                )
            }
        }
        Spacer(Modifier.width(12.dp))
        Column {
            Text(
                text = step.title,
                style = MaterialTheme.typography.bodySmall,
                color = if (isCurrent) {
                    MaterialTheme.colorScheme.onSurface
                } else {
                    MaterialTheme.colorScheme.onSurfaceVariant
                },
            )
            if (isCurrent) {
                Text(
                    text = step.description,
                    style = MaterialTheme.typography.labelSmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                )
            }
        }
    }
}

// ---------------------------------------------------------------------------
// Somatic Practice Overlay
// ---------------------------------------------------------------------------

/**
 * Full-screen guided somatic practice overlay with breathing animation
 * and haptic feedback. The overlay dims the background and provides
 * focused breathing guidance using the device's vibration motor.
 */
@Composable
private fun SomaticPracticeOverlay(
    overlay: SomaticOverlay,
    onDismiss: () -> Unit,
) {
    val haptic = LocalHapticFeedback.current
    var currentCycle by remember { mutableIntStateOf(0) }
    val breathScale by rememberBreathingAnimation(
        min = 0.6f,
        max = 1.3f,
        durationMs = overlay.breathDurationMs,
    )

    // Haptic feedback on breath transitions
    LaunchedEffect(breathScale > 1f) {
        if (overlay.useHaptics) {
            haptic.performHapticFeedback(HapticFeedbackType.TextHandleMove)
        }
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background.copy(alpha = 0.92f))
            .semantics {
                contentDescription = "Somatic practice: ${overlay.title}"
            },
        contentAlignment = Alignment.Center,
    ) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            modifier = Modifier.padding(32.dp),
        ) {
            Text(
                text = overlay.title,
                style = MaterialTheme.typography.headlineMedium,
                textAlign = TextAlign.Center,
            )
            Spacer(Modifier.height(8.dp))
            Text(
                text = overlay.instruction,
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                textAlign = TextAlign.Center,
            )
            Spacer(Modifier.height(48.dp))

            // Breathing visualization
            Box(
                modifier = Modifier
                    .size(180.dp)
                    .scale(breathScale)
                    .clip(CircleShape)
                    .background(
                        Brush.radialGradient(
                            colors = listOf(
                                ResonanceColors.Green400.copy(alpha = 0.3f),
                                ResonanceColors.Green600.copy(alpha = 0.15f),
                                ResonanceColors.GoldPrimary.copy(alpha = 0.05f),
                            ),
                        ),
                        CircleShape,
                    ),
                contentAlignment = Alignment.Center,
            ) {
                Text(
                    text = if (breathScale > 1f) "Inhale" else "Exhale",
                    style = MaterialTheme.typography.titleLarge,
                    color = ResonanceColors.Green200,
                )
            }

            Spacer(Modifier.height(32.dp))
            Text(
                text = "$currentCycle / ${overlay.totalCycles} cycles",
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
            )
            Spacer(Modifier.height(32.dp))

            OutlinedButton(onClick = onDismiss) {
                Text("End Practice")
            }
        }
    }
}
