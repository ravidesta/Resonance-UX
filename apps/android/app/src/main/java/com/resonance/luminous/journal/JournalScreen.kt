package com.resonance.luminous.journal

import androidx.compose.animation.*
import androidx.compose.animation.core.*
import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
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
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.*
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.resonance.luminous.ui.*

// ---------------------------------------------------------------------------
// Data models
// ---------------------------------------------------------------------------

enum class JournalMode { TYPED, VOICE, STYLUS }

data class JournalEntry(
    val id: String,
    val date: String,
    val time: String,
    val mode: JournalMode,
    val title: String,
    val preview: String,
    val moodIndex: Int,     // 0..4
    val wordCount: Int,
    val isSentToCoach: Boolean = false,
    val tags: List<String> = emptyList(),
)

data class JournalPrompt(
    val text: String,
    val category: String,
    val chapter: Int? = null,
)

// ---------------------------------------------------------------------------
// Sample data
// ---------------------------------------------------------------------------

private val samplePrompts = listOf(
    JournalPrompt("What pattern did you notice repeating today?", "Awareness", 3),
    JournalPrompt("Describe a moment when you felt fully present.", "Presence"),
    JournalPrompt("Write a letter to your younger self about what you have learned.", "Compassion", 2),
    JournalPrompt("What are you avoiding, and what would it mean to face it gently?", "Shadow", 4),
    JournalPrompt("Name three things your body is telling you right now.", "Somatic", 6),
    JournalPrompt("What does 'enough' look like for you today?", "Values"),
)

private val sampleEntries = listOf(
    JournalEntry("1", "Mar 19", "9:14 AM", JournalMode.TYPED, "Morning pages", "Woke up with that familiar tightness in my chest again. Instead of pushing through it I sat with it for a few minutes like the book suggested. The tightness had a shape \u2014 something round and heavy, sitting right beneath my sternum...", 2, 340, tags = listOf("somatic", "morning")),
    JournalEntry("2", "Mar 18", "10:32 PM", JournalMode.VOICE, "Evening reflection", "Transcribed from voice memo: Today was a turning point. I caught myself mid-reaction in the meeting and actually paused. The old me would have fired back immediately but I felt the anger, named it, and chose differently...", 3, 280, isSentToCoach = true, tags = listOf("growth", "work")),
    JournalEntry("3", "Mar 17", "3:15 PM", JournalMode.STYLUS, "Drawing exercise", "Freeform drawing exploring the relationship between control and surrender. Used circles and spirals. Added words that arose: release, trust, river, roots...", 3, 120, tags = listOf("creative", "shadow")),
    JournalEntry("4", "Mar 16", "8:00 AM", JournalMode.TYPED, "Chapter 3 response", "The section on family patterns hit hard. I always thought my need to fix everyone was just being kind, but I can see now it is a way of managing my own anxiety...", 1, 450, isSentToCoach = true, tags = listOf("family", "chapter-3")),
    JournalEntry("5", "Mar 15", "7:22 PM", JournalMode.TYPED, "Gratitude list", "Three things: the way light fell through the kitchen window this morning, my friend's laugh on the phone, the feeling of my feet on cool grass...", 4, 180, tags = listOf("gratitude")),
)

private val moods = listOf("\uD83D\uDE14", "\uD83D\uDE10", "\uD83D\uDE42", "\uD83D\uDE0A", "\u2728")
private val moodLabels = listOf("Low", "Flat", "Calm", "Good", "Radiant")
private val moodColors = listOf(
    Color(0xFF8B6B6B),
    Color(0xFF8B8B7A),
    Color(0xFF6B8B7A),
    Color(0xFF5A9E7A),
    Color(0xFFC5A059),
)

// ---------------------------------------------------------------------------
// Journal Screen
// ---------------------------------------------------------------------------

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun JournalScreen(
    isDark: Boolean,
    onShareExcerpt: () -> Unit,
) {
    var selectedTab by remember { mutableIntStateOf(0) }
    val tabs = listOf("Write", "Entries", "Mood Graph")

    var currentMode by remember { mutableStateOf(JournalMode.TYPED) }
    var entryText by remember { mutableStateOf("") }
    var entryTitle by remember { mutableStateOf("") }
    var selectedMood by remember { mutableIntStateOf(-1) }
    var isRecording by remember { mutableStateOf(false) }
    var showPrompts by remember { mutableStateOf(false) }

    Column(modifier = Modifier.fillMaxSize()) {
        // Header
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 20.dp, vertical = 12.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Text(
                text = "Journal",
                style = MaterialTheme.typography.headlineMedium,
                color = MaterialTheme.colorScheme.onBackground,
                modifier = Modifier.weight(1f),
            )
            Text(
                text = "${sampleEntries.size + (if (entryText.isNotEmpty()) 1 else 0)} entries",
                style = MaterialTheme.typography.labelMedium,
                color = Resonance.goldPrimary,
            )
        }

        // Tab row
        TabRow(
            selectedTabIndex = selectedTab,
            containerColor = Color.Transparent,
            contentColor = MaterialTheme.colorScheme.onBackground,
            indicator = { tabPositions ->
                if (selectedTab < tabPositions.size) {
                    TabRowDefaults.SecondaryIndicator(
                        modifier = Modifier.tabIndicatorOffset(tabPositions[selectedTab]),
                        color = Resonance.goldPrimary,
                    )
                }
            },
            divider = {},
        ) {
            tabs.forEachIndexed { idx, title ->
                Tab(
                    selected = idx == selectedTab,
                    onClick = { selectedTab = idx },
                    text = {
                        Text(
                            title,
                            color = if (idx == selectedTab) Resonance.goldPrimary
                            else MaterialTheme.colorScheme.onSurfaceVariant,
                        )
                    },
                )
            }
        }

        when (selectedTab) {
            0 -> WriteView(
                mode = currentMode,
                onModeChange = { currentMode = it },
                entryText = entryText,
                onTextChange = { entryText = it },
                entryTitle = entryTitle,
                onTitleChange = { entryTitle = it },
                selectedMood = selectedMood,
                onMoodSelected = { selectedMood = it },
                isRecording = isRecording,
                onToggleRecording = { isRecording = !isRecording },
                showPrompts = showPrompts,
                onTogglePrompts = { showPrompts = !showPrompts },
                isDark = isDark,
                onShareExcerpt = onShareExcerpt,
            )
            1 -> EntriesListView(
                entries = sampleEntries,
                isDark = isDark,
                onShareExcerpt = onShareExcerpt,
            )
            2 -> MoodGraphView(
                entries = sampleEntries,
                isDark = isDark,
            )
        }
    }
}

// ---------------------------------------------------------------------------
// Write view
// ---------------------------------------------------------------------------

@Composable
private fun WriteView(
    mode: JournalMode,
    onModeChange: (JournalMode) -> Unit,
    entryText: String,
    onTextChange: (String) -> Unit,
    entryTitle: String,
    onTitleChange: (String) -> Unit,
    selectedMood: Int,
    onMoodSelected: (Int) -> Unit,
    isRecording: Boolean,
    onToggleRecording: () -> Unit,
    showPrompts: Boolean,
    onTogglePrompts: () -> Unit,
    isDark: Boolean,
    onShareExcerpt: () -> Unit,
) {
    val scrollState = rememberScrollState()

    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(scrollState)
            .padding(horizontal = 20.dp),
    ) {
        Spacer(Modifier.height(16.dp))

        // Mode selector
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(8.dp),
        ) {
            ModeChip("Type", Icons.Filled.Keyboard, mode == JournalMode.TYPED) { onModeChange(JournalMode.TYPED) }
            ModeChip("Voice", Icons.Filled.Mic, mode == JournalMode.VOICE) { onModeChange(JournalMode.VOICE) }
            ModeChip("Draw", Icons.Filled.Brush, mode == JournalMode.STYLUS) { onModeChange(JournalMode.STYLUS) }

            Spacer(Modifier.weight(1f))

            IconButton(onClick = onTogglePrompts) {
                Icon(
                    if (showPrompts) Icons.Filled.LightbulbCircle else Icons.Outlined.Lightbulb,
                    contentDescription = "Prompts",
                    tint = Resonance.goldPrimary,
                )
            }
        }

        // Prompts carousel
        AnimatedVisibility(visible = showPrompts) {
            Column {
                Spacer(Modifier.height(12.dp))
                Text(
                    text = "Writing Prompts",
                    style = MaterialTheme.typography.labelLarge,
                    color = Resonance.goldPrimary,
                )
                Spacer(Modifier.height(8.dp))
                LazyRow(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                    items(samplePrompts) { prompt ->
                        Card(
                            onClick = {
                                onTextChange(entryText + "\n\nPrompt: ${prompt.text}\n\n")
                            },
                            shape = RoundedCornerShape(16.dp),
                            colors = CardDefaults.cardColors(
                                containerColor = Resonance.goldPrimary.copy(alpha = .1f),
                            ),
                            modifier = Modifier.width(240.dp),
                        ) {
                            Column(modifier = Modifier.padding(12.dp)) {
                                Text(
                                    text = prompt.category,
                                    style = MaterialTheme.typography.labelSmall,
                                    color = Resonance.goldPrimary,
                                )
                                Spacer(Modifier.height(4.dp))
                                Text(
                                    text = prompt.text,
                                    style = MaterialTheme.typography.bodyMedium,
                                    color = MaterialTheme.colorScheme.onSurface,
                                    maxLines = 3,
                                    overflow = TextOverflow.Ellipsis,
                                )
                                if (prompt.chapter != null) {
                                    Spacer(Modifier.height(4.dp))
                                    Text(
                                        text = "From Chapter ${prompt.chapter}",
                                        style = MaterialTheme.typography.labelSmall,
                                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                                    )
                                }
                            }
                        }
                    }
                }
            }
        }

        Spacer(Modifier.height(16.dp))

        when (mode) {
            JournalMode.TYPED -> TypedEditor(
                title = entryTitle,
                onTitleChange = onTitleChange,
                text = entryText,
                onTextChange = onTextChange,
                isDark = isDark,
            )
            JournalMode.VOICE -> VoiceEditor(
                isRecording = isRecording,
                onToggle = onToggleRecording,
                transcription = entryText,
                onTranscriptionChange = onTextChange,
                isDark = isDark,
            )
            JournalMode.STYLUS -> StylusEditor(isDark = isDark)
        }

        Spacer(Modifier.height(16.dp))

        // Mood for this entry
        Text(
            text = "How does this writing feel?",
            style = MaterialTheme.typography.labelLarge,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
        )
        Spacer(Modifier.height(8.dp))
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceEvenly,
        ) {
            moods.forEachIndexed { idx, emoji ->
                val selected = idx == selectedMood
                Box(
                    modifier = Modifier
                        .size(44.dp)
                        .clip(CircleShape)
                        .background(
                            if (selected) moodColors[idx].copy(alpha = .2f) else Color.Transparent
                        )
                        .then(
                            if (selected) Modifier.border(2.dp, moodColors[idx], CircleShape)
                            else Modifier
                        )
                        .clickable { onMoodSelected(idx) },
                    contentAlignment = Alignment.Center,
                ) {
                    Text(emoji, fontSize = 22.sp)
                }
            }
        }

        Spacer(Modifier.height(20.dp))

        // Action buttons
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(12.dp),
        ) {
            OutlinedButton(
                onClick = { /* send to coach */ },
                modifier = Modifier.weight(1f),
                shape = RoundedCornerShape(16.dp),
                colors = ButtonDefaults.outlinedButtonColors(contentColor = Resonance.goldPrimary),
                border = BorderStroke(1.dp, Resonance.goldPrimary.copy(alpha = .4f)),
            ) {
                Icon(Icons.Outlined.Forum, contentDescription = null, modifier = Modifier.size(16.dp))
                Spacer(Modifier.width(6.dp))
                Text("Send to Coach")
            }
            Button(
                onClick = { /* save entry */ },
                modifier = Modifier.weight(1f),
                shape = RoundedCornerShape(16.dp),
                colors = ButtonDefaults.buttonColors(
                    containerColor = Resonance.goldPrimary,
                    contentColor = Color.White,
                ),
            ) {
                Icon(Icons.Filled.Save, contentDescription = null, modifier = Modifier.size(16.dp))
                Spacer(Modifier.width(6.dp))
                Text("Save Entry")
            }
        }

        // Share excerpt
        if (entryText.length > 50) {
            Spacer(Modifier.height(8.dp))
            TextButton(
                onClick = onShareExcerpt,
                modifier = Modifier.fillMaxWidth(),
            ) {
                Icon(Icons.Outlined.Share, contentDescription = null, modifier = Modifier.size(16.dp))
                Spacer(Modifier.width(6.dp))
                Text("Share an excerpt from this entry")
            }
        }

        Spacer(Modifier.height(32.dp))
    }
}

// ---------------------------------------------------------------------------
// Mode chip
// ---------------------------------------------------------------------------

@Composable
private fun ModeChip(
    label: String,
    icon: androidx.compose.ui.graphics.vector.ImageVector,
    selected: Boolean,
    onClick: () -> Unit,
) {
    FilterChip(
        selected = selected,
        onClick = onClick,
        label = { Text(label, style = MaterialTheme.typography.labelMedium) },
        leadingIcon = {
            Icon(icon, contentDescription = null, modifier = Modifier.size(16.dp))
        },
        colors = FilterChipDefaults.filterChipColors(
            selectedContainerColor = Resonance.goldPrimary.copy(alpha = .15f),
            selectedLabelColor = Resonance.goldPrimary,
            selectedLeadingIconColor = Resonance.goldPrimary,
        ),
    )
}

// ---------------------------------------------------------------------------
// Typed editor
// ---------------------------------------------------------------------------

@Composable
private fun TypedEditor(
    title: String,
    onTitleChange: (String) -> Unit,
    text: String,
    onTextChange: (String) -> Unit,
    isDark: Boolean,
) {
    OutlinedTextField(
        value = title,
        onValueChange = onTitleChange,
        placeholder = {
            Text(
                "Entry title...",
                style = MaterialTheme.typography.titleLarge,
                color = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = .5f),
            )
        },
        textStyle = MaterialTheme.typography.titleLarge,
        modifier = Modifier.fillMaxWidth(),
        singleLine = true,
        colors = OutlinedTextFieldDefaults.colors(
            focusedBorderColor = Color.Transparent,
            unfocusedBorderColor = Color.Transparent,
            cursorColor = Resonance.goldPrimary,
        ),
    )

    OutlinedTextField(
        value = text,
        onValueChange = onTextChange,
        placeholder = {
            Text(
                "Begin writing... let the words flow without judgement.",
                color = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = .5f),
            )
        },
        textStyle = MaterialTheme.typography.bodyLarge.copy(lineHeight = 28.sp),
        modifier = Modifier
            .fillMaxWidth()
            .heightIn(min = 200.dp),
        colors = OutlinedTextFieldDefaults.colors(
            focusedBorderColor = Color.Transparent,
            unfocusedBorderColor = Color.Transparent,
            cursorColor = Resonance.goldPrimary,
        ),
    )

    // Word count
    val words = text.split("\\s+".toRegex()).filter { it.isNotBlank() }.size
    Text(
        text = "$words words",
        style = MaterialTheme.typography.labelSmall,
        color = MaterialTheme.colorScheme.onSurfaceVariant,
        modifier = Modifier.fillMaxWidth(),
    )
}

// ---------------------------------------------------------------------------
// Voice editor
// ---------------------------------------------------------------------------

@Composable
private fun VoiceEditor(
    isRecording: Boolean,
    onToggle: () -> Unit,
    transcription: String,
    onTranscriptionChange: (String) -> Unit,
    isDark: Boolean,
) {
    val pulseAnim = rememberInfiniteTransition(label = "pulse")
    val pulse by pulseAnim.animateFloat(
        initialValue = 1f,
        targetValue = 1.3f,
        animationSpec = infiniteRepeatable(
            animation = tween(800, easing = EaseInOutCubic),
            repeatMode = RepeatMode.Reverse,
        ),
        label = "pulseVal",
    )

    Column(
        modifier = Modifier.fillMaxWidth(),
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        Spacer(Modifier.height(24.dp))

        // Recording button
        Box(contentAlignment = Alignment.Center) {
            if (isRecording) {
                Box(
                    modifier = Modifier
                        .size((80 * pulse).dp)
                        .clip(CircleShape)
                        .background(Resonance.error.copy(alpha = .15f)),
                )
            }
            FilledIconButton(
                onClick = onToggle,
                modifier = Modifier.size(64.dp),
                colors = IconButtonDefaults.filledIconButtonColors(
                    containerColor = if (isRecording) Resonance.error else Resonance.goldPrimary,
                    contentColor = Color.White,
                ),
            ) {
                Icon(
                    if (isRecording) Icons.Filled.Stop else Icons.Filled.Mic,
                    contentDescription = if (isRecording) "Stop" else "Record",
                    modifier = Modifier.size(32.dp),
                )
            }
        }

        Spacer(Modifier.height(8.dp))
        Text(
            text = if (isRecording) "Recording... tap to stop" else "Tap to record",
            style = MaterialTheme.typography.bodyMedium,
            color = if (isRecording) Resonance.error else MaterialTheme.colorScheme.onSurfaceVariant,
        )

        Spacer(Modifier.height(24.dp))

        // Transcription area
        if (transcription.isNotEmpty()) {
            Text(
                text = "Transcription",
                style = MaterialTheme.typography.labelLarge,
                color = Resonance.goldPrimary,
                modifier = Modifier.fillMaxWidth(),
            )
            Spacer(Modifier.height(8.dp))
        }

        OutlinedTextField(
            value = transcription,
            onValueChange = onTranscriptionChange,
            placeholder = { Text("Voice transcription will appear here...") },
            textStyle = MaterialTheme.typography.bodyLarge.copy(lineHeight = 28.sp),
            modifier = Modifier
                .fillMaxWidth()
                .heightIn(min = 150.dp),
            colors = OutlinedTextFieldDefaults.colors(
                focusedBorderColor = Resonance.goldPrimary.copy(alpha = .3f),
                unfocusedBorderColor = LuminousThemeExt.colors.glassBorder,
                cursorColor = Resonance.goldPrimary,
            ),
            shape = RoundedCornerShape(16.dp),
        )
    }
}

// ---------------------------------------------------------------------------
// Stylus / drawing editor
// ---------------------------------------------------------------------------

@Composable
private fun StylusEditor(isDark: Boolean) {
    Column(
        modifier = Modifier.fillMaxWidth(),
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        // Toolbar
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(8.dp),
        ) {
            val tools = listOf(
                Icons.Filled.Edit to "Pen",
                Icons.Filled.Brush to "Brush",
                Icons.Filled.Circle to "Marker",
                Icons.Outlined.FormatColorFill to "Color",
                Icons.Filled.Undo to "Undo",
                Icons.Filled.Redo to "Redo",
            )
            tools.forEach { (icon, label) ->
                IconButton(onClick = { /* tool action */ }) {
                    Icon(icon, contentDescription = label, tint = Resonance.goldPrimary, modifier = Modifier.size(20.dp))
                }
            }
        }

        // Canvas placeholder
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(300.dp)
                .clip(RoundedCornerShape(16.dp))
                .background(
                    if (isDark) Resonance.green900.copy(alpha = .5f)
                    else Color.White
                )
                .border(
                    1.dp,
                    LuminousThemeExt.colors.glassBorder,
                    RoundedCornerShape(16.dp),
                ),
            contentAlignment = Alignment.Center,
        ) {
            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                Icon(
                    Icons.Outlined.Draw,
                    contentDescription = null,
                    tint = Resonance.goldPrimary.copy(alpha = .5f),
                    modifier = Modifier.size(48.dp),
                )
                Spacer(Modifier.height(8.dp))
                Text(
                    text = "Draw with your finger or stylus",
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = .6f),
                )
                Text(
                    text = "Supports pressure sensitivity",
                    style = MaterialTheme.typography.labelSmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = .4f),
                )
            }
        }
    }
}

// ---------------------------------------------------------------------------
// Entries list
// ---------------------------------------------------------------------------

@Composable
private fun EntriesListView(
    entries: List<JournalEntry>,
    isDark: Boolean,
    onShareExcerpt: () -> Unit,
) {
    LazyColumn(
        contentPadding = PaddingValues(20.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp),
    ) {
        items(entries) { entry ->
            EntryCard(entry = entry, isDark = isDark, onShare = onShareExcerpt)
        }
    }
}

@Composable
private fun EntryCard(
    entry: JournalEntry,
    isDark: Boolean,
    onShare: () -> Unit,
) {
    Card(
        shape = RoundedCornerShape(20.dp),
        colors = CardDefaults.cardColors(containerColor = LuminousThemeExt.colors.glassSurface),
        border = BorderStroke(1.dp, LuminousThemeExt.colors.glassBorder),
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            // Header
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically,
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Text(moods[entry.moodIndex], fontSize = 20.sp)
                    Spacer(Modifier.width(8.dp))
                    Column {
                        Text(
                            text = entry.title,
                            style = MaterialTheme.typography.titleSmall,
                            color = MaterialTheme.colorScheme.onSurface,
                            fontWeight = FontWeight.SemiBold,
                        )
                        Text(
                            text = "${entry.date} \u2022 ${entry.time}",
                            style = MaterialTheme.typography.labelSmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant,
                        )
                    }
                }

                Row {
                    val modeIcon = when (entry.mode) {
                        JournalMode.TYPED -> Icons.Outlined.Keyboard
                        JournalMode.VOICE -> Icons.Outlined.Mic
                        JournalMode.STYLUS -> Icons.Outlined.Brush
                    }
                    Icon(modeIcon, contentDescription = null, tint = MaterialTheme.colorScheme.onSurfaceVariant, modifier = Modifier.size(16.dp))
                    if (entry.isSentToCoach) {
                        Spacer(Modifier.width(4.dp))
                        Icon(Icons.Outlined.Forum, contentDescription = "Sent to coach", tint = Resonance.goldPrimary, modifier = Modifier.size(16.dp))
                    }
                }
            }

            Spacer(Modifier.height(10.dp))

            Text(
                text = entry.preview,
                style = MaterialTheme.typography.bodyMedium.copy(
                    fontStyle = if (entry.mode == JournalMode.VOICE) FontStyle.Italic else FontStyle.Normal,
                ),
                color = MaterialTheme.colorScheme.onSurface.copy(alpha = .85f),
                maxLines = 3,
                overflow = TextOverflow.Ellipsis,
            )

            Spacer(Modifier.height(10.dp))

            // Tags
            if (entry.tags.isNotEmpty()) {
                Row(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                    entry.tags.forEach { tag ->
                        SuggestionChip(
                            onClick = {},
                            label = { Text(tag, style = MaterialTheme.typography.labelSmall) },
                            colors = SuggestionChipDefaults.suggestionChipColors(
                                containerColor = Resonance.goldPrimary.copy(alpha = .08f),
                                labelColor = Resonance.goldPrimary,
                            ),
                            border = null,
                            modifier = Modifier.height(24.dp),
                        )
                    }
                }
                Spacer(Modifier.height(6.dp))
            }

            // Footer
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically,
            ) {
                Text(
                    text = "${entry.wordCount} words",
                    style = MaterialTheme.typography.labelSmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                )
                Row {
                    IconButton(onClick = onShare, modifier = Modifier.size(32.dp)) {
                        Icon(Icons.Outlined.Share, contentDescription = "Share", tint = Resonance.goldPrimary, modifier = Modifier.size(16.dp))
                    }
                    IconButton(onClick = { /* send to coach */ }, modifier = Modifier.size(32.dp)) {
                        Icon(Icons.Outlined.Forum, contentDescription = "Send to coach", tint = MaterialTheme.colorScheme.onSurfaceVariant, modifier = Modifier.size(16.dp))
                    }
                }
            }
        }
    }
}

// ---------------------------------------------------------------------------
// Mood Graph
// ---------------------------------------------------------------------------

@Composable
private fun MoodGraphView(
    entries: List<JournalEntry>,
    isDark: Boolean,
) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(20.dp),
    ) {
        Text(
            text = "Mood Over Time",
            style = MaterialTheme.typography.titleMedium,
            color = MaterialTheme.colorScheme.onBackground,
        )
        Spacer(Modifier.height(8.dp))
        Text(
            text = "Your emotional landscape across journal entries",
            style = MaterialTheme.typography.bodySmall,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
        )

        Spacer(Modifier.height(24.dp))

        // Graph
        val reversedEntries = entries.reversed()

        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(200.dp)
                .clip(RoundedCornerShape(16.dp))
                .background(LuminousThemeExt.colors.glassSurface)
                .border(1.dp, LuminousThemeExt.colors.glassBorder, RoundedCornerShape(16.dp))
                .drawBehind {
                    val w = size.width
                    val h = size.height
                    val padding = 40f
                    val graphW = w - padding * 2
                    val graphH = h - padding * 2

                    // Grid lines
                    for (i in 0..4) {
                        val y = padding + graphH - (i / 4f) * graphH
                        drawLine(
                            color = Color.Gray.copy(alpha = .15f),
                            start = Offset(padding, y),
                            end = Offset(w - padding, y),
                            strokeWidth = 1f,
                        )
                    }

                    // Plot points and line
                    if (reversedEntries.size >= 2) {
                        val points = reversedEntries.mapIndexed { idx, entry ->
                            val x = padding + (idx.toFloat() / (reversedEntries.size - 1)) * graphW
                            val y = padding + graphH - (entry.moodIndex / 4f) * graphH
                            Offset(x, y)
                        }

                        // Area fill
                        val path = Path().apply {
                            moveTo(points.first().x, padding + graphH)
                            points.forEach { lineTo(it.x, it.y) }
                            lineTo(points.last().x, padding + graphH)
                            close()
                        }
                        drawPath(
                            path = path,
                            brush = Brush.verticalGradient(
                                listOf(
                                    Color(0xFFC5A059).copy(alpha = .25f),
                                    Color.Transparent,
                                ),
                                startY = 0f,
                                endY = h,
                            ),
                        )

                        // Line
                        for (i in 0 until points.size - 1) {
                            drawLine(
                                color = Color(0xFFC5A059),
                                start = points[i],
                                end = points[i + 1],
                                strokeWidth = 3f,
                                cap = StrokeCap.Round,
                            )
                        }

                        // Dots
                        points.forEachIndexed { idx, pt ->
                            drawCircle(
                                color = moodColors[reversedEntries[idx].moodIndex],
                                radius = 8f,
                                center = pt,
                            )
                            drawCircle(
                                color = Color.White,
                                radius = 4f,
                                center = pt,
                            )
                        }
                    }
                },
        ) {
            // Y-axis labels
            Column(
                modifier = Modifier
                    .fillMaxHeight()
                    .padding(start = 4.dp, top = 28.dp, bottom = 28.dp),
                verticalArrangement = Arrangement.SpaceBetween,
            ) {
                moodLabels.reversed().forEach { label ->
                    Text(
                        text = label,
                        style = MaterialTheme.typography.labelSmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                        fontSize = 9.sp,
                    )
                }
            }
        }

        Spacer(Modifier.height(24.dp))

        // Summary stats
        val avgMood = if (entries.isNotEmpty()) entries.map { it.moodIndex }.average() else 0.0
        val mostCommon = entries.groupBy { it.moodIndex }.maxByOrNull { it.value.size }?.key ?: 2

        GlassCard(isDark = isDark) {
            Text(
                text = "This Week's Summary",
                style = MaterialTheme.typography.titleSmall,
                color = Resonance.goldPrimary,
            )
            Spacer(Modifier.height(12.dp))
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceEvenly,
            ) {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Text(moods[avgMood.toInt().coerceIn(0, 4)], fontSize = 24.sp)
                    Text("Average", style = MaterialTheme.typography.labelSmall, color = MaterialTheme.colorScheme.onSurfaceVariant)
                }
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Text(moods[mostCommon], fontSize = 24.sp)
                    Text("Most Common", style = MaterialTheme.typography.labelSmall, color = MaterialTheme.colorScheme.onSurfaceVariant)
                }
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Text("${entries.size}", style = MaterialTheme.typography.titleLarge, color = Resonance.goldPrimary)
                    Text("Entries", style = MaterialTheme.typography.labelSmall, color = MaterialTheme.colorScheme.onSurfaceVariant)
                }
            }
        }
    }
}

// Re-export GlassCard used from HomeScreen
// (In a real project these shared components live in a common ui module)
