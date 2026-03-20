package com.resonance.luminous.coach

import androidx.compose.animation.*
import androidx.compose.animation.core.*
import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.rememberLazyListState
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
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.resonance.luminous.ui.*

// ---------------------------------------------------------------------------
// Data models
// ---------------------------------------------------------------------------

enum class MessageSender { USER, COACH }
enum class MessageType { TEXT, VOICE_MEMO, JOURNAL_REF, EXERCISE_CARD, IMAGE }

data class ChatMessage(
    val id: String,
    val sender: MessageSender,
    val type: MessageType,
    val text: String = "",
    val timestamp: String = "",
    // Voice memo
    val voiceDurationSec: Int = 0,
    // Journal reference
    val journalTitle: String = "",
    val journalDate: String = "",
    val journalExcerpt: String = "",
    // Exercise card
    val exerciseTitle: String = "",
    val exerciseDescription: String = "",
    val exerciseSteps: List<String> = emptyList(),
    val exerciseDurationMin: Int = 0,
)

data class QuickReply(
    val text: String,
    val icon: androidx.compose.ui.graphics.vector.ImageVector? = null,
)

// ---------------------------------------------------------------------------
// Sample data
// ---------------------------------------------------------------------------

private val sampleMessages = listOf(
    ChatMessage(
        id = "1",
        sender = MessageSender.COACH,
        type = MessageType.TEXT,
        text = "Welcome back. I noticed you completed your morning journal entry \u2014 that is three days in a row now. How are you feeling about the consistency?",
        timestamp = "9:15 AM",
    ),
    ChatMessage(
        id = "2",
        sender = MessageSender.USER,
        type = MessageType.TEXT,
        text = "It feels good actually. I almost skipped today but then I remembered what you said about showing up even when it feels pointless.",
        timestamp = "9:18 AM",
    ),
    ChatMessage(
        id = "3",
        sender = MessageSender.COACH,
        type = MessageType.TEXT,
        text = "That is a beautiful observation. The moments when you show up despite resistance are often the most transformative ones. Your journal entry today touched on family patterns \u2014 would you like to explore that further?",
        timestamp = "9:19 AM",
    ),
    ChatMessage(
        id = "4",
        sender = MessageSender.USER,
        type = MessageType.JOURNAL_REF,
        journalTitle = "Chapter 3 response",
        journalDate = "Mar 16",
        journalExcerpt = "The section on family patterns hit hard. I always thought my need to fix everyone was just being kind, but I can see now it is a way of managing my own anxiety...",
        timestamp = "9:20 AM",
    ),
    ChatMessage(
        id = "5",
        sender = MessageSender.COACH,
        type = MessageType.EXERCISE_CARD,
        exerciseTitle = "Pattern Pause Practice",
        exerciseDescription = "A somatic exercise for interrupting automatic caretaking responses.",
        exerciseSteps = listOf(
            "Notice when the urge to \"fix\" arises in your body",
            "Place one hand on your heart and one on your belly",
            "Take three slow breaths, counting to five on each exhale",
            "Ask yourself: \"Is this mine to carry?\"",
            "Allow whatever answer comes without judging it",
        ),
        exerciseDurationMin = 5,
        timestamp = "9:21 AM",
    ),
    ChatMessage(
        id = "6",
        sender = MessageSender.USER,
        type = MessageType.VOICE_MEMO,
        text = "Voice memo \u2022 1:23",
        voiceDurationSec = 83,
        timestamp = "9:25 AM",
    ),
    ChatMessage(
        id = "7",
        sender = MessageSender.COACH,
        type = MessageType.TEXT,
        text = "Thank you for sharing that voice note. I can hear the emotion in your voice, and I want you to know that is completely valid. What you described \u2014 the tightness in your throat when you try to set boundaries \u2014 is very common for people with caretaking patterns.\n\nYou are not broken. You are becoming aware. And awareness is the first step toward choice.",
        timestamp = "9:27 AM",
    ),
)

private val quickReplies = listOf(
    QuickReply("Tell me more", Icons.Outlined.ExpandMore),
    QuickReply("I need an exercise", Icons.Outlined.FitnessCenter),
    QuickReply("How do I sit with this?", Icons.Outlined.SelfImprovement),
    QuickReply("Share from my journal", Icons.Outlined.EditNote),
    QuickReply("I'm struggling today", Icons.Outlined.Favorite),
    QuickReply("Can we try a breathing exercise?", Icons.Outlined.Air),
)

// ---------------------------------------------------------------------------
// Coach Screen
// ---------------------------------------------------------------------------

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CoachScreen(isDark: Boolean) {
    var messages by remember { mutableStateOf(sampleMessages) }
    var inputText by remember { mutableStateOf("") }
    var isRecordingVoice by remember { mutableStateOf(false) }
    var showQuickReplies by remember { mutableStateOf(true) }
    val listState = rememberLazyListState()

    // Auto-scroll to bottom
    LaunchedEffect(messages.size) {
        if (messages.isNotEmpty()) {
            listState.animateScrollToItem(messages.size - 1)
        }
    }

    Column(modifier = Modifier.fillMaxSize()) {
        // Header
        CoachHeader(isDark = isDark)

        // Messages
        LazyColumn(
            state = listState,
            modifier = Modifier
                .weight(1f)
                .fillMaxWidth(),
            contentPadding = PaddingValues(horizontal = 16.dp, vertical = 8.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp),
        ) {
            items(messages, key = { it.id }) { message ->
                MessageBubble(message = message, isDark = isDark)
            }
        }

        // Quick replies
        AnimatedVisibility(visible = showQuickReplies) {
            QuickRepliesRow(
                replies = quickReplies,
                onReplyTap = { reply ->
                    val newMsg = ChatMessage(
                        id = "${messages.size + 1}",
                        sender = MessageSender.USER,
                        type = MessageType.TEXT,
                        text = reply.text,
                        timestamp = "Now",
                    )
                    messages = messages + newMsg
                    showQuickReplies = false
                },
            )
        }

        // Input bar
        ChatInputBar(
            text = inputText,
            onTextChange = { inputText = it },
            isRecording = isRecordingVoice,
            onSend = {
                if (inputText.isNotBlank()) {
                    val newMsg = ChatMessage(
                        id = "${messages.size + 1}",
                        sender = MessageSender.USER,
                        type = MessageType.TEXT,
                        text = inputText.trim(),
                        timestamp = "Now",
                    )
                    messages = messages + newMsg
                    inputText = ""
                    showQuickReplies = false
                }
            },
            onToggleVoice = { isRecordingVoice = !isRecordingVoice },
            onAttachJournal = { /* open journal picker */ },
            isDark = isDark,
        )
    }
}

// ---------------------------------------------------------------------------
// Coach header
// ---------------------------------------------------------------------------

@Composable
private fun CoachHeader(isDark: Boolean) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 20.dp, vertical = 12.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        // Coach avatar
        Box(
            modifier = Modifier
                .size(44.dp)
                .clip(CircleShape)
                .background(
                    Brush.linearGradient(
                        listOf(Resonance.goldDark, Resonance.goldPrimary, Resonance.goldLight)
                    )
                ),
            contentAlignment = Alignment.Center,
        ) {
            Icon(
                Icons.Filled.AutoAwesome,
                contentDescription = null,
                tint = Color.White,
                modifier = Modifier.size(22.dp),
            )
        }

        Spacer(Modifier.width(12.dp))

        Column(modifier = Modifier.weight(1f)) {
            Text(
                text = "Your Coach",
                style = MaterialTheme.typography.titleMedium,
                color = MaterialTheme.colorScheme.onBackground,
            )
            Row(verticalAlignment = Alignment.CenterVertically) {
                Box(
                    modifier = Modifier
                        .size(8.dp)
                        .clip(CircleShape)
                        .background(Resonance.success),
                )
                Spacer(Modifier.width(4.dp))
                Text(
                    text = "Available now",
                    style = MaterialTheme.typography.labelSmall,
                    color = Resonance.success,
                )
            }
        }

        IconButton(onClick = { /* settings */ }) {
            Icon(Icons.Outlined.Settings, contentDescription = "Settings", tint = MaterialTheme.colorScheme.onSurfaceVariant)
        }
    }

    HorizontalDivider(color = LuminousThemeExt.colors.glassBorder)
}

// ---------------------------------------------------------------------------
// Message bubble
// ---------------------------------------------------------------------------

@Composable
private fun MessageBubble(message: ChatMessage, isDark: Boolean) {
    val isUser = message.sender == MessageSender.USER
    val alignment = if (isUser) Alignment.CenterEnd else Alignment.CenterStart

    Box(
        modifier = Modifier.fillMaxWidth(),
        contentAlignment = alignment,
    ) {
        when (message.type) {
            MessageType.TEXT -> TextBubble(message, isUser, isDark)
            MessageType.VOICE_MEMO -> VoiceMemoBubble(message, isUser, isDark)
            MessageType.JOURNAL_REF -> JournalRefBubble(message, isDark)
            MessageType.EXERCISE_CARD -> ExerciseCardBubble(message, isDark)
            MessageType.IMAGE -> TextBubble(message, isUser, isDark) // fallback
        }
    }
}

@Composable
private fun TextBubble(message: ChatMessage, isUser: Boolean, isDark: Boolean) {
    Column(
        modifier = Modifier.fillMaxWidth(0.85f),
        horizontalAlignment = if (isUser) Alignment.End else Alignment.Start,
    ) {
        Card(
            shape = RoundedCornerShape(
                topStart = 20.dp,
                topEnd = 20.dp,
                bottomStart = if (isUser) 20.dp else 4.dp,
                bottomEnd = if (isUser) 4.dp else 20.dp,
            ),
            colors = CardDefaults.cardColors(
                containerColor = if (isUser) {
                    Resonance.goldPrimary.copy(alpha = if (isDark) .2f else .15f)
                } else {
                    LuminousThemeExt.colors.glassSurface
                },
            ),
            border = if (!isUser) BorderStroke(1.dp, LuminousThemeExt.colors.glassBorder) else null,
        ) {
            Text(
                text = message.text,
                style = MaterialTheme.typography.bodyMedium.copy(lineHeight = 22.sp),
                color = MaterialTheme.colorScheme.onSurface,
                modifier = Modifier.padding(14.dp),
            )
        }
        Text(
            text = message.timestamp,
            style = MaterialTheme.typography.labelSmall,
            color = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = .6f),
            modifier = Modifier.padding(horizontal = 4.dp, vertical = 2.dp),
        )
    }
}

@Composable
private fun VoiceMemoBubble(message: ChatMessage, isUser: Boolean, isDark: Boolean) {
    var isPlaying by remember { mutableStateOf(false) }

    Column(
        modifier = Modifier.fillMaxWidth(0.7f),
        horizontalAlignment = if (isUser) Alignment.End else Alignment.Start,
    ) {
        Card(
            shape = RoundedCornerShape(20.dp),
            colors = CardDefaults.cardColors(
                containerColor = if (isUser) Resonance.goldPrimary.copy(alpha = .2f)
                else LuminousThemeExt.colors.glassSurface,
            ),
            border = if (!isUser) BorderStroke(1.dp, LuminousThemeExt.colors.glassBorder) else null,
        ) {
            Row(
                modifier = Modifier.padding(12.dp),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                IconButton(
                    onClick = { isPlaying = !isPlaying },
                    modifier = Modifier
                        .size(40.dp)
                        .clip(CircleShape)
                        .background(Resonance.goldPrimary.copy(alpha = .15f)),
                ) {
                    Icon(
                        if (isPlaying) Icons.Filled.Pause else Icons.Filled.PlayArrow,
                        contentDescription = null,
                        tint = Resonance.goldPrimary,
                    )
                }
                Spacer(Modifier.width(8.dp))

                // Waveform placeholder
                Row(
                    modifier = Modifier.weight(1f),
                    horizontalArrangement = Arrangement.spacedBy(2.dp),
                    verticalAlignment = Alignment.CenterVertically,
                ) {
                    repeat(20) { i ->
                        val height = (8 + (kotlin.math.sin(i * 0.8) * 12).toInt()).dp
                        Box(
                            modifier = Modifier
                                .width(3.dp)
                                .height(height)
                                .clip(RoundedCornerShape(1.dp))
                                .background(Resonance.goldPrimary.copy(alpha = if (i < 8 && isPlaying) .8f else .3f)),
                        )
                    }
                }

                Spacer(Modifier.width(8.dp))
                Text(
                    text = formatDuration(message.voiceDurationSec),
                    style = MaterialTheme.typography.labelSmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                )
            }
        }
        Text(
            text = message.timestamp,
            style = MaterialTheme.typography.labelSmall,
            color = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = .6f),
            modifier = Modifier.padding(horizontal = 4.dp, vertical = 2.dp),
        )
    }
}

@Composable
private fun JournalRefBubble(message: ChatMessage, isDark: Boolean) {
    Column(
        modifier = Modifier.fillMaxWidth(0.85f),
        horizontalAlignment = Alignment.End,
    ) {
        Card(
            shape = RoundedCornerShape(20.dp),
            colors = CardDefaults.cardColors(
                containerColor = Resonance.goldPrimary.copy(alpha = .1f),
            ),
            border = BorderStroke(1.dp, Resonance.goldPrimary.copy(alpha = .25f)),
        ) {
            Column(modifier = Modifier.padding(14.dp)) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(Icons.Filled.EditNote, contentDescription = null, tint = Resonance.goldPrimary, modifier = Modifier.size(16.dp))
                    Spacer(Modifier.width(6.dp))
                    Text(
                        text = "Journal Entry",
                        style = MaterialTheme.typography.labelSmall,
                        color = Resonance.goldPrimary,
                    )
                }
                Spacer(Modifier.height(6.dp))
                Text(
                    text = message.journalTitle,
                    style = MaterialTheme.typography.titleSmall,
                    color = MaterialTheme.colorScheme.onSurface,
                    fontWeight = FontWeight.SemiBold,
                )
                Text(
                    text = message.journalDate,
                    style = MaterialTheme.typography.labelSmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                )
                Spacer(Modifier.height(6.dp))
                Text(
                    text = message.journalExcerpt,
                    style = MaterialTheme.typography.bodySmall.copy(fontStyle = FontStyle.Italic),
                    color = MaterialTheme.colorScheme.onSurface.copy(alpha = .8f),
                    maxLines = 3,
                    overflow = TextOverflow.Ellipsis,
                )
            }
        }
        Text(
            text = message.timestamp,
            style = MaterialTheme.typography.labelSmall,
            color = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = .6f),
            modifier = Modifier.padding(horizontal = 4.dp, vertical = 2.dp),
        )
    }
}

@Composable
private fun ExerciseCardBubble(message: ChatMessage, isDark: Boolean) {
    var isExpanded by remember { mutableStateOf(false) }

    Column(
        modifier = Modifier.fillMaxWidth(0.9f),
        horizontalAlignment = Alignment.Start,
    ) {
        Card(
            onClick = { isExpanded = !isExpanded },
            shape = RoundedCornerShape(20.dp),
            colors = CardDefaults.cardColors(
                containerColor = if (isDark)
                    Resonance.green800.copy(alpha = .6f)
                else
                    Resonance.green100.copy(alpha = .7f),
            ),
            border = BorderStroke(1.dp, Resonance.goldPrimary.copy(alpha = .25f)),
        ) {
            Column(modifier = Modifier.padding(16.dp)) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically,
                ) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(
                            Icons.Filled.SelfImprovement,
                            contentDescription = null,
                            tint = Resonance.goldPrimary,
                            modifier = Modifier.size(20.dp),
                        )
                        Spacer(Modifier.width(8.dp))
                        Text(
                            text = "Exercise",
                            style = MaterialTheme.typography.labelMedium,
                            color = Resonance.goldPrimary,
                        )
                    }
                    Text(
                        text = "${message.exerciseDurationMin} min",
                        style = MaterialTheme.typography.labelSmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                    )
                }

                Spacer(Modifier.height(8.dp))

                Text(
                    text = message.exerciseTitle,
                    style = MaterialTheme.typography.titleMedium,
                    color = MaterialTheme.colorScheme.onSurface,
                    fontWeight = FontWeight.Bold,
                )
                Text(
                    text = message.exerciseDescription,
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                )

                AnimatedVisibility(visible = isExpanded) {
                    Column {
                        Spacer(Modifier.height(12.dp))
                        HorizontalDivider(color = Resonance.goldPrimary.copy(alpha = .15f))
                        Spacer(Modifier.height(12.dp))

                        message.exerciseSteps.forEachIndexed { idx, step ->
                            Row(
                                modifier = Modifier.padding(vertical = 4.dp),
                                crossAxisAlignment = CrossAxisAlignment.Start,
                            ) {
                                Box(
                                    modifier = Modifier
                                        .size(24.dp)
                                        .clip(CircleShape)
                                        .background(Resonance.goldPrimary.copy(alpha = .15f)),
                                    contentAlignment = Alignment.Center,
                                ) {
                                    Text(
                                        text = "${idx + 1}",
                                        style = MaterialTheme.typography.labelSmall,
                                        color = Resonance.goldPrimary,
                                    )
                                }
                                Spacer(Modifier.width(10.dp))
                                Text(
                                    text = step,
                                    style = MaterialTheme.typography.bodyMedium,
                                    color = MaterialTheme.colorScheme.onSurface,
                                    modifier = Modifier.weight(1f),
                                )
                            }
                        }

                        Spacer(Modifier.height(12.dp))

                        Button(
                            onClick = { /* start exercise */ },
                            modifier = Modifier.fillMaxWidth(),
                            shape = RoundedCornerShape(12.dp),
                            colors = ButtonDefaults.buttonColors(
                                containerColor = Resonance.goldPrimary,
                                contentColor = Color.White,
                            ),
                        ) {
                            Icon(Icons.Filled.PlayArrow, contentDescription = null, modifier = Modifier.size(18.dp))
                            Spacer(Modifier.width(6.dp))
                            Text("Begin Exercise")
                        }
                    }
                }

                if (!isExpanded) {
                    Spacer(Modifier.height(4.dp))
                    Text(
                        text = "Tap to expand \u2022 ${message.exerciseSteps.size} steps",
                        style = MaterialTheme.typography.labelSmall,
                        color = Resonance.goldPrimary.copy(alpha = .6f),
                    )
                }
            }
        }
        Text(
            text = message.timestamp,
            style = MaterialTheme.typography.labelSmall,
            color = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = .6f),
            modifier = Modifier.padding(horizontal = 4.dp, vertical = 2.dp),
        )
    }
}

// Alias for Row alignment that works with Column items
private enum class CrossAxisAlignment { Start, Center, End }

@Composable
private fun Row(
    modifier: Modifier = Modifier,
    crossAxisAlignment: CrossAxisAlignment = CrossAxisAlignment.Center,
    content: @Composable RowScope.() -> Unit,
) {
    androidx.compose.foundation.layout.Row(
        modifier = modifier,
        verticalAlignment = when (crossAxisAlignment) {
            CrossAxisAlignment.Start -> Alignment.Top
            CrossAxisAlignment.Center -> Alignment.CenterVertically
            CrossAxisAlignment.End -> Alignment.Bottom
        },
        content = content,
    )
}

// ---------------------------------------------------------------------------
// Quick replies
// ---------------------------------------------------------------------------

@Composable
private fun QuickRepliesRow(
    replies: List<QuickReply>,
    onReplyTap: (QuickReply) -> Unit,
) {
    LazyRow(
        contentPadding = PaddingValues(horizontal = 16.dp, vertical = 8.dp),
        horizontalArrangement = Arrangement.spacedBy(8.dp),
    ) {
        items(replies) { reply ->
            SuggestionChip(
                onClick = { onReplyTap(reply) },
                label = {
                    Text(reply.text, style = MaterialTheme.typography.labelMedium)
                },
                icon = reply.icon?.let { ic ->
                    { Icon(ic, contentDescription = null, modifier = Modifier.size(16.dp)) }
                },
                colors = SuggestionChipDefaults.suggestionChipColors(
                    containerColor = Resonance.goldPrimary.copy(alpha = .08f),
                    labelColor = Resonance.goldPrimary,
                    iconColor = Resonance.goldPrimary,
                ),
                border = SuggestionChipDefaults.suggestionChipBorder(
                    enabled = true,
                    borderColor = Resonance.goldPrimary.copy(alpha = .2f),
                ),
            )
        }
    }
}

// ---------------------------------------------------------------------------
// Chat input bar
// ---------------------------------------------------------------------------

@Composable
private fun ChatInputBar(
    text: String,
    onTextChange: (String) -> Unit,
    isRecording: Boolean,
    onSend: () -> Unit,
    onToggleVoice: () -> Unit,
    onAttachJournal: () -> Unit,
    isDark: Boolean,
) {
    Surface(
        color = if (isDark) Resonance.green900.copy(alpha = .9f) else Color.White.copy(alpha = .9f),
        tonalElevation = 2.dp,
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 12.dp, vertical = 8.dp),
            verticalAlignment = Alignment.Bottom,
        ) {
            // Attach journal entry
            IconButton(onClick = onAttachJournal, modifier = Modifier.size(40.dp)) {
                Icon(
                    Icons.Outlined.AttachFile,
                    contentDescription = "Attach journal",
                    tint = MaterialTheme.colorScheme.onSurfaceVariant,
                )
            }

            // Text field
            OutlinedTextField(
                value = text,
                onValueChange = onTextChange,
                placeholder = { Text("Message your coach...") },
                modifier = Modifier
                    .weight(1f)
                    .heightIn(max = 120.dp),
                shape = RoundedCornerShape(24.dp),
                colors = OutlinedTextFieldDefaults.colors(
                    focusedBorderColor = Resonance.goldPrimary,
                    unfocusedBorderColor = LuminousThemeExt.colors.glassBorder,
                    cursorColor = Resonance.goldPrimary,
                ),
                maxLines = 4,
            )

            Spacer(Modifier.width(4.dp))

            // Voice or send
            if (text.isBlank()) {
                IconButton(
                    onClick = onToggleVoice,
                    modifier = Modifier
                        .size(40.dp)
                        .clip(CircleShape)
                        .background(
                            if (isRecording) Resonance.error.copy(alpha = .15f)
                            else Color.Transparent
                        ),
                ) {
                    Icon(
                        if (isRecording) Icons.Filled.Stop else Icons.Filled.Mic,
                        contentDescription = if (isRecording) "Stop recording" else "Record voice",
                        tint = if (isRecording) Resonance.error else Resonance.goldPrimary,
                    )
                }
            } else {
                IconButton(
                    onClick = onSend,
                    modifier = Modifier
                        .size(40.dp)
                        .clip(CircleShape)
                        .background(Resonance.goldPrimary),
                ) {
                    Icon(
                        Icons.Filled.Send,
                        contentDescription = "Send",
                        tint = Color.White,
                    )
                }
            }
        }
    }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

private fun formatDuration(seconds: Int): String {
    val m = seconds / 60
    val s = seconds % 60
    return "%d:%02d".format(m, s)
}
