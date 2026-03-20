// MARK: - Luminous Guide™ Android Screen
// Jetpack Compose • Claude API • Somatically aware AI companion

package com.luminous.journey.ui.guide

import androidx.compose.animation.core.*
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
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
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.luminous.journey.ui.theme.LuminousColors
import com.luminous.journey.domain.model.GuideSessionType
import com.luminous.journey.domain.model.GuideMessage
import com.luminous.journey.domain.model.GuideMessageRole

@Composable
fun GuideScreen() {
    var showSessionPicker by remember { mutableStateOf(true) }
    var selectedType by remember { mutableStateOf(GuideSessionType.EXPLORATION) }
    var messages by remember { mutableStateOf(listOf<GuideMessage>()) }
    var inputText by remember { mutableStateOf("") }
    var isTyping by remember { mutableStateOf(false) }

    if (showSessionPicker) {
        SessionPickerView(
            onSelectType = { type ->
                selectedType = type
                showSessionPicker = false
                messages = listOf(
                    GuideMessage(
                        role = GuideMessageRole.GUIDE,
                        content = welcomeMessage(type),
                        somaticPrompt = "Before we begin, take a breath. Notice what's present in your body right now."
                    )
                )
            }
        )
    } else {
        ConversationView(
            sessionType = selectedType,
            messages = messages,
            inputText = inputText,
            isTyping = isTyping,
            onInputChange = { inputText = it },
            onSend = {
                if (inputText.isNotBlank()) {
                    messages = messages + GuideMessage(role = GuideMessageRole.USER, content = inputText)
                    inputText = ""
                    isTyping = true
                    // API call would go here — response appended to messages
                }
            },
            onBack = { showSessionPicker = true },
        )
    }
}

// ─── Session Picker ──────────────────────────────────────────────────────

@Composable
fun SessionPickerView(onSelectType: (GuideSessionType) -> Unit) {
    LazyColumn(
        modifier = Modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background),
        contentPadding = PaddingValues(24.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        item {
            Spacer(modifier = Modifier.height(24.dp))

            Text(
                text = "Your Guide",
                style = MaterialTheme.typography.headlineLarge,
                color = MaterialTheme.colorScheme.onBackground,
                textAlign = TextAlign.Center,
                modifier = Modifier.fillMaxWidth(),
            )

            Spacer(modifier = Modifier.height(4.dp))

            Text(
                text = "A compassionate companion for your developmental journey",
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                textAlign = TextAlign.Center,
                modifier = Modifier.fillMaxWidth(),
            )

            Spacer(modifier = Modifier.height(24.dp))

            Text(
                text = "HOW WOULD YOU LIKE TO EXPLORE?",
                style = MaterialTheme.typography.labelLarge,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
            )
        }

        items(sessionTypes) { (type, title, subtitle, icon) ->
            Card(
                modifier = Modifier
                    .fillMaxWidth()
                    .clickable { onSelectType(type) },
                shape = RoundedCornerShape(16.dp),
                colors = CardDefaults.cardColors(
                    containerColor = MaterialTheme.colorScheme.surface,
                ),
            ) {
                Row(
                    modifier = Modifier.padding(16.dp),
                    horizontalArrangement = Arrangement.spacedBy(16.dp),
                    verticalAlignment = Alignment.CenterVertically,
                ) {
                    Box(
                        modifier = Modifier
                            .size(44.dp)
                            .clip(CircleShape)
                            .background(LuminousColors.GoldGlow),
                        contentAlignment = Alignment.Center,
                    ) {
                        Icon(
                            icon,
                            contentDescription = null,
                            tint = LuminousColors.GoldPrimary,
                        )
                    }

                    Column(modifier = Modifier.weight(1f)) {
                        Text(title, style = MaterialTheme.typography.bodyLarge)
                        Text(
                            subtitle,
                            style = MaterialTheme.typography.bodySmall,
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
    }
}

// ─── Conversation ────────────────────────────────────────────────────────

@Composable
fun ConversationView(
    sessionType: GuideSessionType,
    messages: List<GuideMessage>,
    inputText: String,
    isTyping: Boolean,
    onInputChange: (String) -> Unit,
    onSend: () -> Unit,
    onBack: () -> Unit,
) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background),
    ) {
        // Top bar
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 16.dp, vertical = 12.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            IconButton(onClick = onBack) {
                Icon(Icons.Filled.ArrowBack, contentDescription = "Back")
            }

            Column(
                modifier = Modifier.weight(1f),
                horizontalAlignment = Alignment.CenterHorizontally,
            ) {
                Text("Luminous Guide", style = MaterialTheme.typography.bodyLarge)
                Text(
                    sessionType.displayName,
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                )
            }

            IconButton(onClick = { /* somatic check-in */ }) {
                Icon(
                    Icons.Outlined.Waves,
                    contentDescription = "Somatic",
                    tint = LuminousColors.GoldPrimary,
                )
            }
        }

        // Messages
        LazyColumn(
            modifier = Modifier
                .weight(1f)
                .padding(horizontal = 16.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp),
            contentPadding = PaddingValues(vertical = 16.dp),
        ) {
            items(messages) { message ->
                MessageBubble(message)
            }

            if (isTyping) {
                item { TypingIndicator() }
            }
        }

        // Input
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 16.dp, vertical = 12.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(12.dp),
        ) {
            OutlinedTextField(
                value = inputText,
                onValueChange = onInputChange,
                modifier = Modifier.weight(1f),
                placeholder = { Text("Share what's alive in you...") },
                shape = RoundedCornerShape(20.dp),
                colors = OutlinedTextFieldDefaults.colors(
                    focusedBorderColor = LuminousColors.ForestBase,
                    unfocusedBorderColor = LuminousColors.GlassBorder,
                ),
                maxLines = 4,
            )

            IconButton(
                onClick = onSend,
                enabled = inputText.isNotBlank(),
            ) {
                Icon(
                    Icons.Filled.ArrowUpward,
                    contentDescription = "Send",
                    tint = if (inputText.isNotBlank()) LuminousColors.ForestBase else LuminousColors.TextMuted,
                    modifier = Modifier
                        .size(32.dp)
                        .clip(CircleShape)
                        .background(
                            if (inputText.isNotBlank()) LuminousColors.GoldGlow
                            else LuminousColors.TextMuted.copy(alpha = 0.1f)
                        )
                        .padding(4.dp),
                )
            }
        }
    }
}

// ─── Message Bubble ──────────────────────────────────────────────────────

@Composable
fun MessageBubble(message: GuideMessage) {
    val isGuide = message.role == GuideMessageRole.GUIDE

    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = if (isGuide) Arrangement.Start else Arrangement.End,
    ) {
        Column(
            modifier = Modifier.widthIn(max = 300.dp),
            horizontalAlignment = if (isGuide) Alignment.Start else Alignment.End,
        ) {
            Surface(
                shape = RoundedCornerShape(20.dp),
                color = if (isGuide)
                    LuminousColors.ForestBase.copy(alpha = 0.06f)
                else
                    LuminousColors.ForestBase,
                tonalElevation = 0.dp,
            ) {
                Text(
                    text = message.content,
                    modifier = Modifier.padding(16.dp),
                    style = MaterialTheme.typography.bodyLarge,
                    color = if (isGuide)
                        MaterialTheme.colorScheme.onBackground
                    else
                        LuminousColors.Cream,
                    lineHeight = MaterialTheme.typography.bodyLarge.lineHeight,
                )
            }

            // Somatic prompt
            message.somaticPrompt?.let { prompt ->
                Row(
                    modifier = Modifier.padding(horizontal = 4.dp, vertical = 4.dp),
                    horizontalArrangement = Arrangement.spacedBy(6.dp),
                    verticalAlignment = Alignment.CenterVertically,
                ) {
                    Icon(
                        Icons.Outlined.Waves,
                        contentDescription = null,
                        tint = LuminousColors.OrderSelfTransforming,
                        modifier = Modifier.size(14.dp),
                    )
                    Text(
                        text = prompt,
                        style = MaterialTheme.typography.bodySmall,
                        color = LuminousColors.OrderSelfTransforming,
                    )
                }
            }
        }
    }
}

// ─── Typing Indicator ────────────────────────────────────────────────────

@Composable
fun TypingIndicator() {
    val infiniteTransition = rememberInfiniteTransition(label = "typing")

    Row(horizontalArrangement = Arrangement.spacedBy(4.dp)) {
        repeat(3) { index ->
            val scale by infiniteTransition.animateFloat(
                initialValue = 0.6f,
                targetValue = 1f,
                animationSpec = infiniteRepeatable(
                    animation = tween(600, delayMillis = index * 200),
                    repeatMode = RepeatMode.Reverse
                ),
                label = "dot$index"
            )
            Box(
                modifier = Modifier
                    .size((8 * scale).dp)
                    .clip(CircleShape)
                    .background(LuminousColors.TextSecondary)
            )
        }
    }
}

// ─── Data ────────────────────────────────────────────────────────────────

private val sessionTypes = listOf(
    Triple(GuideSessionType.EXPLORATION, "Open Exploration", "Explore your meaning-making landscape with curiosity") to Icons.Outlined.AutoAwesome,
    Triple(GuideSessionType.SOMATIC_GUIDANCE, "Somatic Guidance", "Let the body's wisdom guide the conversation") to Icons.Outlined.Waves,
    Triple(GuideSessionType.REFLECTION_SUPPORT, "Reflection Support", "Deepen your journaling with a compassionate mirror") to Icons.Outlined.Edit,
    Triple(GuideSessionType.BOOK_DISCUSSION, "Book Discussion", "Discuss what you're reading in the LCD text") to Icons.Outlined.Book,
    Triple(GuideSessionType.ASSESSMENT_DEBRIEF, "Assessment Debrief", "Understand your developmental landscape") to Icons.Outlined.BarChart,
    Triple(GuideSessionType.PRACTICE_GUIDANCE, "Practice Guidance", "Be guided through a practice") to Icons.Outlined.SelfImprovement,
    Triple(GuideSessionType.CRISIS_SUPPORT, "Gentle Holding", "When things feel overwhelming. Safety first.") to Icons.Outlined.Favorite,
).map { (triple, icon) -> listOf(triple.first, triple.second, triple.third, icon) }

private fun welcomeMessage(type: GuideSessionType): String = when (type) {
    GuideSessionType.EXPLORATION ->
        "Welcome. I'm here to explore alongside you — wherever your curiosity leads. There's no agenda, no right answer. Just an open space.\n\nWhat's alive in you right now?"
    GuideSessionType.SOMATIC_GUIDANCE ->
        "Let's slow down together.\n\nBefore we begin with words, I'd like to invite you to close your eyes for a moment. Take three slow breaths. What is your body telling you right now?"
    GuideSessionType.REFLECTION_SUPPORT ->
        "I'm here to support your reflection — not to direct it. Think of me as a mirror that occasionally asks a clarifying question.\n\nWhat are you sitting with today?"
    GuideSessionType.BOOK_DISCUSSION ->
        "I'd love to explore the text with you. What's resonating? What's provoking? What's confusing?\n\nAll of those responses are worth examining."
    GuideSessionType.ASSESSMENT_DEBRIEF ->
        "Let's look at your developmental landscape together — with nuance and compassion. These are snapshots, not verdicts.\n\nWhat stood out to you?"
    GuideSessionType.PRACTICE_GUIDANCE ->
        "I'd like to guide you through a practice. Are you somewhere quiet?\n\nWhat does your body need right now? Grounding? Release? Spaciousness?"
    GuideSessionType.CRISIS_SUPPORT ->
        "I'm here. You're not alone.\n\nBefore anything else — are you safe right now? Take your time.\n\nWhatever you're experiencing, it's okay to feel it. I'm not going anywhere."
}
