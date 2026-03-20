package com.resonance.app.ui.screens

import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.core.Spring
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.spring
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.slideInHorizontally
import androidx.compose.animation.slideOutHorizontally
import androidx.compose.animation.togetherWith
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.imePadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.automirrored.filled.Send
import androidx.compose.material.icons.filled.Mic
import androidx.compose.material.icons.filled.PlayArrow
import androidx.compose.material.icons.filled.Stop
import androidx.compose.material.icons.filled.Videocam
import androidx.compose.material.icons.outlined.PictureInPicture
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TextField
import androidx.compose.material3.TextFieldDefaults
import androidx.compose.material3.pulltorefresh.PullToRefreshBox
import androidx.compose.material3.pulltorefresh.rememberPullToRefreshState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.derivedStateOf
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateListOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.resonance.app.data.models.Contact
import com.resonance.app.data.models.IntentionalStatus
import com.resonance.app.data.models.Message
import com.resonance.app.data.models.MessageType
import com.resonance.app.ui.components.GlassMorphismCard
import com.resonance.app.ui.components.IntentionalStatusBadge
import com.resonance.app.ui.components.WaveformVisualizer
import com.resonance.app.ui.theme.ResonanceColors
import com.resonance.app.ui.theme.ResonanceTheme
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import java.time.Instant
import java.time.ZoneId
import java.time.format.DateTimeFormatter

@Composable
fun InnerCircleScreen() {
    var selectedContact by remember { mutableStateOf<Contact?>(null) }

    AnimatedContent(
        targetState = selectedContact,
        transitionSpec = {
            if (targetState != null) {
                (slideInHorizontally { it } + fadeIn()) togetherWith
                        (slideOutHorizontally { -it / 3 } + fadeOut())
            } else {
                (slideInHorizontally { -it } + fadeIn()) togetherWith
                        (slideOutHorizontally { it / 3 } + fadeOut())
            }
        },
        label = "contactNavigation"
    ) { contact ->
        if (contact != null) {
            ConversationView(
                contact = contact,
                onBack = { selectedContact = null },
            )
        } else {
            ContactListView(
                onContactSelected = { selectedContact = it },
            )
        }
    }
}

// ─────────────────────────────────────────────
// Contact List
// ─────────────────────────────────────────────

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun ContactListView(
    onContactSelected: (Contact) -> Unit,
) {
    val spacing = ResonanceTheme.spacing
    var isRefreshing by remember { mutableStateOf(false) }
    val scope = rememberCoroutineScope()
    val refreshState = rememberPullToRefreshState()

    val contacts = remember {
        listOf(
            Contact(name = "Elena", statusText = "Deep work phase", circleRing = 1,
                lastMessagePreview = "The new design feels so calm", lastMessageTime = "10:15 AM", unreadCount = 2),
            Contact(name = "Marcus", statusText = "Open to connect", circleRing = 1,
                lastMessagePreview = "Voice message", lastMessageTime = "9:42 AM", isFavorite = true),
            Contact(name = "Aria", statusText = "Recharging", circleRing = 1,
                lastMessagePreview = "Let's sync tomorrow", lastMessageTime = "Yesterday"),
            Contact(name = "James", statusText = "In flow", circleRing = 2,
                lastMessagePreview = "Sent you the updated protocol", lastMessageTime = "Yesterday"),
            Contact(name = "Luna", statusText = "Available", circleRing = 2,
                lastMessagePreview = "Beautiful reflection!", lastMessageTime = "Mon", unreadCount = 1),
            Contact(name = "Kai", statusText = "Reflecting", circleRing = 2,
                lastMessagePreview = "I'll review the wellness metrics", lastMessageTime = "Sun"),
            Contact(name = "Sage", statusText = "Open to connect", circleRing = 3,
                lastMessagePreview = "Thanks for the breathwork guide", lastMessageTime = "Last week"),
        )
    }

    val groupedContacts by remember {
        derivedStateOf {
            contacts.groupBy { it.circleRing }
        }
    }

    PullToRefreshBox(
        isRefreshing = isRefreshing,
        onRefresh = {
            scope.launch {
                isRefreshing = true
                delay(1500)
                isRefreshing = false
            }
        },
        state = refreshState,
        modifier = Modifier.fillMaxSize(),
    ) {
        LazyColumn(
            contentPadding = PaddingValues(vertical = spacing.md),
            verticalArrangement = Arrangement.spacedBy(spacing.xs),
        ) {
            groupedContacts.forEach { (ring, ringContacts) ->
                item(key = "ring_header_$ring") {
                    val ringLabel = when (ring) {
                        1 -> "Inner Circle"
                        2 -> "Close Friends"
                        else -> "Extended Circle"
                    }
                    Text(
                        text = ringLabel,
                        style = MaterialTheme.typography.labelMedium,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                        modifier = Modifier.padding(
                            horizontal = spacing.screenPadding,
                            vertical = spacing.sm,
                        ),
                    )
                }

                items(ringContacts, key = { it.id }) { contact ->
                    ContactRow(
                        contact = contact,
                        onClick = { onContactSelected(contact) },
                        modifier = Modifier.padding(horizontal = spacing.screenPadding),
                    )
                }
            }
        }
    }
}

@Composable
private fun ContactRow(
    contact: Contact,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
) {
    val spacing = ResonanceTheme.spacing
    val status = remember(contact.statusText) { IntentionalStatus.fromString(contact.statusText) }

    Card(
        modifier = modifier
            .fillMaxWidth()
            .clickable(onClick = onClick),
        shape = RoundedCornerShape(12.dp),
        colors = CardDefaults.cardColors(
            containerColor = if (contact.unreadCount > 0)
                MaterialTheme.colorScheme.surface
            else
                Color.Transparent,
        ),
        elevation = CardDefaults.cardElevation(
            defaultElevation = if (contact.unreadCount > 0) 1.dp else 0.dp
        ),
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(spacing.md),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            // Avatar placeholder
            Box(
                modifier = Modifier
                    .size(48.dp)
                    .clip(CircleShape)
                    .background(
                        ResonanceColors.Green700.copy(alpha = 0.15f)
                    ),
                contentAlignment = Alignment.Center,
            ) {
                Text(
                    text = contact.name.first().toString(),
                    style = MaterialTheme.typography.titleMedium,
                    color = ResonanceColors.Green700,
                    fontWeight = FontWeight.SemiBold,
                )
            }

            Spacer(modifier = Modifier.width(spacing.md))

            Column(modifier = Modifier.weight(1f)) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically,
                ) {
                    Text(
                        text = contact.name,
                        style = MaterialTheme.typography.titleSmall,
                        color = MaterialTheme.colorScheme.onSurface,
                    )
                    contact.lastMessageTime?.let { time ->
                        Text(
                            text = time,
                            style = MaterialTheme.typography.labelSmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant,
                        )
                    }
                }

                Spacer(modifier = Modifier.height(2.dp))

                IntentionalStatusBadge(
                    status = status,
                    showPulse = status.allowsInterruption,
                )

                contact.lastMessagePreview?.let { preview ->
                    Spacer(modifier = Modifier.height(4.dp))
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically,
                    ) {
                        Text(
                            text = preview,
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant,
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis,
                            modifier = Modifier.weight(1f),
                        )

                        if (contact.unreadCount > 0) {
                            Spacer(modifier = Modifier.width(spacing.sm))
                            Box(
                                modifier = Modifier
                                    .size(20.dp)
                                    .clip(CircleShape)
                                    .background(ResonanceColors.Gold),
                                contentAlignment = Alignment.Center,
                            ) {
                                Text(
                                    text = "${contact.unreadCount}",
                                    style = MaterialTheme.typography.labelSmall,
                                    color = ResonanceColors.Green900,
                                    fontWeight = FontWeight.Bold,
                                )
                            }
                        }
                    }
                }
            }
        }
    }
}

// ─────────────────────────────────────────────
// Conversation View
// ─────────────────────────────────────────────

@Composable
private fun ConversationView(
    contact: Contact,
    onBack: () -> Unit,
) {
    val spacing = ResonanceTheme.spacing
    val scope = rememberCoroutineScope()
    val listState = rememberLazyListState()
    var messageText by remember { mutableStateOf("") }
    var isRecording by remember { mutableStateOf(false) }

    val messages = remember {
        mutableStateListOf(
            Message(conversationId = contact.id, senderId = contact.id,
                content = "How is your morning flow going?", isFromMe = false,
                timestamp = "2024-01-15T09:30:00Z"),
            Message(conversationId = contact.id, senderId = "me",
                content = "Really well! The spaciousness metric was at 78% today. Feeling clear.",
                isFromMe = true, timestamp = "2024-01-15T09:32:00Z"),
            Message(conversationId = contact.id, senderId = contact.id,
                content = "That's wonderful. I've been working with the descent phase tasks.",
                isFromMe = false, timestamp = "2024-01-15T09:35:00Z"),
            Message(conversationId = contact.id, senderId = "me",
                content = "", isFromMe = true, type = MessageType.VOICE.name,
                voiceDurationMs = 12000,
                waveformData = List(40) { (Math.random() * 0.8 + 0.1).toFloat() },
                timestamp = "2024-01-15T09:38:00Z"),
            Message(conversationId = contact.id, senderId = contact.id,
                content = "The new design feels so calm", isFromMe = false,
                timestamp = "2024-01-15T10:15:00Z"),
        )
    }

    LaunchedEffect(messages.size) {
        if (messages.isNotEmpty()) {
            listState.animateScrollToItem(messages.lastIndex)
        }
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .imePadding(),
    ) {
        // Conversation header
        ConversationHeader(
            contact = contact,
            onBack = onBack,
            onVideoCall = { /* Video call action */ },
        )

        // Messages
        LazyColumn(
            state = listState,
            modifier = Modifier
                .weight(1f)
                .fillMaxWidth(),
            contentPadding = PaddingValues(
                horizontal = spacing.screenPadding,
                vertical = spacing.md,
            ),
            verticalArrangement = Arrangement.spacedBy(spacing.sm),
        ) {
            items(messages, key = { it.id }) { message ->
                MessageBubble(
                    message = message,
                    contactName = contact.name,
                )
            }
        }

        // Message input
        MessageInput(
            text = messageText,
            onTextChange = { messageText = it },
            isRecording = isRecording,
            onToggleRecording = { isRecording = !isRecording },
            onSend = {
                if (messageText.isNotBlank()) {
                    messages.add(
                        Message(
                            conversationId = contact.id,
                            senderId = "me",
                            content = messageText,
                            isFromMe = true,
                        )
                    )
                    messageText = ""
                }
            },
        )
    }
}

@Composable
private fun ConversationHeader(
    contact: Contact,
    onBack: () -> Unit,
    onVideoCall: () -> Unit,
) {
    val status = remember(contact.statusText) { IntentionalStatus.fromString(contact.statusText) }

    Surface(
        color = MaterialTheme.colorScheme.surface,
        tonalElevation = 1.dp,
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 8.dp, vertical = 12.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            IconButton(onClick = onBack) {
                Icon(
                    Icons.AutoMirrored.Filled.ArrowBack,
                    contentDescription = "Back",
                    tint = MaterialTheme.colorScheme.onSurface,
                )
            }

            Box(
                modifier = Modifier
                    .size(36.dp)
                    .clip(CircleShape)
                    .background(ResonanceColors.Green700.copy(alpha = 0.15f)),
                contentAlignment = Alignment.Center,
            ) {
                Text(
                    text = contact.name.first().toString(),
                    style = MaterialTheme.typography.titleSmall,
                    color = ResonanceColors.Green700,
                )
            }

            Spacer(modifier = Modifier.width(12.dp))

            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = contact.name,
                    style = MaterialTheme.typography.titleSmall,
                    color = MaterialTheme.colorScheme.onSurface,
                )
                IntentionalStatusBadge(
                    status = status,
                    showPulse = false,
                )
            }

            // Video call button
            IconButton(onClick = onVideoCall) {
                Icon(
                    Icons.Filled.Videocam,
                    contentDescription = "Video call",
                    tint = ResonanceColors.Gold,
                )
            }

            // PiP indicator
            IconButton(onClick = { /* PiP action */ }) {
                Icon(
                    Icons.Outlined.PictureInPicture,
                    contentDescription = "Picture in Picture",
                    tint = MaterialTheme.colorScheme.onSurfaceVariant,
                    modifier = Modifier.size(20.dp),
                )
            }
        }
    }
}

// ─────────────────────────────────────────────
// Message Bubble
// ─────────────────────────────────────────────

@Composable
private fun MessageBubble(
    message: Message,
    contactName: String,
) {
    val isFromMe = message.isFromMe
    val isVoice = message.type == MessageType.VOICE.name

    val alignment = if (isFromMe) Alignment.End else Alignment.Start
    val bubbleColor = if (isFromMe)
        ResonanceColors.Green800.copy(alpha = 0.9f)
    else
        MaterialTheme.colorScheme.surfaceVariant

    val textColor = if (isFromMe)
        Color.White
    else
        MaterialTheme.colorScheme.onSurface

    val timeText = remember(message.timestamp) {
        try {
            val instant = Instant.parse(message.timestamp)
            val local = instant.atZone(ZoneId.systemDefault()).toLocalTime()
            local.format(DateTimeFormatter.ofPattern("h:mm a"))
        } catch (_: Exception) { "" }
    }

    Column(
        modifier = Modifier.fillMaxWidth(),
        horizontalAlignment = alignment,
    ) {
        Box(
            modifier = Modifier
                .clip(
                    RoundedCornerShape(
                        topStart = 16.dp,
                        topEnd = 16.dp,
                        bottomStart = if (isFromMe) 16.dp else 4.dp,
                        bottomEnd = if (isFromMe) 4.dp else 16.dp,
                    )
                )
                .background(bubbleColor)
                .padding(horizontal = 14.dp, vertical = 10.dp),
        ) {
            if (isVoice) {
                VoiceMessageContent(
                    waveformData = message.waveformData ?: emptyList(),
                    durationMs = message.voiceDurationMs ?: 0,
                    tintColor = if (isFromMe) ResonanceColors.Gold else ResonanceColors.Green700,
                    textColor = textColor,
                )
            } else {
                Text(
                    text = message.content,
                    style = MaterialTheme.typography.bodyMedium,
                    color = textColor,
                )
            }
        }

        Spacer(modifier = Modifier.height(2.dp))

        Text(
            text = timeText,
            style = MaterialTheme.typography.labelSmall,
            color = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.5f),
        )
    }
}

@Composable
private fun VoiceMessageContent(
    waveformData: List<Float>,
    durationMs: Long,
    tintColor: Color,
    textColor: Color,
) {
    var isPlaying by remember { mutableStateOf(false) }
    var playbackProgress by remember { mutableStateOf(0f) }

    LaunchedEffect(isPlaying) {
        if (isPlaying) {
            val steps = 100
            val stepDelay = durationMs / steps
            for (i in 1..steps) {
                delay(stepDelay)
                playbackProgress = i.toFloat() / steps
            }
            isPlaying = false
            playbackProgress = 0f
        }
    }

    Row(
        verticalAlignment = Alignment.CenterVertically,
        modifier = Modifier.width(200.dp),
    ) {
        IconButton(
            onClick = { isPlaying = !isPlaying },
            modifier = Modifier.size(32.dp),
        ) {
            Icon(
                imageVector = if (isPlaying) Icons.Filled.Stop else Icons.Filled.PlayArrow,
                contentDescription = if (isPlaying) "Stop" else "Play",
                tint = tintColor,
                modifier = Modifier.size(20.dp),
            )
        }

        WaveformVisualizer(
            waveformData = waveformData,
            progress = playbackProgress,
            modifier = Modifier
                .weight(1f)
                .height(28.dp),
            activeColor = tintColor,
            inactiveColor = textColor.copy(alpha = 0.2f),
        )

        Spacer(modifier = Modifier.width(8.dp))

        val durationText = remember(durationMs) {
            val seconds = (durationMs / 1000).toInt()
            "${seconds / 60}:${String.format("%02d", seconds % 60)}"
        }

        Text(
            text = durationText,
            style = MaterialTheme.typography.labelSmall,
            color = textColor.copy(alpha = 0.6f),
        )
    }
}

// ─────────────────────────────────────────────
// Message Input
// ─────────────────────────────────────────────

@Composable
private fun MessageInput(
    text: String,
    onTextChange: (String) -> Unit,
    isRecording: Boolean,
    onToggleRecording: () -> Unit,
    onSend: () -> Unit,
) {
    val spacing = ResonanceTheme.spacing
    val recordingAlpha by animateFloatAsState(
        targetValue = if (isRecording) 1f else 0f,
        animationSpec = tween(300),
        label = "recordingAlpha"
    )

    Surface(
        color = MaterialTheme.colorScheme.surface,
        tonalElevation = 2.dp,
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = spacing.md, vertical = spacing.sm),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            // Voice recording button
            IconButton(
                onClick = onToggleRecording,
                modifier = Modifier.size(40.dp),
            ) {
                Box(contentAlignment = Alignment.Center) {
                    if (isRecording) {
                        Box(
                            modifier = Modifier
                                .size(40.dp)
                                .clip(CircleShape)
                                .background(ResonanceColors.Error.copy(alpha = 0.1f))
                        )
                    }
                    Icon(
                        imageVector = if (isRecording) Icons.Filled.Stop else Icons.Filled.Mic,
                        contentDescription = if (isRecording) "Stop recording" else "Record voice",
                        tint = if (isRecording) ResonanceColors.Error else MaterialTheme.colorScheme.onSurfaceVariant,
                    )
                }
            }

            // Text input
            TextField(
                value = text,
                onValueChange = onTextChange,
                modifier = Modifier.weight(1f),
                placeholder = {
                    Text(
                        text = if (isRecording) "Recording..." else "Write with intention...",
                        style = MaterialTheme.typography.bodyMedium,
                    )
                },
                colors = TextFieldDefaults.colors(
                    focusedContainerColor = Color.Transparent,
                    unfocusedContainerColor = Color.Transparent,
                    focusedIndicatorColor = Color.Transparent,
                    unfocusedIndicatorColor = Color.Transparent,
                ),
                textStyle = MaterialTheme.typography.bodyMedium,
                singleLine = true,
            )

            // Send button
            AnimatedVisibility(visible = text.isNotBlank()) {
                IconButton(
                    onClick = onSend,
                    modifier = Modifier
                        .size(40.dp)
                        .clip(CircleShape)
                        .background(ResonanceColors.Gold),
                ) {
                    Icon(
                        Icons.AutoMirrored.Filled.Send,
                        contentDescription = "Send",
                        tint = ResonanceColors.Green900,
                        modifier = Modifier.size(18.dp),
                    )
                }
            }
        }
    }
}
