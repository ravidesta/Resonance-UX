package com.luminous.cosmic.ui.screens

import android.content.Intent
import android.os.Bundle
import android.speech.RecognizerIntent
import android.speech.SpeechRecognizer
import android.speech.tts.TextToSpeech
import androidx.compose.animation.*
import androidx.compose.animation.core.*
import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.draw.rotate
import androidx.compose.ui.draw.scale
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.*
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.drawscope.rotate
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import java.text.SimpleDateFormat
import java.util.*

import com.luminous.cosmic.ui.components.CosmicBackground
import com.luminous.cosmic.ui.theme.*

// ─────────────────────────────────────────────
// Data Models
// ─────────────────────────────────────────────

data class FacilitatorMessage(
    val id: String = UUID.randomUUID().toString(),
    val role: MessageRole = MessageRole.USER,
    val content: String = "",
    val timestamp: Long = System.currentTimeMillis(),
    val inputMode: InputMode = InputMode.TEXT
)

enum class MessageRole { USER, GUIDE }
enum class InputMode { TEXT, VOICE }

data class ConversationStarter(
    val label: String,
    val prompt: String,
    val icon: String
)

// ─────────────────────────────────────────────
// Main Screen
// ─────────────────────────────────────────────

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun FacilitatorScreen(
    isDarkTheme: Boolean,
    onBack: () -> Unit
) {
    var messages by remember { mutableStateOf(listOf<FacilitatorMessage>()) }
    var inputText by remember { mutableStateOf("") }
    var isRecording by remember { mutableStateOf(false) }
    var isGuideTyping by remember { mutableStateOf(false) }
    var voiceModeActive by remember { mutableStateOf(false) }
    var recordingLevel by remember { mutableFloatStateOf(0f) }

    val listState = rememberLazyListState()
    val scope = rememberCoroutineScope()
    val context = LocalContext.current

    val starters = remember {
        listOf(
            ConversationStarter("Tell me about my chart", "I would love to understand my natal chart more deeply. Can you walk me through the key themes?", "\u2609"),
            ConversationStarter("What should I focus on today?", "Based on the current transits and my chart, what energies are most relevant for me today?", "\u2728"),
            ConversationStarter("Help me understand my Moon sign", "I want to explore what my Moon sign means for my emotional world. Can you guide me?", "\u263D"),
            ConversationStarter("Guide me through a reflection", "I would like a guided reflection connecting me with the current cosmic energies.", "\u2618")
        )
    }

    val guideResponses = remember {
        listOf(
            "That\u2019s a wonderful question to sit with. Your chart holds layers of meaning that unfold as you engage with them. The Sun illuminates your core vitality, but it\u2019s the Moon that reveals your emotional depths. What feels most alive for you right now?",
            "I appreciate your curiosity. In the cosmic framework, this moment is colored by the current transits \u2014 inviting you to notice where expansion meets your inner knowing. Rather than seeking a definitive answer, let\u2019s explore what resonates.",
            "There\u2019s something profound in what you\u2019re noticing. The astrological tradition would say you\u2019re touching on themes of your chart\u2019s deeper architecture. Trust your own experience. What does your intuition say?",
            "Growth often begins at the edge of what we know. The cosmos doesn\u2019t give easy answers, but it offers lenses \u2014 ways of seeing that illuminate what we might miss. What part of this feels most essential to you?",
            "Let\u2019s take a gentle look at this together. The current lunar energy supports reflective awareness. This isn\u2019t about forcing insight, but about creating space for it to arrive. Take a breath, and notice what surfaces."
        )
    }

    fun sendMessage(text: String, mode: InputMode = InputMode.TEXT) {
        if (text.isBlank()) return
        val userMsg = FacilitatorMessage(
            role = MessageRole.USER,
            content = text.trim(),
            inputMode = mode
        )
        messages = messages + userMsg
        inputText = ""

        isGuideTyping = true
        scope.launch {
            delay((1000L..2500L).random())
            val response = guideResponses.random()
            val guideMsg = FacilitatorMessage(
                role = MessageRole.GUIDE,
                content = response
            )
            isGuideTyping = false
            messages = messages + guideMsg
            listState.animateScrollToItem(messages.size)
        }
    }

    // Auto-scroll on new messages
    LaunchedEffect(messages.size) {
        if (messages.isNotEmpty()) {
            listState.animateScrollToItem(messages.size - 1)
        }
    }

    CosmicBackground(isDarkTheme = isDarkTheme) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .statusBarsPadding()
                .navigationBarsPadding()
        ) {
            // ── Header ──
            FacilitatorHeader(
                isDarkTheme = isDarkTheme,
                voiceModeActive = voiceModeActive,
                isGuideTyping = isGuideTyping,
                onBack = onBack,
                onToggleVoice = { voiceModeActive = !voiceModeActive }
            )

            // ── Content ──
            if (messages.isEmpty()) {
                // Welcome state
                WelcomeContent(
                    starters = starters,
                    isDarkTheme = isDarkTheme,
                    onSelectStarter = { sendMessage(it.prompt) },
                    modifier = Modifier.weight(1f)
                )
            } else {
                // Chat messages
                LazyColumn(
                    state = listState,
                    contentPadding = PaddingValues(horizontal = 16.dp, vertical = 8.dp),
                    verticalArrangement = Arrangement.spacedBy(8.dp),
                    modifier = Modifier.weight(1f)
                ) {
                    items(messages, key = { it.id }) { message ->
                        AnimatedVisibility(
                            visible = true,
                            enter = slideInVertically(initialOffsetY = { it / 2 }) + fadeIn()
                        ) {
                            MessageBubbleComposable(
                                message = message,
                                isDarkTheme = isDarkTheme
                            )
                        }
                    }

                    if (isGuideTyping) {
                        item(key = "typing") {
                            TypingIndicatorComposable(isDarkTheme = isDarkTheme)
                        }
                    }
                }
            }

            // ── Input Bar ──
            FacilitatorInputBar(
                inputText = inputText,
                isRecording = isRecording,
                recordingLevel = recordingLevel,
                isDarkTheme = isDarkTheme,
                onInputChange = { inputText = it },
                onSend = { sendMessage(inputText) },
                onToggleRecording = {
                    isRecording = !isRecording
                    if (!isRecording) {
                        sendMessage("What does the current transit mean for me?", InputMode.VOICE)
                    }
                }
            )
        }
    }
}

// ─────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────

@Composable
private fun FacilitatorHeader(
    isDarkTheme: Boolean,
    voiceModeActive: Boolean,
    isGuideTyping: Boolean,
    onBack: () -> Unit,
    onToggleVoice: () -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 8.dp, vertical = 8.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        IconButton(onClick = onBack) {
            Icon(
                Icons.Outlined.ArrowBack,
                contentDescription = "Back",
                tint = ResonanceColors.GoldPrimary
            )
        }

        Spacer(modifier = Modifier.width(4.dp))

        CosmicGuideAvatarComposable(size = 32.dp, isActive = isGuideTyping)

        Spacer(modifier = Modifier.width(8.dp))

        Column(modifier = Modifier.weight(1f)) {
            Text(
                text = "Cosmic Guide",
                style = MaterialTheme.typography.titleLarge,
                color = ResonanceColors.GoldPrimary,
                fontWeight = FontWeight.Light
            )
            AnimatedVisibility(visible = isGuideTyping) {
                Text(
                    text = "reflecting...",
                    style = MaterialTheme.typography.labelSmall,
                    color = ResonanceColors.GoldPrimary.copy(alpha = 0.7f)
                )
            }
        }

        IconButton(onClick = onToggleVoice) {
            Icon(
                if (voiceModeActive) Icons.Outlined.VolumeUp else Icons.Outlined.VolumeOff,
                contentDescription = if (voiceModeActive) "Disable voice" else "Enable voice",
                tint = if (voiceModeActive) ResonanceColors.GoldPrimary
                       else ResonanceColors.TextSage
            )
        }
    }
}

// ─────────────────────────────────────────────
// Welcome Content
// ─────────────────────────────────────────────

@Composable
private fun WelcomeContent(
    starters: List<ConversationStarter>,
    isDarkTheme: Boolean,
    onSelectStarter: (ConversationStarter) -> Unit,
    modifier: Modifier = Modifier
) {
    Column(
        modifier = modifier
            .verticalScroll(rememberScrollState())
            .padding(horizontal = 20.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Spacer(modifier = Modifier.height(48.dp))

        CosmicGuideAvatarComposable(size = 96.dp, isActive = true)

        Spacer(modifier = Modifier.height(24.dp))

        Text(
            text = "Your Cosmic Guide",
            style = MaterialTheme.typography.headlineMedium,
            color = ResonanceColors.GoldPrimary,
            fontWeight = FontWeight.Light
        )

        Spacer(modifier = Modifier.height(8.dp))

        Text(
            text = "Wise counsel through the language of the stars.\nAsk anything about your chart, transits, or inner world.",
            style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            lineHeight = 22.sp,
            textAlign = androidx.compose.ui.text.style.TextAlign.Center
        )

        Spacer(modifier = Modifier.height(32.dp))

        // Conversation starters
        starters.forEach { starter ->
            GlassCard(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(vertical = 4.dp)
                    .clickable { onSelectStarter(starter) },
                cornerRadius = 14.dp
            ) {
                Row(
                    modifier = Modifier.padding(14.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Box(
                        modifier = Modifier
                            .size(36.dp)
                            .clip(CircleShape)
                            .background(ResonanceColors.GoldPrimary.copy(alpha = 0.1f)),
                        contentAlignment = Alignment.Center
                    ) {
                        Text(
                            text = starter.icon,
                            fontSize = 18.sp
                        )
                    }
                    Spacer(modifier = Modifier.width(12.dp))
                    Text(
                        text = starter.label,
                        style = MaterialTheme.typography.bodyMedium,
                        color = MaterialTheme.colorScheme.onSurface,
                        fontWeight = FontWeight.Medium,
                        modifier = Modifier.weight(1f)
                    )
                    Icon(
                        Icons.Outlined.ArrowForward,
                        contentDescription = null,
                        tint = ResonanceColors.GoldPrimary,
                        modifier = Modifier.size(16.dp)
                    )
                }
            }
        }

        Spacer(modifier = Modifier.height(48.dp))
    }
}

// ─────────────────────────────────────────────
// Message Bubble
// ─────────────────────────────────────────────

@Composable
private fun MessageBubbleComposable(
    message: FacilitatorMessage,
    isDarkTheme: Boolean
) {
    val isUser = message.role == MessageRole.USER
    val timeFormat = remember { SimpleDateFormat("h:mm a", Locale.getDefault()) }

    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = if (isUser) Arrangement.End else Arrangement.Start,
        verticalAlignment = Alignment.Top
    ) {
        if (!isUser) {
            CosmicGuideAvatarComposable(size = 28.dp, isActive = false)
            Spacer(modifier = Modifier.width(6.dp))
        }

        Column(
            horizontalAlignment = if (isUser) Alignment.End else Alignment.Start,
            modifier = Modifier.widthIn(max = 300.dp)
        ) {
            Box(
                modifier = Modifier
                    .clip(RoundedCornerShape(18.dp))
                    .background(
                        if (isUser)
                            ResonanceColors.GoldPrimary.copy(alpha = if (isDarkTheme) 0.15f else 0.1f)
                        else
                            ResonanceColors.ForestMedium.copy(alpha = if (isDarkTheme) 0.3f else 0.08f)
                    )
                    .border(
                        width = 0.5.dp,
                        color = if (isUser)
                            ResonanceColors.GoldPrimary.copy(alpha = 0.2f)
                        else
                            Color.White.copy(alpha = if (isDarkTheme) 0.1f else 0.2f),
                        shape = RoundedCornerShape(18.dp)
                    )
                    .padding(horizontal = 14.dp, vertical = 10.dp)
            ) {
                Text(
                    text = message.content,
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurface,
                    lineHeight = 22.sp
                )
            }

            Spacer(modifier = Modifier.height(2.dp))

            Text(
                text = timeFormat.format(Date(message.timestamp)),
                style = MaterialTheme.typography.labelSmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.6f),
                modifier = Modifier.padding(horizontal = 4.dp)
            )
        }
    }
}

// ─────────────────────────────────────────────
// Typing Indicator
// ─────────────────────────────────────────────

@Composable
private fun TypingIndicatorComposable(isDarkTheme: Boolean) {
    val transition = rememberInfiniteTransition(label = "typing")

    Row(
        verticalAlignment = Alignment.Top,
        modifier = Modifier.padding(start = 0.dp)
    ) {
        CosmicGuideAvatarComposable(size = 28.dp, isActive = true)
        Spacer(modifier = Modifier.width(6.dp))

        Row(
            horizontalArrangement = Arrangement.spacedBy(5.dp),
            verticalAlignment = Alignment.CenterVertically,
            modifier = Modifier
                .clip(RoundedCornerShape(18.dp))
                .background(
                    ResonanceColors.ForestMedium.copy(alpha = if (isDarkTheme) 0.3f else 0.08f)
                )
                .border(
                    width = 0.5.dp,
                    color = Color.White.copy(alpha = if (isDarkTheme) 0.1f else 0.2f),
                    shape = RoundedCornerShape(18.dp)
                )
                .padding(horizontal = 16.dp, vertical = 14.dp)
        ) {
            repeat(3) { index ->
                val scale by transition.animateFloat(
                    initialValue = 0.5f,
                    targetValue = 1f,
                    animationSpec = infiniteRepeatable(
                        animation = tween(600, easing = EaseInOut),
                        repeatMode = RepeatMode.Reverse,
                        initialStartOffset = StartOffset(index * 200)
                    ),
                    label = "dot_$index"
                )
                Box(
                    modifier = Modifier
                        .size(7.dp)
                        .scale(scale)
                        .clip(CircleShape)
                        .background(ResonanceColors.GoldPrimary.copy(alpha = 0.6f))
                )
            }
        }
    }
}

// ─────────────────────────────────────────────
// Input Bar
// ─────────────────────────────────────────────

@Composable
private fun FacilitatorInputBar(
    inputText: String,
    isRecording: Boolean,
    recordingLevel: Float,
    isDarkTheme: Boolean,
    onInputChange: (String) -> Unit,
    onSend: () -> Unit,
    onToggleRecording: () -> Unit
) {
    Surface(
        tonalElevation = 3.dp,
        color = MaterialTheme.colorScheme.surface.copy(alpha = 0.95f)
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 12.dp, vertical = 8.dp),
            verticalAlignment = Alignment.Bottom
        ) {
            // Mic button with ripple animation
            Box(contentAlignment = Alignment.Center) {
                if (isRecording) {
                    val pulseAnim = rememberInfiniteTransition(label = "pulse")
                    val pulseScale by pulseAnim.animateFloat(
                        initialValue = 1f,
                        targetValue = 1.4f,
                        animationSpec = infiniteRepeatable(
                            animation = tween(800, easing = EaseInOut),
                            repeatMode = RepeatMode.Reverse
                        ),
                        label = "micPulse"
                    )
                    Box(
                        modifier = Modifier
                            .size(48.dp)
                            .scale(pulseScale)
                            .clip(CircleShape)
                            .background(ResonanceColors.GoldPrimary.copy(alpha = 0.15f))
                    )
                }

                IconButton(
                    onClick = onToggleRecording,
                    modifier = Modifier.semantics {
                        contentDescription = if (isRecording) "Stop recording" else "Start voice input"
                    }
                ) {
                    Icon(
                        if (isRecording) Icons.Outlined.MicNone else Icons.Outlined.Mic,
                        contentDescription = null,
                        tint = if (isRecording) ResonanceColors.GoldPrimary
                               else MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
            }

            // Text field
            OutlinedTextField(
                value = inputText,
                onValueChange = onInputChange,
                placeholder = {
                    Text(
                        "Ask the cosmos...",
                        color = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.5f)
                    )
                },
                modifier = Modifier
                    .weight(1f)
                    .heightIn(min = 48.dp, max = 120.dp),
                shape = RoundedCornerShape(24.dp),
                colors = OutlinedTextFieldDefaults.colors(
                    focusedBorderColor = ResonanceColors.GoldPrimary,
                    unfocusedBorderColor = ResonanceColors.GoldPrimary.copy(alpha = 0.2f),
                    cursorColor = ResonanceColors.GoldPrimary
                ),
                keyboardOptions = KeyboardOptions(imeAction = ImeAction.Send),
                keyboardActions = KeyboardActions(onSend = { onSend() }),
                maxLines = 4
            )

            // Send button
            AnimatedVisibility(
                visible = inputText.isNotBlank(),
                enter = scaleIn() + fadeIn(),
                exit = scaleOut() + fadeOut()
            ) {
                IconButton(
                    onClick = onSend,
                    modifier = Modifier.semantics {
                        contentDescription = "Send message"
                    }
                ) {
                    Box(
                        modifier = Modifier
                            .size(36.dp)
                            .clip(CircleShape)
                            .background(
                                Brush.linearGradient(
                                    colors = listOf(
                                        ResonanceColors.GoldDark,
                                        ResonanceColors.GoldPrimary
                                    )
                                )
                            ),
                        contentAlignment = Alignment.Center
                    ) {
                        Icon(
                            Icons.Outlined.ArrowUpward,
                            contentDescription = null,
                            tint = ResonanceColors.ForestDarkest,
                            modifier = Modifier.size(20.dp)
                        )
                    }
                }
            }
        }
    }
}

// ─────────────────────────────────────────────
// Cosmic Guide Avatar (Canvas)
// ─────────────────────────────────────────────

@Composable
fun CosmicGuideAvatarComposable(
    size: Dp,
    isActive: Boolean,
    modifier: Modifier = Modifier
) {
    val infiniteTransition = rememberInfiniteTransition(label = "avatar")

    val rotation by infiniteTransition.animateFloat(
        initialValue = 0f,
        targetValue = 360f,
        animationSpec = infiniteRepeatable(
            animation = tween(20000, easing = LinearEasing),
            repeatMode = RepeatMode.Restart
        ),
        label = "rotation"
    )

    val pulseScale by infiniteTransition.animateFloat(
        initialValue = 1f,
        targetValue = if (isActive) 1.08f else 1.03f,
        animationSpec = infiniteRepeatable(
            animation = tween(3000, easing = EaseInOut),
            repeatMode = RepeatMode.Reverse
        ),
        label = "pulse"
    )

    val glowAlpha by infiniteTransition.animateFloat(
        initialValue = 0.3f,
        targetValue = if (isActive) 0.6f else 0.35f,
        animationSpec = infiniteRepeatable(
            animation = tween(3000, easing = EaseInOut),
            repeatMode = RepeatMode.Reverse
        ),
        label = "glow"
    )

    Canvas(
        modifier = modifier
            .size(size * 1.3f)
            .scale(pulseScale)
            .semantics { contentDescription = "Cosmic Guide" }
    ) {
        val center = this.center
        val radius = this.size.minDimension / 2f * 0.7f

        // Outer glow
        drawCircle(
            brush = Brush.radialGradient(
                colors = listOf(
                    ResonanceColors.GoldPrimary.copy(alpha = if (isActive) 0.25f else 0.1f),
                    Color.Transparent
                ),
                center = center,
                radius = radius * 1.4f
            )
        )

        // Ring
        rotate(rotation, pivot = center) {
            drawCircle(
                brush = Brush.sweepGradient(
                    colors = listOf(
                        ResonanceColors.GoldDark,
                        ResonanceColors.GoldPrimary,
                        ResonanceColors.GoldLight,
                        ResonanceColors.GoldPrimary,
                        ResonanceColors.GoldDark
                    ),
                    center = center
                ),
                radius = radius,
                center = center,
                style = Stroke(width = radius * 0.1f)
            )
        }

        // Inner star pattern
        val starRadius = radius * 0.55f
        val innerRadius = starRadius * 0.45f
        val points = 8
        val starPath = Path().apply {
            for (i in 0 until points) {
                val angle = (i.toFloat() / points) * 2 * Math.PI.toFloat() - Math.PI.toFloat() / 2
                val r = if (i % 2 == 0) starRadius else innerRadius
                val x = center.x + kotlin.math.cos(angle) * r
                val y = center.y + kotlin.math.sin(angle) * r
                if (i == 0) moveTo(x, y) else lineTo(x, y)
            }
            close()
        }

        drawPath(
            path = starPath,
            color = ResonanceColors.GoldPrimary.copy(alpha = glowAlpha + 0.3f)
        )
    }
}
